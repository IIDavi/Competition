# Project Status

## Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **Target Platform**: Linux (Desktop)

## Features
- **Event Sources**:
  - JudgeRules API
  - Competition Corner API (Schedule & Workouts)
- **UI/UX**:
  - Material Design with Dark/Light mode support
  - English Localization
  - Responsive Timeline view
- **Functionality**:
  - Event listing
  - Detailed schedule/timeline for selected events
  - Team tracking & favorites
  - Notifications for heat times

## Changelog

### Reverted Changes (Latest)
- **Participant Count**: Reverted the automatic participant counting feature for Competition Corner events due to inaccuracy. The app now displays 0 or the default API value for subscribers on CC events.

### Recent Updates
- **Localization**: Full English translation of the UI.
- **Empty States**: Improved messages for empty timelines ("The timeline is not available yet").
- **Dark Mode**: Toggle implemented in the AppBar.
