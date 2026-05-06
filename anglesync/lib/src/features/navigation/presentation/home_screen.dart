import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                child: _ScanCard(),
              ),
              const SizedBox(height: 28),
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
            ],
          ),
        ),
      ),
    );
  }
}

// App Bar 
class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
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
          // Badge
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

          // Headline
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

// Scan Card
class _ScanCard extends StatelessWidget {
  const _ScanCard();

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
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4DD08A), AppTheme.teal],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(72, 72),
              painter: _ScannerPainter(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready to scan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const r = 10.0;
    const arm = 20.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - 28;
    final right = cx + 28;
    final top = cy - 24;
    final bottom = cy + 24;

    canvas.drawPath(
      Path()
        ..moveTo(left + arm, top)
        ..lineTo(left + r, top)
        ..arcToPoint(Offset(left, top + r), radius: const Radius.circular(r))
        ..lineTo(left, top + arm),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(right - arm, top)
        ..lineTo(right - r, top)
        ..arcToPoint(Offset(right, top + r),
            radius: const Radius.circular(r), clockwise: false)
        ..lineTo(right, top + arm),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - arm)
        ..lineTo(left, bottom - r)
        ..arcToPoint(Offset(left + r, bottom),
            radius: const Radius.circular(r), clockwise: false)
        ..lineTo(left + arm, bottom),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(right, bottom - arm)
        ..lineTo(right, bottom - r)
        ..arcToPoint(Offset(right - r, bottom),
            radius: const Radius.circular(r))
        ..lineTo(right - arm, bottom),
      paint,
    );

    canvas.drawLine(
      Offset(cx - 14, cy + 4),
      Offset(cx + 14, cy + 4),
      paint..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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