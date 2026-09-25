import 'package:flutter/material.dart';

import '../widgets/total_users.dart';
import '../widgets/total_session.dart';
import '../widgets/status_user.dart';
import '/src/core/router/app_router.dart';
import '/src/core/service/auth_service.dart';
import '/src/core/theme/app_theme.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AuthService _authService = AuthService();
  int? _currentAdminUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminUserId();
  }

  Future<void> _loadAdminUserId() async {
    // ดึง user_id ของผู้ใช้ที่กำลังล็อกอินอยู่จริงจาก AuthService / Token
    final userId = await _authService.getCurrentUserId();
    if (mounted) {
      setState(() {
        _currentAdminUserId = userId;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Log out?',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will need to sign in again to access your dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textDark,
                        side: BorderSide(color: Colors.grey.shade300),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await _authService.signOut();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: 'Log out',
              child: IconButton(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout_rounded),
                color: Colors.red.shade600,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.09),
                  fixedSize: const Size(44, 44),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentAdminUserId == null
          ? const Center(child: Text('Error loading user profile.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TotalUsers(adminUserId: _currentAdminUserId!),
                  const SizedBox(height: 24),
                  TotalSessions(adminUserId: _currentAdminUserId!),
                  const SizedBox(height: 24),
                  StatusUser(adminUserId: _currentAdminUserId!),
                ],
              ),
            ),
    );
  }
}
