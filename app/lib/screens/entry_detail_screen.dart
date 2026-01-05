import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trale/models/daily_entry.dart';
import 'package:trale/models/user_profile.dart';
import 'package:trale/database/database_helper.dart';
import 'package:trale/screens/daily_entry_screen.dart';
import 'package:trale/widgets/photo_viewer.dart';

class EntryDetailScreen extends StatefulWidget {
  final DailyEntry entry;

  const EntryDetailScreen({Key? key, required this.entry}) : super(key: key);

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late DailyEntry _entry;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    setState(() => _userProfile = profile);
  }

  Future<void> _editEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyEntryScreen(
          initialDate: _entry.date,
          existingEntry: _entry,
        ),
      ),
    );

    if (result == true) {
      // Reload entry
      final updated = await DatabaseHelper.instance.getDailyEntry(_entry.date);
      if (updated != null) {
        setState(() => _entry = updated);
      }
    }
  }

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
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
      await DatabaseHelper.instance.deleteEntry(_entry.date);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double? bmi;
    if (_entry.weight != null && _entry.height != null) {
      bmi = _userProfile?.calculateBMI(_entry.weight, _entry.height);
    } else if (_entry.weight != null && _userProfile?.initialHeight != null) {
      bmi = _userProfile?.calculateBMI(_entry.weight, _userProfile!.initialHeight);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editEntry,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_entry.date),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Logged at ${DateFormat('h:mm a').format(_entry.timestamp)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Weight & Height
            if (_entry.weight != null) ...[
              _buildSectionHeader(Icons.monitor_weight, 'Weight & Metrics'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Weight'),
                          Text(
                            '${_entry.weight} kg',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      if (_entry.height != null) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Height'),
                            Text(
                              '${_entry.height} cm',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ],
                      if (bmi != null) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('BMI'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getBMIColor(bmi).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _getBMIColor(bmi)),
                              ),
                              child: Text(
                                '${bmi.toStringAsFixed(1)} • ${_getBMICategory(bmi)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getBMIColor(bmi),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Photos
            if (_entry.photoPaths.isNotEmpty) ...[
              _buildSectionHeader(Icons.photo_camera, 'Photos'),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _entry.photoPaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _openPhotoViewer(index),
                        child: Hero(
                          tag: 'photo_${_entry.photoPaths[index]}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_entry.photoPaths[index]),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Workout
            if (_entry.workoutText?.isNotEmpty == true || 
                _entry.workoutTags.isNotEmpty) ...[
              _buildSectionHeader(Icons.fitness_center, 'Workout'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_entry.workoutTags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _entry.workoutTags
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                        ),
                        if (_entry.workoutText?.isNotEmpty == true)
                          const SizedBox(height: 12),
                      ],
                      if (_entry.workoutText?.isNotEmpty == true)
                        Text(
                          _entry.workoutText!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Emotional Check-ins
            if (_entry.emotionalCheckIns.isNotEmpty) ...[
              _buildSectionHeader(Icons.sentiment_satisfied, 'Emotional Check-Ins'),
              const SizedBox(height: 12),
              ..._entry.emotionalCheckIns.map((checkIn) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
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
                              child: Text(emoji, style: const TextStyle(fontSize: 24)),
                            )
                          ),
                        ],
                      ),
                      if (checkIn.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          checkIn.text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 24),
            ],

            // Thoughts
            if (_entry.thoughts?.isNotEmpty == true) ...[
              _buildSectionHeader(Icons.edit_note, 'Thoughts'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _entry.thoughts!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _openPhotoViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewer(
          photoPaths: _entry.photoPaths,
          initialIndex: index,
        ),
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
