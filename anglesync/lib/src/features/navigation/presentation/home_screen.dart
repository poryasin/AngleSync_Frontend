import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/analysis_service.dart';
import '../../history/domain/scan_history_item.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllHistory;
  const HomeScreen({super.key, this.onViewAllHistory});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<ScanHistoryItem> _recentScans = [];
  Set<int> _scannedDaysThisMonth = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final history = await fetchAnalysisHistory();
      final now = DateTime.now();

      // 1. ดึง 3 รายการล่าสุด
      final recent = history.take(3).toList();

      // 2. หาวันที่มีการทำสแกนใน "เดือนปัจจุบัน"
      final daysInMonth = <int>{};
      for (var item in history) {
        if (item.createdAt.year == now.year && item.createdAt.month == now.month) {
          daysInMonth.add(item.createdAt.day);
        }
      }

      if (mounted) {
        setState(() {
          _recentScans = recent;
          _scannedDaysThisMonth = daysInMonth;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppTheme.green,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _AppBar(),
                const _HeroSection(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ScanCalendarCard(
                    scannedDays: _scannedDaysThisMonth,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _ScanPostureButton(),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Pick an exercise category to begin',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _RecentScansSection(
                    recentScans: _recentScans,
                    isLoading: _isLoading,
                    onViewAllHistory: widget.onViewAllHistory,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// App Bar
class _AppBar extends StatelessWidget {
  const _AppBar();

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

    await AuthService().signOut();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.waveform_path,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AngleSync',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _handleLogout(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.square_arrow_right,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hero Section
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.sparkles, size: 15, color: AppTheme.green),
                SizedBox(width: 6),
                Text(
                  'AI Posture Coach',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.green, AppTheme.teal],
              ).createShader(bounds),
              child: const Text(
                'Move better. Train\nsmarter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.8,
                  color: AppTheme.green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan your posture with your camera and get\ninstant, AI-powered feedback on every rep.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Scan Calendar Card
class _ScanCalendarCard extends StatelessWidget {
  final Set<int> scannedDays;
  final bool isLoading;

  const _ScanCalendarCard({
    required this.scannedDays,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekdayOfMonth = DateTime(now.year, now.month, 1).weekday; // 1 = Mon, 7 = Sun
    final firstWeekdayOffset = firstWeekdayOfMonth - 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan calendar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Days you scanned this month',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${scannedDays.length} days',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day of week headers
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayLabel('M'),
              _DayLabel('T'),
              _DayLabel('W'),
              _DayLabel('T'),
              _DayLabel('F'),
              _DayLabel('S'),
              _DayLabel('S'),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar grid
          isLoading
              ? const SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.green),
                  ),
                )
              : _buildCalendarGrid(firstWeekdayOffset, totalDaysInMonth, now.day),

          const SizedBox(height: 16),

          // Legend
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppTheme.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Scanned',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'No scan',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int offset, int totalDays, int today) {
    final List<int?> days = [
      ...List.filled(offset, null),
      ...List.generate(totalDays, (i) => i + 1),
    ];

    while (days.length % 7 != 0) {
      days.add(null);
    }

    final rows = days.length ~/ 7;

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final day = days[rowIndex * 7 + colIndex];
              return _DayCell(
                day: day,
                isScanned: day != null && scannedDays.contains(day),
                isToday: day == today,
              );
            }),
          ),
        );
      }),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int? day;
  final bool isScanned;
  final bool isToday;

  const _DayCell({
    required this.day,
    required this.isScanned,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return const SizedBox(width: 36, height: 36);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isScanned ? AppTheme.green : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: isToday && !isScanned
            ? Border.all(color: AppTheme.green, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isScanned
                ? Colors.white
                : isToday
                ? AppTheme.green
                : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

// Scan Posture Button
class _ScanPostureButton extends StatelessWidget {
  const _ScanPostureButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.scan),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.green, AppTheme.teal],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.green.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.viewfinder, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Scan Posture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '→',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recent Scans Section
class _RecentScansSection extends StatelessWidget {
  final List<ScanHistoryItem> recentScans;
  final bool isLoading;
  final VoidCallback? onViewAllHistory;

  const _RecentScansSection({
    required this.recentScans,
    required this.isLoading,
    this.onViewAllHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent scans',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Jump back into your latest progress.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            GestureDetector(
              onTap: onViewAllHistory,
              child: const Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.green,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 14,
                    color: AppTheme.green,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Scan items
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppTheme.green),
            ),
          )
        else if (recentScans.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No recent scans yet',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          )
        else
          ...recentScans.map(
            (scan) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecentScanItem(item: scan),
            ),
          ),
      ],
    );
  }
}

class _RecentScanItem extends StatelessWidget {
  final ScanHistoryItem item;

  const _RecentScanItem({required this.item});

  int get _scoreValue => item.score?.round() ?? 0;

  Color get _scoreColor {
    if (_scoreValue >= 85) return AppTheme.green;
    if (_scoreValue >= 70) return Colors.blue.shade300;
    return Colors.orange;
  }

  // คำนวณช่วงเวลา เช่น Today, Yesterday, 2 days ago
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(itemDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 30) return '$difference days ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTimeAgo(item.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                '$_scoreValue',
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
                      timeStr,
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

          // Arrow
          Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}