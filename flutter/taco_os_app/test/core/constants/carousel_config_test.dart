import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/core/constants/carousel_config.dart';

void main() {
  group('CarouselAssets', () {
    group('getImagePath', () {
      test('returns correct path for index 1', () {
        // Act
        final path = CarouselAssets.getImagePath(1);

        // Assert
        expect(path, equals('assets/images/carousel/carousel_1.png'));
      });

      test('returns correct path for index 2', () {
        // Act
        final path = CarouselAssets.getImagePath(2);

        // Assert
        expect(path, equals('assets/images/carousel/carousel_2.png'));
      });

      test('returns correct path for index 3', () {
        // Act
        final path = CarouselAssets.getImagePath(3);

        // Assert
        expect(path, equals('assets/images/carousel/carousel_3.png'));
      });

      test('returns correct path for index 4', () {
        // Act
        final path = CarouselAssets.getImagePath(4);

        // Assert
        expect(path, equals('assets/images/carousel/carousel_4.png'));
      });

      test('returns correct path for index 5', () {
        // Act
        final path = CarouselAssets.getImagePath(5);

        // Assert
        expect(path, equals('assets/images/carousel/carousel_5.png'));
      });

      test('throws assertion error for index 0', () {
        // Act & Assert
        expect(() => CarouselAssets.getImagePath(0), throwsAssertionError);
      });

      test('throws assertion error for index 6', () {
        // Act & Assert
        expect(() => CarouselAssets.getImagePath(6), throwsAssertionError);
      });

      test('throws assertion error for negative index', () {
        // Act & Assert
        expect(() => CarouselAssets.getImagePath(-1), throwsAssertionError);
      });

      test('throws assertion error for index 100', () {
        // Act & Assert
        expect(() => CarouselAssets.getImagePath(100), throwsAssertionError);
      });
    });

    group('getAllImagePaths', () {
      test('returns list of 5 image paths', () {
        // Act
        final paths = CarouselAssets.getAllImagePaths();

        // Assert
        expect(paths, hasLength(5));
      });

      test('returns paths in correct sequential order', () {
        // Act
        final paths = CarouselAssets.getAllImagePaths();

        // Assert
        expect(
          paths,
          equals([
            'assets/images/carousel/carousel_1.png',
            'assets/images/carousel/carousel_2.png',
            'assets/images/carousel/carousel_3.png',
            'assets/images/carousel/carousel_4.png',
            'assets/images/carousel/carousel_5.png',
          ]),
        );
      });

      test('each path follows the naming convention carousel_N.png', () {
        // Act
        final paths = CarouselAssets.getAllImagePaths();

        // Assert
        for (int i = 0; i < paths.length; i++) {
          final expectedPath = 'assets/images/carousel/carousel_${i + 1}.png';
          expect(paths[i], equals(expectedPath));
        }
      });

      test('all paths start with correct base path', () {
        // Act
        final paths = CarouselAssets.getAllImagePaths();

        // Assert
        for (final path in paths) {
          expect(path, startsWith('assets/images/carousel/'));
        }
      });

      test('all paths end with .png extension', () {
        // Act
        final paths = CarouselAssets.getAllImagePaths();

        // Assert
        for (final path in paths) {
          expect(path, endsWith('.png'));
        }
      });

      test('returns new list instance each time (not cached)', () {
        // Act
        final paths1 = CarouselAssets.getAllImagePaths();
        final paths2 = CarouselAssets.getAllImagePaths();

        // Assert
        expect(identical(paths1, paths2), isFalse);
        expect(paths1, equals(paths2)); // Content should be equal
      });
    });

    group('integration tests', () {
      test('getAllImagePaths matches individual getImagePath calls', () {
        // Act
        final allPaths = CarouselAssets.getAllImagePaths();
        final individualPaths = [
          CarouselAssets.getImagePath(1),
          CarouselAssets.getImagePath(2),
          CarouselAssets.getImagePath(3),
          CarouselAssets.getImagePath(4),
          CarouselAssets.getImagePath(5),
        ];

        // Assert
        expect(allPaths, equals(individualPaths));
      });
    });
  });

  group('CarouselConfig', () {
    test('has correct image count', () {
      expect(CarouselConfig.imageCount, equals(5));
    });

    test('has correct auto-play interval', () {
      expect(
        CarouselConfig.autoPlayInterval,
        equals(const Duration(seconds: 3)),
      );
    });

    test('has correct transition duration', () {
      expect(
        CarouselConfig.transitionDuration,
        equals(const Duration(milliseconds: 300)),
      );
    });

    test('has correct maximum width', () {
      expect(CarouselConfig.maxWidth, equals(300.0));
    });

    test('has correct maximum height', () {
      expect(CarouselConfig.maxHeight, equals(350.0));
    });

    test('has correct border radius', () {
      expect(CarouselConfig.borderRadius, equals(20.0));
    });

    test('has correct active indicator width', () {
      expect(CarouselConfig.activeIndicatorWidth, equals(24.0));
    });

    test('has correct inactive indicator width', () {
      expect(CarouselConfig.inactiveIndicatorWidth, equals(8.0));
    });

    test('has correct indicator height', () {
      expect(CarouselConfig.indicatorHeight, equals(8.0));
    });
  });
}
