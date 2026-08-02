import 'package:flutter/material.dart';

import '/src/core/service/admin_api_service.dart';

class TotalUsers extends StatefulWidget {
  final int adminUserId;

  const TotalUsers({super.key, required this.adminUserId});

  @override
  State<TotalUsers> createState() => _TotalUsersState();
}

class _TotalUsersState extends State<TotalUsers> {
  final AdminApiService _apiService = AdminApiService();

  bool _isLoading = true;
  String? _errorMessage;
  int _totalUsers = 0;
  int _totalSessions = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _apiService.fetchDashboardSummary(
        userId: widget.adminUserId,
      );
      setState(() {
        _totalUsers = summary['total_users'] ?? 0;
        _totalSessions = summary['total_analysis_sessions'] ?? 0;
        _isLoading = false;
      });
    } on AdminApiException catch (error) {
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to load data. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            TextButton(
              onPressed: _loadSummary,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Users',
            value: _totalUsers.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Total Analysis Sessions',
            value: _totalSessions.toString(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}