import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/course.dart';
import '../models/pending_course_operation.dart';

class CourseLocalDatabase {
  CourseLocalDatabase(this._preferences);

  static const String _coursesKey = 'cached_courses';
  static const String _pendingOperationsKey = 'pending_course_operations';
  static const String _nextLocalIdKey = 'next_local_course_id';

  final SharedPreferences _preferences;

  Future<List<Course>> getCourses() async {
    final rawCourses = _preferences.getStringList(_coursesKey) ?? [];

    return rawCourses
        .map((rawCourse) => Course.fromJson(jsonDecode(rawCourse)))
        .toList();
  }

  Future<void> saveCourses(List<Course> courses) async {
    final rawCourses = courses
        .map((course) => jsonEncode(course.toJson()))
        .toList(growable: false);

    await _preferences.setStringList(_coursesKey, rawCourses);
  }

  Future<int> nextLocalId() async {
    final nextId = _preferences.getInt(_nextLocalIdKey) ?? -1;
    await _preferences.setInt(_nextLocalIdKey, nextId - 1);
    return nextId;
  }

  Future<List<PendingCourseOperation>> getPendingOperations() async {
    final rawOperations =
        _preferences.getStringList(_pendingOperationsKey) ?? [];

    return rawOperations
        .map(
          (rawOperation) => PendingCourseOperation.fromJson(
            jsonDecode(rawOperation) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> addPendingOperation(PendingCourseOperation operation) async {
    final operations = await getPendingOperations();
    operations.add(operation);
    await savePendingOperations(operations);
  }

  Future<void> savePendingOperations(
    List<PendingCourseOperation> operations,
  ) async {
    final rawOperations = operations
        .map((operation) => jsonEncode(operation.toJson()))
        .toList(growable: false);

    await _preferences.setStringList(_pendingOperationsKey, rawOperations);
  }
}
