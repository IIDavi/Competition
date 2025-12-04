# Project Status

## Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **Target Platform**: Linux (Desktop)

## Features
- **Event Sources**:
  - JudgeRules API
  - Competition Corner API (Schedule & Workouts)
  - Circle21 API (Events Listing)
- **UI/UX**:
  - Material Design with Dark/Light mode support
  - English Localization
  - Responsive Timeline view
- **Functionality**:
  - Event listing (Unified from 3 sources)
  - Detailed schedule/timeline for selected events (JudgeRules & Competition Corner)
  - Team tracking & favorites
  - Notifications for heat times

## Changelog

### Recent Updates
- **Circle21 Integration**: Added a third event source (`https://api.circle21.events/api/competition`).
  - Events are now fetched and displayed alongside JudgeRules and Competition Corner events.
  - Data mapping implemented for the specific JSON structure of Circle21.
- **Localization**: Full English translation of the UI.
- **Empty States**: Improved messages for empty timelines ("The timeline is not available yet").
- **Dark Mode**: Toggle implemented in the AppBar.

### Notes
- **Circle21**: Currently only fetches the event list. Timeline/Schedule integration for this source returns "Not available yet".
- **Competition Corner**: Participant count logic was previously reverted due to inaccuracy.