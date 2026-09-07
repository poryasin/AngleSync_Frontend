import 'package:flutter/material.dart';

import '../widgets/total_users.dart';
import '../widgets/total_session.dart';
import '../widgets/status_user.dart';
import '/src/core/router/app_router.dart';
import '/src/core/service/auth_service.dart';

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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
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
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => _handleLogout(context),
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