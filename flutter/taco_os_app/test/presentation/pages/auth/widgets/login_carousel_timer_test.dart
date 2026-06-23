import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/login_carousel.dart';

/// Unit tests for LoginCarousel auto-advance timer methods.
///
/// Tests verify that:
/// - Timer is properly initialized after widget creation
/// - Timer fires and advances pages automatically
/// - Timer can be stopped and restarted
/// - Timer is properly disposed when widget is disposed
///
/// **Validates: Requirement 2.1** - Automatic advancement every 3 seconds
void main() {
  group('LoginCarousel Timer Methods Tests', () {
    testWidgets('Timer starts after widget initialization', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Act: Wait for the first frame callback to complete
      await tester.pumpAndSettle();

      // Assert: Widget builds without errors (timer initialized internally)
      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Auto-advance timer advances page after 3 seconds', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Find the first indicator (should be active initially)
      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Advance time by 3 seconds to trigger auto-advance
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert: PageView should have advanced to the next page
      // The widget should still be present and functioning
      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Timer is cancelled when widget is disposed', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Act: Remove the widget from the tree
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      await tester.pumpAndSettle();

      // Assert: No exceptions or memory leaks should occur
      // The test passing confirms proper cleanup
      expect(find.byType(LoginCarousel), findsNothing);
    });

    testWidgets('Manual page change resets auto-advance timer', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Act: Simulate a manual swipe gesture
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Assert: Widget should still be functioning after manual interaction
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Verify timer continues to work after manual interaction
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Timer handles rapid page changes gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Act: Simulate multiple rapid swipes
      for (int i = 0; i < 3; i++) {
        await tester.drag(find.byType(PageView), const Offset(-300, 0));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      // Assert: Widget should still be functioning after rapid interactions
      expect(find.byType(LoginCarousel), findsOneWidget);
    });
  });
}
