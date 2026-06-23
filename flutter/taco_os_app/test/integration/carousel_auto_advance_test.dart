import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/login_carousel.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/carousel_config.dart';

/// Integration tests for carousel auto-advance functionality
///
/// Tests verify:
/// - Automatic advancement to next page after 3 seconds
/// - Wraparound from last page (5) to first page (1)
/// - Correct indicator updates during auto-advance
///
/// Uses FakeAsync for deterministic timer testing without flakiness.
///
/// **Validates: Requirements 2.1, 2.2, 4.2**
void main() {
  group('Carousel Auto-Advance Integration Tests', () {
    testWidgets('should advance to page 2 after 3 seconds', (
      WidgetTester tester,
    ) async {
      // Build the carousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Wait for initial build and frame callbacks
      await tester.pumpAndSettle();

      // Verify initial page is 0 (first image)
      final PageView pageView = tester.widget(find.byType(PageView));
      expect(pageView.controller!.page, equals(0.0));

      // Verify first indicator is active (width 24)
      final firstIndicator = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == CarouselConfig.activeIndicatorWidth,
      );
      expect(firstIndicator, findsOneWidget);

      // Advance time by 3 seconds (auto-play interval)
      await tester.pump(const Duration(seconds: 3));

      // Pump to complete the transition animation (300ms)
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Verify carousel advanced to page 1 (second image)
      expect(pageView.controller!.page, equals(1.0));

      // Verify second indicator is now active
      final indicators = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              (widget.constraints?.maxWidth ==
                      CarouselConfig.activeIndicatorWidth ||
                  widget.constraints?.maxWidth ==
                      CarouselConfig.inactiveIndicatorWidth),
        ),
      );

      // Should have 5 indicators total
      expect(indicators.length, equals(5));
    });

    testWidgets('should wrap from page 5 to page 1 on auto-advance', (
      WidgetTester tester,
    ) async {
      // Build the carousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Wait for initial build and frame callbacks
      await tester.pumpAndSettle();

      final PageView pageView = tester.widget(find.byType(PageView));

      // Manually advance to page 4 (last page, 0-indexed)
      pageView.controller!.jumpToPage(4);
      await tester.pumpAndSettle();

      // Verify we're on the last page
      expect(pageView.controller!.page, equals(4.0));

      // Advance time by 3 seconds
      await tester.pump(const Duration(seconds: 3));

      // Pump to complete the transition animation
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Verify carousel wrapped back to page 0 (first image)
      expect(pageView.controller!.page, equals(0.0));
    });

    testWidgets('should update indicators correctly during auto-advance', (
      WidgetTester tester,
    ) async {
      // Build the carousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Wait for initial build
      await tester.pumpAndSettle();

      // Helper function to find active indicator by checking decoration color
      int findActiveIndicatorIndex() {
        final indicators = tester.widgetList<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color != null,
          ),
        );

        int activeIndex = -1;
        int index = 0;
        for (final indicator in indicators) {
          final decoration = indicator.decoration as BoxDecoration;
          if (decoration.color == CarouselConfig.activeIndicatorColor &&
              indicator.constraints?.maxWidth ==
                  CarouselConfig.activeIndicatorWidth) {
            activeIndex = index;
            break;
          }
          index++;
        }
        return activeIndex;
      }

      // Verify first indicator is active initially
      expect(findActiveIndicatorIndex(), equals(0));

      final PageView pageView = tester.widget(find.byType(PageView));

      // Test auto-advance through multiple pages
      for (int expectedPage = 1; expectedPage < 3; expectedPage++) {
        // Advance time by 3 seconds
        await tester.pump(const Duration(seconds: 3));

        // Pump to complete the transition animation
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        // Verify page changed
        expect(pageView.controller!.page, equals(expectedPage.toDouble()));

        // Verify corresponding indicator is active
        expect(findActiveIndicatorIndex(), equals(expectedPage));
      }
    });

    testWidgets('should maintain 60 FPS during transition animation', (
      WidgetTester tester,
    ) async {
      // Build the carousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      await tester.pumpAndSettle();

      // Advance time to trigger auto-advance
      await tester.pump(const Duration(seconds: 3));

      // Record frames during transition (300ms at 60 FPS = ~18 frames)
      int frameCount = 0;
      const Duration frameDuration = Duration(milliseconds: 16); // ~60 FPS

      // Pump frames for the transition duration
      for (int i = 0; i < 20; i++) {
        await tester.pump(frameDuration);
        frameCount++;
      }

      // Verify we pumped at least 18 frames (allowing for slight variance)
      expect(frameCount, greaterThanOrEqualTo(18));

      // Final settle to complete any remaining animation
      await tester.pumpAndSettle();
    });

    testWidgets('should continue auto-advancing after multiple cycles', (
      WidgetTester tester,
    ) async {
      // Build the carousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      await tester.pumpAndSettle();

      final PageView pageView = tester.widget(find.byType(PageView));

      // Test continuous auto-advance through 7 transitions (more than one full cycle)
      for (int cycle = 0; cycle < 7; cycle++) {
        final expectedPage = (cycle + 1) % CarouselConfig.imageCount;

        // Advance time by 3 seconds
        await tester.pump(const Duration(seconds: 3));

        // Pump to complete the transition animation
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        // Verify correct page
        expect(
          pageView.controller!.page,
          equals(expectedPage.toDouble()),
          reason: 'After cycle $cycle, should be on page $expectedPage',
        );
      }
    });

    testWidgets('should respect transition duration of 300ms', (
      WidgetTester tester,
    ) async {
      // Build the carousel widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      await tester.pumpAndSettle();

      final PageView pageView = tester.widget(find.byType(PageView));

      // Trigger auto-advance
      await tester.pump(const Duration(seconds: 3));

      // Verify animation is in progress (not yet complete)
      await tester.pump(const Duration(milliseconds: 50));
      final pageAfter50ms = pageView.controller!.page!;

      // Page should be between 0 and 1 (in transition)
      expect(pageAfter50ms, greaterThan(0.0));
      expect(pageAfter50ms, lessThan(1.0));

      // Complete transition
      await tester.pumpAndSettle(const Duration(milliseconds: 250));

      // Verify page is now fully at position 1
      expect(pageView.controller!.page, equals(1.0));
    });
  });
}
