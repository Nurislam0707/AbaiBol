import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nuris/features/auth/presentation/screens/auth_welcome_screen.dart';

void main() {
  testWidgets('auth welcome screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthWelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Abai Feedback'), findsOneWidget);
    expect(find.text('Қосымшаға кіру'), findsOneWidget);
  });
}
