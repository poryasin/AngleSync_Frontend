import 'package:flutter/material.dart';
import '/src/core/router/app_router.dart';
import '/src/features/auth/auth_navigation.dart';
import '/src/core/service/auth_service.dart';
import '/src/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final result = await AuthService().checkSession();
    if (!mounted) return;

    if (result == null) {
      // ไม่มี session ค้าง หรือ token หมดอายุ -> ไปหน้า login
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
      return;
    }

    navigateAfterAuth(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(child: CircularProgressIndicator(color: AppTheme.green)),
    );
  }
}