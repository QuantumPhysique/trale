import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trale/models/daily_entry.dart';
import 'package:trale/models/user_profile.dart';
import 'package:trale/database/database_helper.dart';
import 'package:trale/screens/daily_entry_screen.dart';
import 'package:trale/screens/entry_detail_screen.dart';
import 'package:trale/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DailyEntry> _entries = <DailyEntry>[];
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadUserProfile();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    
    try {
      final List<DailyEntry> entries = await DatabaseHelper.instance.getAllEntries();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entries: $e')),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final UserProfile? profile = await DatabaseHelper.instance.getUserProfile();
      if (mounted) {
        setState(() => _userProfile = profile);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user profile')),
        );
      }
    }
  }

  Future<void> _openNewEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const DailyEntryScreen(),
      ),
    );

    if (result == true) {
      _loadEntries(); // Refresh list
    }
  }

  Future<void> _openEntryDetail(DailyEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => EntryDetailScreen(entry: entry),
      ),
    );

    if (result == true) {
      _loadEntries(); // Refresh if edited/deleted
    }
  }

  Future<void> _deleteEntry(DailyEntry entry) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete the entry for ${DateFormat('MMM d, yyyy').format(entry.date)}?'
        ),
        actions: <Widget>[
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
      await DatabaseHelper.instance.deleteEntry(entry.date);
      _loadEntries();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trale+'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const SettingsScreen(),
                ),
              );
              _loadUserProfile(); // Refresh profile if changed
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadEntries,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildEntryCard(_entries[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewEntry,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.fitness_center,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Entries Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Start your fitness journey by creating your first daily entry!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _openNewEntry,
              icon: const Icon(Icons.add),
              label: const Text('Create First Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(DailyEntry entry) {
    final bool hasWeight = entry.weight != null;
    final bool hasPhotos = entry.photoPaths.isNotEmpty;
    final bool hasWorkout = entry.workoutText?.isNotEmpty == true || 
                       entry.workoutTags.isNotEmpty;
    final bool hasThoughts = entry.thoughts?.isNotEmpty == true;
    final bool hasEmotions = entry.emotionalCheckIns.isNotEmpty;

    // Calculate BMI if both weight and height available
    double? bmi;
    if (entry.weight != null && entry.height != null) {
      bmi = _userProfile?.calculateBMI(entry.weight, entry.height);
    } else if (entry.weight != null && _userProfile?.initialHeight != null) {
      bmi = _userProfile?.calculateBMI(entry.weight, _userProfile!.initialHeight);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openEntryDetail(entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header with date and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(entry.date),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(entry.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.edit),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (String value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => DailyEntryScreen(
                              initialDate: entry.date,
                              existingEntry: entry,
                            ),
                          ),
                        );
                        if (result == true) _loadEntries();
                      } else if (value == 'delete') {
                        _deleteEntry(entry);
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Weight and BMI
              if (hasWeight) ...<Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.monitor_weight,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.weight} kg',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (bmi != null) ...<Widget>[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getBMIColor(bmi).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getBMIColor(bmi)),
                        ),
                        child: Text(
                          'BMI: ${bmi.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getBMIColor(bmi),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Photos
              if (hasPhotos) ...<Widget>[
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.photoPaths.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(entry.photoPaths[index]),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Workout tags
              if (hasWorkout) ...<Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    ...entry.workoutTags.map((String tag) => Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Emotions
              if (hasEmotions) ...<Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.sentiment_satisfied,
                      size: 20,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.emotionalCheckIns.length} check-in${entry.emotionalCheckIns.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Thoughts preview
              if (hasThoughts) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.edit_note,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.thoughts!.length > 100
                              ? '${entry.thoughts!.substring(0, 100)}...'
                              : entry.thoughts!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
}
