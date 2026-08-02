import 'package:flutter/cupertino.dart';
import 'package:anglesync/src/features/navigation/presentation/main_shell.dart';
import 'package:anglesync/src/features/scan/presentation/scan_screen.dart';
import 'package:anglesync/src/features/scan/domain/exercise_detail.dart';
import 'package:anglesync/src/features/scan/presentation/upload_screen.dart';
import 'package:anglesync/src/features/admin/presentation/admin_dashboard.dart'; 

class AppRouter {
  static const String home = '/';
  static const String scan = '/scan';
  static const String history = '/history';
  static const String upload = '/upload';
  static const String adminDashboard = '/admin-dashboard'; 

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = buildPage(settings.name ?? '/', settings.arguments);

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
      case home:
        return const MainShell();

      case scan:
        return const ScanScreen();

      case history:
        return const MainShell(initialIndex: 2);

      case upload:
        return UploadScreen(
          exercise: arguments as ExerciseDetail,
        );

      case adminDashboard: // เพิ่ม
        return const AdminDashboardPage();

      default:
        return const MainShell();
    }
  }
}