# Combined Flutter Assignments App

Branch: `feature/offline-cache-and-state-manangement`

This is one combined Flutter codebase for the submitted assignments. It merges the multi-screen authentication/dashboard assignment, the course CRUD API integration assignment, and the offline cache/state-management extension into a single working app.

## Tools and Packages Used

- Flutter and Dart
- `http` for API requests
- `provider` for state management
- `shared_preferences` for persistent local storage
- JSONPlaceholder posts API as the course CRUD API

## Features

- Registration with validation for required fields, email, password strength, confirm password, and gender
- Login with remembered session support
- Student dashboard with profile summary and subject cards
- Subject detail pages with description, timing, and schedule
- Course CRUD manager opened from the dashboard
- API-backed course list, create, update, and delete actions
- Offline course cache with local persistence
- Provider-managed course loading, success, error, empty, saving, and row-busy states
- Optimistic update and delete with rollback when the API fails
- Pull-to-refresh and course search/filter

## Architecture

The app is organized as one Flutter application with two main feature areas.

Authentication and dashboard:

UI -> AuthController -> SharedPreferences

Course manager:

UI -> Provider state management -> Repository -> API service -> Local database

- UI screens only render state and forward user events.
- `AuthController` handles registration, login, logout, remembered sessions, and stored user data.
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

- `screenshots/registration.svg`
- `screenshots/auth-login.svg`
- `screenshots/dashboard.svg`
- `screenshots/detail.svg`
- `screenshots/login.png`
- `screenshots/course-list.png`
- `screenshots/add-course.png`
- `screenshots/edit-course.png`
- `screenshots/delete-confirmation.png`

The current environment does not have the Flutter SDK on PATH, so screenshots were carried forward from the completed ZIP submissions.

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
