import 'dart:async';
import 'package:flutter/material.dart';
import 'package:anglesync/src/core/service/auth_service.dart';

class InactivityService {
  static const Duration timeoutDuration = Duration(hours: 1);
  static Timer? _inactivityTimer;

  static void startTimer(BuildContext context) {
    resetTimer(context);
  }

  static void resetTimer(BuildContext context) {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeoutDuration, () => _handleTimeout(context));
  }

  static void stopTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  static Future<void> _handleTimeout(BuildContext context) async {
    stopTimer();

    final authService = AuthService();
    await authService.logout();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "You have been signed out due to inactivity to protect your account.",
        ),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.redAccent,
      ),
    );

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}