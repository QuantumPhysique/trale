import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trale/models/daily_entry.dart';
import 'package:trale/models/emotional_checkin.dart';
import 'package:trale/database/database_helper.dart';
import 'package:trale/services/photo_service.dart';
import 'package:trale/widgets/photo_viewer.dart';

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
  List<EmotionalCheckIn> _emotionalCheckIns = [];
  
  // Current emotional check-in being edited (for new entry form)
  List<String> _currentEmotions = [];
  final TextEditingController _emotionalTextController = TextEditingController();
  
  // Track if entry has been saved (becomes immutable)
  bool _isEntryImmutable = false;

  // Track expanded sections
  final Set<String> _expandedSections = {};

  // Photo service
  final PhotoService _photoService = PhotoService();
  bool _isProcessingPhoto = false;

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
      _emotionalCheckIns = List.from(entry.emotionalCheckIns);
      _isEntryImmutable = entry.isImmutable;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
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
        emotionalCheckIns: _emotionalCheckIns,
        isImmutable: true, // Entry becomes immutable after first save
      );

      await DatabaseHelper.instance.saveDailyEntry(entry);

      if (mounted) {
        setState(() => _isEntryImmutable = true);
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
  
  Future<void> _saveEmotionalCheckIn() async {
    // Validate emotional check-in
    if (_currentEmotions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one emotion')),
      );
      return;
    }
    
    final text = _emotionalTextController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write about your feelings')),
      );
      return;
    }
    
    if (text.length > EmotionalCheckIn.maxTextLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text must be ${EmotionalCheckIn.maxTextLength} characters or less')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Create new emotional check-in
      final checkIn = EmotionalCheckIn(
        timestamp: DateTime.now(),
        emotions: List.from(_currentEmotions),
        text: text,
      );

      // Add to list
      _emotionalCheckIns.add(checkIn);

      // Save updated entry with new emotional check-in
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
        emotionalCheckIns: _emotionalCheckIns,
        isImmutable: _isEntryImmutable,
      );

      await DatabaseHelper.instance.saveDailyEntry(entry);

      if (mounted) {
        // Reset the emotional check-in form
        setState(() {
          _currentEmotions.clear();
          _emotionalTextController.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emotional check-in saved!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving emotional check-in: $e')),
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
    _emotionalTextController.dispose();
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
                  if (_isProcessingPhoto)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Processing photo...'),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: photoCount >= 3 ? null : _capturePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: photoCount >= 3 ? null : _selectFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                  if (photoCount > 0) ...[
                    const SizedBox(height: 16),
                    // Photo preview grid
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
                        return _buildPhotoThumbnail(index);
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

  Widget _buildPhotoThumbnail(int index) {
    return GestureDetector(
      onTap: () => _openPhotoViewer(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_photoPaths[index]),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => _deletePhoto(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto() async {
    setState(() => _isProcessingPhoto = true);

    try {
      final photoPath = await _photoService.capturePhoto(context);
      
      if (photoPath != null) {
        setState(() {
          _photoPaths.add(photoPath);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo added (EXIF data removed)')),
          );
        }
      }
    } finally {
      setState(() => _isProcessingPhoto = false);
    }
  }

  Future<void> _selectFromGallery() async {
    setState(() => _isProcessingPhoto = true);

    try {
      final photoPath = await _photoService.selectFromGallery(context);
      
      if (photoPath != null) {
        setState(() {
          _photoPaths.add(photoPath);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo added (EXIF data removed)')),
          );
        }
      }
    } finally {
      setState(() => _isProcessingPhoto = false);
    }
  }

  Future<void> _deletePhoto(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to remove this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final photoPath = _photoPaths[index];
      
      // Delete from disk
      await _photoService.deletePhoto(photoPath);
      
      // Remove from list
      setState(() {
        _photoPaths.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo removed')),
        );
      }
    }
  }

  void _openPhotoViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewer(
          photoPaths: _photoPaths,
          initialIndex: index,
          onDelete: (deleteIndex) async {
            await _deletePhoto(deleteIndex);
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutSection() {
    final isExpanded = _expandedSections.contains('workout');
    final hasContent = _workoutController.text.isNotEmpty || _workoutTags.isNotEmpty;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Workout'),
            subtitle: !isExpanded && hasContent
                ? Text(_buildWorkoutSummary())
                : null,
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
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
    final hasContent = _emotionalCheckIns.isNotEmpty || _currentEmotions.isNotEmpty;
    final isToday = _selectedDate.year == DateTime.now().year &&
                    _selectedDate.month == DateTime.now().month &&
                    _selectedDate.day == DateTime.now().day;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.sentiment_satisfied),
            title: const Text('Emotional Check-Ins'),
            subtitle: !isExpanded && hasContent
                ? Text('${_emotionalCheckIns.length} check-in${_emotionalCheckIns.length != 1 ? 's' : ''} today')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isToday && _currentEmotions.isNotEmpty)
                  Text('${_currentEmotions.length}/4',
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
                  // Show current emotional check-in form (only for today)
                  if (isToday) ...[
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, 
                          color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Right now - ${DateFormat('h:mm a').format(DateTime.now())}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Current emotion selection
                    if (_currentEmotions.isNotEmpty) ...[
                      Text(
                        'Selected emotions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _currentEmotions.map((emoji) {
                          return Chip(
                            label: Text(emoji, style: const TextStyle(fontSize: 24)),
                            onDeleted: () {
                              setState(() => _currentEmotions.remove(emoji));
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    Text(
                      'How are you feeling right now?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildEmotionGrid(),
                    const SizedBox(height: 16),
                    
                    // Text input for feelings
                    TextField(
                      controller: _emotionalTextController,
                      maxLines: 4,
                      maxLength: EmotionalCheckIn.maxTextLength,
                      decoration: InputDecoration(
                        labelText: 'What\'s on your mind?',
                        hintText: 'Describe how you\'re feeling...',
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        counterText: '${_emotionalTextController.text.length}/${EmotionalCheckIn.maxTextLength}',
                      ),
                      onChanged: (value) {
                        // Update counter
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Save emotional check-in button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveEmotionalCheckIn,
                        icon: const Icon(Icons.check_circle),
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
                      'Previous check-ins ${isToday ? 'today' : 'on this day'}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_emotionalCheckIns.length, (index) {
                      final checkIn = _emotionalCheckIns[_emotionalCheckIns.length - 1 - index]; // Reverse order
                      return _buildEmotionalCheckInCard(checkIn);
                    }),
                  ] else if (!isToday) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No emotional check-ins recorded for this day',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
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
  
  Widget _buildEmotionalCheckInCard(EmotionalCheckIn checkIn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('h:mm a').format(checkIn.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ...checkIn.emotions.map((emoji) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  )
                ),
              ],
            ),
            if (checkIn.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                checkIn.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: EmotionalCheckIn.availableEmotions.entries.map((entry) {
        final isSelected = _currentEmotions.contains(entry.key);
        final canSelect = _currentEmotions.length < EmotionalCheckIn.maxEmotionCount || isSelected;

        return InkWell(
          onTap: canSelect
              ? () {
                  setState(() {
                    if (isSelected) {
                      _currentEmotions.remove(entry.key);
                    } else {
                      _currentEmotions.add(entry.key);
                    }
                  });
                }
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You can select up to ${EmotionalCheckIn.maxEmotionCount} emotions'),
                      duration: const Duration(seconds: 1),
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
