import 'package:flutter/material.dart';

import '../models/admin_session.dart';
import '/src/core/service/admin_api_service.dart';

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              ),
              onPressed: _toggleSortOrder,
            ),
            IconButton(
              tooltip: 'Filter by date',
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDate,
            ),
            if (_filterDate != null)
              IconButton(
                tooltip: 'Clear date filter',
                icon: const Icon(Icons.clear),
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
              style: const TextStyle(color: Colors.grey),
            ),
          ),
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
            TextButton(onPressed: _loadSessions, child: const Text('Retry')),
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
        child: Center(child: Text(message)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sessions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return ListTile(
          title: Text(session.sessionName),
          subtitle: Text(
            session.analysisDate != null
                ? session.analysisDate!.toLocal().toString().split('.').first
                : 'Unknown date',
          ),
        );
      },
    );
  }
}