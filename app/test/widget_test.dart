// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:valdi_mobile/main.dart';
import 'package:valdi_mobile/src/services/auth_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final auth = AuthService();
    // Pump the app with a default (signed-out) AuthService — this should show the LoginScreen.
    await tester.pumpWidget(ValdiApp(auth: auth));

    // Verify that our counter starts at 0.
    // Basic smoke test — app boots and shows the sign-in copy from LoginScreen.
    expect(find.text('Use your admin credentials to sign in.'), findsOneWidget);
  });
}
