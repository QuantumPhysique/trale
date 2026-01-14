# Trale Fitness Journal Refactor – Complete Development Instructions

**Project**: Convert trale weight diary (Flutter) into secure, private fitness journal  
**Framework**: GitHub Flow (feature branches) + Linear project management  
**Device**: Pixel7 (wireless ADB, debugging enabled)  
**Target**: iOS 18+, Android 9+ (minSdkVersion 28)  
**Tools**: Linear MCP, Oraios/Serena (RAG), firecrawl, playwright, dart, Flutter CLI

**Reference Implementation**: See `trale-plus_old/app/lib/screens/daily_entry_screen.dart` for UI/UX patterns and `desired_ss/` for screenshot examples of expected UI flows.

---


## 🎯 IMPLEMENTATION STATUS (Last Updated: 2026-01-13)


### ✅ COMPLETED & MERGED TO MAIN
- **T9 (Stage 1)**: Platform targets (Android 9+, iOS 18+) - SUN-13 ✅
- **T2 (Stage 2)**: SQLite/Drift database refactor - SUN-6 ✅


### 📋 COMPLETED & IN REVIEW (Ready for PR/Merge)
- **T6**: Full-screen calendar HomeScreen - SUN-10 (branch: feature/homescreen-calendar)
- **T3**: Camera-only photo capture (max 3, NSFW toggle) - SUN-7 ✅
- **T4**: Multi-section check-in form (weight, height, photos, thoughts, workout, emotional) - SUN-8
- **T5**: Emotional check-ins with **color wheel** (implemented), timestamp, multiple per day - SUN-9 ✅
- **T7**: Immutability enforcement (past dates + saved emotional check-ins) - SUN-11 ✅

**Branch**: `feature/checkin-ui-refactor` (commit d5dac94) - Contains T3, T4, T5, T7 implementations


### ⏸️ BACKLOG (Not Started)
- **T8**: "Coming Soon" placeholders for Achievements/Measurements tabs - SUN-12
- Remove target weight UI references - SUN-5
- Fix SSL certificate validation (security) - SUN-14


### 📝 IMPLEMENTATION NOTES

1. **Emotional Check-ins**: Implemented with **color wheel** (flutter_colorpicker) instead of emoji grid
   - Reference implementation in trale-plus_old uses 8 emoji emotions
   - Current: ColorPickerArea color wheel, live timestamp, optional message
   - Future enhancement: Could add emoji-based alternative as Stage 3e
2. **File**: `app/lib/screens/daily_entry_screen.dart` (975 lines, fully functional)
3. **Testing**: Integration tests, widget tests, device-verified on Pixel 7
4. **Dependencies added**: flutter_colorpicker, image_picker, table_calendar, drift, sqlite3_flutter_libs

---

## UI/UX Design Philosophy


### Core Principles (from trale-plus_old reference)
1. **Collapsible Card Sections**: Each entry component (weight/height, photos, workout, thoughts, emotions) lives in an expandable Card widget with ListTile header showing summary when collapsed
2. **Color Wheel Emotional Check-ins**: Current implementation uses ColorPickerArea (flutter_colorpicker) for intuitive color selection with live timestamps and optional messages; emoji-based alternative (8 emotions: 😠 Anger, 😨 Fear, 😣 Pain, 😔 Shame, 😞 Guilt, 😊 Joy, 💪 Strength, ❤️ Love) available as future Stage 3e enhancement
3. **Multiple Emotional Check-ins**: Allow multiple emotional check-ins per day with timestamps (HH:mm a format), each immutable after save
4. **Form Validation**: NSFW photo checkboxes default checked, must uncheck to enable save; emotion selection requires 1-4 emojis
5. **Immutability Indicators**: Visual badges/indicators for locked/immutable entries
6. **Date Banner**: Display selected date prominently at top (e.g., "Wednesday, January 11, 2026")

---

## Prerequisites & Initial Setup


### Linear Project Creation
1. Use **linear mcp connector** to create Linear project `trale-fitness-journal-refactor`
2. Create cycles for each stage (DB Refactor, Check-in Process, etc.)
3. Add Linear issues for T2–T9, sequenced as below


### Oraios/Serena RAG Index
Index the following into Serena before starting:
- **Repo overview**: "Flutter Material3 weight diary app, converting to fitness journal per .db_schema_refactor.md schema plan"
- **Key files path**: `pubspec.yaml`, `lib/`, `android/app/build.gradle`, `ios/Runner.xcworkspace`
- **Schema plan**: Full contents of `.db_schema_refactor.md`
- **Reference**: trale GitHub repo (https://github.com/QuantumPhysique/trale)


### Context & Search Queries for MCP Servers

**Firecrawl**: Fetch full trale repo context from https://github.com/QuantumPhysique/trale; retrieve Flutter pub.dev docs (sqflite, table_calendar, image_picker, flutter_colorpicker)

**Oraios/Serena (RAG queries)**:
- "Flutter SQLite schema migration best practices sqflite"
- "Flutter color picker wheel implementation flagview style"
- "Flutter full screen month calendar widget table_calendar"
- "Flutter camera only photo capture no gallery multiple images"
- "Flutter tags input user creatable multi-select"
- "Flutter timestamp format DD-MM-YYYY HH:mm:ss:ms"
- "skydoves ColorPickerView flutter equivalent wheel"
- "Flutter SQLite row immutability date check constraints"
- "Flutter form disable after submit immutable"
- "Flutter table_calendar full screen month view date selection"
- "Flutter android minSdkVersion 28 iOS 18.0 config"

**Context7**: Retrieve code context from repo files (pubspec.yaml, lib/main.dart, existing schema, models)

**Dart**: Run analyzer (`dart analyze`), format code (`dart format`)

**Playwright**: Screenshot verification on Pixel7 post-build (home, calendar, check-in forms, emotional picker, immutability blocks)


### Device Setup
```bash
flutter devices  # Verify Pixel7 listed as 'Pixel_7_*' (wireless ADB)
```


### Clean Main Branch Before Each Stage
```bash
git checkout main
git pull origin main
flutter pub get
flutter clean
```

---

## Stage 1: Platform Targets (T8–T9)

**Scope**: Update iOS 18.0 and Android 9+ (minSdkVersion 28)  
**Branch**: `feature/platform-targets`  
**Linear**: Create & link issues T8, T9


### Steps

1. **Create feature branch**:
   ```bash
   git checkout -b feature/platform-targets
   ```

2. **Update pubspec.yaml platform constraints**:
   - Serena query: "Flutter platform constraint iOS 18.0 android version config"
   - Update to specify iOS >= 18.0, Android >= 9

3. **Configure Android** (`android/app/build.gradle`):
   - Set `minSdkVersion 28` (Android 9)
   - Query Serena: "Flutter android minSdkVersion 28 config"

4. **Configure iOS** (`ios/Runner.xcworkspace`):
   - Set iOS Deployment Target to 18.0
   - Query Serena: "Flutter iOS 18.0 deployment target config"

5. **Verify dependencies**:
   ```bash
   flutter pub get
   flutter pub outdated
   ```
   - Use Serena: "Flutter dependencies compatible iOS 18 Android 9"

6. **Test build**:
   ```bash
   flutter build apk --debug
   flutter install -d Pixel_7_<id>
   flutter run -d Pixel_7_<id>
   ```

7. **Verify on device**:
   - Playwright: Screenshot home screen, entry point
   - Check for crashes in Flutter logs: `flutter logs`
   - Verify app launches and basic navigation works

8. **Commit & push**:
   ```bash
   git add .
   git commit -m "feat: target iOS18 Android9+ (minSdkVersion 28)"
   git push origin feature/platform-targets
   ```

9. **Create PR, review, merge to main**:
   - Verify CI/CD passes (GitHub Actions)
   - Merge via GitHub

10. **Uninstall test build**:
    ```bash
    flutter uninstall -d Pixel_7_<id>
    ```

11. **Update Linear**: Move T8, T9 to "Done"

---

## Stage 2: Database Refactor (T2)

**Scope**: Migrate to SQLite per `.db_schema_refactor.md`; remove target weight  
**Branch**: `feature/db-sqlite-refactor`  
**Linear**: Link issue T2


### Steps

1. **Create feature branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/db-sqlite-refactor
   ```

2. **Review schema plan**:
   - Serena: "SQLite schema refactor design best practices migrations"
   - Load `.db_schema_refactor.md` into Serena context
   - Note: Check-in tables, check_in_color table (timestamp, color, message), immutability flags

3. **Implement sqflite**:
   - Serena: "Flutter sqflite database refactor migration onUpgrade onCreate"
   - Add `sqflite` to pubspec.yaml if not present
   - Create/update `lib/database/` module (db_helper.dart, migrations)
   - Implement `onCreate()` (v1 schema) and `onUpgrade()` (future versions)
   - Include `check_in_color` table per schema

4. **Remove target weight**:
   - Delete DB schema columns: `target_weight`, related fields
   - Update models: remove TargetWeight class
   - Serena: "Flutter sqflite drop column migration"

5. **Test database operations**:
   ```bash
   flutter pub get
   flutter run -d Pixel_7_<id>
   ```
   - Manually add weight-only check-in via existing UI
   - Verify it saves to DB (check app cache/database files or logging)
   - Playwright: Screenshot entry form, confirm no target weight field

6. **Analyze code**:
   ```bash
   dart analyze
   ```
   - Fix any unused imports, type issues

7. **Commit incrementally** (per major change):
   ```bash
   git add lib/database/
   git commit -m "feat(db): implement sqflite with schema refactor per .db_schema_refactor.md"
   git push origin feature/db-sqlite-refactor
   
   git add lib/models/
   git commit -m "feat(db): remove target_weight from schema and models"
   git push origin feature/db-sqlite-refactor
   ```

8. **Create PR, review, merge to main**

9. **Uninstall & move Linear**: T2 → Done

---

## Stage 3: Update Check-in Process (T3)

**Scope**: Implement new check-in form with weight, height, photos, thoughts, workout, emotional  
**Branch**: `feature/checkin-process-update`  
**Linear**: Link issue T3


### Substeps

#### 3a. Weight & Height (Optional, Collapsible Card Section)

**Reference**: `trale-plus_old/app/lib/screens/daily_entry_screen.dart` _buildWeightSection() (lines 334-398)

1. **UI Structure**:
   - Serena: "Flutter Card ListTile expandable collapsible section"
   - Card widget with:
     - ListTile header:
       - Leading: Icon(Icons.monitor_weight)
       - Title: "Weight & Height"
       - Subtitle (when collapsed): Display summary if values present (e.g., "70.5 kg")
       - Trailing: Expand/collapse icon (Icons.expand_more / Icons.expand_less)
       - onTap: Toggle section expansion
   - Expanded content (Padding 16px):
     - Weight TextField:
       - labelText: "Weight"
       - keyboardType: TextInputType.number
       - decoration: OutlineInputBorder, suffixText: "kg", prefixIcon: Icon(Icons.monitor_weight)
     - SizedBox(height: 16)
     - Height TextField:
       - labelText: "Height (optional)"
       - keyboardType: TextInputType.number
       - decoration: OutlineInputBorder, suffixText: "cm", prefixIcon: Icon(Icons.height)
       - helperText: "Update if changed"
     - If both weight & height filled: Display BMI calculation

2. **Model Updates**:
   - Update check-in model: add `height_cm` field (nullable double)
   - Store in check_in table

3. **Test**:
   - Save with weight only, height only, both, neither
   - Verify collapsible behavior (tap to expand/collapse)
   - Verify BMI display when both present

#### 3b. Photos (Optional, Camera-Only, Up to 3, NSFW Flag, Collapsible Card Section)

**Reference**: `trale-plus_old/app/lib/screens/daily_entry_screen.dart` _buildPhotoSection() (lines 400-510)

1. **UI Structure**:
   - Serena: "Flutter image_picker camera gallery multiple 3 photos GridView"
   - Card widget with:
     - ListTile header:
       - Leading: Icon(Icons.photo_camera)
       - Title: "Photos"
       - Subtitle (when collapsed): "X photo(s) added" (if photos present)
       - Trailing: Photo count badge "2/3" + expand/collapse icon
       - onTap: Toggle section expansion
   - Expanded content (Padding 16px):
     - Action buttons row:
       - OutlinedButton.icon (Camera): Icon(Icons.camera_alt), label: "Camera"
       - OutlinedButton.icon (Gallery): Icon(Icons.photo_library), label: "Gallery"
       - Disable if photoCount >= 3
     - If photos.isNotEmpty:
       - SizedBox(height: 16)
       - GridView.builder (3-column grid, crossAxisSpacing: 8, mainAxisSpacing: 8):
         - Display photo thumbnails (ClipRRect, borderRadius: 8)
         - Stack with delete button overlay (top-right, IconButton with Icon(Icons.delete))
         - onTap thumbnail: Open full-screen PhotoViewer
     - Else: Display "No photos added yet" (bodySmall)

2. **Image Picker Implementation**:
   - Add `image_picker` to pubspec.yaml
   - Serena: "Flutter image_picker ImageSource camera gallery"
   - Camera button: `ImagePicker().pickImage(source: ImageSource.camera)`
   - Gallery button: `ImagePicker().pickImage(source: ImageSource.gallery)`
   - Store photo paths (or Base64 if preferred) in check_in_photo table

3. **NSFW Toggle** (removed from old implementation, skip this):
   - Original plan had per-photo NSFW checkbox, but not in reference UI
   - Omit NSFW logic for simplicity unless explicitly requested

4. **Photo Storage**:
   - Store file paths in app directory or Base64 in SQLite
   - Link to check-in via check_in_photo table (check_in_date FK, path, ts)

5. **Test**:
   - Capture 3 photos via camera
   - Select 3 photos via gallery
   - Verify 3-photo limit (buttons disable)
   - Delete photos, verify removal
   - Open photo viewer, verify display

#### 3c. Thoughts (Optional, Multi-line, Collapsible Card Section)

**Reference**: `trale-plus_old/app/lib/screens/daily_entry_screen.dart` _buildThoughtsSection() (lines 698-742)

1. **UI Structure**:
   - Serena: "Flutter textarea multi-line text field Card collapsible"
   - Card widget with:
     - ListTile header:
       - Leading: Icon(Icons.edit_note)
       - Title: "Thoughts"
       - Subtitle (when collapsed): Show first 50 chars if text present ("...")
       - Trailing: Expand/collapse icon
       - onTap: Toggle section expansion
   - Expanded content (Padding 16px):
     - TextField:
       - labelText: "How are you feeling today?"
       - hintText: "Write your thoughts here..."
       - border: OutlineInputBorder
       - maxLines: 6
       - maxLength: 2000
       - alignLabelWithHint: true

2. **Model Updates**:
   - Update check-in model: add `thoughts` field (nullable String)
   - Store in check_in table

3. **Test**:
   - Enter multi-line text, verify wrapping
   - Verify character counter (0/2000)
   - Save, retrieve, verify persistence
   - Verify collapsed summary shows first 50 chars

#### 3d. Workout (Optional Text + User-Creatable Tags, Collapsible Card Section)

**Reference**: `trale-plus_old/app/lib/screens/daily_entry_screen.dart` _buildWorkoutSection() (lines 608-696)

1. **UI Structure**:
   - Serena: "Flutter tags input user creatable Chip ActionChip"
   - Card widget with:
     - ListTile header:
       - Leading: Icon(Icons.fitness_center)
       - Title: "Workout"
       - Subtitle (when collapsed): Show workout summary if present (first 50 chars or tag count)
       - Trailing: Expand/collapse icon
       - onTap: Toggle section expansion
   - Expanded content (Padding 16px):
     - TextField (workout description):
       - labelText: "Workout description"
       - hintText: "Describe your workout..."
       - border: OutlineInputBorder
       - maxLines: 4
       - maxLength: 500
       - alignLabelWithHint: true
     - SizedBox(height: 16)
     - Text: "Tags" (titleSmall)
     - SizedBox(height: 8)
     - Wrap widget (spacing: 8, runSpacing: 8):
       - Display existing tags as Chip widgets with delete buttons
       - ActionChip: "+ Add Tag" (opens tag input dialog)

2. **Tag Input System**:
   - Serena: "Flutter dialog TextField create tag user input"
   - On "+ Add Tag" tap:
     - Show AlertDialog with TextField
     - TextField: labelText: "Tag name", maxLength: 50
     - Actions: Cancel, Add buttons
     - On Add: validate non-empty, add to local tag list, update UI
   - Store tags in workout_tags table (tag text)
   - Link to workout via workout_workout_tags join table

3. **Database Schema**:
   - workout table: check_in_date (FK), description (nullable)
   - workout_tag table: id (PK), tag (unique text)
   - workout_workout_tag join table: workout_id, workout_tag_id

4. **Test**:
   - Add workout text, verify save
   - Create new tags, verify storage
   - Select existing tags from DB
   - Delete tags from selection
   - Save, retrieve, verify persistence

#### 3e. Emotional Check-in (Immutable, Emoji Grid, Timestamp, Text Field)

**Reference**: `trale-plus_old/app/lib/models/emotional_checkin.dart` and `trale-plus_old/app/lib/screens/daily_entry_screen.dart` (lines 740-1000)

1. **Emoji Grid (NOT Color Picker)**:
   - Serena: "Flutter grid 8 emoji buttons selectable emotional check-in"
   - Display 8 emotions in 4x2 grid:
     - 😠 Anger, 😨 Fear, 😣 Pain, 😔 Shame (top row)
     - 😞 Guilt, 😊 Joy, 💪 Strength, ❤️ Love (bottom row)
   - Selection rules:
     - User must select 1-4 emotions
     - Selected emotions show border highlight (primary color, 3px border)
     - Clicking 5th emotion shows snackbar: "You can select up to 4 emotions"
   - Display selected emotions as chips with delete buttons

2. **Timestamp & Text Field**:
   - Serena: "Flutter timestamp auto-populate current time HH:mm a format"
   - Auto-populate timestamp: "Right now - 3:45 PM" (read-only, formatted: DateFormat('h:mm a').format(DateTime.now()))
   - Multi-line text field (maxLines: 4, maxLength: 500):
     - Label: "What's on your mind?"
     - Hint: "Describe how you're feeling..."
     - Show character counter: "0/500"
   - Optional: text can be empty

3. **Multiple Check-ins Per Day**:
   - Serena: "Flutter list multiple timestamped entries same day"
   - Allow saving multiple emotional check-ins for same date
   - Each check-in saved to `check_in_color` table with:
     - `check_in_date` (FK to check_in.date)
     - `ts` (timestamp, milliseconds since epoch)
     - `color` (store as emoji string, e.g., "😊,💪" comma-separated)
     - `message` (text field, nullable)
   - After save:
     - Clear form (emotions, text field)
     - Show success snackbar: "Emotional check-in saved!"
     - Set `is_immutable = true` (cannot edit/delete)
     - Display saved check-in in list below form

4. **Display Previous Check-ins**:
   - Show list of emotional check-ins for selected date (reverse chronological)
   - Each check-in card displays:
     - Timestamp (small, gray text): "3:45 PM"
     - Emoji row: "😊 💪" (larger font, 20px)
     - Text message (if present): wrap text, body medium style
   - Card style: surfaceContainerHighest with 30% alpha, 12px padding

5. **Immutability**:
   - Once saved, emotional check-in cannot be edited or deleted
   - No edit/delete buttons on saved check-in cards
   - Show "immutable" indicator if user tries to interact

6. **UI Structure** (collapsible card section):
   - Card with ListTile header:
     - Leading: Icon(Icons.sentiment_satisfied)
     - Title: "Emotional Check-Ins"
     - Subtitle (when collapsed): "X check-in(s) today"
     - Trailing: Expand/collapse icon + emotion count badge "2/4" (if form active)
   - Expanded content:
     - "Right now - 3:45 PM" banner (for today only)
     - Emoji grid (4x2)
     - Selected emotions chips
     - Text field
     - "Save Emotional Check-In" button (full width, ElevatedButton.icon)
     - Divider
     - "Previous check-ins today" label
     - List of saved check-in cards


### Full Stage 3 Execution

1. **Create branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/checkin-process-update
   ```

2. **Refactor Check-in Screen Structure**:
   - Replace current `showAddCheckInDialog` with full-screen DailyEntryScreen (scaffold)
   - Serena: "Flutter Scaffold ListView collapsible Card sections"
   - AppBar:
     - title: "Daily Entry"
     - actions: Calendar icon button (select date)
   - Date banner (Container, full width, primaryContainer background):
     - Display selected date: DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)
     - Center aligned, titleMedium text style
   - Body: ListView with card sections (weight, photos, workout, thoughts, emotions)
   - FloatingActionButton.extended:
     - icon: Icons.save
     - label: "Save Entry"
     - onPressed: _saveEntry()

3. **Execute substeps 3a–3e sequentially**:
   - After each substep, test on Pixel7:
     ```bash
     flutter run -d Pixel_7_<id>
     ```
   - Playwright: Screenshot form sections (collapsed, expanded states)
   - Verify DB save (check file or logs)
   - Commit & push per substep:
     ```bash
     git add .
     git commit -m "feat(checkin): add weight/height collapsible section"
     git push origin feature/checkin-process-update
     ```

4. **Full test flow**:
   ```bash
   flutter run -d Pixel_7_<id>
   ```
   - Navigate to "Daily Entry" screen (via FAB or calendar)
   - Fill all fields:
     - Weight/height (expand section, fill both)
     - 3 photos (camera/gallery)
     - Workout text + create tags
     - Thoughts (multi-line text)
     - Emotional check-in (select 2 emojis, add text, save)
     - Add 2nd emotional check-in (different emojis, timestamp updates)
   - Verify save succeeds
   - Reload screen, verify all data persists
   - Playwright: Screenshot complete form (all sections expanded), submission confirmation, saved data display

5. **Merge to main** after all substeps pass

6. **Uninstall & update Linear**: T3 → Done

---

## Stage 4: Immutability Rules (T5–T6)

**Scope**: Enforce immutability for past check-ins & all emotional check-ins  
**Branch**: `feature/checkin-immutability`  
**Linear**: Link issues T5, T6


### Steps

1. **Create branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/checkin-immutability
   ```

2. **Immutability for Past Check-ins** (T5):
   - Serena: "Flutter SQLite row immutability date check constraint"
   - Add DB field: `is_locked` (boolean, default false)
   - On check-in save: if date < today, set `is_locked = true`
   - On check-in view/edit screen:
     - If locked, disable all input fields (read-only)
     - Display "locked" badge/indicator
     - Remove edit/delete buttons
   - Test: save check-in for yesterday, try to edit, verify block

3. **Immutability for Emotional Check-ins** (T6):
   - Serena: "Flutter form disable after submit immutable state"
   - Once emotional check-in saved:
     - Set `is_immutable = true` in `check_in_color` table
     - On view: show color/message, disable edit/delete
     - Display "immutable" indicator
   - Test: add emotional check-in, refresh, attempt edit, verify block

4. **Test both immutability rules**:
   ```bash
   flutter run -d Pixel_7_<id>
   ```
   - Add past check-in (yesterday)
   - Try to edit → verify locked UI
   - Add emotional check-in (today)
   - Refresh/re-open → verify immutable
   - Playwright: Before/after screenshots (editable → locked)

5. **Commit & push**:
   ```bash
   git add .
   git commit -m "feat(immutability): lock past & emotional check-ins"
   git push origin feature/checkin-immutability
   ```

6. **Merge to main, uninstall, update Linear**: T5, T6 → Done

---

## Stage 5: HomeScreen Calendar (T4)

**Scope**: Full-screen month calendar; add/edit check-ins by date  
**Branch**: `feature/homescreen-calendar`  
**Linear**: Link issue T4


### Steps

1. **Create branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/homescreen-calendar
   ```

2. **Implement calendar widget**:
   - Add package: `table_calendar` or `awesome_calendart` to pubspec.yaml
   - Serena: "Flutter table_calendar full screen month view date selection"
   - Replace existing HomeScreen with calendar:
     - Full-screen month view (not scrollable, fits screen)
     - Display selected month/year with navigation (prev/next month)
     - Highlight dates with existing check-ins (dot, badge, or color)

3. **Add check-in entry points**:
   - **Floating Action Button (FAB)** with "+" icon:
     - Tap → Add check-in for today (launch form with today's date pre-filled)
   - **Tap on calendar date**:
     - Tap past date → Add check-in form pre-filled with that date
     - Tap today → Same as FAB
     - Tap future date → Show error message or disable (per design choice, suggest: allow future entry)

4. **Integrate with DB**:
   - Query DB on calendar load: fetch all check-in dates
   - Update calendar cell styling for dates with check-ins
   - Serena: "Flutter table_calendar past date entry"

5. **Test navigation**:
   ```bash
   flutter run -d Pixel_7_<id>
   ```
   - Navigate months (prev/next)
   - Tap today's date → Check-in form opens
   - Tap past date → Check-in form pre-filled
   - Add check-in, return to calendar → Date highlighted
   - Playwright: Screenshot month view, tapped dates, form pre-fill

6. **Commit & push**:
   ```bash
   git add .
   git commit -m "feat(homescreen): full-screen month calendar with date-based check-in entry"
   git push origin feature/homescreen-calendar
   ```

7. **Merge to main, uninstall, update Linear**: T4 → Done

---

## Stage 6: Tabs Update (T7)

**Scope**: Add "Coming soon" placeholders for Achievements & Measurements tabs  
**Branch**: `feature/tabs-coming-soon`  
**Linear**: Link issue T7


### Steps

1. **Create branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/tabs-coming-soon
   ```

2. **Update Achievements tab**:
   - Replace existing content with centered "Coming soon" message
   - Serena: "Flutter tab scaffold placeholder UI centered"
   - Style: large centered text, optional icon (e.g., trophy, star)

3. **Update Measurements tab**:
   - Same as Achievements: "Coming soon" placeholder

4. **Test navigation**:
   ```bash
   flutter run -d Pixel_7_<id>
   ```
   - Tap Achievements → "Coming soon" displayed
   - Tap Measurements → "Coming soon" displayed
   - Playwright: Screenshot each tab

5. **Commit & push**:
   ```bash
   git add .
   git commit -m "feat(tabs): add coming soon placeholders for achievements and measurements"
   git push origin feature/tabs-coming-soon
   ```

6. **Merge to main, uninstall, update Linear**: T7 → Done

---

## Finalization

After all stages (T2–T9) merged to main:

1. **Clean & verify main**:
   ```bash
   git checkout main
   git pull origin main
   flutter pub get
   flutter clean
   ```

2. **Build release**:
   ```bash
   flutter build apk --release
   flutter build ios
   ```

3. **Verify no build errors**:
   - Serena: "Flutter build release errors troubleshooting"
   - Check console output for warnings/errors

4. **Final test on Pixel7**:
   ```bash
   flutter run -d Pixel_7_<id> --release
   ```
   - Full user flow: calendar → add check-in (all fields) → immutability check → past-date entry
   - Playwright: Full flow screenshots

5. **Update Linear project**: Mark all issues Done, update cycle status

6. **Documentation**:
   - Serena: "Flutter fitness journal architecture documentation"
   - Commit CHANGELOG, README updates

---

## Notes

- **Pixel7 Device ID**: Use `flutter devices` to find exact ID (format: `Pixel_7_<serial>`)
- **Uninstall after each stage**: `flutter uninstall -d Pixel_7_<id>` to clean test builds
- **Git commits**: Push incrementally per feature/substep for clean history
- **Serena RAG**: Lean heavily on RAG queries for context-aware recommendations
- **Playwright Screenshots**: Capture key UI states (forms, immutability blocks, calendar, color picker)
- **No Code**: Instructions only; agent implements based on guidance

---

## Tool Summary

| Tool | Usage |
|------|-------|
| **Linear MCP** | Project/issue creation, cycle management, progress tracking |
| **Oraios/Serena** | RAG-based code context, dependency guidance, best practices |
| **Firecrawl** | Full repo context, pub.dev dependency docs |
| **Context7** | Code file retrieval (models, DB, UI screens) |
| **Dart** | `dart analyze`, `dart format` |
| **Playwright** | Screenshot verification post-build (UI state validation) |
| **Flutter CLI** | Build, run, install, uninstall on Pixel7 |
| **Git CLI** | Branch, commit, push, PR operations |
