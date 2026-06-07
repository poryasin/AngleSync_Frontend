import 'package:flutter_test/flutter_test.dart';

import 'package:anglesync/main.dart';

void main() {
  testWidgets('AngleSync app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AngleSyncApp());

    expect(find.text('AngleSync'), findsOneWidget);
  });
}
