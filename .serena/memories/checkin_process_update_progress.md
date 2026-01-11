Check-in process update - progress

- Branch: feature/checkin-process-update
- Commit: daef290 (feat(checkin): add camera-only photos (limit 3), NSFW toggle, emotional color picker and DB helpers)
- Files added/changed:
  - `app/lib/widget/addCheckInDialog.dart` (new): dialog UI to capture weight, height, notes, up to 3 camera photos (ImagePicker), per-photo NSFW toggle, and emotional color picker (flutter_colorpicker).
  - `app/lib/core/db/app_database.dart`: added helper methods `insertPhoto` and `insertColor` and bumped schema earlier.
  - `app/test/db/app_database_extra_test.dart` (new): tests for photo and color DB methods (skips when native sqlite not available).
- Notes: Uses `ImageSource.camera` only; limits to 3 photos on the client side. Photos are stored as file paths. iOS and Android permission entries added.
- Next steps: integrate dialog into the home/check-in flow, add UI tests & Playwright screenshots, add immutability enforcement for past check-ins (T5/T6), and add per-photo NSFW UI indicators.
