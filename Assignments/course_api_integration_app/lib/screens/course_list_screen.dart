import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/course_service.dart';
import 'course_form_screen.dart';
import 'login_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CourseService _courseService = CourseService();

  List<Course> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _busyCourseId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courses = await _courseService.fetchCourses();
      setState(() => _courses = courses);
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openAddCourse() async {
    final result = await Navigator.of(context).push<CourseFormResult>(
      MaterialPageRoute(builder: (_) => const CourseFormScreen()),
    );

    if (result == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final createdCourse = await _courseService.addCourse(
        title: result.title,
        description: result.description,
      );

      setState(() => _courses = [createdCourse, ..._courses]);
      _showMessage('Course added successfully');
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openEditCourse(Course course) async {
    final result = await Navigator.of(context).push<CourseFormResult>(
      MaterialPageRoute(builder: (_) => CourseFormScreen(course: course)),
    );

    if (result == null) {
      return;
    }

    setState(() => _busyCourseId = course.id);
    try {
      final updatedCourse = await _courseService.updateCourse(
        course.copyWith(
          title: result.title,
          description: result.description,
        ),
      );

      setState(() {
        _courses = _courses
            .map((item) => item.id == updatedCourse.id ? updatedCourse : item)
            .toList();
      });
      _showMessage('Course updated successfully');
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _busyCourseId = null);
      }
    }
  }

  Future<void> _confirmDelete(Course course) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() => _busyCourseId = course.id);
    try {
      await _courseService.deleteCourse(course.id);
      setState(() {
        _courses = _courses.where((item) => item.id != course.id).toList();
      });
      _showMessage('Course deleted successfully');
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _busyCourseId = null);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _fetchCourses,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _openAddCourse,
        icon: _isSaving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchCourses,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_courses.isEmpty) {
      return const Center(child: Text('No courses available'));
    }

    return RefreshIndicator(
      onRefresh: _fetchCourses,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final course = _courses[index];
          final isBusy = _busyCourseId == course.id;

          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(course.title),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('ID: ${course.id}\n${course.description}'),
              ),
              isThreeLine: true,
              trailing: isBusy
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditCourse(course);
                        } else if (value == 'delete') {
                          _confirmDelete(course);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
