import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/analysis_details.dart';
import '../widgets/risk_graph.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/router/app_router.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF0F7F4),
    body: SafeArea(
      child: Column(
        children: [
          // AppBar แบบ manual เหมือน _UploadAppBar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
            
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    CupertinoIcons.chevron_left,
                    size: 20,
                    color: CupertinoColors.activeBlue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Upload',
                    style: TextStyle(
                      fontSize: 17,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          const Divider(height: 1, thickness: 1),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreCard(),
                  const SizedBox(height: 20),
                  const RiskGraph(),
                  const SizedBox(height: 20),
                  const AnalysisDetails(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Result Saved")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        "Save Result",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// SCORE CARD
Widget _buildScoreCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white, // card = white บน mint background
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "ACCURACY SCORE",
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.5,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDDF5E5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "GOOD",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Score text
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "72",
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              TextSpan(
                text: "%",
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: " /100",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const LinearProgressIndicator(
            value: 0.72,
            minHeight: 14,
            backgroundColor: Color(0xFFEAEAEA),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ],
    ),
  );
}
}