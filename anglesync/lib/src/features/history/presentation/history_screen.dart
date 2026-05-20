import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/scan_history_item.dart';




class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const List<ScanHistoryItem> _mockScans = [
    ScanHistoryItem(
      title: 'Morning squat check',
      exercise: 'Squat',
      time: 'Today',
      score: 88,
    ),
    ScanHistoryItem(
      title: 'Push-up form review',
      exercise: 'Push-up',
      time: 'Yesterday',
      score: 75,
    ),
    ScanHistoryItem(
      title: 'Plank hold test',
      exercise: 'Plank',
      time: '2 days ago',
      score: 92,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
      child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
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
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Scan list
                    ..._mockScans.map(
                      (scan) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ScanHistoryCard(item: scan),
                      ),
                    ),
                  ],
        )
    ),
  ),
    );
  
}
}


// Scan History Card
class _ScanHistoryCard extends StatelessWidget {
  final ScanHistoryItem item;

  const _ScanHistoryCard({required this.item});

  Color get _scoreColor {
    if (item.score >= 85) return AppTheme.green;
    if (item.score >= 70) return Colors.blue.shade300;
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
                '${item.score}',
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
                      '${item.exercise} · ${item.time}',
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

          // Eye + Arrow icons
          Row(
            children: [
              Icon(
                CupertinoIcons.eye,
                size: 20,
                color: AppTheme.green,
              ),
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