import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/core/constants/carousel_config.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/login_carousel.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/carousel_indicators.dart';

/// Comprehensive widget tests for LoginCarousel component.
///
/// **Validates Task 8.3: Write widget tests for LoginCarousel**
/// Tests cover:
/// - Carousel renders PageView with 5 pages
/// - Initial page displays first image (index 0)
/// - Indicators render below carousel
/// - Correct spacing between carousel and indicators
/// - Mounted checks prevent errors during disposal
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 4.1, 4.2, 8.2**
void main() {
  group('LoginCarousel Widget Tests - Task 8.3', () {
    group('PageView Rendering', () {
      testWidgets('should render PageView with 5 pages', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - PageView exists
        final pageViewFinder = find.byType(PageView);
        expect(
          pageViewFinder,
          findsOneWidget,
          reason: 'LoginCarousel should contain exactly one PageView',
        );

        // Assert - PageView is configured correctly
        final pageView = tester.widget<PageView>(pageViewFinder);
        expect(
          pageView.controller,
          isNotNull,
          reason: 'PageView should have a PageController',
        );

        // Verify we can navigate through pages (0 -> 1 -> 2 -> 3 -> 4)
        for (int i = 1; i <= 4; i++) {
          await tester.drag(find.byType(PageView), const Offset(-400, 0));
          await tester.pumpAndSettle();

          final indicators = tester.widget<CarouselIndicators>(
            find.byType(CarouselIndicators),
          );
          expect(
            indicators.currentIndex,
            equals(i),
            reason: 'Should be on page $i after $i swipe(s)',
          );
        }

        // Verify we're on last page (page 4)
        final finalIndicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          finalIndicators.currentIndex,
          equals(4),
          reason: 'Should have navigated through all 5 pages (0-4)',
        );
      });

      testWidgets('should use correct PageView dimensions', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - SizedBox with correct dimensions wraps PageView
        final sizedBoxFinder = find.descendant(
          of: find.byType(LoginCarousel),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.width == CarouselConfig.maxWidth &&
                widget.height == CarouselConfig.maxHeight,
          ),
        );
        expect(
          sizedBoxFinder,
          findsOneWidget,
          reason:
              'PageView should be wrapped in SizedBox with 300x350 dimensions',
        );
      });

      testWidgets('should have PageView as a child of Column', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - PageView is descendant of Column
        final pageViewInColumn = find.descendant(
          of: find.byType(Column),
          matching: find.byType(PageView),
        );
        expect(
          pageViewInColumn,
          findsOneWidget,
          reason: 'PageView should be within Column layout',
        );
      });
    });

    group('Initial Page Display', () {
      testWidgets('should display first image on initial load (index 0)', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - CarouselIndicators shows index 0 as active
        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(0),
          reason: 'Initial page should be index 0 (first image)',
        );
      });

      testWidgets('should initialize PageController with page 0', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - PageView controller points to page 0
        final pageView = tester.widget<PageView>(find.byType(PageView));
        expect(
          pageView.controller,
          isNotNull,
          reason: 'PageController should be initialized',
        );

        // Verify through indicators that we're on page 0
        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(indicators.currentIndex, equals(0));
      });

      testWidgets('should display first page without user interaction', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );

        // No user interaction - just wait for initial render
        await tester.pump();

        // Assert - First page is visible immediately
        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(0),
          reason: 'First page should be visible without user interaction',
        );
      });
    });

    group('Indicator Rendering', () {
      testWidgets('should render indicators below carousel', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - CarouselIndicators exists
        final indicatorsFinder = find.byType(CarouselIndicators);
        expect(
          indicatorsFinder,
          findsOneWidget,
          reason: 'CarouselIndicators should be present',
        );

        // Assert - Indicators are in Column after PageView
        final columnFinder = find.descendant(
          of: find.byType(LoginCarousel),
          matching: find.byType(Column),
        );
        final column = tester.widget<Column>(columnFinder);

        // Verify Column structure: SizedBox(PageView), SizedBox(spacing), CarouselIndicators
        expect(
          column.children.length,
          equals(3),
          reason: 'Column should have 3 children',
        );

        // Last child should be CarouselIndicators
        expect(
          column.children[2],
          isA<CarouselIndicators>(),
          reason: 'Last child should be CarouselIndicators',
        );
      });

      testWidgets('should render 5 indicator dots', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - 5 indicator containers exist
        final indicatorContainers = find.descendant(
          of: find.byType(CarouselIndicators),
          matching: find.byType(Container),
        );
        expect(
          indicatorContainers,
          findsNWidgets(5),
          reason: 'Should have exactly 5 indicator dots',
        );
      });

      testWidgets('should pass correct props to CarouselIndicators', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - CarouselIndicators has correct properties
        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(0),
          reason: 'Initial currentIndex should be 0',
        );
        expect(
          indicators.pageCount,
          equals(5),
          reason: 'pageCount should be 5',
        );
        expect(
          indicators.pageCount,
          equals(CarouselConfig.imageCount),
          reason: 'pageCount should match CarouselConfig.imageCount',
        );
      });

      testWidgets('should update indicators when page changes', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Swipe to next page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Assert - Indicators reflect new page
        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(1),
          reason: 'currentIndex should update to 1 after swipe',
        );
      });

      testWidgets('should maintain 5 indicators throughout navigation', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Navigate through pages
        for (int i = 0; i < 3; i++) {
          await tester.drag(find.byType(PageView), const Offset(-400, 0));
          await tester.pumpAndSettle();
        }

        // Assert - Still 5 indicators
        final indicatorContainers = find.descendant(
          of: find.byType(CarouselIndicators),
          matching: find.byType(Container),
        );
        expect(
          indicatorContainers,
          findsNWidgets(5),
          reason: 'Should maintain 5 indicators during navigation',
        );
      });
    });

    group('Spacing Verification', () {
      testWidgets('should have 16px spacing between carousel and indicators', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - Column structure has correct spacing
        final columnFinder = find.descendant(
          of: find.byType(LoginCarousel),
          matching: find.byType(Column),
        );
        final column = tester.widget<Column>(columnFinder);

        // Verify middle child is SizedBox with height 16
        expect(
          column.children.length,
          equals(3),
          reason: 'Column should have 3 children',
        );

        final spacingWidget = column.children[1];
        expect(
          spacingWidget,
          isA<SizedBox>(),
          reason: 'Middle child should be SizedBox for spacing',
        );
        expect(
          (spacingWidget as SizedBox).height,
          equals(16),
          reason: 'Spacing should be 16px',
        );
      });

      testWidgets('should maintain spacing after page changes', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Change pages
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Assert - Spacing remains consistent
        final columnFinder = find.descendant(
          of: find.byType(LoginCarousel),
          matching: find.byType(Column),
        );
        final column = tester.widget<Column>(columnFinder);
        final spacingWidget = column.children[1];

        expect((spacingWidget as SizedBox).height, equals(16));
      });

      testWidgets('should have correct order: PageView, spacing, indicators', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Assert - Verify Column children order
        final columnFinder = find.descendant(
          of: find.byType(LoginCarousel),
          matching: find.byType(Column),
        );
        final column = tester.widget<Column>(columnFinder);

        // First: SizedBox containing PageView
        expect(column.children[0], isA<SizedBox>());

        // Second: SizedBox for spacing
        expect(column.children[1], isA<SizedBox>());
        expect((column.children[1] as SizedBox).height, equals(16));

        // Third: CarouselIndicators
        expect(column.children[2], isA<CarouselIndicators>());
      });
    });

    group('Mounted Checks and Lifecycle', () {
      testWidgets('should dispose without errors', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Remove widget from tree
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );

        // Assert - No errors during disposal (test passes if no exception)
        expect(find.byType(LoginCarousel), findsNothing);
      });

      testWidgets('should handle rapid disposal gracefully', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );

        // Act - Dispose immediately without settling
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );

        // Assert - No errors (mounted checks prevent crashes)
        expect(find.byType(LoginCarousel), findsNothing);
      });

      testWidgets('should handle disposal during timer callback', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Wait for partial timer duration, then dispose
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );

        // Assert - No errors during disposal
        expect(find.byType(LoginCarousel), findsNothing);
      });

      testWidgets('should not crash when disposed after page change', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Change page, then dispose
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pump(); // Start animation but don't settle

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );

        // Assert - No crashes (mounted checks prevent setState on disposed widget)
        expect(find.byType(LoginCarousel), findsNothing);
      });

      testWidgets('should cancel timer on disposal', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Dispose the widget
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
        await tester.pumpAndSettle();

        // Assert - Widget tree is clean (timer cancelled properly)
        expect(find.byType(LoginCarousel), findsNothing);
        // If timer wasn't cancelled, we'd see errors in console
      });

      testWidgets('should dispose PageController properly', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        final pageView = tester.widget<PageView>(find.byType(PageView));
        final controller = pageView.controller;

        expect(controller, isNotNull);

        // Act - Dispose the carousel
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );

        // Assert - No errors during disposal
        expect(find.byType(LoginCarousel), findsNothing);
        // PageController disposal is handled internally
      });

      testWidgets('should handle multiple rapid dispose calls', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );

        // Act - Rapidly add and remove widget
        for (int i = 0; i < 3; i++) {
          await tester.pumpWidget(
            const MaterialApp(home: Scaffold(body: LoginCarousel())),
          );
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pumpWidget(
            const MaterialApp(home: Scaffold(body: SizedBox())),
          );
        }

        // Assert - No crashes from lifecycle issues
        expect(find.byType(LoginCarousel), findsNothing);
      });
    });

    group('Integration Tests', () {
      testWidgets('should work correctly in full widget tree', (tester) async {
        // Arrange & Act - Simulate real usage in login page
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B7FFF), Color(0xFF3D5CFF)],
                  ),
                ),
                child: const Center(child: LoginCarousel()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - All components render correctly
        expect(find.byType(LoginCarousel), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
        expect(find.byType(CarouselIndicators), findsOneWidget);

        // Verify functionality
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        final indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(indicators.currentIndex, equals(1));
      });

      testWidgets('should handle multiple page transitions', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Navigate through all pages
        final transitions = [0, 1, 2, 3, 4];
        for (int i = 0; i < transitions.length; i++) {
          if (i > 0) {
            await tester.drag(find.byType(PageView), const Offset(-400, 0));
            await tester.pumpAndSettle();
          }

          // Assert - Correct page after each transition
          final indicators = tester.widget<CarouselIndicators>(
            find.byType(CarouselIndicators),
          );
          expect(
            indicators.currentIndex,
            equals(transitions[i]),
            reason: 'Should be on page ${transitions[i]}',
          );
        }
      });

      testWidgets('should stay on last page when swiping beyond it', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Act - Navigate to last page (4 swipes: 0->1, 1->2, 2->3, 3->4)
        for (int i = 0; i < 4; i++) {
          await tester.drag(find.byType(PageView), const Offset(-400, 0));
          await tester.pumpAndSettle();
        }

        // Verify we're on last page
        var indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(indicators.currentIndex, equals(4));

        // Act - Try to swipe beyond last page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Assert - Should still be on last page (PageView doesn't wrap by default)
        indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(4),
          reason: 'Should stay on last page when swiping beyond it',
        );
      });

      testWidgets('should stay on first page when swiping backward from it', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );
        await tester.pumpAndSettle();

        // Verify we start on first page
        var indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(indicators.currentIndex, equals(0));

        // Act - Try to swipe backward from first page
        await tester.drag(find.byType(PageView), const Offset(400, 0));
        await tester.pumpAndSettle();

        // Assert - Should still be on first page
        indicators = tester.widget<CarouselIndicators>(
          find.byType(CarouselIndicators),
        );
        expect(
          indicators.currentIndex,
          equals(0),
          reason: 'Should stay on first page when swiping backward from it',
        );
      });
    });
  });
}
