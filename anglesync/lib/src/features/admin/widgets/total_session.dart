import 'package:flutter/material.dart';

import '../models/admin_session.dart';
import '/src/core/service/admin_api_service.dart';
import '/src/core/theme/app_theme.dart';

class TotalSessions extends StatefulWidget {
  final int adminUserId;

  const TotalSessions({super.key, required this.adminUserId});

  @override
  State<TotalSessions> createState() => _TotalSessionsState();
}

class _TotalSessionsState extends State<TotalSessions> {
  final AdminApiService _apiService = AdminApiService();

  String _sortOrder = 'desc';
  DateTime? _filterDate;

  bool _isLoading = true;
  String? _errorMessage;
  List<AdminSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessions = await _apiService.fetchSessions(
        userId: widget.adminUserId,
        sortOrder: _sortOrder,
        filterDate: _filterDate,
      );
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } on AdminApiException catch (error) {
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to load sessions. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.green),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _filterDate = picked);
      _loadSessions();
    }
  }

  void _clearDateFilter() {
    setState(() => _filterDate = null);
    _loadSessions();
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
    });
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Analysis Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: _sortOrder == 'asc'
                  ? 'Sorted oldest first'
                  : 'Sorted newest first',
              icon: Icon(
                _sortOrder == 'asc'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: AppTheme.green,
                size: 20,
              ),
              onPressed: _toggleSortOrder,
            ),
            IconButton(
              tooltip: 'Filter by date',
              icon: const Icon(
                Icons.calendar_today,
                color: AppTheme.green,
                size: 20,
              ),
              onPressed: _pickDate,
            ),
            if (_filterDate != null)
              IconButton(
                tooltip: 'Clear date filter',
                icon: Icon(Icons.clear, color: Colors.grey.shade500, size: 20),
                onPressed: _clearDateFilter,
              ),
          ],
        ),
        if (_filterDate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Filtered by: '
              '${_filterDate!.toLocal().toString().split(' ').first}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
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
              onPressed: _loadSessions,
              style: TextButton.styleFrom(foregroundColor: AppTheme.green),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      final message = _filterDate != null
          ? 'No sessions found for the selected date.'
          : 'No sessions yet.';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(message, style: TextStyle(color: Colors.grey.shade500)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _SessionCard(
          title: session.sessionName,
          subtitle: session.analysisDate != null
              ? session.analysisDate!.toLocal().toString().split('.').first
              : 'Unknown date',
        );
      },
    );
  }
}

// การ์ด session แต่ละแถว พร้อม press effect (เงาเข้มขึ้น + ยุบตัวลงนิดหน่อยตอนกด)
class _SessionCard extends StatefulWidget {
  final String title;
  final String subtitle;

  const _SessionCard({required this.title, required this.subtitle});

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
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
}