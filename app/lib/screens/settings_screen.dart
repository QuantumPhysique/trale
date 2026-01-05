import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trale/models/user_profile.dart';
import 'package:trale/models/daily_entry.dart';
import 'package:trale/database/database_helper.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildUserSection(),
                const Divider(),
                _buildDataSection(),
                const Divider(),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildUserSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'User Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.height),
          title: const Text('Height'),
          subtitle: _userProfile?.initialHeight != null
              ? Text(
                  '${_userProfile!.initialHeight} ${_userProfile!.preferredUnits == 'metric' ? 'cm' : 'in'}')
              : const Text('Not set'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showHeightUpdateDialog,
        ),
        ListTile(
          leading: const Icon(Icons.straighten),
          title: const Text('Units'),
          subtitle: Text(
            _userProfile?.preferredUnits == 'metric' ? 'Metric (kg, cm)' : 'Imperial (lb, in)',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showUnitsDialog,
        ),
        if (_userProfile?.heightHistory != null && 
            _userProfile!.heightHistory.isNotEmpty) ...[
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Height History'),
            subtitle: Text('${_userProfile!.heightHistory.length} entries'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showHeightHistory,
          ),
        ],
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Data Management',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: const Text('Export Data'),
          subtitle: const Text('Backup all your entries'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _exportData,
        ),
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('Storage Info'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showStorageInfo,
        ),
        ListTile(
          leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
          title: Text(
            'Delete All Data',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('Permanently delete all entries'),
          onTap: _confirmDeleteAllData,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About Trale+'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showAboutDialog,
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showPrivacyPolicy,
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Open Source Licenses'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(context: context),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Version 2.0.0 (Fitness Journal)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showHeightUpdateDialog() async {
    final currentHeight = _userProfile?.initialHeight?.toString() ?? '';
    final currentUnit = _userProfile?.preferredUnits ?? 'metric';
    
    final controller = TextEditingController(text: currentHeight);
    String selectedUnit = currentUnit;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Height'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'metric', label: Text('cm')),
                  ButtonSegment(value: 'imperial', label: Text('in')),
                ],
                selected: {selectedUnit},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => selectedUnit = newSelection.first);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Height',
                  suffixText: selectedUnit == 'metric' ? 'cm' : 'in',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newHeight = double.tryParse(controller.text);
                if (newHeight != null) {
                  final updatedProfile = UserProfile(
                    initialHeight: newHeight,
                    heightHistory: [
                      ...?_userProfile?.heightHistory,
                      HeightEntry(date: DateTime.now(), height: newHeight),
                    ],
                    preferredUnits: selectedUnit,
                  );
                  await DatabaseHelper.instance.saveUserProfile(updatedProfile);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadUserProfile();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Height updated')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    
    controller.dispose();
  }

  Future<void> _showUnitsDialog() async {
    final currentUnit = _userProfile?.preferredUnits ?? 'metric';
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferred Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Metric (kg, cm)'),
              value: 'metric',
              groupValue: currentUnit,
              onChanged: (value) async {
                if (value != null) {
                  final updatedProfile = UserProfile(
                    initialHeight: _userProfile?.initialHeight,
                    heightHistory: _userProfile?.heightHistory ?? [],
                    preferredUnits: value,
                  );
                  await DatabaseHelper.instance.saveUserProfile(updatedProfile);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadUserProfile();
                  }
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Imperial (lb, in)'),
              value: 'imperial',
              groupValue: currentUnit,
              onChanged: (value) async {
                if (value != null) {
                  final updatedProfile = UserProfile(
                    initialHeight: _userProfile?.initialHeight,
                    heightHistory: _userProfile?.heightHistory ?? [],
                    preferredUnits: value,
                  );
                  await DatabaseHelper.instance.saveUserProfile(updatedProfile);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadUserProfile();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHeightHistory() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Height History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _userProfile?.heightHistory.length ?? 0,
            itemBuilder: (context, index) {
              final entry = _userProfile!.heightHistory[index];
              return ListTile(
                leading: const Icon(Icons.height),
                title: Text('${entry.height} ${_userProfile!.preferredUnits == 'metric' ? 'cm' : 'in'}'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(entry.date)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get all data
      final entries = await DatabaseHelper.instance.getAllEntries();
      final profile = await DatabaseHelper.instance.getUserProfile();

      // Create export object
      final exportData = {
        'version': '2.0.0',
        'exported_at': DateTime.now().toIso8601String(),
        'user_profile': profile?.toMap(),
        'entries': entries.map((e) => e.toMap()).toList(),
        'total_entries': entries.length,
      };

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'trale_plus_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';
      
      await File(filePath).writeAsString(jsonString);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Trale+ Data Backup',
        text: 'Backup of ${entries.length} entries from Trale+',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported ${entries.length} entries')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _showStorageInfo() async {
    final entries = await DatabaseHelper.instance.getAllEntries();
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/photos');
    
    int photoCount = 0;
    int totalPhotoSize = 0;
    
    if (await photosDir.exists()) {
      final photos = await photosDir.list().toList();
      photoCount = photos.length;
      
      for (final photo in photos) {
        if (photo is File) {
          final stat = await photo.stat();
          totalPhotoSize += stat.size;
        }
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Total Entries', '${entries.length}'),
              _buildInfoRow('Photos Stored', '$photoCount'),
              _buildInfoRow('Photo Storage', '${(totalPhotoSize / 1024 / 1024).toStringAsFixed(2)} MB'),
              const SizedBox(height: 16),
              Text(
                'All data is stored locally on your device.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your entries, photos, and settings. This action cannot be undone.',
        ),
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
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete all entries
      final entries = await DatabaseHelper.instance.getAllEntries();
      for (final entry in entries) {
        await DatabaseHelper.instance.deleteEntry(entry.date);
      }

      // Reset user profile
      await DatabaseHelper.instance.saveUserProfile(
        UserProfile(preferredUnits: 'metric'),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted')),
        );
        Navigator.pop(context); // Return to home
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Trale+',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(Icons.fitness_center, size: 48),
      children: [
        const Text(
          'A complete fitness journal app for tracking weight, workouts, photos, thoughts, and emotions.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Built with privacy in mind - all your data stays on your device.',
        ),
        const SizedBox(height: 16),
        const Text('Based on the original trale app by QuantumPhysique.'),
      ],
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy is Our Priority',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('Trale+ is designed with privacy at its core:'),
              SizedBox(height: 12),
              Text('• All data stays on your device'),
              Text('• No cloud sync or servers'),
              Text('• No analytics or tracking'),
              Text('• Photo EXIF data is stripped (GPS, device info removed)'),
              Text('• Open source code (verifiable)'),
              SizedBox(height: 12),
              Text(
                'Permissions Used:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Camera: To capture progress photos'),
              Text('• Photos: To select images from gallery'),
              SizedBox(height: 12),
              Text(
                'We never collect, transmit, or sell your data.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
