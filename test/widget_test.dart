import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/main.dart';

void main() {
  testWidgets('LifeOS app renders initial screen text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the initial welcome text is displayed on screen
    expect(find.text('LifeOS Ready'), findsOneWidget);
  });
}
