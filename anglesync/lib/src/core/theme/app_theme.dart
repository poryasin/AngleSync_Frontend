import 'package:flutter/material.dart';

class AppTheme {
  static const Color green = Color(0xFF3DBE7A);
  static const Color teal = Color(0xFF2BA8A8);
  static const Color background = Color(0xFFF5FBF8);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFFAAAAAA);
  static const Color iconBg = Color(0xFFE8F8F0);

  static ThemeData get theme => ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        useMaterial3: true,
      );
}