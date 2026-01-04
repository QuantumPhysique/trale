import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trale/models/daily_entry.dart';
import 'package:trale/database/database_helper.dart';

class DailyEntryScreen extends StatefulWidget {
  final DateTime? initialDate;
  final DailyEntry? existingEntry; // For editing existing entries

  const DailyEntryScreen({
    Key? key,
    this.initialDate,
    this.existingEntry,
  }) : super(key: key);

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  late DateTime _selectedDate;
  bool _isLoading = false;
  bool _isSaving = false;

  // Controllers and state for each section
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _workoutController = TextEditingController();
  final TextEditingController _thoughtsController = TextEditingController();

  List<String> _photoPaths = [];
  List<String> _workoutTags = [];
  List<String> _selectedEmotions = [];

  // Track expanded sections
  final Set<String> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadEntryForDate();
  }

  Future<void> _loadEntryForDate() async {
    setState(() => _isLoading = true);

    final entry = widget.existingEntry ??
                  await DatabaseHelper.instance.getDailyEntry(_selectedDate);

    if (entry != null) {
      _weightController.text = entry.weight?.toString() ?? '';
      _heightController.text = entry.height?.toString() ?? '';
      _workoutController.text = entry.workoutText ?? '';
      _thoughtsController.text = entry.thoughts ?? '';
      _photoPaths = List.from(entry.photoPaths);
      _workoutTags = List.from(entry.workoutTags);
      _selectedEmotions = List.from(entry.emotions);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveEntry() async {
    setState(() => _isSaving = true);

    try {
      final entry = DailyEntry(
        date: _selectedDate,
        weight: _weightController.text.isEmpty
            ? null
            : double.parse(_weightController.text),
        height: _heightController.text.isEmpty
            ? null
            : double.parse(_heightController.text),
        photoPaths: _photoPaths,
        workoutText: _workoutController.text.isEmpty
            ? null
            : _workoutController.text,
        workoutTags: _workoutTags,
        thoughts: _thoughtsController.text.isEmpty
            ? null
            : _thoughtsController.text,
        emotions: _selectedEmotions,
      );

      await DatabaseHelper.instance.saveDailyEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate save
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadEntryForDate();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _workoutController.dispose();
    _thoughtsController.dispose();
    super.dispose();
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
          // Date display banner
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
    final isExpanded = _expandedSections.contains('weight');
    final hasContent = _weightController.text.isNotEmpty ||
                       _heightController.text.isNotEmpty;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Weight & Height'),
            subtitle: !isExpanded && hasContent
                ? Text(_buildWeightSummary())
                : null,
            trailing: Icon(isExpanded
                ? Icons.expand_less
                : Icons.expand_more),
            onTap: () => _toggleSection('weight'),
          ),
          if (isExpanded) ...[
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
                  ),
                  if (_weightController.text.isNotEmpty &&
                      _heightController.text.isNotEmpty)
                    _buildBMIDisplay(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final isExpanded = _expandedSections.contains('photos');
    final photoCount = _photoPaths.length;

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
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Photo action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: photoCount >= 3 ? null : () {
                            // TODO: Implement camera capture in Sprint 4
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Camera feature coming in Sprint 4'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: photoCount >= 3 ? null : () {
                            // TODO: Implement gallery picker in Sprint 4
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gallery feature coming in Sprint 4'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                  if (photoCount > 0) ...[
                    const SizedBox(height: 16),
                    // Photo preview grid (placeholder for now)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _photoPaths.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image, size: 48),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton.filled(
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _photoPaths.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Text(
                      'No photos added yet',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutSection() {
    final isExpanded = _expandedSections.contains('workout');
    final hasContent = _workoutController.text.isNotEmpty ||
                       _workoutTags.isNotEmpty;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Workout'),
            subtitle: !isExpanded && hasContent
                ? Text(_buildWorkoutSummary())
                : null,
            trailing: Icon(isExpanded
                ? Icons.expand_less
                : Icons.expand_more),
            onTap: () => _toggleSection('workout'),
          ),
          if (isExpanded) ...[
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
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  // Tag chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._workoutTags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() => _workoutTags.remove(tag));
                        },
                      )),
                      ActionChip(
                        label: const Text('+ Add Tag'),
                        onPressed: () => _showAddTagDialog(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThoughtsSection() {
    final isExpanded = _expandedSections.contains('thoughts');
    final hasContent = _thoughtsController.text.isNotEmpty;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Thoughts'),
            subtitle: !isExpanded && hasContent
                ? Text(
                    _thoughtsController.text.length > 50
                        ? '${_thoughtsController.text.substring(0, 50)}...'
                        : _thoughtsController.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Icon(isExpanded
                ? Icons.expand_less
                : Icons.expand_more),
            onTap: () => _toggleSection('thoughts'),
          ),
          if (isExpanded) ...[
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
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionSection() {
    final isExpanded = _expandedSections.contains('emotions');
    final hasContent = _selectedEmotions.isNotEmpty;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.sentiment_satisfied),
            title: const Text('How I\'m Feeling'),
            subtitle: !isExpanded && hasContent
                ? Wrap(
                    spacing: 4,
                    children: _selectedEmotions
                        .map((e) => Text(e, style: const TextStyle(fontSize: 20)))
                        .toList(),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_selectedEmotions.length}/4',
                  style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () => _toggleSection('emotions'),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedEmotions.isNotEmpty) ...[
                    Text(
                      'Selected',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _selectedEmotions.map((emoji) {
                        return Chip(
                          label: Text(emoji, style: const TextStyle(fontSize: 24)),
                          onDeleted: () {
                            setState(() => _selectedEmotions.remove(emoji));
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Choose up to 4 emotions',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  _buildEmotionGrid(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionGrid() {
    const emotions = {
      '😠': 'Anger',
      '😨': 'Fear',
      '😣': 'Pain',
      '😔': 'Shame',
      '😞': 'Guilt',
      '😊': 'Joy',
      '💪': 'Strength',
      '❤️': 'Love',
    };

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: emotions.entries.map((entry) {
        final isSelected = _selectedEmotions.contains(entry.key);
        final canSelect = _selectedEmotions.length < 4 || isSelected;

        return InkWell(
          onTap: canSelect
              ? () {
                  setState(() {
                    if (isSelected) {
                      _selectedEmotions.remove(entry.key);
                    } else {
                      _selectedEmotions.add(entry.key);
                    }
                  });
                }
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You can select up to 4 emotions'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBMIDisplay() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null) return const SizedBox.shrink();

    final bmi = weight / ((height / 100) * (height / 100));
    String category;
    Color color;

    if (bmi < 18.5) {
      category = 'Underweight';
      color = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normal';
      color = Colors.green;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = Colors.orange;
    } else {
      category = 'Obese';
      color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'BMI',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            '${bmi.toStringAsFixed(1)} • $category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _buildWeightSummary() {
    final parts = <String>[];
    if (_weightController.text.isNotEmpty) {
      parts.add('${_weightController.text} kg');
    }
    if (_heightController.text.isNotEmpty) {
      parts.add('${_heightController.text} cm');
    }
    return parts.join(' • ');
  }

  String _buildWorkoutSummary() {
    if (_workoutTags.isNotEmpty) {
      return _workoutTags.join(', ');
    }
    if (_workoutController.text.isNotEmpty) {
      return _workoutController.text.length > 30
          ? '${_workoutController.text.substring(0, 30)}...'
          : _workoutController.text;
    }
    return '';
  }

  Future<void> _showAddTagDialog() async {
    final controller = TextEditingController();

    // Load existing tags for suggestions
    final existingTags = await DatabaseHelper.instance.getAllWorkoutTags();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Workout Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Tag name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Cardio, Legs, Yoga',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            if (existingTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Suggestions',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: existingTags
                    .where((tag) => !_workoutTags.contains(tag))
                    .take(6)
                    .map((tag) => ActionChip(
                          label: Text(tag),
                          onPressed: () {
                            setState(() {
                              if (!_workoutTags.contains(tag)) {
                                _workoutTags.add(tag);
                              }
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty &&
                  !_workoutTags.contains(controller.text)) {
                setState(() {
                  _workoutTags.add(controller.text);
                });
                // Save tag to database for future suggestions
                DatabaseHelper.instance.saveWorkoutTag(
                  controller.text,
                  '#${(controller.text.hashCode & 0xFFFFFF).toRadixString(16)}',
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();
  }
}
