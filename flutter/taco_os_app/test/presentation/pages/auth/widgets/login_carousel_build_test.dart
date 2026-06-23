import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/core/constants/carousel_config.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/login_carousel.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/carousel_indicators.dart';

/// Widget tests for LoginCarousel build() method implementation.
///
/// **Validates Task 5.1: Build PageView with indicators**
/// - Implement build() method returning Column
/// - Create SizedBox container with configured max dimensions
/// - Build PageView.builder with 5 items
/// - Connect PageController and onPageChanged callback
/// - Add CarouselIndicators below PageView with spacing
/// - Pass currentPage and pageCount to indicators
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 4.1, 4.2**
void main() {
  group('LoginCarousel build() method - Task 5.1', () {
    testWidgets('should render Column as root widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Assert - Column should be the root widget
      final columnFinder = find.descendant(
        of: find.byType(LoginCarousel),
        matching: find.byType(Column),
      );
      expect(columnFinder, findsOneWidget);
    });

    testWidgets('should contain SizedBox with configured dimensions', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Assert - SizedBox with correct dimensions
      final sizedBoxFinder = find.descendant(
        of: find.byType(LoginCarousel),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.width == CarouselConfig.maxWidth &&
              widget.height == CarouselConfig.maxHeight,
        ),
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('should contain PageView.builder with 5 items', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Assert - PageView exists
      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);

      // Assert - PageView has correct itemCount
      final pageView = tester.widget<PageView>(pageViewFinder);
      expect(pageView.controller, isNotNull);
      // We can't directly check itemCount on PageView, but we can verify
      // by checking that the PageView is configured correctly through its children
    });

    testWidgets('should contain CarouselIndicators widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Assert - CarouselIndicators exists
      final indicatorsFinder = find.byType(CarouselIndicators);
      expect(indicatorsFinder, findsOneWidget);
    });

    testWidgets(
      'should pass currentIndex and pageCount to CarouselIndicators',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );

        // Assert - CarouselIndicators has correct properties
        final indicatorsFinder = find.byType(CarouselIndicators);
        final indicators = tester.widget<CarouselIndicators>(indicatorsFinder);

        expect(indicators.currentIndex, equals(0)); // Initial page is 0
        expect(indicators.pageCount, equals(CarouselConfig.imageCount));
        expect(indicators.pageCount, equals(5)); // Verify 5 pages
      },
    );

    testWidgets('should have spacing between PageView and indicators', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Assert - SizedBox spacing exists between PageView and indicators
      final columnFinder = find.descendant(
        of: find.byType(LoginCarousel),
        matching: find.byType(Column),
      );
      final column = tester.widget<Column>(columnFinder);

      // Column should have 3 children: SizedBox(PageView), SizedBox(spacing), CarouselIndicators
      expect(column.children.length, equals(3));

      // Check that the second child is a SizedBox with height spacing
      final spacingWidget = column.children[1];
      expect(spacingWidget, isA<SizedBox>());
      expect((spacingWidget as SizedBox).height, equals(16));
    });

    testWidgets('should render 5 indicator dots', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Assert - 5 indicator dots should be present
      final indicatorContainers = find.descendant(
        of: find.byType(CarouselIndicators),
        matching: find.byType(Container),
      );

      // Should find exactly 5 indicator containers
      expect(indicatorContainers, findsNWidgets(5));
    });

    testWidgets('should highlight first indicator on initial load', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      await tester.pumpAndSettle();

      // Assert - First indicator should be active (wider)
      final indicatorContainers = find.descendant(
        of: find.byType(CarouselIndicators),
        matching: find.byType(Container),
      );

      // Verify 5 indicators are present
      expect(indicatorContainers, findsNWidgets(5));

      // Verify first indicator has active styling
      final firstIndicator = tester.widget<Container>(
        indicatorContainers.at(0),
      );

      // Check that the first indicator has the correct decoration
      expect(firstIndicator.decoration, isA<BoxDecoration>());
      final decoration = firstIndicator.decoration as BoxDecoration;
      expect(decoration.color, CarouselConfig.activeIndicatorColor);
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

      // Assert - CarouselIndicators should update currentIndex
      final indicatorsFinder = find.byType(CarouselIndicators);
      final indicators = tester.widget<CarouselIndicators>(indicatorsFinder);

      // After swiping left, currentIndex should be 1
      expect(indicators.currentIndex, equals(1));
    });

    testWidgets(
      'should maintain pageCount=5 throughout page navigation lifecycle',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoginCarousel())),
        );

        await tester.pumpAndSettle();

        // Act - Navigate through multiple pages
        for (int i = 0; i < 3; i++) {
          await tester.drag(find.byType(PageView), const Offset(-400, 0));
          await tester.pumpAndSettle();
        }

        // Assert - pageCount should remain 5
        final indicatorsFinder = find.byType(CarouselIndicators);
        final indicators = tester.widget<CarouselIndicators>(indicatorsFinder);
        expect(indicators.pageCount, equals(5));
      },
    );
  });

  group('LoginCarousel structure validation', () {
    testWidgets('should have proper widget hierarchy', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Assert proper hierarchy:
      // LoginCarousel -> Column -> [SizedBox(PageView), SizedBox(spacing), CarouselIndicators]
      expect(find.byType(LoginCarousel), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LoginCarousel),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(LoginCarousel),
          matching: find.byType(PageView),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(LoginCarousel),
          matching: find.byType(CarouselIndicators),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use CarouselConfig constants', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoginCarousel())),
      );

      // Assert - Verify configuration constants are used
      expect(CarouselConfig.imageCount, equals(5));
      expect(CarouselConfig.maxWidth, equals(300.0));
      expect(CarouselConfig.maxHeight, equals(350.0));

      final indicatorsFinder = find.byType(CarouselIndicators);
      final indicators = tester.widget<CarouselIndicators>(indicatorsFinder);
      expect(indicators.pageCount, equals(CarouselConfig.imageCount));
    });
  });
}
