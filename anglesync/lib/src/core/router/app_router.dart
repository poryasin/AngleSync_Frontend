import 'package:flutter/material.dart';
import '../../features/navigation/presentation/main_shell.dart';
import '../../features/scan/presentation/scan_screen.dart';
import 'package:anglesync/src/features/history/presentation/history_screen.dart';



class AppRouter {
  // Route names
  static const String home = '/';
  static const String scan = '/scan';
  static const String videoUpload = '/scan/upload';
  static const String  history = '/history';


  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const MainShell());

      case scan:
        return _buildRoute(const ScanScreen());

      case history:
      return _buildRoute(const HistoryScreen());


      default:
        return _buildRoute(const MainShell());
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}