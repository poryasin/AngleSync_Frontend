import 'package:flutter/material.dart';

import '../widgets/total_users.dart';
import '../widgets/total_session.dart';
import '../widgets/status_user.dart';

// TODO: replace with the real logged-in admin's user_id once login is built.
const int currentAdminUserId = 1;

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            TotalUsers(adminUserId: currentAdminUserId),
            SizedBox(height: 24),
            TotalSessions(adminUserId: currentAdminUserId),
            SizedBox(height: 24),
            StatusUser(adminUserId: currentAdminUserId),
          ],
        ),
      ),
    );
  }
}