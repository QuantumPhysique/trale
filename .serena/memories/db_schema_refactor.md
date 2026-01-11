Contents of .db_schema_refactor.md:

1. check_in table: date TEXT PRIMARY KEY (YYYY-MM-DD), weight REAL, height REAL, notes TEXT
2. workout_tag table: id INTEGER PK AUTOINCREMENT, tag TEXT UNIQUE
3. workout table: check_in_date TEXT PK FK->check_in(date), description TEXT; index idx_workout_checkin
4. workout_workout_tag junction table with PK (check_in_date, workout_tag_id) and indexes
5. check_in_color table: check_in_date TEXT, ts INTEGER (Unix timestamp), color_rgb INTEGER (0xRRGGBB), message TEXT; PK (check_in_date, ts); index idx_color_date_ts
6. check_in_photo table: id INTEGER PK AUTOINCREMENT, check_in_date TEXT, file_path TEXT, ts INTEGER, fw INTEGER DEFAULT 0; index idx_photo_date

Notes: relationship overview, avoid BLOBs for photos (store paths), timestamp primary keys for check_in_color, normalized schema ready for mobile.