import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/core/constants/carousel_config.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/login_carousel.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/carousel_indicators.dart';

/// Integration tests for carousel swipe gesture navigation.
///
/// **Validates Task 9.2: Write integration test for swipe gestures**
/// Tests cover:
/// - Swipe left advances to next page
/// - Swipe right goes to previous page
/// - Swipe from last page wraps to first page (automatic advancement)
/// - Swipe from first page wraps to last page (automatic advancement)
/// - Indicators update after manual swipe
///
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 4.5**
void main() {
  group('Carousel Swipe Gesture Integration Tests - Task 9.2', () {
    testWidgets('swipe left advances to next page', (tester) async {
      // Arrange - Render carousel
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Verify initial state (page 0)
      var indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(0),
        reason: 'Should start on first page',
      );

      // Act - Swipe left (right-to-left gesture) to advance
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Assert - Should be on page 1
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(1),
        reason: 'Swipe left should advance to next page (page 1)',
      );

      // Act - Swipe left again
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Assert - Should be on page 2
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(2),
        reason: 'Second swipe left should advance to page 2',
      );
    });

    testWidgets('swipe right goes to previous page', (tester) async {
      // Arrange - Render carousel and navigate to page 2
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Navigate to page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify we're on page 2
      var indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(indicators.currentIndex, equals(2));

      // Act - Swipe right (left-to-right gesture) to go back
      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pumpAndSettle();

      // Assert - Should be on page 1
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(1),
        reason: 'Swipe right should go to previous page (page 1)',
      );

      // Act - Swipe right again
      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pumpAndSettle();

      // Assert - Should be on page 0
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(0),
        reason: 'Second swipe right should go back to page 0',
      );
    });

    testWidgets('swipe from last page wraps to first page', (tester) async {
      // Arrange - Render carousel and navigate to last page (page 4)
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Navigate to last page (4 swipes: 0->1->2->3->4)
      for (int i = 0; i < 4; i++) {
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
      }

      // Verify we're on last page (page 4)
      var indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(4),
        reason: 'Should be on last page before testing wrap',
      );

      // Act - Wait for auto-advance to trigger wrap (3 seconds + buffer)
      await tester.pump(const Duration(seconds: 3, milliseconds: 100));
      await tester.pumpAndSettle();

      // Assert - Should wrap to first page (page 0)
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(0),
        reason: 'Auto-advance from last page should wrap to first page',
      );
    });

    testWidgets('swipe from first page wraps to last page', (tester) async {
      // Arrange - Render carousel (starts on page 0)
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Verify we're on first page
      var indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(0),
        reason: 'Should start on first page',
      );

      // Act - Navigate forward once, then wait for auto-advance to wrap around
      // First go to page 1
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(indicators.currentIndex, equals(1));

      // Navigate to page 2, 3, 4 via swipes
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify we're on last page (page 4)
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(indicators.currentIndex, equals(4));

      // Now wait for auto-advance to wrap from last to first
      await tester.pump(const Duration(seconds: 3, milliseconds: 100));
      await tester.pumpAndSettle();

      // Assert - Should wrap to first page (page 0)
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(0),
        reason: 'Auto-advance from last page wraps to first page',
      );
    });

    testWidgets('indicators update after manual swipe', (tester) async {
      // Arrange - Render carousel
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Verify initial indicator state
      var indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(0),
        reason: 'Initial indicator should show page 0',
      );
      expect(
        indicators.pageCount,
        equals(5),
        reason: 'Should have 5 total indicators',
      );

      // Act - Perform manual swipe to page 1
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Assert - Indicator updates to page 1
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(1),
        reason: 'Indicator should update to page 1 after swipe',
      );

      // Act - Swipe to page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Assert - Indicator updates to page 2
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(2),
        reason: 'Indicator should update to page 2 after second swipe',
      );

      // Act - Swipe back to page 1
      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pumpAndSettle();

      // Assert - Indicator updates back to page 1
      indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(1),
        reason: 'Indicator should update back to page 1 after backward swipe',
      );
    });

    testWidgets('rapid swipes update indicators correctly', (tester) async {
      // Arrange - Render carousel
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Act - Perform multiple rapid swipes
      final swipesToPerform = [
        const Offset(-400, 0), // Page 0 -> 1
        const Offset(-400, 0), // Page 1 -> 2
        const Offset(-400, 0), // Page 2 -> 3
      ];

      for (int i = 0; i < swipesToPerform.length; i++) {
        await tester.drag(find.byType(PageView), swipesToPerform[i]);
        await tester.pumpAndSettle();

        // Assert - Indicator matches expected page after each swipe
        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(i + 1),
          reason: 'Indicator should show page ${i + 1} after swipe ${i + 1}',
        );
      }
    });

    testWidgets('bidirectional swipes maintain indicator accuracy', (
      tester,
    ) async {
      // Arrange - Render carousel
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Define swipe sequence: forward, forward, backward, forward, backward
      final swipeSequence = [
        (offset: const Offset(-400, 0), expectedPage: 1), // 0 -> 1
        (offset: const Offset(-400, 0), expectedPage: 2), // 1 -> 2
        (offset: const Offset(400, 0), expectedPage: 1), // 2 -> 1
        (offset: const Offset(-400, 0), expectedPage: 2), // 1 -> 2
        (offset: const Offset(400, 0), expectedPage: 1), // 2 -> 1
      ];

      // Act & Assert - Execute swipe sequence and verify indicators
      for (final swipe in swipeSequence) {
        await tester.drag(find.byType(PageView), swipe.offset);
        await tester.pumpAndSettle();

        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(swipe.expectedPage),
          reason: 'Indicator should show page ${swipe.expectedPage}',
        );
      }
    });

    testWidgets('swipe updates indicators within 100ms requirement', (
      tester,
    ) async {
      // Arrange - Render carousel
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Act - Perform swipe
      await tester.drag(find.byType(PageView), const Offset(-400, 0));

      // Pump only 100ms to verify indicator updates within requirement
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Indicator should have updated within 100ms
      final indicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        indicators.currentIndex,
        equals(1),
        reason: 'Indicator should update within 100ms (Requirement 4.5)',
      );
    });

    testWidgets('complete navigation cycle updates indicators correctly', (
      tester,
    ) async {
      // Arrange - Render carousel
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );
      await tester.pumpAndSettle();

      // Act & Assert - Navigate through all pages (0 -> 1 -> 2 -> 3 -> 4)
      for (
        int expectedPage = 0;
        expectedPage < CarouselConfig.imageCount;
        expectedPage++
      ) {
        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(expectedPage),
          reason: 'Should be on page $expectedPage',
        );

        // Navigate to next page (unless we're on the last page)
        if (expectedPage < CarouselConfig.imageCount - 1) {
          await tester.drag(find.byType(PageView), const Offset(-400, 0));
          await tester.pumpAndSettle();
        }
      }

      // Verify final state is last page
      final finalIndicators = tester.widget<CarouselIndicators>(
        find.byType(CarouselIndicators),
      );
      expect(
        finalIndicators.currentIndex,
        equals(4),
        reason: 'Should end on last page after complete cycle',
      );
    });
  });
}
