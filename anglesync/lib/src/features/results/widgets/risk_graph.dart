import 'package:flutter/material.dart';

class RiskGraph extends StatefulWidget {
  const RiskGraph({super.key});

  @override
  State<RiskGraph> createState() => _RiskGraphState();
}

class _RiskGraphState extends State<RiskGraph> {
  final List<double> _riskData = [
    12, 10, 15, 13, 18, 14, 20, 16, 22, 18,
    25, 30, 35, 38, 42, 46, 50, 47, 44, 48,
    45, 42, 38, 35, 30, 25, 20, 18, 15, 18,
    14, 16,
  ];

  int _selectedIndex = 16;
  final double _totalDuration = 7.8;

  @override
  void initState() {
    super.initState();
  }

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

  double get _selectedTime =>
      (_selectedIndex / (_riskData.length - 1)) * _totalDuration;

  double get _selectedRisk => _riskData[_selectedIndex];

  void _resolveIndex(double dx, double totalWidth) {
    const leftPad = 40.0;
    const rightPad = 16.0;
    final graphWidth = totalWidth - leftPad - rightPad;
    final relX = (dx - leftPad).clamp(0.0, graphWidth);
    final index =
        ((relX / graphWidth) * (_riskData.length - 1)).round();
    setState(() {
      _selectedIndex = index.clamp(0, _riskData.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Graph ──
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (d) =>
                    _resolveIndex(d.localPosition.dx, constraints.maxWidth),
                onHorizontalDragUpdate: (d) =>
                    _resolveIndex(d.localPosition.dx, constraints.maxWidth),
                child: SizedBox(
                  height: 200,
                  width: constraints.maxWidth,
                  child: CustomPaint(
                    painter: _RiskChartPainter(
                      data: _riskData,
                      selectedIndex: _selectedIndex,
                      peakIndex: _peakIndex,
                      peakValue: _riskData[_peakIndex],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── X-axis labels ──
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("0s",
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF667085))),
                Text("${_totalDuration}s",
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF667085))),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Hint ──
          const Center(
            child: Text(
              "Tap any point on the graph to inspect that frame",
              style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF0F0F0), height: 1),
          const SizedBox(height: 16),

          // ── Selected Frame label ──
          const Text(
            "SELECTED FRAME",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "t = ${_selectedTime.toStringAsFixed(2)}s · risk ${_selectedRisk.toInt()}/100",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // ── Frame image placeholder ──
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_outline,
                  color: Colors.white38, size: 48),
            ),
          ),
          const SizedBox(height: 12),

          // ── Biggest deviation ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: RichText(
              text: const TextSpan(
                style:
                    TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
                children: [
                  TextSpan(
                    text: "Biggest deviation here: ",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: "Left Knee — off by 6°",
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter ──
class _RiskChartPainter extends CustomPainter {
  final List<double> data;
  final int selectedIndex;
  final int peakIndex;
  final double peakValue;

  const _RiskChartPainter({
    required this.data,
    required this.selectedIndex,
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

    // ── Gridlines & Y labels ──
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = 1;

    for (final yVal in [0, 25, 50, 75, 100]) {
      final y = topPad + graphH * (1 - yVal / 100);
      _drawDashed(canvas, Offset(leftPad, y),
          Offset(size.width - rightPad, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: "$yVal",
          style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 6, y - tp.height / 2));
    }

    // ── Build points list ──
    final pts = List.generate(data.length, (i) => _point(i, size));

    // ── Filled area ──
    final fillPath = Path()..moveTo(pts.first.dx, bottomY);
    for (final p in pts) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(pts.last.dx, bottomY);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red.withOpacity(0.25),
            Colors.red.withOpacity(0.04),
          ],
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

    // ── Dots ──
    for (final p in pts) {
      canvas.drawCircle(p, 5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(p, 5,
          Paint()
            ..color = Colors.green
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }

    // ── Peak dashed vertical ──
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
    peakTp.paint(
        canvas, Offset(peakPt.dx - peakTp.width / 2, 4));

    // ── Selected dot (red, bigger) ──
    final selPt = pts[selectedIndex];
    canvas.drawCircle(selPt, 8,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill);
    canvas.drawCircle(selPt, 8,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke);
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
        Offset(start.dx + dx * t1.clamp(0.0, 1.0),
            start.dy + dy * t1.clamp(0.0, 1.0)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RiskChartPainter old) =>
      old.selectedIndex != selectedIndex ||
      old.peakIndex != peakIndex;
}