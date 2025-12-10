# Project Status

## Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **Target Platform**: Linux (Desktop)
- **Auth**: Firebase Auth + Google Sign-In
- **Routing**: GoRouter

## Features
- **Event Sources**:
  - JudgeRules API
  - Competition Corner API (Schedule & Workouts)
  - Circle21 API (Events Listing)
- **UI/UX**:
  - Material Design with Dark/Light mode support
  - English Localization
  - Responsive Timeline view
  - **Source Filtering**: Filter events by platform (JudgeRules, Competition Corner, Circle21)
- **Authentication**:
  - Google Sign-In Integration
  - Login Screen
  - Protected Admin Route
- **Management**:
  - Admin Dashboard (Restricted access)

## Changelog

### Authentication & Management Update
- **Authentication System**: Integrated `firebase_auth` and `google_sign_in`.
  - Added `AuthService` to manage user sessions.
  - Added `LoginScreen` with Google Sign-In button.
- **Management Panel**: Created a restricted `AdminScreen` (`/admin`) for management tasks.
- **Routing**: Migrated navigation to `GoRouter`.
  - Implemented `AuthGuard` to protect the `/admin` route (redirects to `/login` if not authenticated).
- **Infrastructure**: Added `firebase_options.dart` (requires configuration) and updated `pubspec.yaml`.
- **UI Updates**: Added Login/Admin button to the Home Screen AppBar.

### Recent Updates
- **API Reliability**: Implemented a fallback mechanism for JudgeRules API.
- **API Fix**: Modified HTTP headers for JudgeRules API requests.
- **Dark Mode Fix**: Improved text visibility on the Timeline screen.
- **Circle21 Update**: Corrected the API endpoint.
- **Event Filtering**: Added filter chips on the Home Screen.
- **Circle21 Integration**: Added a third event source.

### Notes
- **Configuration Required**: You must update `lib/firebase_options.dart` with your actual Firebase Project keys for authentication to work.
- **Admin Access**: Currently, the admin check is a placeholder (`email == 'admin@example.com'`). Update `AuthService.dart` to match your Google email address for admin access.