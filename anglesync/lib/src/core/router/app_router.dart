import 'package:flutter/material.dart';
import '../../features/navigation/presentation/main_shell.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/results_page/screen/analysis_result_screen.dart';

class AppRouter {
  // Route names
  static const String home = '/';
  static const String scan = '/scan';
  static const String videoUpload = '/scan/upload';
  static const String analysisResult = '/analysis-result';


  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const MainShell());

      case scan:
        return _buildRoute(const ScanScreen());
      case analysisResult:
        return _buildRoute(const AnalysisResultScreen());

      default:
        return _buildRoute(const MainShell());
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}