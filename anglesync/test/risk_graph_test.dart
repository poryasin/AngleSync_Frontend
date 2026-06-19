import 'package:anglesync/src/features/results/widgets/risk_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses backend-selected highest risk index for peak marker', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RiskGraph(
              riskScores: [10, 23, 42],
              frameTimes: [0, 15.58, 20],
              highestRiskFrameIndex: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('t = 15.58s · risk 23/100'), findsOneWidget);
    expect(find.bySemanticsLabel('Peak 23 at 15.58 seconds'), findsOneWidget);
    expect(find.text('t = 20.00s · risk 42/100'), findsNothing);
    expect(find.bySemanticsLabel('Peak 42 at 20.00 seconds'), findsNothing);

    semantics.dispose();
  });
}
