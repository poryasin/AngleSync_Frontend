import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/analysis_details.dart';
import '../widgets/risk_graph.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        title: const Text("Analysis Result"),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 Score Card
            _buildScoreCard(),

            const SizedBox(height: 20),

            // 🔹 Risk Graph
            const RiskGraph(),

            const SizedBox(height: 20),

            // 🔹 Selected Frame
            _buildSelectedFrame(),

            const SizedBox(height: 20),

            // 🔹 AI Analysis
            const AnalysisDetails(),

            const SizedBox(height: 32),

            // ===================================================
            // SAVE BUTTON
            // ===================================================

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Result Saved"),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),

                label: const Text(
                  "Save Result",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // =======================================================
      // BOTTOM NAVIGATION
      // =======================================================

      bottomNavigationBar: _BottomNavBar(
        currentIndex: 2,
        onTap: (index) {

          // HOME
          if (index == 0) {
            Navigator.pop(context);
          }

          // SCAN
          if (index == 1) {
            // TODO:
            // Navigator.pushNamed(context, '/scan');
          }

          // HISTORY
          if (index == 2) {
            // Current Page
          }
        },
      ),
    );
  }
}

// =======================================================
// SCORE CARD
// =======================================================

Widget _buildScoreCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFFF3FAF5),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ===================================================
        // TOP ROW
        // ===================================================

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Row(
              children: [

                const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.green,
                  size: 24,
                ),

                const SizedBox(width: 12),

                const Text(
                  "ACCURACY SCORE",
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 2,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDDF5E5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "GOOD",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // ===================================================
        // SCORE TEXT
        // ===================================================

        RichText(
          text: const TextSpan(
            children: [

              TextSpan(
                text: "72",
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  height: 1,
                ),
              ),

              TextSpan(
                text: "%",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              TextSpan(
                text: " /100",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ===================================================
        // PROGRESS BAR
        // ===================================================

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const LinearProgressIndicator(
            value: 0.72,
            minHeight: 18,
            backgroundColor: Color(0xFFEAEAEA),
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.green,
            ),
          ),
        ),
      ],
    ),
  );
}

// =======================================================
// SELECTED FRAME
// =======================================================

Widget _buildSelectedFrame() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Selected Frame",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      const SizedBox(height: 10),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [

            // =================================================
            // IMAGE
            // =================================================

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
              ),
            ),

            const SizedBox(width: 16),

            // =================================================
            // INFO
            // =================================================

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Time: 4.00s",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Risk: 50/100",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ],
  );
}

// =======================================================
// BOTTOM NAVIGATION BAR
// =======================================================

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              // HOME
              _NavItem(
                icon: CupertinoIcons.house_fill,
                outlineIcon: CupertinoIcons.house,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),

              // SCAN
              _NavItem(
                icon: CupertinoIcons.viewfinder,
                outlineIcon: CupertinoIcons.viewfinder,
                label: 'Scan',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              // HISTORY
              _NavItem(
                icon: CupertinoIcons.square_grid_2x2_fill,
                outlineIcon: CupertinoIcons.square_grid_2x2,
                label: 'History',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// NAV ITEM
// =======================================================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.outlineIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              selected ? icon : outlineIcon,
              color: selected
                  ? Colors.green
                  : Colors.grey,
              size: 22,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? Colors.green
                    : Colors.grey,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}