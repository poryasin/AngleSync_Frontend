import 'package:flutter/material.dart';

class RiskGraph extends StatelessWidget {
  final List<double> riskScores;
  final List<double> frameTimes;
  final int highestRiskFrameIndex;
  final String? highestRiskImageUrl;

  const RiskGraph({
    super.key,
    required this.riskScores,
    required this.frameTimes,
    required this.highestRiskFrameIndex,
    this.highestRiskImageUrl,
  });

  List<double> get _riskData => riskScores;

  double get _totalDuration => frameTimes.isNotEmpty ? frameTimes.last : 0.0;

  double get _peakTime => highestRiskFrameIndex < frameTimes.length
      ? frameTimes[highestRiskFrameIndex]
      : 0.0;

  double get _peakRisk =>
      riskScores.isNotEmpty ? riskScores[highestRiskFrameIndex] : 0.0;

  int get _peakIndex {
    double max = 0;
    int idx = 0;
    for (int i = 0; i < _riskData.length; i++) {
      if (_riskData[i] > max) {
        max = _riskData[i];
        idx = i;
      }
    }
    return idx;
  }

  @override
  Widget build(BuildContext context) {
    if (_riskData.isEmpty) {
      return const Center(child: Text("No risk data"));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Risk over time",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "${_riskData.length} samples",
                style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Graph (ไม่มี GestureDetector แล้ว) ──
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _RiskChartPainter(
                data: _riskData,
                peakIndex: _peakIndex,
                peakValue: _riskData[_peakIndex],
              ),
              size: Size.infinite,
            ),
          ),

          // ── X-axis labels ──
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "0s",
                  style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
                Text(
                  "${_totalDuration.toStringAsFixed(1)}s",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF0F0F0), height: 1),
          const SizedBox(height: 16),

          // ── Highest risk label ──
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "HIGHEST RISK FRAME",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "t = ${_peakTime.toStringAsFixed(2)}s · risk ${_peakRisk.toInt()}/100",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // ── Frame image ──
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            child: highestRiskImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(16),
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  minScale: 1.0,
                                  maxScale: 5.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      highestRiskImageUrl!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              highestRiskImageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white38,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white38,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.zoom_in_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white38,
                      size: 48,
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // ── Caption ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE53935),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tap the image above to inspect the frame in detail",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter — ไม่มี selectedIndex แล้ว ──
class _RiskChartPainter extends CustomPainter {
  final List<double> data;
  final int peakIndex;
  final double peakValue;

  const _RiskChartPainter({
    required this.data,
    required this.peakIndex,
    required this.peakValue,
  });

  static const double leftPad = 40;
  static const double rightPad = 16;
  static const double topPad = 24;
  static const double bottomPad = 8;

  Offset _point(int i, Size size) {
    final graphW = size.width - leftPad - rightPad;
    final graphH = size.height - topPad - bottomPad;
    final x = leftPad + (i / (data.length - 1)) * graphW;
    final y = topPad + graphH * (1 - data[i] / 100);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final graphH = size.height - topPad - bottomPad;
    final bottomY = topPad + graphH;

    // ── Gridlines ──
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = 1;

    for (final yVal in [0, 25, 50, 75, 100]) {
      final y = topPad + graphH * (1 - yVal / 100);
      _drawDashed(
        canvas,
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: "$yVal",
          style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 6, y - tp.height / 2));
    }

    final pts = List.generate(data.length, (i) => _point(i, size));

    // ── Fill ──
    final fillPath = Path()..moveTo(pts.first.dx, bottomY);
    for (final p in pts) fillPath.lineTo(p.dx, p.dy);
    fillPath.lineTo(pts.last.dx, bottomY);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red.withOpacity(0.25), Colors.red.withOpacity(0.04)],
        ).createShader(Rect.fromLTWH(0, topPad, size.width, graphH)),
    );

    // ── Line ──
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = Colors.red.shade400
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Peak dashed line ──
    final peakPt = pts[peakIndex];
    _drawDashed(
      canvas,
      Offset(peakPt.dx, topPad),
      Offset(peakPt.dx, bottomY),
      Paint()
        ..color = Colors.red.shade400
        ..strokeWidth = 1.5,
      dashLen: 4,
      gapLen: 4,
    );

    // ── Peak label ──
    final peakTp = TextPainter(
      text: TextSpan(
        text: "Peak ${peakValue.toInt()}",
        style: TextStyle(
          fontSize: 12,
          color: Colors.red.shade500,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    peakTp.paint(canvas, Offset(peakPt.dx - peakTp.width / 2, 4));

    // ── Peak dot ──
    canvas.drawCircle(
      peakPt,
      8,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      peakPt,
      8,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawDashed(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashLen = 5,
    double gapLen = 4,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = (end - start).distance;
    final step = dashLen + gapLen;
    final steps = (dist / step).floor();
    for (int i = 0; i <= steps; i++) {
      final t0 = (i * step) / dist;
      final t1 = ((i * step) + dashLen) / dist;
      canvas.drawLine(
        Offset(start.dx + dx * t0, start.dy + dy * t0),
        Offset(
          start.dx + dx * t1.clamp(0.0, 1.0),
          start.dy + dy * t1.clamp(0.0, 1.0),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RiskChartPainter old) => old.peakIndex != peakIndex;
}
