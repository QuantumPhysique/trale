# Trale Fitness Journal Refactor – Complete Development Instructions

**Project**: Convert trale weight diary (Flutter) into secure, private fitness journal  
**Framework**: GitHub Flow (feature branches) + Linear project management  
**Device**: Pixel7 (wireless ADB, debugging enabled)  
**Target**: iOS 18+, Android 9+ (minSdkVersion 28)  
**Tools**: Linear MCP, Oraios/Serena (RAG), firecrawl, playwright, dart, Flutter CLI  

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

#### 3a. Weight & Height (Optional)
1. Serena: "Flutter optional form fields weight height nullable"
2. Update check-in form UI: add height field (optional)
3. Update check-in model: add `height_cm` (nullable)
4. Test: save with/without height; verify DB

#### 3b. Photos (Optional, Camera-Only, Up to 3, NSFW Flag)
1. Serena: "Flutter image_picker camera only multiple 3 photos"
2. Add `image_picker` to pubspec.yaml (camera only: `ImageSource.camera`)
3. Implement photo upload UI: up to 3 image slots
4. **NSFW Checkbox Logic**:
   - Default: checkbox checked (NSFW = true)
   - User must uncheck before saving
   - On unchecked, enable submit button
   - Serena: "Flutter checkbox state form validation"
5. Store photos: Base64 encoded in SQLite or file paths in app cache
6. Test: take 3 photos, verify NSFW toggle blocks save until unchecked

#### 3c. Thoughts (Optional, Multi-line)
1. Serena: "Flutter textarea multi-line text field form"
2. Add thoughts field to check-in form (TextFormField, multiline, maxLines: 5)
3. Update check-in model: add `thoughts` (nullable String)
4. Test: enter multi-line text, save, retrieve

#### 3d. Workout (Optional Text + User-Creatable Tags)
1. Serena: "Flutter tags input user creatable multi-select"
2. Add workout textarea (multiline text field, optional)
3. Implement tag input system:
   - Display existing tags (queryable from DB)
   - Allow user to create new tags inline
   - Multiple selection
   - Store selected tags in `workout_tags` join table
4. Update schema/models: `workouts` table, `workout_tags` join table
5. Test: add workout text, select/create tags, save, verify DB

#### 3e. Emotional Check-in (Immutable, Color Picker, Timestamp, Message)
1. Serena: "Flutter timestamp format DD-MM-YYYY HH:mm:ss:ms"
2. Implement color picker wheel (flutter_colorpicker or equivalent):
   - Serena: "skydoves ColorPickerView flutter equivalent wheel"
   - Present full color wheel picker (not just palette)
   - Implement flagview() or similar visual indicator
3. Add timestamp field (read-only, auto-populated DD-MM-YYYY HH:mm:ss:ms)
4. Add message field (optional, multi-line)
5. On save: mark check-in as immutable, store in `check_in_color` table with timestamp, color hex, message
6. Test: color picker selection, timestamp accuracy, save

### Full Stage 3 Execution

1. **Create branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/checkin-process-update
   ```

2. **Execute substeps 3a–3e sequentially**:
   - After each substep, test on Pixel7:
     ```bash
     flutter run -d Pixel_7_<id>
     ```
   - Playwright: Screenshot form fields
   - Verify DB save (check file or logs)
   - Commit & push per substep

3. **Full test flow**:
   ```bash
   flutter run -d Pixel_7_<id>
   ```
   - Navigate to "Add Check-in" screen
   - Fill all fields (weight, height, 3 photos with NSFW unchecked, thoughts, workout + tags, emotional color + message)
   - Verify save succeeds
   - Playwright: Screenshot complete form, submission confirmation

4. **Merge to main** after all substeps pass

5. **Uninstall & update Linear**: T3 → Done

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
