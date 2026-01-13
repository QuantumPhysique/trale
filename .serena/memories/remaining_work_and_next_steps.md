# Remaining Work and Next Steps

## Work Ready for PR/Merge
### 1. feature/homescreen-calendar → main
- **Status**: Ready for PR creation
- **Linear**: SUN-10 (In Review)
- **Files**: app/lib/pages/homescreen_calendar.dart (156 lines)
- **Tests**: Widget tests in app/test/widget/homescreen_calendar_test.dart
- **Action needed**: Create PR, wait for review, merge

### 2. feature/checkin-ui-refactor → main
- **Status**: Ready for PR creation
- **Linear**: SUN-8 (In Review)
- **Files**: 
  - app/lib/screens/daily_entry_screen.dart (975 lines)
  - app/lib/core/db/app_database.dart (extended)
  - Tests and screenshots
- **Action needed**: Create PR, wait for review, merge

## Backlog Items (Not Started)

### 3. SUN-12: T8 - Add Coming Soon Messages to Tabs
**Priority**: Medium (not urgent)
**Scope**: Simple UI placeholders
**Files to update**:
- `app/lib/pages/statScreen.dart` (achievements)
- `app/lib/pages/measurementScreen.dart` (measurements)

**Implementation**:
```dart
Center(
  child: Text(
    'Coming Soon',
    style: TextStyle(
      fontSize: 24,
      color: Colors.grey,
    ),
  ),
)
```

**Branch**: `feature/coming-soon-tabs`
**Estimated effort**: 30 minutes
**Dependencies**: None

### 4. SUN-5: Remove Target Weight
**Priority**: Low (database already updated)
**Scope**: Remove any remaining UI references to target_weight

**Already completed**:
- ✅ Database schema: target_weight column removed (schema v2)
- ✅ Migration: Handles existing installs

**Remaining work**:
- Search codebase for any UI references to "target weight"
- Remove any input fields, labels, or display logic
- Update any documentation

**Search needed**:
```bash
grep -r "target.*weight" app/lib/
grep -r "targetWeight" app/lib/
```

**Branch**: `feature/remove-target-weight-ui`
**Estimated effort**: 1-2 hours
**Dependencies**: None

## Future Enhancements (Not in Current Scope)

### Emoji-Based Emotional Check-ins
**Note**: Current implementation uses color wheel (flutter_colorpicker)
**Reference**: trale-plus_old/app/lib/models/emotional_checkin.dart shows emoji-based approach

**If emoji-based implementation is desired**:
- Replace BlockPicker color wheel with emoji grid
- 8 emotions: 😠 Anger, 😨 Fear, 😣 Pain, 😔 Shame, 😞 Guilt, 😊 Joy, 💪 Strength, ❤️ Love
- Selection: 1-4 emotions allowed
- Update database storage from color hex to emoji string
- Update _EmotionalCheckIn model and display

**Branch**: `feature/emoji-emotional-checkins` (future)
**Estimated effort**: 4-6 hours
**Dependencies**: Would replace current emotional check-in implementation

## Integration and Testing TODOs

### Before Final Release
1. **Run full test suite**:
   ```bash
   flutter analyze
   flutter test
   flutter test integration_test/
   ```

2. **Build and verify on device**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug
   flutter install -d Pixel_7_<id>
   ```

3. **Playwright screenshots** (if available):
   - Home screen
   - Calendar view
   - Check-in form (all sections)
   - Emotional check-in
   - Immutability indicators

4. **Update documentation**:
   - CHANGELOG.md with all changes
   - README.md if needed
   - Agent_Instructions.md to reflect actual implementation

## Security Issue
### SUN-14: Improper SSL Certificate Validation
- **Source**: Aikido Security scan
- **Priority**: High
- **File**: app/android/app/src/debug/AndroidManifest.xml (line 1)
- **Status**: Backlog
- **Action**: Review and fix SSL certificate validation in debug manifest
- **Branch**: TBD (heet/sun-14-improper-ssl-certificate-validation-trale-plus suggested)

## CI/CD Considerations
- GitHub Actions workflows should run on PR creation
- CodeRabbit will provide automated review
- Wait ~2 minutes for CI feedback before addressing
- Ensure all tests pass before requesting human review

## Post-Merge Cleanup
1. Delete merged feature branches:
   ```bash
   git branch -d feature/platform-targets
   git branch -d feature/db-sqlite-refactor
   git branch -d feature/homescreen-calendar
   git branch -d feature/checkin-ui-refactor
   git branch -d feature/checkin-process-update  # superseded
   git push origin --delete feature/platform-targets
   git push origin --delete feature/db-sqlite-refactor
   # etc.
   ```

2. Create release tag:
   ```bash
   git tag -a v0.15.0 -m "Fitness journal refactor: check-ins, calendar, immutability"
   git push origin v0.15.0
   ```

3. Update Linear cycles and close issues

4. Generate release notes for F-Droid/Play Store
