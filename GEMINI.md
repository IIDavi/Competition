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
  - **Source Filtering**: Filter events by platform (JudgeRules, Competition Corner, Circle21)
- **Functionality**:
  - Event listing (Unified from 3 sources)
  - Detailed schedule/timeline for selected events (JudgeRules & Competition Corner)
  - Team tracking & favorites
  - Notifications for heat times

## Changelog

### Recent Updates
- **Event Filtering**: Added filter chips on the Home Screen to show events from specific sources ("All", "JudgeRules", "Competition Corner", "Circle21").
- **Circle21 Integration**: Added a third event source (`https://api.circle21.events/api/competition`).
  - Events are now fetched and displayed alongside JudgeRules and Competition Corner events.
  - Data mapping implemented for the specific JSON structure of Circle21.
- **Localization**: Full English translation of the UI.
- **Empty States**: Improved messages for empty timelines ("The timeline is not available yet").
- **Dark Mode**: Toggle implemented in the AppBar.

### Notes
- **Circle21**: Currently only fetches the event list. Timeline/Schedule integration for this source returns "Not available yet".
- **Competition Corner**: Participant count logic was previously reverted due to inaccuracy.