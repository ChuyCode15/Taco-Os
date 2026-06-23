import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/carousel_indicators.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/carousel_config.dart';

/// **Validates Requirements: 4.1, 4.2, 4.3, 4.4, 4.5**
void main() {
  group('CarouselIndicators Widget Tests', () {
    testWidgets('displays correct number of indicators', (
      WidgetTester tester,
    ) async {
      // **Validates: Requirement 4.1** - Display 5 PageIndicators
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 0, pageCount: 5),
          ),
        ),
      );

      // Get the Row widget and its children
      final row = tester.widget<Row>(find.byType(Row));
      final List<Widget> children = row.children;

      // Should have exactly 5 indicators
      expect(children.length, 5);

      // Verify Row widget exists
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('highlights the correct active indicator', (
      WidgetTester tester,
    ) async {
      // **Validates: Requirement 4.2** - Highlight corresponding PageIndicator
      for (int activeIndex = 0; activeIndex < 5; activeIndex++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CarouselIndicators(currentIndex: activeIndex, pageCount: 5),
            ),
          ),
        );

        // Get the Row widget and its children
        final row = tester.widget<Row>(find.byType(Row));
        final List<Widget> children = row.children;

        // Verify we have 5 indicators
        expect(children.length, 5);

        // Check each indicator's styling
        for (int i = 0; i < 5; i++) {
          final container = children[i] as Container;
          final decoration = container.decoration as BoxDecoration;

          if (i == activeIndex) {
            // Active indicator should be white
            expect(decoration.color, CarouselConfig.activeIndicatorColor);
          } else {
            // Inactive indicator should have reduced opacity
            expect(decoration.color, CarouselConfig.inactiveIndicatorColor);
          }
        }
      }
    });

    testWidgets('active indicator has correct dimensions and styling', (
      WidgetTester tester,
    ) async {
      // **Validates: Requirement 4.3** - Active indicator 24px width, 8px height, white
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 2, pageCount: 5),
          ),
        ),
      );

      // Build and get the actual rendered box
      await tester.pumpAndSettle();

      // Get the Row widget
      final row = tester.widget<Row>(find.byType(Row));
      final List<Widget> children = row.children;

      // Get the active indicator (index 2)
      final activeIndicator = children[2] as Container;
      final activeDecoration = activeIndicator.decoration as BoxDecoration;

      // Verify active indicator color is white
      expect(activeDecoration.color, Colors.white);
      expect(activeDecoration.color, CarouselConfig.activeIndicatorColor);

      // Verify active indicator has correct width (24px) and height (8px)
      final BoxConstraints? constraints = activeIndicator.constraints;
      if (constraints != null) {
        expect(constraints.minWidth, 24.0);
        expect(constraints.maxWidth, 24.0);
        expect(constraints.minHeight, 8.0);
        expect(constraints.maxHeight, 8.0);
      } else {
        // If no constraints, the Container uses width/height properties directly
        // Verify the rendered size
        final Size size = tester.getSize(find.byWidget(activeIndicator));
        expect(size.width, 24.0);
        expect(size.height, 8.0);
      }

      // Check border radius
      final borderRadius = activeDecoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, CarouselConfig.indicatorBorderRadius);
    });

    testWidgets('inactive indicators have correct styling', (
      WidgetTester tester,
    ) async {
      // **Validates: Requirement 4.4** - Inactive indicator 8px width, 8px height, 40% opacity
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 2, pageCount: 5),
          ),
        ),
      );

      // Get the Row widget
      final row = tester.widget<Row>(find.byType(Row));
      final List<Widget> children = row.children;

      // Check inactive indicators (all except index 2)
      for (int i = 0; i < 5; i++) {
        if (i != 2) {
          final indicator = children[i] as Container;
          final decoration = indicator.decoration as BoxDecoration;

          // Verify inactive indicator has the configured color with 40% opacity
          expect(decoration.color, CarouselConfig.inactiveIndicatorColor);

          // Verify inactive indicator has correct width (8px) and height (8px)
          final BoxConstraints? constraints = indicator.constraints;
          if (constraints != null) {
            expect(constraints.minWidth, 8.0);
            expect(constraints.maxWidth, 8.0);
            expect(constraints.minHeight, 8.0);
            expect(constraints.maxHeight, 8.0);
          } else {
            // If no constraints, the Container uses width/height properties directly
            // Verify the rendered size
            final Size size = tester.getSize(find.byWidget(indicator));
            expect(size.width, 8.0);
            expect(size.height, 8.0);
          }

          // Verify the opacity is approximately 0.4
          final color = decoration.color;
          if (color != null) {
            expect(color.a, closeTo(0.4, 0.01));
          }
        }
      }
    });

    testWidgets('indicators update when currentIndex changes', (
      WidgetTester tester,
    ) async {
      // **Validates: Requirement 4.5** - Update indicator highlighting

      // Start with index 0
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 0, pageCount: 5),
          ),
        ),
      );

      // Get initial state
      var row = tester.widget<Row>(find.byType(Row));
      var children = row.children;
      var firstIndicator = children[0] as Container;
      var firstDecoration = firstIndicator.decoration as BoxDecoration;

      // Verify first indicator is active
      expect(firstDecoration.color, CarouselConfig.activeIndicatorColor);

      // Change to index 3
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 3, pageCount: 5),
          ),
        ),
      );

      // Pump to allow rebuild
      await tester.pump();

      // Get updated state
      row = tester.widget<Row>(find.byType(Row));
      children = row.children;

      // Verify new active indicator is at index 3
      final activeIndicator = children[3] as Container;
      final activeDecoration = activeIndicator.decoration as BoxDecoration;
      expect(activeDecoration.color, CarouselConfig.activeIndicatorColor);

      // Verify previous active (index 0) is now inactive
      final previousActive = children[0] as Container;
      final previousDecoration = previousActive.decoration as BoxDecoration;
      expect(previousDecoration.color, CarouselConfig.inactiveIndicatorColor);
    });

    testWidgets('indicators have proper spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 0, pageCount: 5),
          ),
        ),
      );

      // Get the Row widget
      final row = tester.widget<Row>(find.byType(Row));
      final List<Widget> children = row.children;

      // Verify each indicator has proper margin
      for (final child in children) {
        final indicator = child as Container;
        final margin = indicator.margin as EdgeInsets;

        // Each side should have half the spacing (symmetric)
        expect(margin.horizontal, CarouselConfig.indicatorSpacing);
      }
    });

    testWidgets('indicators have rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 0, pageCount: 5),
          ),
        ),
      );

      // Get the Row widget
      final row = tester.widget<Row>(find.byType(Row));
      final List<Widget> children = row.children;

      // Verify each indicator has border radius
      for (final child in children) {
        final indicator = child as Container;
        final decoration = indicator.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        expect(borderRadius.topLeft.x, CarouselConfig.indicatorBorderRadius);
        expect(borderRadius.topLeft.y, CarouselConfig.indicatorBorderRadius);
      }
    });

    testWidgets('indicators are centered in Row', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 0, pageCount: 5),
          ),
        ),
      );

      // Get the Row widget
      final row = tester.widget<Row>(find.byType(Row));

      // Verify Row uses center alignment
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('works with different page counts', (
      WidgetTester tester,
    ) async {
      // Test with 3 pages
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 1, pageCount: 3),
          ),
        ),
      );

      var row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 3);

      // Test with 7 pages
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarouselIndicators(currentIndex: 4, pageCount: 7),
          ),
        ),
      );

      row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 7);
    });
  });
}
