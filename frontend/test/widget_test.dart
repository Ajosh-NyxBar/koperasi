import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kbmt_app/app.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KBMTApp()));
    await tester.pump();
    expect(find.text('KBMT'), findsOneWidget);
  });
}
