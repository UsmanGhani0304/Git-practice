import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import 'course_form_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddCourse() async {
    final result = await Navigator.of(context).push<CourseFormResult>(
      MaterialPageRoute(builder: (_) => const CourseFormScreen()),
    );

    if (!mounted || result == null) {
      return;
    }

    final message = await context.read<CourseProvider>().addCourse(
          title: result.title,
          description: result.description,
        );
    _showMessage(message);
  }

  Future<void> _openEditCourse(Course course) async {
    final result = await Navigator.of(context).push<CourseFormResult>(
      MaterialPageRoute(builder: (_) => CourseFormScreen(course: course)),
    );

    if (!mounted || result == null) {
      return;
    }

    final message = await context.read<CourseProvider>().updateCourse(
          course.copyWith(
            title: result.title,
            description: result.description,
          ),
        );
    _showMessage(message);
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

    if (!mounted || shouldDelete != true) {
      return;
    }

    final message = await context.read<CourseProvider>().deleteCourse(course);
    _showMessage(message);
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Courses'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: provider.status == CourseViewStatus.loading
                    ? null
                    : () => provider.loadCourses(forceRemote: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.isSaving ? null : _openAddCourse,
            icon: provider.isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: const Text('Add Course'),
          ),
          body: SafeArea(child: _buildBody(provider)),
        );
      },
    );
  }

  Widget _buildBody(CourseProvider provider) {
    if (provider.status == CourseViewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == CourseViewStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage ?? 'Unable to load courses.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => provider.loadCourses(forceRemote: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCourses(forceRemote: true),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                onChanged: provider.updateSearchQuery,
                decoration: InputDecoration(
                  labelText: 'Search courses',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: provider.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            provider.updateSearchQuery('');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
          ),
          if (provider.courses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_outlined, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        provider.hasCachedData
                            ? 'No courses match your search'
                            : 'No courses available',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) {
                      return const SizedBox(height: 12);
                    }

                    final course = provider.courses[index ~/ 2];
                    final isBusy = provider.busyCourseId == course.id;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(course.title),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child:
                              Text('ID: ${course.id}\n${course.description}'),
                        ),
                        isThreeLine: true,
                        trailing: isBusy
                            ? const SizedBox.square(
                                dimension: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
                  childCount: provider.courses.length * 2 - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
