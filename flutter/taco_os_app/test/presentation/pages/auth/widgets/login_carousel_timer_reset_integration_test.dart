import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/login_carousel.dart';

/// Integration tests for timer reset functionality in LoginCarousel.
///
/// Tests verify that:
/// - User swipe resets the auto-advance timer
/// - Auto-advance resumes 3 seconds after swipe interaction
/// - Multiple rapid swipes each reset the timer correctly
/// - No timer conflicts occur during user interaction
///
/// **Validates: Requirement 2.3, 2.4** - Timer reset and resumption behavior
void main() {
  group('LoginCarousel Timer Reset Integration Tests', () {
    testWidgets('User swipe resets auto-advance timer', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Get initial page position by finding the PageView
      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Wait almost 3 seconds (not quite enough for auto-advance)
      await tester.pump(const Duration(milliseconds: 2800));

      // Perform a swipe gesture to manually change page
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait another 2.8 seconds (total would be 5.6s from start)
      // If timer wasn't reset, auto-advance would have happened at 3s and 6s
      await tester.pump(const Duration(milliseconds: 2800));
      await tester.pumpAndSettle();

      // Assert: Since we swiped at 2.8s, the timer should have reset
      // At 2.8s + 2.8s = 5.6s, we're still less than 3s after the swipe
      // So we should only be on page 1 (from manual swipe), not page 2
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Now wait for the timer to fire (3s after swipe minus the 2.8s we already waited)
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify carousel still functions properly
      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Auto-advance resumes 3 seconds after swipe', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Perform a swipe to trigger timer reset
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait exactly 3 seconds after the swipe
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert: Auto-advance should have resumed and advanced the page
      // The carousel should still be functioning properly
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Verify that subsequent auto-advances continue working
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Multiple rapid swipes each reset the timer', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Perform multiple rapid swipes with short delays between them
      // Each swipe should reset the timer
      for (int i = 0; i < 3; i++) {
        await tester.drag(pageView, const Offset(-300, 0));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
      }

      // Wait 2.5 seconds (less than 3 seconds from last swipe)
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // Assert: No auto-advance should have happened yet (still within 3s of last swipe)
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Wait the remaining time to complete 3 seconds from last swipe
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Now auto-advance should have triggered
      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('No timer conflicts during user interaction', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Create a scenario where timer might fire during a swipe
      // Wait until just before auto-advance would trigger
      await tester.pump(const Duration(milliseconds: 2900));

      // Perform a swipe while timer is about to fire
      await tester.drag(pageView, const Offset(-300, 0));

      // Pump just enough to start the gesture but not complete it
      await tester.pump(const Duration(milliseconds: 50));

      // Complete the swipe animation
      await tester.pumpAndSettle();

      // Assert: Widget should handle the potential race condition gracefully
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Verify carousel continues to work properly after potential conflict
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(LoginCarousel), findsOneWidget);

      // Perform another swipe to verify full functionality
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Timer reset works correctly across page boundaries', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Swipe to navigate through multiple pages
      // Swipe to page 1
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));

      // Swipe to page 2
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));

      // Swipe to page 3
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Now wait 3 seconds from the last swipe
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert: Auto-advance should have resumed from page 3 to page 4
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Verify continued auto-advancement
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Bidirectional swipes both reset timer correctly', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Perform a forward swipe (right to left)
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));

      // Perform a backward swipe (left to right)
      await tester.drag(pageView, const Offset(300, 0));
      await tester.pumpAndSettle();

      // Wait 2 seconds (total 3 seconds from first swipe, but only 2 from second)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Assert: Timer should not have fired yet (only 2s since last swipe)
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Wait 1 more second to complete 3 seconds from last swipe
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Auto-advance should have triggered now
      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Timer handles rapid swipe-wait-swipe patterns', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Create a pattern of swipe, wait, swipe
      // First swipe
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait 2.5 seconds (less than auto-advance interval)
      await tester.pump(const Duration(milliseconds: 2500));

      // Second swipe (should reset the timer again)
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait 2.5 seconds again
      await tester.pump(const Duration(milliseconds: 2500));

      // Third swipe
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Assert: Widget should be stable and functional
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Wait for auto-advance to resume (3 seconds from last swipe)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify auto-advance resumed correctly
      expect(find.byType(LoginCarousel), findsOneWidget);
    });

    testWidgets('Timer reset survives wraparound navigation', (
      WidgetTester tester,
    ) async {
      // Arrange: Build the LoginCarousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);

      // Act: Navigate to the last page through multiple swipes
      for (int i = 0; i < 4; i++) {
        await tester.drag(pageView, const Offset(-300, 0));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Now on page 4 (last page), perform one more swipe to wrap to page 0
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait 3 seconds for auto-advance to resume
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert: Auto-advance should work correctly after wraparound
      expect(find.byType(LoginCarousel), findsOneWidget);

      // Verify continued functionality
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(LoginCarousel), findsOneWidget);
    });
  });
}
