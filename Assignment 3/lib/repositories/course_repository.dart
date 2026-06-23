import '../data/course_local_database.dart';
import '../models/course.dart';
import '../models/pending_course_operation.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  CourseRepository({
    required CourseApiService apiService,
    required CourseLocalDatabase localDatabase,
  })  : _apiService = apiService,
        _localDatabase = localDatabase;

  final CourseApiService _apiService;
  final CourseLocalDatabase _localDatabase;

  Future<List<Course>> getCourses({bool forceRemote = false}) async {
    final cachedCourses = await _localDatabase.getCourses();

    if (!forceRemote && cachedCourses.isNotEmpty) {
      unawaitedSyncPendingOperations();
      return cachedCourses;
    }

    try {
      await syncPendingOperations();
      final remoteCourses = await _apiService.fetchCourses();
      await _localDatabase.saveCourses(remoteCourses);
      return remoteCourses;
    } catch (_) {
      if (cachedCourses.isNotEmpty) {
        return cachedCourses;
      }
      rethrow;
    }
  }

  Future<Course> addCourse({
    required String title,
    required String description,
  }) async {
    final localCourse = Course(
      id: await _localDatabase.nextLocalId(),
      title: title,
      description: description,
    );

    try {
      final createdCourse = await _apiService.addCourse(localCourse);
      await _upsertLocalCourse(createdCourse);
      return createdCourse;
    } catch (_) {
      await _upsertLocalCourse(localCourse);
      await _localDatabase.addPendingOperation(
        PendingCourseOperation(
          type: CourseOperationType.create,
          course: localCourse,
        ),
      );
      return localCourse;
    }
  }

  Future<void> updateCourse(Course course) async {
    final previousCourses = await _localDatabase.getCourses();
    await _upsertLocalCourse(course);

    try {
      await _apiService.updateCourse(course);
    } catch (_) {
      await _localDatabase.saveCourses(previousCourses);
      rethrow;
    }
  }

  Future<void> deleteCourse(Course course) async {
    final previousCourses = await _localDatabase.getCourses();
    await _localDatabase.saveCourses(
      previousCourses.where((item) => item.id != course.id).toList(),
    );

    try {
      await _apiService.deleteCourse(course.id);
    } catch (_) {
      await _localDatabase.saveCourses(previousCourses);
      rethrow;
    }
  }

  Future<void> syncPendingOperations() async {
    final operations = await _localDatabase.getPendingOperations();

    if (operations.isEmpty) {
      return;
    }

    final remainingOperations = <PendingCourseOperation>[];

    for (final operation in operations) {
      try {
        switch (operation.type) {
          case CourseOperationType.create:
            final createdCourse = await _apiService.addCourse(operation.course);
            await _replaceLocalCourse(operation.course.id, createdCourse);
            break;
          case CourseOperationType.update:
            await _apiService.updateCourse(operation.course);
            break;
          case CourseOperationType.delete:
            await _apiService.deleteCourse(operation.course.id);
            break;
        }
      } catch (_) {
        remainingOperations.add(operation);
      }
    }

    await _localDatabase.savePendingOperations(remainingOperations);
  }

  void unawaitedSyncPendingOperations() {
    syncPendingOperations();
  }

  Future<void> _upsertLocalCourse(Course course) async {
    final courses = await _localDatabase.getCourses();
    final index = courses.indexWhere((item) => item.id == course.id);

    if (index == -1) {
      await _localDatabase.saveCourses([course, ...courses]);
      return;
    }

    courses[index] = course;
    await _localDatabase.saveCourses(courses);
  }

  Future<void> _replaceLocalCourse(int localId, Course remoteCourse) async {
    final courses = await _localDatabase.getCourses();
    await _localDatabase.saveCourses(
      courses
          .map((course) => course.id == localId ? remoteCourse : course)
          .toList(),
    );
  }
}
