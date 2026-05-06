import 'package:flutter_test/flutter_test.dart';
import 'package:kbmt_app/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KBMTApp());
    expect(find.text('KBMT'), findsOneWidget);
  });
}
