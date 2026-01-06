import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/models/user_profile.dart';
import 'package:trale/database/database_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Height entry state
  final TextEditingController _heightController = TextEditingController();
  final FocusNode _heightFocusNode = FocusNode();
  UnitSystem _selectedUnit = UnitSystem.metric; // UnitSystem (metric or imperial)
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _heightFocusNode.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your height')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double height = double.parse(_heightController.text);

      // Save user profile
      final UserProfile profile = UserProfile(
        initialHeight: height,
        preferredUnits: _selectedUnit,
      );
      await DatabaseHelper.instance.saveUserProfile(profile);

      // Set onboarding completed flag
      final Preferences prefs = Preferences();
      prefs.showOnBoarding = false;
      
      // Also set the old key for compatibility just in case, or we rely purely on Preferences now.
      // But AppInitializer uses onboarding_completed.
      final SharedPreferences rawPrefs = await SharedPreferences.getInstance();
      await rawPrefs.setBool('onboarding_completed', true);

      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid height value: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() => _currentPage = index);
                  if (index == 1) {
                    // Auto-focus the height input when swiping to the second page
                    // Delaying slightly to allow the transition to complete
                    Future<void>.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        _heightFocusNode.requestFocus();
                      }
                    });
                  } else {
                     FocusScope.of(context).unfocus();
                  }
                },
                children: <Widget>[
                  _buildWelcomePage(),
                  _buildHeightEntryPage(),
                  _buildPrivacyPage(),
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.fitness_center,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to Trale+',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your complete fitness journal for tracking weight, workouts, thoughts, and emotions.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: <Widget>[
              _buildFeatureChip('📊 Weight Tracking'),
              _buildFeatureChip('📸 Progress Photos'),
              _buildFeatureChip('💪 Workout Log'),
              _buildFeatureChip('📝 Daily Thoughts'),
              _buildFeatureChip('😊 Mood Tracking'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeightEntryPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.height,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Enter Your Height',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We\'ll use this to calculate your BMI',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Unit toggle
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment(
                value: 'metric',
                label: Text('Metric (cm)'),
                icon: Icon(Icons.straighten),
              ),
              ButtonSegment(
                value: 'imperial',
                label: Text('Imperial (in)'),
                icon: Icon(Icons.straighten),
              ),
            ],
            selected: <String>{_selectedUnit.value},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _selectedUnit = UnitSystem.fromString(newSelection.first));
            },
          ),
          const SizedBox(height: 24),
          // Height input
          SizedBox(
            width: 200,
            child: TextField(
              controller: _heightController,
              focusNode: _heightFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffix: Text(_selectedUnit == UnitSystem.metric ? 'cm' : 'in'),
                hintText: _selectedUnit == UnitSystem.metric ? '170' : '67',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You can update this later in settings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Your Privacy Matters',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildPrivacyFeature(
            Icons.phone_android,
            'All data stays on your device',
            'No cloud sync, no servers',
          ),
          const SizedBox(height: 16),
          _buildPrivacyFeature(
            Icons.image,
            'Photo EXIF data stripped',
            'Location and metadata removed',
          ),
          const SizedBox(height: 16),
          _buildPrivacyFeature(
            Icons.visibility_off,
            'No tracking or analytics',
            'We don\'t see anything you do',
          ),
          const SizedBox(height: 16),
          _buildPrivacyFeature(
            Icons.code,
            'Open source',
            'Verify everything yourself',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildPrivacyFeature(IconData icon, String title, String subtitle) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: <Widget>[
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (int index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                )
              else
                const SizedBox(width: 80),
              if (_currentPage < 2)
                FilledButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Next'),
                )
              else
                FilledButton(
                  onPressed: _isLoading ? null : _completeOnboarding,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Get Started'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
