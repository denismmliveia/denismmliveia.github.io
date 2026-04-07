import 'package:flutter_test/flutter_test.dart';
import 'package:ravecards/main.dart';

void main() {
  testWidgets('RaveCardsApp renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RaveCardsApp());
    expect(find.text('RAVECARDS'), findsOneWidget);
  });
}
