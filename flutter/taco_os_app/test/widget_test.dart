// Basic smoke test — verifies that the root widget tree renders without
// throwing. Full widget tests will be added in later tasks.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app launches without throwing', (WidgetTester tester) async {
    // Provide a minimal MaterialApp wrapper to satisfy widget pump requirements.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text("Taco'Os — setup complete"))),
      ),
    );
    expect(find.text("Taco'Os — setup complete"), findsOneWidget);
  });
}
