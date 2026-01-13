# Trale Plus - Refactor and Fixes (January 12, 2026)

## Overview
This document summarizes the major changes, fixes, and refactoring work done on the Trale Plus Flutter app.

---

## 1. SQLite Reserved Keyword Fix

### Problem
The `check_in` table was using a column that could be interpreted as the SQLite reserved keyword `date`, causing database save errors and SQL exceptions.

### Solution Implemented
- **File**: `app/lib/core/db/app_database.dart`
- **Change**: Added explicit `.named('check_in_date')` to the CheckIns table definition
  ```dart
  TextColumn get checkInDate => text().named('check_in_date')();
  ```
- **Schema Version**: Bumped from 5 to 6
- **Migration Added**: 
  - Detects if column is named `date` or `check_in_date`
  - Renames `date` → `check_in_date` if needed (with PRAGMA foreign_keys handling)
  - Recreates triggers with correct syntax using `OLD.check_in_date`

### Trigger Fixes
Fixed SQLite trigger syntax to properly reference row values in WHEN clauses:
- **Before**: `WHEN check_in_date < date('now','localtime')`
- **After**: `WHEN OLD.check_in_date < date('now','localtime')`

This ensures triggers properly check the actual row data being updated/deleted.

---

## 2. Date Entry Restrictions

### Problem
Users could add/edit data for future dates from the calendar, which shouldn't be allowed. The app should only allow editing data for TODAY.

### Solution Implemented
- **File**: `app/lib/core/db/app_database.dart`
- **Function**: `isCheckInMutable(String dateStr)`
- **Change**: Modified logic to only allow editing TODAY (not past, not future)
  ```dart
  // Only allow editing TODAY - block both past and future
  if (!d.isAtSameMomentAs(today)) return false;
  ```
- **Before**: Allowed editing for today and all future dates
- **After**: ONLY allows editing for today's date

### Impact
- Past dates: Immutable (unchanged behavior)
- Today's date: Mutable (editable) ✓
- Future dates: NOW IMMUTABLE (changed from mutable)

---

## 3. Achievements Tab - Under Construction

### Problem
The achievements tab (StatsScreen) had complex widgets and functionality that needed to be removed and replaced with a placeholder.

### Solution Implemented
- **File**: `app/lib/pages/statScreen.dart`
- **Changes**:
  - Removed all imports except `flutter/material.dart`
  - Removed `MeasurementDatabase`, `emptyChart`, and `statsWidgetsList` dependencies
  - Replaced entire screen content with "Under Construction" message
  - Simple centered column with:
    - Construction icon (80px, grey)
    - "Under Construction" title (24px, bold)
    - "This feature is coming soon" subtitle (16px)

### Deleted Components
- `StatsWidgetsList` widget integration
- `MeasurementDatabase` stream handling
- `defaultEmptyChart` fallback
- All measurement-related logic

---

## 4. Measurements Tab - Under Construction

### Problem
The measurements tab (MeasurementScreen) had complex list and scrolling widgets that needed to be removed and replaced with a placeholder.

### Solution Implemented
- **File**: `app/lib/pages/measurementScreen.dart`
- **Changes**:
  - Removed all imports except `flutter/material.dart`
  - Removed `TotalWeightList`, `MeasurementDatabase`, and theme dependencies
  - Replaced entire screen with identical "Under Construction" message
  - Removed ScrollController and animation logic

### Deleted Components
- `TotalWeightList` widget
- `Scrollbar` with custom styling
- `MeasurementDatabase` stream handling
- `defaultEmptyChart` fallback
- Animation duration logic from TraleTheme

---

## Testing & Deployment

### To Apply All Changes
1. **Restart the app** (not just hot reload) to trigger database migration
2. The migration will automatically:
   - Rename the date column if needed
   - Fix the triggers
   - Update schema to version 6

### Testing Checklist
- [ ] Verify can only edit TODAY's check-in (not past, not future)
- [ ] Verify Achievements tab shows "Under Construction"
- [ ] Verify Measurements tab shows "Under Construction"
- [ ] Verify no SQL errors when saving check-ins
- [ ] Test calendar navigation and date restrictions

### Files Modified
1. `app/lib/core/db/app_database.dart` - Database schema and migrations
2. `app/lib/pages/statScreen.dart` - Achievements tab simplified
3. `app/lib/pages/measurementScreen.dart` - Measurements tab simplified

---

## Future Considerations

### Achievements Tab
When ready to implement:
- Design the achievement system (milestones, streaks, goals)
- Create new achievement widgets
- Integrate with check-in data
- Update `statScreen.dart` with actual implementation

### Measurements Tab
When ready to implement:
- Decide if using old measurement system or new check-in based system
- If keeping old system, restore `TotalWeightList` and related widgets
- If using new system, build from check-in data
- Update `measurementScreen.dart` with actual implementation

### Date Restrictions
The current restriction (TODAY only) can be adjusted in `isCheckInMutable()` if business rules change:
- To allow future dates: Remove the `isAtSameMomentAs` check
- To allow past N days: Use `d.isAfter(today.subtract(Duration(days: N)))`

---

## Technical Notes

### Database Migration Safety
The migration checks for column existence before attempting rename, making it safe to run multiple times.

### Widget Cleanup
Removed widgets are still in the codebase (e.g., `statsWidgetsList.dart`, `weightList.dart`) but are no longer imported/used. Consider deleting these files in a future cleanup pass if not needed.

### Schema Version History
- v4: Original schema (before these changes)
- v5: Added explicit `.named()` but migration was incorrect
- v6: Current version with proper migration and trigger fixes

---

## Appendix: Key Code Locations

### Check-In Mutability Logic
`app/lib/core/db/app_database.dart` - Line ~363
```dart
Future<bool> isCheckInMutable(String dateStr) async
```

### Tab Configuration
`app/lib/pages/home.dart` - Line ~107
```dart
final List<Widget> activeTabs = <Widget>[
  const OverviewScreen(),     // Home tab (index 0)
  StatsScreen(...),           // Achievements tab (index 1)
  MeasurementScreen(...),     // Measurements tab (index 2)
];
```

### Database Migration
`app/lib/core/db/app_database.dart` - Line ~183
```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from == 5 && to >= 6) { ... }
}
```
