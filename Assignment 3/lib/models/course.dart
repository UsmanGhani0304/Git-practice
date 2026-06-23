class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.userId = 1,
  });

  final int id;
  final String title;
  final String description;
  final int userId;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['body'] as String? ?? '',
      userId: json['userId'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': description,
      'userId': userId,
    };
  }

  Course copyWith({
    int? id,
    String? title,
    String? description,
    int? userId,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }
}
