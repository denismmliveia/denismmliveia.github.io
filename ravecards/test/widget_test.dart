import 'package:flutter_test/flutter_test.dart';

import 'package:ravecards/main.dart';

void main() {
  testWidgets('RaveCards app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RaveCardsApp());
    expect(find.text('RaveCards'), findsOneWidget);
  });
}
