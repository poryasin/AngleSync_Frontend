import 'package:flutter/material.dart';
import '/src/core/router/app_router.dart';
import '/src/core/service/auth_service.dart';
import '/src/features/auth/presentation/gender_selection_screen.dart';

void navigateAfterAuth(BuildContext context, AuthResult result) {
  if (result.needsGender) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GenderSelectionScreen()),
    );
    return;
  }

  final targetRoute = result.userRole == 'Admin'
      ? AppRouter.adminDashboard
      : AppRouter.home;

  Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
}