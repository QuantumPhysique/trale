# Code Changes Implementation Checklist

**For**: db_refactorist & platform_engg  
**Issue**: Reserved keyword 'date' → 'check_in_date'  
**Status**: Ready for implementation

---

## ✅ SECTION 1: Database Schema Changes (db_refactorist)

### File: `app/lib/core/db/app_database.dart`

---

#### ✏️ Change 1: Rename date column in CheckIns table
**Location**: Line 15  
**Search for**:
```dart
  TextColumn get date => text()(); // ISO-8601 YYYY-MM-DD
```
**Replace with**:
```dart
  TextColumn get checkInDate => text().named('check_in_date')(); // ISO-8601 YYYY-MM-DD
```

---

#### ✏️ Change 2: Update primary key reference
**Location**: Line 21  
**Search for**:
```dart
  Set<Column> get primaryKey => {date};
```
**Replace with**:
```dart
  Set<Column> get primaryKey => {checkInDate};
```

---

#### ✏️ Change 3: Update Workouts foreign key constraint
**Location**: Line 47  
**Search for**:
```dart
    'FOREIGN KEY (check_in_date) REFERENCES check_in(date) ON DELETE CASCADE',
```
**Replace with**:
```dart
    'FOREIGN KEY (check_in_date) REFERENCES check_in(check_in_date) ON DELETE CASCADE',
```

---

#### ✏️ Change 4: Update CheckInColor foreign key constraint
**Location**: Line 83  
**Search for**:
```dart
    'FOREIGN KEY (check_in_date) REFERENCES check_in(date) ON DELETE CASCADE',
```
**Replace with**:
```dart
    'FOREIGN KEY (check_in_date) REFERENCES check_in(check_in_date) ON DELETE CASCADE',
```

---

#### ✏️ Change 5: Update CheckInPhoto foreign key constraint
**Location**: Line 99  
**Search for**:
```dart
    'FOREIGN KEY (check_in_date) REFERENCES check_in(date) ON DELETE CASCADE',
```
**Replace with**:
```dart
    'FOREIGN KEY (check_in_date) REFERENCES check_in(check_in_date) ON DELETE CASCADE',
```

---

#### ✏️ Change 6: Bump schema version
**Location**: Line 118  
**Search for**:
```dart
  @override
  int get schemaVersion => 4;
```
**Replace with**:
```dart
  @override
  int get schemaVersion => 5;
```

---

#### ✏️ Change 7: Update trigger in onCreate (prevent_update_old_checkin)
**Location**: Lines 147-152  
**Search for**:
```dart
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_update_old_checkin
        BEFORE UPDATE ON check_in
        WHEN date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
```
**Replace with**:
```dart
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_update_old_checkin
        BEFORE UPDATE ON check_in
        WHEN check_in_date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
```

---

#### ✏️ Change 8: Update trigger in onCreate (prevent_delete_old_checkin)
**Location**: Lines 153-158  
**Search for**:
```dart
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_delete_old_checkin
        BEFORE DELETE ON check_in
        WHEN date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
```
**Replace with**:
```dart
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_delete_old_checkin
        BEFORE DELETE ON check_in
        WHEN check_in_date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
```

---

#### ✏️ Change 9: Add migration code block
**Location**: After line 187 (after the `if (from < 4)` block)  
**Insert this new block**:
```dart
      // Migration v4 → v5: Rename 'date' to 'check_in_date' to avoid reserved keyword
      if (from < 5) {
        await customStatement('PRAGMA foreign_keys = OFF');
        await customStatement('BEGIN TRANSACTION');
        
        // Create new table with correct column name
        await customStatement('''
          CREATE TABLE check_in_new (
            check_in_date TEXT PRIMARY KEY,
            weight        REAL,
            height        REAL,
            notes         TEXT
          )
        ''');
        
        // Copy data from old to new table
        await customStatement('''
          INSERT INTO check_in_new (check_in_date, weight, height, notes)
          SELECT date, weight, height, notes FROM check_in
        ''');
        
        // Drop old table and rename new table
        await customStatement('DROP TABLE check_in');
        await customStatement('ALTER TABLE check_in_new RENAME TO check_in');
        
        await customStatement('COMMIT');
        await customStatement('PRAGMA foreign_keys = ON');
      }
```

**⚠️ Important**: Add this AFTER the existing `if (from < 4)` block but BEFORE `await m.createAll();`

---

#### ✏️ Change 10: Update trigger in onUpgrade (prevent_update_old_checkin)
**Location**: Lines 210-215 (approximately, after first set of index creations)  
**Search for**:
```dart
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_update_old_checkin
        BEFORE UPDATE ON check_in
        WHEN date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
```
**Replace with**:
```dart
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_update_old_checkin
        BEFORE UPDATE ON check_in
        WHEN check_in_date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
```

---

#### ✏️ Change 11: Update trigger in onUpgrade (prevent_delete_old_checkin)
**Location**: Lines 216-221 (immediately after previous trigger)  
**Search for**:
```dart
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_delete_old_checkin
        BEFORE DELETE ON check_in
        WHEN date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
```
**Replace with**:
```dart
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_delete_old_checkin
        BEFORE DELETE ON check_in
        WHEN check_in_date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
```

---

#### ✏️ Change 12: Update getCheckInByDate method
**Location**: Line 275 (approximately, in the methods section)  
**Search for**:
```dart
  Future<CheckIn?> getCheckInByDate(String date) async {
    return (select(
      checkIns,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
  }
```
**Replace with**:
```dart
  Future<CheckIn?> getCheckInByDate(String checkInDate) async {
    return (select(
      checkIns,
    )..where((t) => t.checkInDate.equals(checkInDate))).getSingleOrNull();
  }
```

---

### 🔨 Build Step (db_refactorist)

After making all the above changes, run:
```bash
cd app
dart run build_runner build --delete-conflicting-outputs
```

This will regenerate `app/lib/core/db/app_database.g.dart` with the new column names.

**Expected output**: Build should succeed, and generated file should now use `checkInDate` instead of `date`.

---

## ✅ SECTION 2: Application Code Changes (platform_engg)

**⚠️ DO NOT proceed with this section until db_refactorist completes Section 1 and runs build_runner**

### File: `app/lib/screens/daily_entry_screen.dart`

---

#### ✏️ Change 13: Update check-in query
**Location**: Line 92  
**Search for**:
```dart
      )..where((tbl) => tbl.date.equals(_dateStr))).getSingleOrNull();
```
**Replace with**:
```dart
      )..where((tbl) => tbl.checkInDate.equals(_dateStr))).getSingleOrNull();
```

---

#### ✏️ Change 14: Update first check-in insert
**Location**: Around line 207  
**Search for**:
```dart
            CheckInsCompanion.insert(
              date: _dateStr,
```
**Replace with**:
```dart
            CheckInsCompanion.insert(
              checkInDate: _dateStr,
```

---

#### ✏️ Change 15: Find and update second check-in insert
**Location**: Search for second occurrence (around line 330)  
**Search for**:
```dart
            CheckInsCompanion.insert(
              date: _dateStr,
```
**Replace with**:
```dart
            CheckInsCompanion.insert(
              checkInDate: _dateStr,
```

**Note**: Use Find All (Ctrl+Shift+F) to search for `CheckInsCompanion.insert` to locate both occurrences.

---

### File: `app/lib/pages/homescreen_calendar.dart`

---

#### ✏️ Change 16: Update date field access
**Location**: Line 49  
**Search for**:
```dart
            final parts = r.date.split('-');
```
**Replace with**:
```dart
            final parts = r.checkInDate.split('-');
```

---

## ✅ SECTION 3: Verification & Testing

### Compile Check
```bash
cd app
flutter analyze
```

**Expected**: No errors related to CheckIn or date fields.

---

### Test Cases

#### Test 1: Fresh Install
1. Uninstall app completely
2. Install fresh build
3. Create a new check-in
4. Verify it saves without errors
5. Verify you can query it back
6. Check database: `check_in` table should have `check_in_date` column

#### Test 2: Migration from v4
1. Install app with schema v4 (old version)
2. Create some check-ins
3. Install new build with schema v5
4. Launch app (migration should run)
5. Verify old check-ins still visible
6. Create new check-in
7. Verify both old and new data intact

#### Test 3: Foreign Key Cascade
1. Create check-in
2. Add workout for that check-in
3. Add emotional color for that check-in
4. Add photo for that check-in
5. Delete the check-in
6. Verify workout, color, and photo are also deleted (cascade)

#### Test 4: Trigger Verification
1. Create check-in for yesterday
2. Try to edit it → should fail with "check-in is immutable by date"
3. Try to delete it → should fail with "check-in is immutable by date"
4. Create check-in for today
5. Edit it → should succeed
6. Delete it → should succeed

---

## ⚠️ Common Issues & Solutions

### Issue 1: Build fails with "Column 'date' not found"
**Solution**: Make sure you changed ALL 12 occurrences in app_database.dart before running build_runner.

### Issue 2: Runtime error "no such column: date"
**Solution**: 
- Uninstall app completely (to clear old database)
- Or bump schema version and add migration code

### Issue 3: Foreign key constraint failed
**Solution**: 
- Verify all 4 foreign key constraints reference `check_in(check_in_date)`
- Verify migration code ran successfully

### Issue 4: "CheckInsCompanion has no parameter 'checkInDate'"
**Solution**: 
- Run `dart run build_runner clean`
- Then run `dart run build_runner build --delete-conflicting-outputs`

---

## 📋 Completion Checklist

### db_refactorist:
- [ ] Changed CheckIns.date to CheckIns.checkInDate (line 15)
- [ ] Updated primary key reference (line 21)
- [ ] Updated Workouts FK constraint (line 47)
- [ ] Updated CheckInColor FK constraint (line 83)
- [ ] Updated CheckInPhoto FK constraint (line 99)
- [ ] Bumped schema version to 5 (line 118)
- [ ] Updated onCreate trigger #1 (lines 147-152)
- [ ] Updated onCreate trigger #2 (lines 153-158)
- [ ] Added v4→v5 migration block (after line 187)
- [ ] Updated onUpgrade trigger #1 (lines ~210-215)
- [ ] Updated onUpgrade trigger #2 (lines ~216-221)
- [ ] Updated getCheckInByDate method (line ~275)
- [ ] Ran build_runner successfully
- [ ] Verified app_database.g.dart uses checkInDate
- [ ] No build errors

### platform_engg:
- [ ] Updated daily_entry_screen.dart query (line 92)
- [ ] Updated daily_entry_screen.dart insert #1 (~line 207)
- [ ] Updated daily_entry_screen.dart insert #2 (~line 330)
- [ ] Updated homescreen_calendar.dart field access (line 49)
- [ ] Ran flutter analyze (no errors)
- [ ] Tested fresh install
- [ ] Tested migration from v4
- [ ] Tested foreign key cascade
- [ ] Tested trigger immutability
- [ ] All tests passed

---

## 🎯 Definition of Done

- ✅ All 16 code changes implemented
- ✅ Build succeeds without errors or warnings
- ✅ All 4 test cases pass
- ✅ No references to `.date` on CheckIn objects remain
- ✅ Schema version is 5
- ✅ Migration preserves existing data
- ✅ Foreign key constraints work correctly
- ✅ Triggers enforce immutability correctly

---

**Last Updated**: 2026-01-11  
**Implementation Time Estimate**: 45-60 minutes  
**Testing Time Estimate**: 30-45 minutes  
**Total**: ~2 hours

---
