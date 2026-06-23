import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/course_local_database.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/login_screen.dart';
import 'services/course_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final repository = CourseRepository(
    apiService: CourseApiService(),
    localDatabase: CourseLocalDatabase(preferences),
  );

  runApp(CourseCrudApp(repository: repository));
}

class CourseCrudApp extends StatelessWidget {
  const CourseCrudApp({super.key, required this.repository});

  final CourseRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseProvider(repository),
      child: MaterialApp(
        title: 'Course API Integration',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
