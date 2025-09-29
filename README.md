# Harvestor Flutter App

Flutter + Firebase app for Harvester monitoring.

## Setup

1. Install Flutter SDK and Dart.
2. From project root, run:
   - `flutter pub get`
   - `flutter run`
3. Firebase is initialized inline in `lib/main.dart` with your provided config.
4. Ensure RTDB paths exist (e.g., `live/HARV-001`) or use the Cloud Function ingest pipeline.

## Screens
- Dashboard: live tank %, bales, PTO RPM gauge, suction pressure state, alerts.
- Reports: placeholder charts (wire to aggregates).
- History: placeholder list (wire to daily aggregates).
- Settings: profile fields, set `deviceId`.

## Notes
- Replace `deviceId` in Settings with your actual device.
- For push notifications and secure ingest, set up Cloud Functions and FCM.
