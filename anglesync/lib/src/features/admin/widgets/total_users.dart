import 'package:flutter/material.dart';

import '/src/core/service/admin_api_service.dart';
import '/src/core/theme/app_theme.dart';

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
              onPressed: _loadSummary,
              style: TextButton.styleFrom(foregroundColor: AppTheme.green),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Row เดียวกัน ความสูงเท่ากันแน่นอนด้วย fixed height
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

// การ์ดสถิติ: label อยู่บน, ตัวเลขอยู่ล่าง, ขนาดเท่ากันทุกกล่อง (fixed height)
// พร้อม press effect (เงาเข้มขึ้น + ยุบตัวลงนิดหน่อยตอนกด) ใช้งานได้จริงบนมือถือ
class _StatCard extends StatefulWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _pressed = false;

  static const double _cardHeight = 110;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        height: _cardHeight,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.12 : 0.05),
              blurRadius: _pressed ? 6 : 10,
              offset: Offset(0, _pressed ? 1 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              widget.value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.green,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}