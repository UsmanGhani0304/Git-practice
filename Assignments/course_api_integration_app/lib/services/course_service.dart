import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';

class CourseService {
  CourseService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client;

  Future<List<Course>> fetchCourses() async {
    final response = await _client.get(Uri.parse('$_baseUrl/posts'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch courses. Please try again.');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .take(20)
        .toList();
  }

  Future<Course> addCourse({
    required String title,
    required String description,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'title': title,
        'body': description,
        'userId': 1,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add course. Please try again.');
    }

    return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Course> updateCourse(Course course) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/posts/${course.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update course. Please try again.');
    }

    return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteCourse(int id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/posts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete course. Please try again.');
    }
  }
}
