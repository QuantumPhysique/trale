import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:trale/core/db/app_database.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurement.dart';
import 'package:drift/drift.dart' show Value, OrderingTerm;

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

  // Form state
  List<String> _photoPaths = [];
  List<String> _workoutTags = [];
  Color? _pickedEmotionalColor;

  // Section expansion state
  final Set<String> _expandedSections = {};

  final AppDatabase _db = AppDatabase();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _dateStr = _formatDate(_selectedDate);
    _loadEntryForDate();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _workoutController.dispose();
    _thoughtsController.dispose();
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

      // Load emotional color
      final emotionalRows = await (_db.select(_db.checkInColor)
            ..where((tbl) => tbl.checkInDate.equals(_dateStr))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.ts)]))
          .get();

      if (emotionalRows.isNotEmpty) {
        final colorRgb = emotionalRows.first.colorRgb;
        _pickedEmotionalColor = Color.fromARGB(
          255,
          (colorRgb >> 16) & 0xFF,
          (colorRgb >> 8) & 0xFF,
          colorRgb & 0xFF,
        );
      }
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

      // Save emotional color if picked
      if (_pickedEmotionalColor != null) {
        final colorRgb = (_pickedEmotionalColor!.red << 16) |
            (_pickedEmotionalColor!.green << 8) |
            _pickedEmotionalColor!.blue;
        await _db.into(_db.checkInColor).insertOnConflictUpdate(
              CheckInColorCompanion.insert(
                checkInDate: _dateStr,
                ts: DateTime.now().millisecondsSinceEpoch,
                colorRgb: colorRgb,
                message: const Value(null),
                isImmutable: const Value(true),
              ),
            );
      }

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
        // (Tag insertion logic would go here)
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

  Future<void> _selectFromGallery() async {
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
      source: ImageSource.gallery,
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: photoCount >= 3 || _isEntryImmutable
                              ? null
                              : _capturePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: photoCount >= 3 || _isEntryImmutable
                              ? null
                              : _selectFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionSection() {
    final bool isExpanded = _expandedSections.contains('emotions');

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Emotional Check-In'),
            subtitle: !isExpanded && _pickedEmotionalColor != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: _pickedEmotionalColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Color selected'),
                    ],
                  )
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
                  Text(
                    'Pick a color to represent your emotional state',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  BlockPicker(
                    pickerColor: _pickedEmotionalColor ?? Colors.blue,
                    onColorChanged: (Color color) {
                      setState(() {
                        _pickedEmotionalColor = color;
                      });
                    },
                  ),
                  if (_pickedEmotionalColor != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Selected:'),
                        const SizedBox(width: 12),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _pickedEmotionalColor,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _pickedEmotionalColor = null;
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
