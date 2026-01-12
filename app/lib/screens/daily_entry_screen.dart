import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:trale/core/db/app_database.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurement.dart';
import 'package:drift/drift.dart' show Value, OrderingTerm, InsertMode;

/// Full-screen daily entry form with collapsible sections for weight, photos,
/// workout, thoughts, and emotional check-ins.
class DailyEntryScreen extends StatefulWidget {
  const DailyEntryScreen({
    super.key,
    this.initialDate,
    this.existingDate,
  });

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
  final TextEditingController _emotionalMessageController = TextEditingController();

  // Form state
  List<String> _photoPaths = [];
  List<String> _workoutTags = [];
  Color? _currentEmotionalColor;
  List<_EmotionalCheckIn> _emotionalCheckIns = [];

  // Section expansion state
  final Set<String> _expandedSections = {};

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
      final mutable = await _db.isCheckInMutable(_dateStr);
      _isEntryImmutable = !mutable;

      // Load check-in data
      final checkIn = await (_db.select(_db.checkIns)
            ..where((tbl) => tbl.date.equals(_dateStr)))
          .getSingleOrNull();

      if (checkIn != null) {
        _weightController.text = checkIn.weight?.toString() ?? '';
        _heightController.text = checkIn.height?.toString() ?? '';
        _thoughtsController.text = checkIn.notes ?? '';
      }

      // Load workout data
      final workout = await (_db.select(_db.workouts)
            ..where((tbl) => tbl.checkInDate.equals(_dateStr)))
          .getSingleOrNull();

      if (workout != null) {
        _workoutController.text = workout.description ?? '';
        // Load workout tags
        final tagLinks = await (_db.select(_db.workoutWorkoutTags)
              ..where((tbl) => tbl.checkInDate.equals(_dateStr)))
            .get();
        final tagIds = tagLinks.map((link) => link.workoutTagId).toList();
        if (tagIds.isNotEmpty) {
          final tags = await (_db.select(_db.workoutTags)
                ..where((tbl) => tbl.id.isIn(tagIds)))
              .get();
          _workoutTags = tags.map((tag) => tag.tag).toList();
        }
      }

      // Load photos
      final photos = await (_db.select(_db.checkInPhoto)
            ..where((tbl) => tbl.checkInDate.equals(_dateStr))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.ts)]))
          .get();
      _photoPaths = photos.map((photo) => photo.filePath).toList();

      // Load emotional check-ins
      final emotionalRows = await (_db.select(_db.checkInColor)
            ..where((tbl) => tbl.checkInDate.equals(_dateStr))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.ts)]))
          .get();

      _emotionalCheckIns = emotionalRows.map((row) {
        final colorRgb = row.colorRgb;
        final color = Color.fromARGB(
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
    if (_isEntryImmutable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This entry is immutable and cannot be modified.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Save check-in
      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);

      await _db.into(_db.checkIns).insertOnConflictUpdate(
            CheckInsCompanion.insert(
              date: _dateStr,
              weight: Value(weight),
              height: Value(height),
              notes: Value(_thoughtsController.text.isEmpty
                  ? null
                  : _thoughtsController.text),
            ),
          );

      // Sync with legacy MeasurementDatabase for charts
      if (weight != null) {
        final m = Measurement(
          date: _selectedDate,
          weight: weight,
          isMeasured: true,
        );
        await MeasurementDatabase().insertMeasurement(m);
      }

      // Save photos
      for (final photoPath in _photoPaths) {
        await _db.into(_db.checkInPhoto).insert(
              CheckInPhotoCompanion.insert(
                checkInDate: _dateStr,
                filePath: photoPath,
                ts: DateTime.now().millisecondsSinceEpoch,
                fw: const Value(false),
              ),
            );
      }

      // Note: Emotional check-ins are saved separately via _saveEmotionalCheckIn

      // Save workout
      if (_workoutController.text.isNotEmpty || _workoutTags.isNotEmpty) {
        await _db.into(_db.workouts).insertOnConflictUpdate(
              WorkoutsCompanion.insert(
                checkInDate: _dateStr,
                description: Value(_workoutController.text.isEmpty
                    ? null
                    : _workoutController.text),
              ),
            );

        // Save workout tags
        if (_workoutTags.isNotEmpty) {
          // Wrap the entire delete-and-insert sequence in a transaction
          await _db.transaction(() async {
            // First, delete existing tag links for this check-in
            await (_db.delete(_db.workoutWorkoutTags)
                  ..where((tbl) => tbl.checkInDate.equals(_dateStr)))
                .go();

            // Insert or get tag IDs for each tag
            for (final tagName in _workoutTags) {
              // Try to insert the tag, or get existing one
              final existingTag = await (_db.select(_db.workoutTags)
                    ..where((tbl) => tbl.tag.equals(tagName)))
                  .getSingleOrNull();

              int tagId;
              if (existingTag != null) {
                tagId = existingTag.id;
              } else {
                tagId = await _db.into(_db.workoutTags).insert(
                      WorkoutTagsCompanion.insert(tag: tagName),
                    );
              }

              // Link the tag to this workout
              await _db.into(_db.workoutWorkoutTags).insert(
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveEmotionalCheckIn() async {
    if (_currentEmotionalColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a color')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final timestamp = DateTime.now();
      final colorRgb = (_currentEmotionalColor!.red << 16) |
          (_currentEmotionalColor!.green << 8) |
          _currentEmotionalColor!.blue;

      await _db.into(_db.checkInColor).insert(
            CheckInColorCompanion.insert(
              checkInDate: _dateStr,
              ts: timestamp.millisecondsSinceEpoch,
              colorRgb: colorRgb,
              message: Value(_emotionalMessageController.text.isEmpty
                  ? null
                  : _emotionalMessageController.text),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving check-in: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _capturePhoto() async {
    if (_photoPaths.length >= 3) {
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
        _photoPaths.add(photo.path);
      });
    }
  }

  Future<void> _showAddTagDialog() async {
    final TextEditingController tagController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Workout Tag'),
        content: TextField(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = tagController.text.trim();
              if (tag.isNotEmpty) {
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select date',
          ),
        ],
      ),
      body: Column(
        children: [
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
              children: [
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
        label: const Text('Save Entry'),
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
        children: [
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Weight & Height'),
            subtitle: summary.isNotEmpty ? Text(summary) : null,
            trailing:
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => _toggleSection('weight'),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
    final int photoCount = _photoPaths.length;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Photos'),
            subtitle: !isExpanded && photoCount > 0
                ? Text('$photoCount photo${photoCount > 1 ? 's' : ''} added')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$photoCount/3',
                    style: Theme.of(context).textTheme.bodySmall),
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
                children: [
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
                  if (photoCount == 0)
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

  Widget _buildWorkoutSection() {
    final bool isExpanded = _expandedSections.contains('workout');
    final bool hasContent = _workoutController.text.isNotEmpty ||
        _workoutTags.isNotEmpty;

    String summary = '';
    if (!isExpanded && hasContent) {
      if (_workoutController.text.isNotEmpty) {
        summary = _workoutController.text.length > 50
            ? '${_workoutController.text.substring(0, 50)}...'
            : _workoutController.text;
      } else if (_workoutTags.isNotEmpty) {
        summary = '${_workoutTags.length} tag${_workoutTags.length > 1 ? 's' : ''}';
      }
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Workout'),
            subtitle: summary.isNotEmpty ? Text(summary) : null,
            trailing:
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => _toggleSection('workout'),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._workoutTags.map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: _isEntryImmutable
                                ? null
                                : () {
                                    setState(() => _workoutTags.remove(tag));
                                  },
                          )),
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
        children: [
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Thoughts'),
            subtitle: summary.isNotEmpty ? Text(summary) : null,
            trailing:
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
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
    final bool isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Emotional Check-Ins'),
            subtitle: !isExpanded && _emotionalCheckIns.isNotEmpty
                ? Text(
                    '${_emotionalCheckIns.length} check-in${_emotionalCheckIns.length != 1 ? 's' : ''} recorded')
                : null,
            trailing:
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => _toggleSection('emotions'),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add new emotional check-in (only for today)
                  if (isToday) ...[
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
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Live time: ${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pick a color to represent your emotional state',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // Circular color wheel only
                    Center(
                      child: ColorPicker(
                        pickerColor: _currentEmotionalColor ?? Colors.blue,
                        onColorChanged: (Color color) {
                          setState(() {
                            _currentEmotionalColor = color;
                          });
                        },
                        paletteType: PaletteType.hueWheel,
                        enableAlpha: false,
                        displayThumbColor: true,
                        pickerAreaHeightPercent: 1.0,
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
                    if (_emotionalCheckIns.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                  ],
                  // Show previous emotional check-ins
                  if (_emotionalCheckIns.isNotEmpty) ...[
                    Text(
                      'Previous Check-Ins ${isToday ? 'Today' : 'on This Day'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._emotionalCheckIns.map((checkIn) {
                      return _buildEmotionalCheckInCard(checkIn, key: ValueKey(checkIn.timestamp));
                    }),
                  ] else if (!isToday) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No emotional check-ins recorded for this day',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
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
    final bool isToday = checkInDate.year == now.year &&
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
          children: [
            Row(
              children: [
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
                    children: [
                      Text(
                        'Timestamp',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
            if (checkIn.message.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Message',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
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
  final DateTime timestamp;
  final Color color;
  final String message;

  _EmotionalCheckIn({
    required this.timestamp,
    required this.color,
    required this.message,
  });
}
