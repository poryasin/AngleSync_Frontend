import 'package:flutter/cupertino.dart';
import 'package:anglesync/src/features/navigation/presentation/main_shell.dart';
import 'package:anglesync/src/features/scan/presentation/scan_screen.dart';
import 'package:anglesync/src/features/scan/domain/exercise_detail.dart';
import 'package:anglesync/src/features/scan/presentation/upload_screen.dart';
import 'package:anglesync/src/features/admin/presentation/admin_dashboard.dart';
import 'package:anglesync/src/features/auth/presentation/auth_wrapper.dart';
import 'package:anglesync/src/features/auth/presentation/login_screen.dart';
import 'package:anglesync/src/features/auth/presentation/gender_selection_screen.dart';
import 'package:anglesync/src/features/auth/presentation/splash_screen.dart';

class AppRouter {
  static const String root = '/';
  static const String home = '/';
  static const String splash = '/splash';   // ⬅️ เพิ่มใหม่
  static const String login = '/login';
  static const String genderSelection = '/gender-selection';
  static const String scan = '/scan';
  static const String history = '/history';
  static const String upload = '/upload';
  static const String adminDashboard = '/admin-dashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = buildPage(settings.name ?? root, settings.arguments);

    switch (settings.name) {
      case scan:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
        );

      default:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => page,
        );
    }
  }

  static Widget buildPage(String routeName, Object? arguments) {
    switch (routeName) {
      case root:
        return const MainShell();   // ⬅️ เปลี่ยนจาก AuthWrapper() เป็น MainShell() ตรงๆ

      case splash:
        return const SplashScreen();   // ⬅️ เพิ่มใหม่

      case login:
        return const LoginScreen();

      case genderSelection:
        return const GenderSelectionScreen();

      case scan:
        return const ScanScreen();

      case history:
        return const MainShell(initialIndex: 2);

      case upload:
        return UploadScreen(
          exercise: arguments as ExerciseDetail,
        );

      case adminDashboard:
        return const AdminDashboardPage();

      default:
        return const SplashScreen();   // ⬅️ เปลี่ยน fallback เป็น SplashScreen
    }
  }
}