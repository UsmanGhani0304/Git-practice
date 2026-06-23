import 'course.dart';

enum CourseOperationType {
  create,
  update,
  delete,
}

class PendingCourseOperation {
  const PendingCourseOperation({
    required this.type,
    required this.course,
  });

  final CourseOperationType type;
  final Course course;

  factory PendingCourseOperation.fromJson(Map<String, dynamic> json) {
    return PendingCourseOperation(
      type: CourseOperationType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => CourseOperationType.update,
      ),
      course: Course.fromJson(json['course'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'course': course.toJson(),
    };
  }
}
