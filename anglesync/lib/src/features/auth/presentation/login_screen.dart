import 'package:flutter/material.dart';
import '/src/core/service/auth_service.dart';
import '/src/core/theme/app_theme.dart';
import '/src/features/auth/auth_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isSigningIn = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);

    try {
      final result = await _authService.signInWithGoogle();
      if (!mounted) return;
      navigateAfterAuth(context, result);
    } on AuthException catch (error) {
      if (!mounted) return;

      // SRS-075: แสดง SnackBar สีแดง พร้อมข้อความแจ้งเตือนจาก Backend/AuthService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Spacer ด้านบนโลโก้
              const Spacer(flex: 3),

              // โลโก้แอป
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Image.asset(
                    'assets/images/logo_AngleSync.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ข้อความสโลแกนใต้โลโก้
              const Text(
                'Smart AI Assistant\nfor Movement & Posture',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF667085),
                  letterSpacing: 0.1,
                ),
              ),

              // Spacer คั่นระหว่างโลโก้กับกลุ่มปุ่ม (flex 2)
              const Spacer(flex: 2),

              // ปุ่ม Sign in with Google
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSigningIn
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.green,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.g_mobiledata, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),

              // เพิ่ม Spacer/SizedBox ด้านล่างสุดเพื่อขยับกลุ่มปุ่มขึ้นไปด้านบน
              const SizedBox(height: 48), // หรือปรับความสูงตรงนี้ตามต้องการ (เช่น 40 - 80)
            ],
          ),
        ),
      ),
    );
  }
}