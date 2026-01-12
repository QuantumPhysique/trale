# Trale+ Architecture Foundation

## Core Principles
1. **Privacy-First**: All data local, no cloud by default
2. **Lightweight**: Minimal dependencies, efficient storage
3. **Immutable Data**: Entries cannot be edited once saved (audit trail)
4. **Future-Ready**: Architected for server sync, health integration, on-device AI

## Target Environment
- **Android**: API 31+ (Android 12+), android-arm64 only
- **iOS**: iOS 16+ (future)
- **ML/AI**: Google ML Kit, sqlite-vss for vector search

## Data Architecture

### Current: SQLite (sqflite)
- Lightweight, mature, excellent performance
- Vector extension available (sqlite-vss) for future AI features
- JSON column support for nested data structures

### Daily Entry Structure (Immutable after save)
```dart
class DailyEntry {
  final DateTime date;              // Primary key: YYYY-MM-DD
  final double? weight;
  final double? height;
  final List<String> photoPaths;
  final String? workoutText;
  final List<String> workoutTags;
  final String? thoughts;
  final List<EmotionalCheckIn> emotionalCheckIns;  // NEW: Array of check-ins
  final DateTime timestamp;         // When entry was created/last modified
}
```

### Emotional Check-In Structure (NEW)
```dart
class EmotionalCheckIn {
  final DateTime timestamp;        // Exact moment of check-in
  final List<String> emotions;     // 4 emojis from 8 options
  final String text;               // Max 500 characters
  
  // Stored as JSON array in daily_entries.emotional_checkins column
}
```

**Key Properties:**
- Multiple emotional check-ins per day
- Each check-in is immutable
- Bundled with daily entry (not separate table)
- User can add unlimited check-ins throughout the day
- Stored as JSON array in SQLite for efficiency

### Available Emotions (8 options, select any 4)
```dart
const EMOTIONS = {
  '😠': 'Anger',
  '😨': 'Fear',
  '😣': 'Pain',
  '😔': 'Shame',
  '😞': 'Guilt',
  '😊': 'Joy',
  '💪': 'Strength',
  '❤️': 'Love',
};
```

## Database Schema Changes

### Migration Plan
```sql
-- Current schema (v1) has:
-- emotions TEXT (JSON array of emoji strings)

-- New schema (v2) will have:
-- emotional_checkins TEXT (JSON array of objects)

-- Example stored data:
-- emotional_checkins: '[
--   {"timestamp":"2026-01-05T09:30:00.000Z","emotions":["😊","💪","❤️"],"text":"Great morning workout!"},
--   {"timestamp":"2026-01-05T14:15:00.000Z","emotions":["😨","😣"],"text":"Stressful meeting at work"}
-- ]'
```

### Future: Vector Extension (v3+)
```sql
-- Add vector columns for AI/semantic search
ALTER TABLE daily_entries ADD COLUMN thoughts_vector BLOB;
ALTER TABLE daily_entries ADD COLUMN emotional_summary_vector BLOB;

-- Create virtual table for vector search
CREATE VIRTUAL TABLE entry_vectors USING vss0(
  date TEXT,
  content_vector(768)  -- Embedding dimension
);
```

## UI/UX Flow

### Daily Entry Screen
**Current Behavior:** Single save updates entire entry
**New Behavior:** 
1. All fields editable until first save (weight, height, photos, workout, thoughts)
2. After first save, entry becomes immutable EXCEPT emotional check-ins
3. Emotional check-in section resets after each save
4. User can add unlimited emotional check-ins throughout the day
5. All emotional check-ins visible in expanded view

### Emotional Check-In Section
```
┌─────────────────────────────────────┐
│ 💭 Emotional Check-In               │
│ ─────────────────────────────────── │
│ [Time: 2:30 PM]                     │
│                                      │
│ Select up to 4 emotions:            │
│ [😠] [😨] [😣] [😔] [😞] [😊] [💪] [❤️] │
│                                      │
│ How are you feeling right now?      │
│ ┌───────────────────────────────┐  │
│ │ [Text input, 500 char max]    │  │
│ │                               │  │
│ └───────────────────────────────┘  │
│                                      │
│            [Save Check-In]          │
│                                      │
│ Previous check-ins today:           │
│ • 9:30 AM - 😊💪❤️ "Great workout!" │
│ • 2:30 PM - 😨😣 "Stressful..."     │
└─────────────────────────────────────┘
```

## Performance Considerations

### For Future Server Sync
- **Background Queue**: Local queue for pending sync operations
- **Incremental Sync**: Only changed entries since last sync
- **Conflict Resolution**: Last-write-wins (timestamp-based)
- **Offline-First**: All operations local, sync is background task
- **Compression**: gzip JSON payloads for network transfer

**Architecture Pattern:**
```dart
abstract class SyncService {
  Future<void> queueForSync(DailyEntry entry);
  Future<void> performSync();  // Called daily
  Stream<SyncStatus> get syncStatus;
}
```

### For Future Health Integration
- **Platform Abstraction**: Interface for Android/iOS health APIs
- **Data Fetching**: Periodic background fetch (daily)
- **Context Only**: Health data for LLM, not displayed in UI
- **Storage**: Separate table for health snapshots

**Architecture Pattern:**
```dart
abstract class HealthDataProvider {
  Future<HealthSnapshot> fetchDailyHealth(DateTime date);
  Stream<HealthSnapshot> get realtimeHealth;
}

class HealthSnapshot {
  final DateTime date;
  final int? steps;
  final double? activeMinutes;
  final double? heartRateAvg;
  final double? sleepHours;
  // ... all available metrics
}
```

### For Future LLM Integration
- **On-Device Only**: No cloud AI services
- **Model**: Small quantized model (<500MB)
- **Vector Storage**: sqlite-vss extension
- **Embeddings**: Cached, regenerated on data change
- **Query Types**: Semantic search, pattern detection, insights

**Architecture Pattern:**
```dart
abstract class AIService {
  Future<void> indexEntries(List<DailyEntry> entries);
  Future<List<DailyEntry>> semanticSearch(String query);
  Future<String> generateInsight(String question);
  Future<List<String>> detectPatterns();
}
```

## Implementation Priority

### Phase 1: Foundation (Current Sprint)
1. ✅ Update minSdkVersion to 31 (Android 12)
2. ✅ Update build targets to android-arm64 only
3. ✅ Migrate database schema for emotional check-ins
4. ✅ Update DailyEntry model with EmotionalCheckIn class
5. ✅ Implement immutable entry logic
6. ✅ Update UI for multiple emotional check-ins
7. ✅ Add 500-char limit and validation

### Phase 2: Health Integration
1. Add Google Health Connect dependency
2. Create HealthDataProvider interface
3. Implement Android Health Connect adapter
4. Create health_snapshots table
5. Background health data sync

### Phase 3: Server Sync
1. Create SyncService interface
2. Implement local sync queue
3. Add encryption layer
4. Implement daily sync scheduler
5. Settings UI for server configuration

### Phase 4: AI/LLM Features
1. Add sqlite-vss dependency
2. Implement embedding generation (ML Kit)
3. Create AIService interface
4. Vector indexing pipeline
5. Chat UI for introspection
6. Pattern detection algorithms

## Migration Strategy

### From Current (v1) to New (v2)
```dart
// Old: emotions field contains selected emojis for the day
// emotions TEXT: '["😊","💪","❤️"]'

// New: emotional_checkins contains timestamped check-ins
// emotional_checkins TEXT: '[{"timestamp":"...","emotions":["😊","💪"],"text":"..."}]'

// Migration:
// If old emotions field exists and not empty:
//   - Create single emotional check-in
//   - Timestamp: Use entry's timestamp (or noon of that day)
//   - Emotions: Copy from old field
//   - Text: Empty string
// Drop emotions field
```

### No Existing Users Impact
- This is internal alpha, no migration needed for external users
- Can safely break compatibility if needed
- Focus on getting architecture right now

## Technical Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Database | SQLite (sqflite) | Lightweight, vector extension available, mature |
| Data Model | Daily entry + embedded emotional check-ins | Simpler queries, natural grouping, efficient |
| Immutability | After first save | Audit trail, sync simplification |
| Emotional Storage | JSON array in column | Flexible, efficient, no separate table needed |
| Vector Search | sqlite-vss (future) | Lightweight, no separate DB, good performance |
| Health Data | Platform APIs (future) | Native, most accurate, privacy-compliant |
| Server Sync | Daily background (future) | Balances freshness and battery life |
| LLM | On-device only (future) | Privacy-first, no network dependency |

## Open Questions / Future Considerations

1. **Entry Editing**: Currently entries become immutable. What if user wants to correct a typo?
   - Option A: Allow edit window (24 hours?)
   - Option B: "Correction" entries that supersede
   - Option C: Strict immutability

2. **Photo Storage**: With health data and vectors, storage will grow
   - Option: Configurable photo quality/size
   - Option: Archive old photos to server

3. **LLM Model Selection**: Which on-device model?
   - Google Gemini Nano (best integration with ML Kit)
   - Llama 3.2 1B (more open)
   - Phi-3 Mini (Microsoft, good performance)

4. **Health Data Privacy**: Should health data be separately encrypted?
   - More sensitive than weight/exercise logs
   - Consider separate encryption key

## Success Metrics (Internal Alpha)

- **Performance**: Entry creation <100ms
- **Storage**: <10MB per 365 days (excluding photos)
- **Battery**: <1% daily battery impact
- **Stability**: Zero crashes in 30-day dogfooding
- **UX**: <3 taps to create emotional check-in

---

**Version**: 2.0.0-alpha  
**Last Updated**: 2026-01-05  
**Status**: Foundation phase - implementing Phase 1
