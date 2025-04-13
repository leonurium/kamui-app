# kamui_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Directory Structure
lib/
│── core/                  # Core modules (constants, helpers, etc.)
│   ├── config/            # App-wide configurations (e.g., theme, routes, env)
│   ├── errors/            # Custom error handling classes
│   ├── network/           # API services, Dio/http client, interceptors
│   ├── usecases/          # Business logic (domain layer)
│   ├── utils/             # Utility functions/helpers
│
│── data/                  # Data layer (repositories & models)
│   ├── datasources/       # API calls & local database handling
│   │   ├── remote/        # Remote APIs (Dio, GraphQL, Firebase, etc.)
│   │   ├── local/         # Local storage (Hive, SharedPreferences, SQLite)
│   ├── models/            # Data models (JSON serialization, Freezed, etc.)
│   ├── repositories/      # Repository implementations
│
│── domain/                # Domain layer (independent of Flutter)
│   ├── entities/          # Core business entities (e.g., User, Product)
│   ├── repositories/      # Abstract repository definitions
│   ├── usecases/          # Business logic use cases
│
│── presentation/          # UI layer (Widgets & BLoC)
│   ├── blocs/             # BLoC logic (one per feature)
│   │   ├── authentication/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   ├── auth_state.dart
│   │   ├── user_profile/
│   │   │   ├── profile_bloc.dart
│   │   │   ├── profile_event.dart
│   │   │   ├── profile_state.dart
│   ├── screens/           # Screens/pages grouped by features
│   │   ├── auth/          # Authentication screens (login, signup, etc.)
│   │   ├── home/          # Home screen UI
│   │   ├── settings/      # Settings page
│   ├── widgets/           # Reusable UI components (buttons, cards, etc.)
│
│── app.dart               # Root widget (MaterialApp)
│── main.dart              # Entry point
│── injection.dart         # Dependency Injection (GetIt)
│── routes.dart            # App-wide navigation routes
│── theme.dart             # Global themes


- ads should be have auto click, settings by cms
- logo app is it already fix?
- add field for flag country image
- apakah timer waktu di hilangkan di halaman home page?
- update package entities
- privacy policy
- support page
- marketing page
- user agreement
- onboarding page?

ads
- first load showing ads
- before connect showing ads
- after limit time, showing ads
- want disconnect? showing ads