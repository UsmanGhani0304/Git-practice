import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth_controller.dart';
import 'data/course_local_database.dart';
import 'models/app_user.dart';
import 'models/subject.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/course_list_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'services/course_api_service.dart';
import 'utils/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final authController = AuthController();
  await authController.loadRememberedSession();
  final repository = CourseRepository(
    apiService: CourseApiService(),
    localDatabase: CourseLocalDatabase(preferences),
  );

  runApp(
    CourseCrudApp(
      authController: authController,
      repository: repository,
    ),
  );
}

class CourseCrudApp extends StatelessWidget {
  const CourseCrudApp({
    super.key,
    required this.authController,
    required this.repository,
  });

  final AuthController authController;
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
        home: authController.isRemembered
            ? DashboardScreen(authController: authController)
            : RegistrationScreen(authController: authController),
        routes: {
          AppRoutes.registration: (_) =>
              RegistrationScreen(authController: authController),
          AppRoutes.login: (_) => LoginScreen(authController: authController),
          AppRoutes.courses: (_) => const CourseListScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.detail) {
            final subject = settings.arguments as Subject;
            return MaterialPageRoute<void>(
              builder: (_) => DetailScreen(subject: subject),
            );
          }

          if (settings.name == AppRoutes.dashboard) {
            final user = settings.arguments is AppUser
                ? settings.arguments as AppUser
                : null;
            return MaterialPageRoute<void>(
              builder: (_) => DashboardScreen(
                authController: authController,
                user: user,
              ),
            );
          }

          return null;
        },
      ),
    );
  }
}
