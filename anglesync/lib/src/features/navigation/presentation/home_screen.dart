import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/service/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onViewAllHistory;
  const HomeScreen({super.key, this.onViewAllHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _AppBar(),
              const _HeroSection(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _ScanCalendarCard(),
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _RecentScansSection(onViewAllHistory: onViewAllHistory),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// App Bar
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
  const _ScanCalendarCard();

  // mock data of days user scanned in current month (1-based day numbers)
  static const Set<int> _scannedDays = {1, 2, 4, 5, 8, 9, 11, 12, 13};

  static const int _firstWeekdayOffset = 3; // May 2025 starts on Thursday
  static const int _totalDays = 31;
  static const int _today = 14;

  @override
  Widget build(BuildContext context) {
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
                  '${_scannedDays.length} days',
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
          _buildCalendarGrid(),

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

  Widget _buildCalendarGrid() {
    // list of day numbers with null for empty cells before the first day
    final List<int?> days = [
      ...List.filled(_firstWeekdayOffset, null),
      ...List.generate(_totalDays, (i) => i + 1),
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
                isScanned: day != null && _scannedDays.contains(day),
                isToday: day == _today,
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
  final VoidCallback? onViewAllHistory;
  const _RecentScansSection({this.onViewAllHistory});

  static const List<Map<String, dynamic>> _recentScans = [
    {
      'title': 'Morning squat check',
      'exercise': 'Squat',
      'time': 'Today',
      'score': 88,
    },
    {
      'title': 'Push-up form review',
      'exercise': 'Push-up',
      'time': 'Yesterday',
      'score': 75,
    },
    {
      'title': 'Plank hold test',
      'exercise': 'Plank',
      'time': '2 days ago',
      'score': 92,
    },
  ];

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
        ..._recentScans.map(
          (scan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecentScanItem(
              title: scan['title'] as String,
              exercise: scan['exercise'] as String,
              time: scan['time'] as String,
              score: scan['score'] as int,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentScanItem extends StatelessWidget {
  final String title;
  final String exercise;
  final String time;
  final int score;

  const _RecentScanItem({
    required this.title,
    required this.exercise,
    required this.time,
    required this.score,
  });

  Color get _scoreColor {
    if (score >= 85) return AppTheme.green;
    if (score >= 70) return Colors.blue.shade300;
    return Colors.orange;
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
                '$score',
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
                  title,
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
                      '$exercise · $time',
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
