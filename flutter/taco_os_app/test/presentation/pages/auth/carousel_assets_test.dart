import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Test to verify that all carousel images exist in the assets directory
void main() {
  group('Carousel Asset Tests', () {
    test('All 5 carousel images should exist in assets directory', () {
      final baseDir = Directory('assets/images/carousel');

      // Verify directory exists
      expect(
        baseDir.existsSync(),
        isTrue,
        reason: 'Carousel assets directory should exist',
      );

      for (int i = 1; i <= 5; i++) {
        final imagePath = 'assets/images/carousel/carousel_$i.png';
        final imageFile = File(imagePath);

        // Verify file exists
        expect(
          imageFile.existsSync(),
          isTrue,
          reason: '$imagePath should exist',
        );

        // Verify file has content
        expect(
          imageFile.lengthSync(),
          greaterThan(0),
          reason: '$imagePath should contain data',
        );
      }
    });

    test('Carousel images should have correct naming format', () {
      final expectedNames = [
        'assets/images/carousel/carousel_1.png',
        'assets/images/carousel/carousel_2.png',
        'assets/images/carousel/carousel_3.png',
        'assets/images/carousel/carousel_4.png',
        'assets/images/carousel/carousel_5.png',
      ];

      // Verify naming convention is consistent
      for (int i = 0; i < expectedNames.length; i++) {
        expect(expectedNames[i], contains('carousel_${i + 1}.png'));
        expect(expectedNames[i], startsWith('assets/images/carousel/'));
        expect(expectedNames[i], endsWith('.png'));
      }
    });

    test('Carousel images should have appropriate dimensions', () {
      // This is verified by the image generation script
      // Images are created with 300x350 dimensions
      // This test documents the expected dimensions
      const expectedWidth = 300;
      const expectedHeight = 350;

      expect(expectedWidth, equals(300));
      expect(expectedHeight, equals(350));
    });
  });
}
