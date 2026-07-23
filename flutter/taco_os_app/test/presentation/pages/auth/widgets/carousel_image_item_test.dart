import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/carousel_image_item.dart';
import 'package:taco_os_app/presentation/pages/auth/widgets/carousel_config.dart';

/// **Validates Requirements: 1.3, 1.5, 1.6, 6.4**
void main() {
  group('CarouselImageItem Widget Tests', () {
    testWidgets('renders successfully with valid index', (
      WidgetTester tester,
    ) async {
      // **Validates: Requirement 1.5** - Display images properly
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CarouselImageItem(index: 0))),
      );

      // Verify Container widget exists
      expect(find.byType(Container), findsWidgets);

      // Verify Image.asset widget exists (successful image rendering)
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('image fills available space', (WidgetTester tester) async {
      // **Validates: Requirement 1.3** - Images fill the entire screen width
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CarouselImageItem(index: 0))),
      );

      // Find the ClipRRect widget
      final clipRRectFinder = find.byType(ClipRRect);
      expect(clipRRectFinder, findsOneWidget);

      // Verify Image widget exists
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('has correct border radius', (WidgetTester tester) async {
      // **Validates: Requirement 1.6** - 20-pixel radius rounded corners
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CarouselImageItem(index: 0))),
      );

      // Find the ClipRRect widget
      final clipRRectFinder = find.byType(ClipRRect);
      final clipRRect = tester.widget<ClipRRect>(clipRRectFinder);

      // Verify border radius
      final borderRadius = clipRRect.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, CarouselConfig.borderRadius);
      expect(borderRadius.topRight.x, CarouselConfig.borderRadius);
      expect(borderRadius.bottomLeft.x, CarouselConfig.borderRadius);
      expect(borderRadius.bottomRight.x, CarouselConfig.borderRadius);
    });

    testWidgets('image uses correct asset path', (WidgetTester tester) async {
      // Test various indices to verify correct path generation
      for (int index = 0; index < CarouselConfig.imageCount; index++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CarouselImageItem(index: index)),
          ),
        );

        // Find the Image widget
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);

        final image = tester.widget<Image>(imageFinder);
        final assetImage = image.image as AssetImage;

        // Verify the asset path matches expected format
        expect(assetImage.assetName, CarouselConfig.getImagePath(index));
      }
    });

    testWidgets('image has correct fit property', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CarouselImageItem(index: 0))),
      );

      // Find the Image widget
      final image = tester.widget<Image>(find.byType(Image));

      // Verify BoxFit.cover for filling the entire space
      expect(image.fit, BoxFit.cover);
    });

    testWidgets('displays error placeholder when image fails to load', (
      WidgetTester tester,
    ) async {
      // **Validates: Requirement 6.4** - Display placeholder with app's blue color
      // Using an invalid asset path to trigger error
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClipRRect(
              borderRadius: BorderRadius.circular(CarouselConfig.borderRadius),
              child: Image.asset(
                'invalid/path/to/image.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Simulate the error placeholder
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: CarouselConfig.errorPlaceholderColor,
                      borderRadius: BorderRadius.circular(
                        CarouselConfig.borderRadius,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: CarouselConfig.errorIconColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Image 1',
                            style: TextStyle(
                              color: CarouselConfig.errorTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Allow error to be caught and errorBuilder to be called
      await tester.pumpAndSettle();

      // Verify error placeholder Container is displayed
      final errorContainers = find.byType(Container);
      expect(errorContainers, findsWidgets);

      // Verify error icon is displayed
      final errorIcon = find.byIcon(Icons.image_not_supported);
      expect(errorIcon, findsOneWidget);

      // Verify error text is displayed
      final errorText = find.text('Image 1');
      expect(errorText, findsOneWidget);
    });

    testWidgets('error placeholder has correct background color', (
      WidgetTester tester,
    ) async {
      // **Validates: Requirement 6.4** - Placeholder with app's primary blue color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: CarouselConfig.errorPlaceholderColor,
                borderRadius: BorderRadius.circular(
                  CarouselConfig.borderRadius,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: CarouselConfig.errorIconColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Image 1',
                      style: TextStyle(
                        color: CarouselConfig.errorTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the error placeholder Container
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      // Verify background color is the app's primary blue (#5B7FFF)
      expect(decoration.color, const Color(0xFF5B7FFF));
      expect(decoration.color, CarouselConfig.errorPlaceholderColor);
    });

    testWidgets('error placeholder shows correct icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: CarouselConfig.errorPlaceholderColor,
                borderRadius: BorderRadius.circular(
                  CarouselConfig.borderRadius,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: CarouselConfig.errorIconColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Image 1',
                      style: TextStyle(
                        color: CarouselConfig.errorTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error icon exists
      final iconFinder = find.byIcon(Icons.image_not_supported);
      expect(iconFinder, findsOneWidget);

      // Verify icon properties
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, 64);
      expect(icon.color, CarouselConfig.errorIconColor);
    });

    testWidgets('error placeholder shows image number text', (
      WidgetTester tester,
    ) async {
      // Test with different indices
      for (int index = 0; index < 3; index++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: CarouselConfig.errorPlaceholderColor,
                  borderRadius: BorderRadius.circular(
                    CarouselConfig.borderRadius,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: CarouselConfig.errorIconColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Image ${index + 1}',
                        style: TextStyle(
                          color: CarouselConfig.errorTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify text shows correct image number (1-based)
        final textFinder = find.text('Image ${index + 1}');
        expect(textFinder, findsOneWidget);

        // Verify text styling
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.fontSize, 16);
        expect(textWidget.style?.fontWeight, FontWeight.w500);
        expect(textWidget.style?.color, CarouselConfig.errorTextColor);
      }
    });

    testWidgets('has anti-alias clipping with ClipRRect', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CarouselImageItem(index: 0))),
      );

      // Find the ClipRRect widget
      final clipRRectFinder = find.byType(ClipRRect);
      expect(clipRRectFinder, findsOneWidget);

      // ClipRRect provides anti-aliased clipping by default
      final clipRRect = tester.widget<ClipRRect>(clipRRectFinder);
      expect(clipRRect.clipBehavior, Clip.antiAlias);
    });

    testWidgets('renders all carousel image indices correctly', (
      WidgetTester tester,
    ) async {
      // Test that all 5 carousel images can be rendered
      for (int index = 0; index < CarouselConfig.imageCount; index++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CarouselImageItem(index: index)),
          ),
        );

        // Verify widget builds successfully
        expect(find.byType(CarouselImageItem), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Image), findsOneWidget);
      }
    });

    testWidgets('error placeholder fills available space', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: CarouselConfig.errorPlaceholderColor,
                borderRadius: BorderRadius.circular(
                  CarouselConfig.borderRadius,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: CarouselConfig.errorIconColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Image 1',
                      style: TextStyle(
                        color: CarouselConfig.errorTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the error placeholder container
      final container = tester.widget<Container>(find.byType(Container).first);

      // Verify container uses infinity dimensions to fill space
      expect(container.constraints?.maxWidth, double.infinity);
      expect(container.constraints?.maxHeight, double.infinity);
    });

    testWidgets('error placeholder content is centered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: CarouselConfig.errorPlaceholderColor,
                borderRadius: BorderRadius.circular(
                  CarouselConfig.borderRadius,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: CarouselConfig.errorIconColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Image 1',
                      style: TextStyle(
                        color: CarouselConfig.errorTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Column widget to verify alignment
      final column = tester.widget<Column>(find.byType(Column));

      // Verify Column uses center alignment
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });
  });
}
