import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value, OrderingTerm, InsertMode;
import 'package:drift/src/runtime/query_builder/query_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trale/core/db/app_database.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';

/// Full-screen daily entry form with collapsible sections for weight, photos,
/// workout, thoughts, and emotional check-ins.
class DailyEntryScreen extends StatefulWidget {
  const DailyEntryScreen({super.key, this.initialDate, this.existingDate});

  final DateTime? initialDate;
  final String? existingDate; // ISO format YYYY-MM-DD

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  late DateTime _selectedDate;
  late String _dateStr;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isEntryImmutable = false;

  // Form controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _workoutController = TextEditingController();
  final TextEditingController _thoughtsController = TextEditingController();
  final TextEditingController _emotionalMessageController =
      TextEditingController();

  // Form state
  List<_PhotoData> _photos = <_PhotoData>[];
  List<String> _workoutTags = <String>[];
  Color? _currentEmotionalColor;
  List<_EmotionalCheckIn> _emotionalCheckIns = <_EmotionalCheckIn>[];

  // Track changes to existing photos
  final List<int> _deletedPhotoIds = <int>[];
  final Map<int, bool> _nsfwChanges = <int, bool>{};

  // Section expansion state
  final Set<String> _expandedSections = <String>{};

  final AppDatabase _db = AppDatabase();

  // Timer for live clock updates
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _dateStr = _formatDate(_selectedDate);
    _loadEntryForDate();

    // Start live clock timer
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _workoutController.dispose();
    _thoughtsController.dispose();
    _emotionalMessageController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadEntryForDate() async {
    setState(() => _isLoading = true);

    try {
      // Check immutability
      final bool mutable = await _db.isCheckInMutable(_dateStr);
      _isEntryImmutable = !mutable;

      // Load check-in data
      final CheckIn? checkIn = await (_db.select(
        _db.checkIns,
      )..where(($CheckInsTable tbl) => tbl.checkInDate.equals(_dateStr))).getSingleOrNull();

      if (checkIn != null) {
        _weightController.text = checkIn.weight?.toString() ?? '';
        _heightController.text = checkIn.height?.toString() ?? '';
        _thoughtsController.text = checkIn.notes ?? '';
      }

      // Load workout data
      final Workout? workout = await (_db.select(
        _db.workouts,
      )..where(($WorkoutsTable tbl) => tbl.checkInDate.equals(_dateStr))).getSingleOrNull();

      if (workout != null) {
        _workoutController.text = workout.description ?? '';
        // Load workout tags
        final List<WorkoutWorkoutTag> tagLinks = await (_db.select(
          _db.workoutWorkoutTags,
        )..where(($WorkoutWorkoutTagsTable tbl) => tbl.checkInDate.equals(_dateStr))).get();
        final List<int> tagIds = tagLinks.map((WorkoutWorkoutTag link) => link.workoutTagId).toList();
        if (tagIds.isNotEmpty) {
          final List<WorkoutTag> tags = await (_db.select(
            _db.workoutTags,
          )..where(($WorkoutTagsTable tbl) => tbl.id.isIn(tagIds))).get();
          _workoutTags = tags.map((WorkoutTag tag) => tag.tag).toList();
        }
      }

      // Load photos
      final List<CheckInPhotoData> photos =
          await (_db.select(_db.checkInPhoto)
                ..where(($CheckInPhotoTable tbl) => tbl.checkInDate.equals(_dateStr))
                ..orderBy(<OrderClauseGenerator<$CheckInPhotoTable>>[($CheckInPhotoTable tbl) => OrderingTerm.asc(tbl.ts)]))
              .get();
      _photos = photos
          .map((CheckInPhotoData photo) => _PhotoData(
                id: photo.id,
                path: photo.filePath,
                isNsfw: photo.fw,
                isNew: false, // Existing photos are not new
              ))
          .toList();

      // Load emotional check-ins
      final List<CheckInColorData> emotionalRows =
          await (_db.select(_db.checkInColor)
                ..where(($CheckInColorTable tbl) => tbl.checkInDate.equals(_dateStr))
                ..orderBy(<OrderClauseGenerator<$CheckInColorTable>>[($CheckInColorTable tbl) => OrderingTerm.desc(tbl.ts)]))
              .get();

      _emotionalCheckIns = emotionalRows.map((CheckInColorData row) {
        final int colorRgb = row.colorRgb;
        final Color color = Color.fromARGB(
          255,
          (colorRgb >> 16) & 0xFF,
          (colorRgb >> 8) & 0xFF,
          colorRgb & 0xFF,
        );
        return _EmotionalCheckIn(
          timestamp: DateTime.fromMillisecondsSinceEpoch(row.ts),
          color: color,
          message: row.message ?? '',
        );
      }).toList();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateStr = _formatDate(picked);
      });
      _loadEntryForDate();
    }
  }

  void _toggleSection(String section) {
    setState(() {
      if (_expandedSections.contains(section)) {
        _expandedSections.remove(section);
      } else {
        _expandedSections.add(section);
      }
    });
  }

  Future<void> _saveEntry() async {
    if (kDebugMode) debugPrint('[DEBUG] _saveEntry called');
    if (_isEntryImmutable) {
      if (kDebugMode) debugPrint('[DEBUG] Entry is immutable, returning');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This entry is immutable and cannot be modified.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (kDebugMode) debugPrint('[DEBUG] Saving check-in with date: $_dateStr');
      // Save check-in
      final double? weight = double.tryParse(_weightController.text);
      final double? height = double.tryParse(_heightController.text);
      if (kDebugMode) debugPrint('[DEBUG] Weight: $weight, Height: $height');

      await _db
          .into(_db.checkIns)
          .insertOnConflictUpdate(
            CheckInsCompanion.insert(
              checkInDate: _dateStr,
              weight: Value(weight),
              height: Value(height),
              notes: Value(
                _thoughtsController.text.isEmpty
                    ? null
                    : _thoughtsController.text,
              ),
            ),
          );
      if (kDebugMode) debugPrint('[DEBUG] Check-in saved successfully');
      // Sync with legacy MeasurementDatabase for charts
      if (weight != null) {
        final Measurement m = Measurement(
          date: _selectedDate,
          weight: weight,
          isMeasured: true,
        );
        MeasurementDatabase().insertMeasurement(m);
      }

      // Handle photo deletions
      for (final int photoId in _deletedPhotoIds) {
        await (_db.delete(_db.checkInPhoto)
              ..where(($CheckInPhotoTable tbl) => tbl.id.equals(photoId)))
            .go();
      }

      // Handle NSFW changes for existing photos
      for (final MapEntry<int, bool> entry in _nsfwChanges.entries) {
        await (_db.update(_db.checkInPhoto)
              ..where(($CheckInPhotoTable tbl) => tbl.id.equals(entry.key)))
            .write(CheckInPhotoCompanion(fw: Value(entry.value)));
      }

      // Save only new photos (not already in database)
      for (final _PhotoData photo in _photos.where((_PhotoData p) => p.isNew)) {
        await _db
            .into(_db.checkInPhoto)
            .insert(
              CheckInPhotoCompanion.insert(
                checkInDate: _dateStr,
                filePath: photo.path,
                ts: DateTime.now().millisecondsSinceEpoch,
                fw: Value(photo.isNsfw),
              ),
            );
      }

      // Note: Emotional check-ins are saved separately via _saveEmotionalCheckIn

      // Save workout
      if (_workoutController.text.isNotEmpty || _workoutTags.isNotEmpty) {
        await _db
            .into(_db.workouts)
            .insertOnConflictUpdate(
              WorkoutsCompanion.insert(
                checkInDate: _dateStr,
                description: Value(
                  _workoutController.text.isEmpty
                      ? null
                      : _workoutController.text,
                ),
              ),
            );

        // Save workout tags
        if (_workoutTags.isNotEmpty) {
          // Wrap the entire delete-and-insert sequence in a transaction
          await _db.transaction(() async {
            // First, delete existing tag links for this check-in
            await (_db.delete(
              _db.workoutWorkoutTags,
            )..where(($WorkoutWorkoutTagsTable tbl) => tbl.checkInDate.equals(_dateStr))).go();

            // Insert or get tag IDs for each tag
            for (final String tagName in _workoutTags) {
              // Try to insert the tag, or get existing one
              final WorkoutTag? existingTag = await (_db.select(
                _db.workoutTags,
              )..where(($WorkoutTagsTable tbl) => tbl.tag.equals(tagName))).getSingleOrNull();

              int tagId;
              if (existingTag != null) {
                tagId = existingTag.id;
              } else {
                tagId = await _db
                    .into(_db.workoutTags)
                    .insert(WorkoutTagsCompanion.insert(tag: tagName));
              }

              // Link the tag to this workout
              await _db
                  .into(_db.workoutWorkoutTags)
                  .insert(
                    WorkoutWorkoutTagsCompanion.insert(
                      checkInDate: _dateStr,
                      workoutTagId: tagId,
                    ),
                    mode: InsertMode.insertOrIgnore,
                  );
            }
          });
        }
      }

      // Clear tracking lists after successful save
      _deletedPhotoIds.clear();
      _nsfwChanges.clear();

      if (mounted) {
        if (kDebugMode) debugPrint('[DEBUG] Save completed successfully, showing snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) debugPrint('[DEBUG] Error saving entry: $e');
      if (kDebugMode) debugPrint('[DEBUG] Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save entry, please try again')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveEmotionalCheckIn() async {
    if (_currentEmotionalColor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please pick a color')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Ensure check_in record exists (FK constraint requirement)
      final CheckIn? existingCheckIn = await _db.getCheckInByDate(_dateStr);
      if (existingCheckIn == null) {
        // Create minimal check_in record
        await _db
            .into(_db.checkIns)
            .insert(
              CheckInsCompanion.insert(
                checkInDate: _dateStr,
                weight: const Value(null),
                height: const Value(null),
                notes: const Value(null),
              ),
            );
      }

      final DateTime timestamp = DateTime.now();
      final int colorRgb =
          (_currentEmotionalColor!.red << 16) |
          (_currentEmotionalColor!.green << 8) |
          _currentEmotionalColor!.blue;

      await _db
          .into(_db.checkInColor)
          .insert(
            CheckInColorCompanion.insert(
              checkInDate: _dateStr,
              ts: timestamp.millisecondsSinceEpoch,
              colorRgb: colorRgb,
              message: Value(
                _emotionalMessageController.text.isEmpty
                    ? null
                    : _emotionalMessageController.text,
              ),
              isImmutable: const Value(true),
            ),
          );

      // Add to local list
      setState(() {
        _emotionalCheckIns.insert(
          0,
          _EmotionalCheckIn(
            timestamp: timestamp,
            color: _currentEmotionalColor!,
            message: _emotionalMessageController.text,
          ),
        );
        _currentEmotionalColor = null;
        _emotionalMessageController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emotional check-in saved!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving check-in: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _capturePhoto() async {
    if (_photos.length >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 photos allowed')),
        );
      }
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (photo != null) {
      setState(() {
        _photos.add(
          _PhotoData(
            path: photo.path,
            isNsfw: true, // Default to NSFW for safety
            isNew: true, // Mark as new photo
          ),
        );
      });
    }
  }

  void _deletePhoto(int index) {
    final _PhotoData photo = _photos[index];
    if (!photo.isNew && photo.id != null) {
      // Track deletion of existing photo
      _deletedPhotoIds.add(photo.id!);
    }
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _togglePhotoNsfw(int index) {
    final _PhotoData photo = _photos[index];
    final bool newNsfw = !photo.isNsfw;
    
    if (!photo.isNew && photo.id != null) {
      // Track NSFW change for existing photo
      _nsfwChanges[photo.id!] = newNsfw;
    }
    
    setState(() {
      _photos[index] = photo.copyWith(isNsfw: newNsfw);
    });
  }

  void _openPhotoViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => _PhotoViewerScreen(
          photos: _photos,
          initialIndex: index,
          onDelete: _deletePhoto,
        ),
      ),
    );
  }

  Future<void> _showAddTagDialog() async {
    final TextEditingController tagController = TextEditingController();

    // Load all available tags from database
    final List<WorkoutTag> allTags = await _db.select(_db.workoutTags).get();
    final List<String> availableTags = allTags.map((WorkoutTag tag) => tag.tag).toList();

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Workout Tag'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Show pre-installed tags as selectable chips
              if (availableTags.isNotEmpty) ...<Widget>[
                const Text('Choose from existing tags:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTags.map((String tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () => Navigator.pop(context, tag),
                  )).toList(),
                ),
                const Divider(height: 24),
              ],
              // Allow creating new tags
              const Text('Or create a new tag:'),
              const SizedBox(height: 8),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag name',
                  hintText: 'e.g., Cardio, Strength, Yoga',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final String tag = tagController.text.trim();
              if (tag.isNotEmpty) {
                // Check if tag already exists
                final List<WorkoutTag> existingTags = await (_db.select(_db.workoutTags)
                  ..where(($WorkoutTagsTable tbl) => tbl.tag.equals(tag))).get();
                
                // If tag doesn't exist, save it to database
                if (existingTags.isEmpty) {
                  await _db.into(_db.workoutTags).insert(
                    WorkoutTagsCompanion.insert(tag: tag),
                  );
                }
                
                if (!mounted) return;
                Navigator.pop(context, tag);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (!_workoutTags.contains(result)) {
          _workoutTags.add(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Entry'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select date',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Date banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Scrollable sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _buildWeightSection(),
                const SizedBox(height: 12),
                _buildPhotoSection(),
                const SizedBox(height: 12),
                _buildWorkoutSection(),
                const SizedBox(height: 12),
                _buildThoughtsSection(),
                const SizedBox(height: 12),
                _buildEmotionSection(),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('save_entry_fab'),
        onPressed: _isSaving ? null : _saveEntry,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: const Text('Save'),
      ),
    );
  }

  Widget _buildWeightSection() {
    final bool isExpanded = _expandedSections.contains('weight');
    final bool hasContent =
        _weightController.text.isNotEmpty || _heightController.text.isNotEmpty;

    String summary = '';
    if (!isExpanded && hasContent) {
      if (_weightController.text.isNotEmpty) {
        summary = '${_weightController.text} kg';
      }
      if (_heightController.text.isNotEmpty) {
        summary +=
            '${summary.isNotEmpty ? ', ' : ''}${_heightController.text} cm';
      }
    }

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Weight & Height'),
            subtitle: summary.isNotEmpty ? Text(summary) : null,
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => _toggleSection('weight'),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                    enabled: !_isEntryImmutable,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (optional)',
                      border: OutlineInputBorder(),
                      suffixText: 'cm',
                      prefixIcon: Icon(Icons.height),
                      helperText: 'Update if changed',
                    ),
                    enabled: !_isEntryImmutable,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final bool isExpanded = _expandedSections.contains('photos');
    final int photoCount = _photos.length;

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Photos'),
            subtitle: !isExpanded && photoCount > 0
                ? Text('$photoCount photo${photoCount > 1 ? 's' : ''} added')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$photoCount/3',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () => _toggleSection('photos'),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: photoCount >= 3 || _isEntryImmutable
                          ? null
                          : _capturePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                  ),
                  if (photoCount > 0) ...<Widget>[
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: photoCount,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildPhotoThumbnail(index);
                      },
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'No photos added yet',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(int index) {
    final _PhotoData photo = _photos[index];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () => _openPhotoViewer(index),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(photo.path),
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
                if (!_isEntryImmutable)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        iconSize: 16,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => _deletePhoto(index),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Checkbox(
              value: photo.isNsfw,
              onChanged: _isEntryImmutable
                  ? null
                  : (bool? value) => _togglePhotoNsfw(index),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                'NSFW',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutSection() {
    final bool isExpanded = _expandedSections.contains('workout');
    final bool hasContent =
        _workoutController.text.isNotEmpty || _workoutTags.isNotEmpty;

    String summary = '';
    if (!isExpanded && hasContent) {
      if (_workoutController.text.isNotEmpty) {
        summary = _workoutController.text.length > 50
            ? '${_workoutController.text.substring(0, 50)}...'
            : _workoutController.text;
      } else if (_workoutTags.isNotEmpty) {
        summary =
            '${_workoutTags.length} tag${_workoutTags.length > 1 ? 's' : ''}';
      }
    }

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Workout'),
            subtitle: summary.isNotEmpty ? Text(summary) : null,
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => _toggleSection('workout'),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _workoutController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Workout description',
                      border: OutlineInputBorder(),
                      hintText: 'Describe your workout...',
                      alignLabelWithHint: true,
                    ),
                    enabled: !_isEntryImmutable,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 16),
                  Text('Tags', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      ..._workoutTags.map(
                        (String tag) => Chip(
                          label: Text(tag),
                          onDeleted: _isEntryImmutable
                              ? null
                              : () {
                                  setState(() => _workoutTags.remove(tag));
                                },
                        ),
                      ),
                      if (!_isEntryImmutable)
                        ActionChip(
                          label: const Text('+ Add Tag'),
                          onPressed: _showAddTagDialog,
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThoughtsSection() {
    final bool isExpanded = _expandedSections.contains('thoughts');
    final bool hasContent = _thoughtsController.text.isNotEmpty;

    String summary = '';
    if (!isExpanded && hasContent) {
      summary = _thoughtsController.text.length > 50
          ? '${_thoughtsController.text.substring(0, 50)}...'
          : _thoughtsController.text;
    }

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Thoughts'),
            subtitle: summary.isNotEmpty ? Text(summary) : null,
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => _toggleSection('thoughts'),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _thoughtsController,
                maxLines: 6,
                maxLength: 2000,
                decoration: const InputDecoration(
                  labelText: 'How are you feeling today?',
                  border: OutlineInputBorder(),
                  hintText: 'Write your thoughts here...',
                  alignLabelWithHint: true,
                ),
                enabled: !_isEntryImmutable,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionSection() {
    final bool isExpanded = _expandedSections.contains('emotions');
    final bool isToday =
        _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Emotional Check-Ins'),
            subtitle: !isExpanded && _emotionalCheckIns.isNotEmpty
                ? Text(
                    '${_emotionalCheckIns.length} check-in${_emotionalCheckIns.length != 1 ? 's' : ''} recorded',
                  )
                : null,
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => _toggleSection('emotions'),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Add new emotional check-in (only for today)
                  if (isToday) ...<Widget>[
                    Text(
                      'Add Emotional Check-In',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Show current timestamp
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Live time: ${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontFamily: 'monospace',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'What color do you feel like right now?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // Circular color wheel only
                    Center(
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          final double size = constraints.maxWidth * 0.8; // 80% of available width
                          return SizedBox(
                            width: size,
                            height: size,
                            child: ColorPickerArea(
                              HSVColor.fromColor(_currentEmotionalColor ?? Colors.white),
                              (HSVColor hsvColor) {
                                setState(() {
                                  _currentEmotionalColor = hsvColor.toColor();
                                });
                              },
                              PaletteType.hueWheel,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emotionalMessageController,
                      maxLines: 3,
                      maxLength: 500,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Message (optional)',
                        hintText: 'Describe how you\'re feeling...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveEmotionalCheckIn,
                        icon: const Icon(Icons.add),
                        label: const Text('Save Emotional Check-In'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    if (_emotionalCheckIns.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                  ],
                  // Show previous emotional check-ins
                  if (_emotionalCheckIns.isNotEmpty) ...<Widget>[
                    Text(
                      'Previous Check-Ins ${isToday ? 'Today' : 'on This Day'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._emotionalCheckIns.map((_EmotionalCheckIn checkIn) {
                      return _buildEmotionalCheckInCard(
                        checkIn,
                        key: ValueKey(checkIn.timestamp),
                      );
                    }),
                  ] else if (!isToday) ...<Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No emotional check-ins recorded for this day',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionalCheckInCard(_EmotionalCheckIn checkIn, {Key? key}) {
    final DateTime checkInDate = checkIn.timestamp;
    final DateTime now = DateTime.now();
    final bool isToday =
        checkInDate.year == now.year &&
        checkInDate.month == now.month &&
        checkInDate.day == now.day;
    final String formattedTimestamp = isToday
        ? DateFormat('h:mm a').format(checkInDate)
        : DateFormat('MMM d, h:mm a').format(checkInDate);
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: checkIn.color,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Timestamp',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        formattedTimestamp,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (checkIn.message.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Message',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                checkIn.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Data class for emotional check-in display
class _EmotionalCheckIn {

  _EmotionalCheckIn({
    required this.timestamp,
    required this.color,
    required this.message,
  });
  final DateTime timestamp;
  final Color color;
  final String message;
}

/// Data class for photo with NSFW state
class _PhotoData { // Track if photo is newly added

  _PhotoData({
    this.id,
    required this.path,
    required this.isNsfw,
    this.isNew = false,
  });
  final int? id; // Database ID for existing photos
  final String path;
  final bool isNsfw;
  final bool isNew;

  _PhotoData copyWith({
    int? id,
    String? path,
    bool? isNsfw,
    bool? isNew,
  }) {
    return _PhotoData(
      id: id ?? this.id,
      path: path ?? this.path,
      isNsfw: isNsfw ?? this.isNsfw,
      isNew: isNew ?? this.isNew,
    );
  }
}

/// Full-screen photo viewer
class _PhotoViewerScreen extends StatefulWidget {

  const _PhotoViewerScreen({
    required this.photos,
    required this.initialIndex,
    required this.onDelete,
  });
  final List<_PhotoData> photos;
  final int initialIndex;
  final Function(int) onDelete;

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Photo ${_currentIndex + 1} of ${widget.photos.length}'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete photo?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onDelete(_currentIndex);
                          Navigator.of(context).pop(); // Dismiss dialog
                          Navigator.of(context).pop(); // Close viewer
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                File(widget.photos[index].path),
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 64),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
