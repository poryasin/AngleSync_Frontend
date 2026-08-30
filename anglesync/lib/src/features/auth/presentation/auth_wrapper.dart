import 'package:flutter/material.dart';
import 'package:anglesync/src/core/service/auth_service.dart'; 
import 'package:anglesync/src/features/auth/presentation/login_screen.dart';
import 'package:anglesync/src/features/navigation/presentation/main_shell.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService().getToken(),
      builder: (context, snapshot) {
        // ขณะกำลังโหลด Token จาก Storage
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ถ้ามี Token -> ให้เข้าหน้าหลัก
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          return const MainShell();
        }

        // ถ้าไม่มี Token -> ไปหน้า Login
        return const LoginScreen();
      },
    );
  }
}