# Event Countdown App

A mobile application to track and display countdowns to upcoming events, built with Flutter and following Clean Architecture principles.

## Project Overview

The Event Countdown app allows users to create countdown timers for their important events (e.g., birthdays, meetings, deadlines). Users can add events, set timers, and receive push notifications as the event date approaches. The app features an intuitive UI for managing multiple events and displays live countdowns.

## Architecture

This project implements Clean Architecture (without the domain layer) with a focus on maintainability and testability:

```
lib/
├── core/             # Core functionality, constants, and shared components
├── data/             # Data layer (models, repositories, data sources)
└── presentation/     # UI layer (pages, widgets, and state management)
```

### Key Components

- **Data Layer**
  - Models: Represent the data structures used in the app
  - Repositories: Provide a clean API for data operations
  - Data Sources: Handle data persistence and external services

- **Presentation Layer**
  - Cubit: Manages state for the UI components
  - Pages: Full screens in the application
  - Widgets: Reusable UI components

- **Core**
  - Constants: App-wide constants like colors, themes, and strings
  - Utils: Helper functions and utilities
  - Widgets: Shared UI components used across the app

## Features

- Create, edit, and delete countdown events
- Live countdown timers for each event
- Customizable notifications and reminders
- Light/dark theme support
- Event categorization with icons

## Dependencies

- [flutter_bloc](https://pub.dev/packages/flutter_bloc): State management
- [get_it](https://pub.dev/packages/get_it): Dependency injection
- [sqflite](https://pub.dev/packages/sqflite): Local database storage
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications): Push notifications
- [intl](https://pub.dev/packages/intl): Internationalization and formatting

## Setup and Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/event_countdown_app.git
   ```

2. Navigate to the project directory:
   ```
   cd event_countdown_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Development Timeline

### Week 1: Setup and UI Design
- Set up the development environment
- Create wireframes
- Implement basic UI

### Week 2: Event Management and Countdown Logic
- Implement event creation functionality
- Develop countdown timers
- Test core functionality

### Week 3: Notifications and Reminders
- Set up push notifications
- Implement customizable reminders
- Test notification system

### Week 4: Final Testing and Deployment
- Conduct final testing
- Optimize app performance
- Complete documentation

## Testing

Run the tests with:
```
flutter test
```

## Contributors

- [yourusername](https://github.com/yourusername)


## License

This project is licensed under the MIT License - see the LICENSE file for details.
