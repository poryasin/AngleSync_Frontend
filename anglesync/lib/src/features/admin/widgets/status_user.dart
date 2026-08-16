import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '/src/core/service/admin_api_service.dart';
import '/src/core/theme/app_theme.dart';

class StatusUser extends StatefulWidget {
  final int adminUserId;

  const StatusUser({super.key, required this.adminUserId});

  @override
  State<StatusUser> createState() => _StatusUserState();
}

class _StatusUserState extends State<StatusUser> {
  final AdminApiService _apiService = AdminApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<AdminUser> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _apiService.fetchUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } on AdminApiException catch (error) {
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to load users. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleToggle(AdminUser user, bool wantsInactive) async {
    // ป้องกัน admin ปิดการใช้งานบัญชีตัวเอง (reactivate ตัวเองยังทำได้ปกติ)
    if (wantsInactive && user.userId == widget.adminUserId) {
      _showSnackBar('An admin cannot deactivate their own account.');
      return;
    }

    // ทั้งสองทิศทาง (ปิด / เปิดกลับ) ต้องยืนยันก่อนเสมอ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(wantsInactive ? 'Deactivate user' : 'Activate user'),
        content: Text(
          'Are you sure you want to set "${user.username}" to '
          '${wantsInactive ? 'Inactive' : 'Active'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Confirm',
              style: TextStyle(
                color: wantsInactive ? Colors.red : AppTheme.green,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final newStatus = wantsInactive ? 'Inactive' : 'Active';

    try {
      final message = await _apiService.updateUserStatus(
        adminUserId: widget.adminUserId,
        targetUserId: user.userId,
        newStatus: newStatus,
      );
      _showSnackBar(message);
      _loadUsers();
    } on AdminApiException catch (error) {
      _showSnackBar(error.message);
    } catch (_) {
      _showSnackBar('Unable to update user status. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Users',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.green),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadUsers,
              style: TextButton.styleFrom(foregroundColor: AppTheme.green),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No users found.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = _users[index];
        final isInactive = user.isInactive;
        final isAdmin = user.userRole == 'Admin';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.userRole} • ${user.userStatus}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isAdmin)
                Switch(
                  value: !isInactive,
                  activeColor: AppTheme.green,
                  onChanged: (isActive) => _handleToggle(user, !isActive),
                ),
            ],
          ),
        );
      },
    );
  }
}