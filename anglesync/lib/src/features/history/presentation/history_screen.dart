import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/service/analysis_service.dart';
import '../../results/presentation/analysis_result_screen.dart';
import '../domain/scan_history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanHistoryItem>> _historyFuture;

  List<ScanHistoryItem> _allItems = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _sortAscending = false;

  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ScanHistoryItem>> _loadHistory() async {
    final items = await fetchAnalysisHistory();
    _allItems = items;
    return items;
  }

  Future<void> _refresh() async {
    setState(() => _historyFuture = _loadHistory());
    await _historyFuture;
  }

  List<ScanHistoryItem> get _visibleItems {
    var items = List<ScanHistoryItem>.from(_allItems);

    if (_searchQuery.isNotEmpty) {
      items = items
          .where((item) => item.title.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (_selectedDateRange != null) {
      final start = DateTime(
        _selectedDateRange!.start.year,
        _selectedDateRange!.start.month,
        _selectedDateRange!.start.day,
      );
      final end = DateTime(
        _selectedDateRange!.end.year,
        _selectedDateRange!.end.month,
        _selectedDateRange!.end.day,
        23,
        59,
        59,
      );
      items = items.where((item) {
        final date = item.analysisDate;
        if (date == null) return false;
        return !date.isBefore(start) && !date.isAfter(end);
      }).toList();
    }

    items.sort((a, b) {
      final dateA = a.analysisDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.analysisDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return _sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    return items;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _selectedDateRange,
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
      setState(() => _selectedDateRange = picked);
    }
  }

  Future<void> _pickSingleDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDate: _selectedDateRange?.start ?? now,
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
      setState(
        () => _selectedDateRange = DateTimeRange(start: picked, end: picked),
      );
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDateRange = null);
  }

  String get _dateFilterLabel {
    if (_selectedDateRange == null) return 'All dates';
    final range = _selectedDateRange!;
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (range.start.year == range.end.year &&
        range.start.month == range.end.month &&
        range.start.day == range.end.day) {
      return fmt(range.start);
    }
    return '${fmt(range.start)} - ${fmt(range.end)}';
  }

  Future<void> _openSession(ScanHistoryItem session) async {
    if (session.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session ID is missing from the history response.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await fetchAnalysisSessionDetail(session.id!);
      if (!mounted) return;
      Navigator.pop(context); // ปิด Dialog Loading

      final AnalysisResult analysisResult =
          detail.result['analysis_obj'] is AnalysisResult
          ? detail.result['analysis_obj'] as AnalysisResult
          : AnalysisResult.fromJson(detail.result, detail.title);

      final deleted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            analysisStream: Stream<AnalysisEvent>.multi((controller) {
              controller.add(ResultEvent(analysisResult));
              controller.close();
            }),
            userId: detail.userId,
            referenceVideoId: detail.referenceVideoId,
            videoUserUrl: detail.videoUserUrl,
            isSavedSession: true,
            sessionId: detail.sessionId,
          ),
        ),
      );

      if (deleted == true && mounted) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;

        try {
          await _refresh();
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Result deleted.')),
          );
        }
      }
    } on AnalysisException catch (error) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading session: $e')));
    }
  }

  Future<bool> _confirmDelete(ScanHistoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete scan?'),
        content: Text('Delete "${item.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _deleteSession(ScanHistoryItem item) async {
    if (item.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete: session ID is missing.')),
      );
      return;
    }

    try {
      await deleteAnalysisSession(item.id!);
      setState(() {
        _allItems.removeWhere((e) => e.id == item.id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Scan deleted.')));
    } on AnalysisException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header & Filter Controls Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent scans',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your latest posture analysis sessions.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 1. Search Bar (UI Refactored)
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by title...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      CupertinoIcons.clear_circled_solid,
                                      size: 18,
                                    ),
                                    color: Colors.grey.shade400,
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. Filter & Sort Actions Bar (UI Refactored)
                      Row(
                        children: [
                          // Sort Button (Newest / Oldest)
                          Expanded(
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () => setState(
                                  () => _sortAscending = !_sortAscending,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _sortAscending
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        size: 16,
                                        color: AppTheme.green,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _sortAscending
                                            ? 'Oldest first'
                                            : 'Newest first',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Date Filter PopupMenu Button
                          Expanded(
                            child: PopupMenuButton<String>(
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.12),
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              onSelected: (value) {
                                if (value == 'range') _pickDateRange();
                                if (value == 'single') _pickSingleDate();
                                if (value == 'clear') _clearDateFilter();
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'single',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Pick a date',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuDivider(
                                    height: 1, color: Colors.grey.shade200),
                                PopupMenuItem<String>(
                                  value: 'range',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.date_range_outlined,
                                        size: 18,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Pick a date range',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_selectedDateRange != null) ...[
                                  PopupMenuDivider(
                                      height: 1, color: Colors.grey.shade200),
                                  const PopupMenuItem<String>(
                                    value: 'clear',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Clear filter',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                              child: Container(
                                height: 44,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: _selectedDateRange != null
                                        ? AppTheme.green
                                        : Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.filter_alt_outlined,
                                      size: 18,
                                      color: _selectedDateRange != null
                                          ? AppTheme.green
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _dateFilterLabel,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedDateRange != null
                                              ? AppTheme.green
                                              : AppTheme.textDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: _selectedDateRange != null
                                          ? AppTheme.green
                                          : Colors.grey.shade500,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Dynamic List Content
              FutureBuilder<List<ScanHistoryItem>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Failed to load history.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    );
                  }

                  final items = _visibleItems;
                  if (items.isEmpty) {
                    final message = _allItems.isEmpty
                        ? 'No scans yet.'
                        : 'No scans match your search or filter.';
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          message,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(item.id ?? item.hashCode),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(item),
                            onDismissed: (_) => _deleteSession(item),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                CupertinoIcons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () => _openSession(item),
                              child: _ScanHistoryCard(item: item),
                            ),
                          ),
                        );
                      }, childCount: items.length),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Scan History Card Component
class _ScanHistoryCard extends StatelessWidget {
  final ScanHistoryItem item;

  const _ScanHistoryCard({required this.item});

  Color get _scoreColor {
    final score = item.score ?? 0;
    if (score >= 85) return AppTheme.green;
    if (score >= 70) return Colors.blue.shade300;
    return Colors.orange;
  }

  String get _formattedDate {
    final date = item.analysisDate;
    if (date == null) return '-';
    final localDate = date.toLocal();
    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year} '
        '${localDate.hour.toString().padLeft(2, '0')}:'
        '${localDate.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _scoreColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                item.score != null ? item.score!.toStringAsFixed(0) : '-',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_up_right,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Icons
          Row(
            children: [
              Icon(CupertinoIcons.eye, size: 20, color: AppTheme.green),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}