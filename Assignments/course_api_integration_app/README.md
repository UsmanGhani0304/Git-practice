# Course API Integration App

Student: **Usman Ghani**  
Roll Number: **SE-221043**  
Branch: **feature/course-api-integration**

## Overview

This Flutter project extends the multi-screen authentication application with REST API integration and full CRUD operations for course data.

## API Used

The app uses **JSONPlaceholder**:

- Base URL: `https://jsonplaceholder.typicode.com`
- Course endpoint used: `/posts`
- Official documentation followed: <https://jsonplaceholder.typicode.com/guide>

JSONPlaceholder does not permanently store created, updated, or deleted data. The API returns successful fake responses, so the app updates the local UI after successful POST, PUT, and DELETE requests.

## Features

- Login and registration screens with form validation
- Fetch courses with GET
- Display course ID, title, and description
- Loading indicator during API requests
- Error state with retry action
- Add course with POST
- Edit course with pre-filled form and PUT request
- Delete course with confirmation dialog and DELETE request
- Separate API service layer in `lib/services/course_service.dart`

## Project Structure

```text
lib/
  main.dart
  models/
    course.dart
  screens/
    course_form_screen.dart
    course_list_screen.dart
    login_screen.dart
    register_screen.dart
  services/
    course_service.dart
```

## Screenshots

Add screenshots after running the app:

- Login screen: `screenshots/login.png`
- Course list screen: `screenshots/course-list.png`
- Add course screen: `screenshots/add-course.png`
- Edit course screen: `screenshots/edit-course.png`
- Delete confirmation: `screenshots/delete-confirmation.png`

## How to Run

```bash
flutter pub get
flutter run
```

## Submission Branch

All assignment work should be submitted from:

```bash
feature/course-api-integration
```
