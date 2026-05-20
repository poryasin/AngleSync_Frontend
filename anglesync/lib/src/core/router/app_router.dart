import 'package:anglesync/src/features/navigation/presentation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/scan/domain/exercise_detail.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/scan/presentation/upload_screen.dart';
import '../../features/results/presentation/analysis_result_screen.dart';


class AppRouter {
  static const String home = '/';
  static const String scan = '/scan';
  static const String videoUpload = '/scan/upload';
  static const String history = '/history';
  static const String upload = '/upload';
  static const String analysisResult = '/analysis';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final page = buildPage(settings.name ?? '/', settings.arguments);

  switch (settings.name) {
    // Navbar route: no swipe back
    case scan:
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,

      
      );

    // Non-navbar routes: swipe back 
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
      return UploadScreen(exercise: arguments as ExerciseDetail);
    case analysisResult:
      return const AnalysisResultScreen();
    default:
      return const MainShell();
  }
}
}
