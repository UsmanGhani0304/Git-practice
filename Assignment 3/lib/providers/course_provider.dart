import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

enum CourseViewStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class CourseProvider extends ChangeNotifier {
  CourseProvider(this._repository);

  final CourseRepository _repository;

  CourseViewStatus _status = CourseViewStatus.initial;
  List<Course> _courses = [];
  String _searchQuery = '';
  String? _errorMessage;
  int? _busyCourseId;
  bool _isSaving = false;

  CourseViewStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int? get busyCourseId => _busyCourseId;
  bool get isSaving => _isSaving;
  String get searchQuery => _searchQuery;

  List<Course> get courses {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_courses);
    }

    final normalizedQuery = _searchQuery.toLowerCase().trim();
    return _courses.where((course) {
      return course.title.toLowerCase().contains(normalizedQuery) ||
          course.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  bool get hasCachedData => _courses.isNotEmpty;

  Future<void> loadCourses({bool forceRemote = false}) async {
    _status = _courses.isEmpty ? CourseViewStatus.loading : CourseViewStatus.success;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _repository.getCourses(forceRemote: forceRemote);
      _status = _courses.isEmpty ? CourseViewStatus.empty : CourseViewStatus.success;
    } catch (error) {
      _errorMessage = error.toString();
      _status = _courses.isEmpty ? CourseViewStatus.error : CourseViewStatus.success;
    }

    notifyListeners();
  }

  Future<String> addCourse({
    required String title,
    required String description,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final createdCourse = await _repository.addCourse(
        title: title,
        description: description,
      );
      _courses = [createdCourse, ..._courses];
      _status = CourseViewStatus.success;
      return createdCourse.id < 0
          ? 'Course saved offline and will sync later'
          : 'Course added successfully';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String> updateCourse(Course updatedCourse) async {
    final previousCourses = List<Course>.from(_courses);
    _busyCourseId = updatedCourse.id;
    _courses = _courses
        .map((course) => course.id == updatedCourse.id ? updatedCourse : course)
        .toList();
    notifyListeners();

    try {
      await _repository.updateCourse(updatedCourse);
      return 'Course updated successfully';
    } catch (error) {
      _courses = previousCourses;
      return 'Update failed. Changes were rolled back.';
    } finally {
      _busyCourseId = null;
      notifyListeners();
    }
  }

  Future<String> deleteCourse(Course course) async {
    final previousCourses = List<Course>.from(_courses);
    _busyCourseId = course.id;
    _courses = _courses.where((item) => item.id != course.id).toList();
    _status = _courses.isEmpty ? CourseViewStatus.empty : CourseViewStatus.success;
    notifyListeners();

    try {
      await _repository.deleteCourse(course);
      return 'Course deleted successfully';
    } catch (error) {
      _courses = previousCourses;
      _status = CourseViewStatus.success;
      return 'Delete failed. Course was restored.';
    } finally {
      _busyCourseId = null;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
