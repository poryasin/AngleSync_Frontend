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
    // เช็คฝั่ง frontend ก่อนเสมอ เพื่อ UX ที่เร็วและไม่ต้องรอ network round-trip
    if (wantsInactive && user.userId == widget.adminUserId) {
      _showActionNotAllowedDialog('You cannot deactivate your own account.');
      return;
    }

    // ทั้งสองทิศทาง (ปิด / เปิดกลับ) ต้องยืนยันก่อนเสมอ
    final confirmed = await _showConfirmDialog(
      username: user.username,
      wantsInactive: wantsInactive,
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
      _showStatusBanner(
        title: 'Status updated',
        message: message,
        isSuccess: true,
      );
      _loadUsers();
    } on AdminApiException catch (error) {
      // fallback กรณี frontend เช็คพลาด (เช่น เผลอ deactivate ตัวเองผ่านทางอื่น)
      // backend จะ raise SelfStatusUpdateNotAllowedException กลับมาที่นี่
      _showStatusBanner(
        title: 'Update failed',
        message: error.message,
        isSuccess: false,
      );
    } catch (_) {
      _showStatusBanner(
        title: 'Update failed',
        message: 'Unable to update user status. Please try again.',
        isSuccess: false,
      );
    }
  }

  /// Dialog ยืนยันแบบมี icon วงกลม + ข้อความกึ่งกลาง + ปุ่มเต็มความกว้าง
  Future<bool?> _showConfirmDialog({
    required String username,
    required bool wantsInactive,
  }) {
    final actionColor = wantsInactive ? Colors.red : AppTheme.green;

    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
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
                  color: actionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  wantsInactive ? Icons.person_off_rounded : Icons.person_rounded,
                  color: actionColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                wantsInactive ? 'Deactivate user' : 'Activate user',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set "$username" to '
                '${wantsInactive ? 'Inactive' : 'Active'}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.w600),
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
  }

  /// การ์ดแจ้งผลแบบ floating (สำเร็จ = เขียว, ล้มเหลว = แดง)
  void _showStatusBanner({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    if (!mounted) return;

    final accentColor = isSuccess ? AppTheme.green : Colors.red;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 4,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_rounded : Icons.close_rounded,
                color: accentColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog แจ้งเตือนเมื่อ Admin พยายาม deactivate บัญชีตัวเอง
  void _showActionNotAllowedDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.red,
                        size: 34,
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.do_not_disturb_on_rounded,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Action not allowed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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