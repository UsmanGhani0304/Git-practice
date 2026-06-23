# Course API Integration App

Branch: `feature/offline-cache-and-state-manangement`

This Flutter project extends the previous CRUD API assignment with offline cache support, Provider state management, repository pattern architecture, optimistic UI updates, pull-to-refresh, search, loading, error, and empty states.

## Tools and Packages Used

- Flutter and Dart
- `http` for API requests
- `provider` for state management
- `shared_preferences` for persistent local storage
- JSONPlaceholder posts API as the course CRUD API

## Architecture

The app follows this structure:

UI -> Provider state management -> Repository -> API service -> Local database

- UI screens only render state and forward user events.
- `CourseProvider` manages loading, success, error, empty, saving, busy row, and search state.
- `CourseRepository` decides whether to use remote API data or cached local data.
- `CourseApiService` only performs HTTP requests.
- `CourseLocalDatabase` stores cached courses and pending offline create operations in SharedPreferences.

## Offline and State Management Approach

After a successful fetch, courses are saved locally. On the next launch, cached data is loaded immediately when available, and the repository attempts background synchronization. If the API is unavailable and cached data exists, the app continues to work from local storage.

Provider replaces list-screen `setState` for course business state. The form screens still use local controllers for field input, while course loading and CRUD behavior live in `CourseProvider`.

Create requests are saved locally when the network is unavailable and queued for later sync. Update and delete use optimistic UI updates: the UI changes immediately, then rolls back if the API call fails.

## Screenshots

Included screenshot files:

- `screenshots/login.png`
- `screenshots/course-list.png`
- `screenshots/add-course.png`
- `screenshots/edit-course.png`
- `screenshots/delete-confirmation.png`

The current environment does not have the Flutter SDK on PATH, so the screenshots were carried forward from the previous completed CRUD assignment.

## Run

```bash
flutter pub get
flutter run
```

## Verification

Run these commands before submitting from a machine with Flutter installed:

```bash
flutter pub get
flutter analyze
flutter test
```
