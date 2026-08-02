import 'package:flutter/material.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/router/app_router.dart';

void main() {
  runApp(const AngleSyncApp());
}

class AngleSyncApp extends StatelessWidget {
  const AngleSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AngleSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRouter.home,
      // initialRoute: AppRouter.adminDashboard,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}