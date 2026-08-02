import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '/src/core/service/admin_api_service.dart';

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
    if (!wantsInactive) {
      return;
    }

    if (user.userId == widget.adminUserId) {
      _showSnackBar('An admin cannot deactivate their own account.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate user'),
        content: Text(
          'Are you sure you want to set "${user.username}" to Inactive?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      final message = await _apiService.updateUserStatus(
        adminUserId: widget.adminUserId,
        targetUserId: user.userId,
        newStatus: 'Inactive',
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
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
            TextButton(onPressed: _loadUsers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No users found.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _users[index];
        final isInactive = user.isInactive;
        final isAdmin = user.userRole == 'Admin';

        return ListTile(
          title: Text(user.username),
          subtitle: Text('${user.userRole} • ${user.userStatus}'),
          trailing: isAdmin
              ? null
              : Switch(
                  value: !isInactive,
                  onChanged: (isActive) => _handleToggle(user, !isActive),
                ),
        );
      },
    );
  }
}