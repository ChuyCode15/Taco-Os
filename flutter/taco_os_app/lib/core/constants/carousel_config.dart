/// Configuration and utility classes for the login carousel feature.
///
/// This file contains:
/// - CarouselAssets: Asset path generation utilities
/// - CarouselConfig: Carousel behavior and styling constants
library;

import 'package:flutter/material.dart';

/// Utility class for generating carousel image asset paths.
///
/// Provides methods to generate properly formatted asset paths for carousel
/// images stored in the assets/images/carousel/ directory.
///
/// **Validates: Requirements 6.1, 6.5**
class CarouselAssets {
  // Private constructor to prevent instantiation
  CarouselAssets._();

  static const String _baseAssetPath = 'assets/images/carousel/';

  /// Returns the asset path for a carousel image at the given index.
  ///
  /// The index is 1-based (1-5) to match the carousel image naming convention:
  /// carousel_1.png, carousel_2.png, etc.
  ///
  /// **Parameters:**
  /// - [index]: Image index from 1 to 5 (inclusive)
  ///
  /// **Returns:**
  /// - String path in format: 'assets/images/carousel/carousel_N.png'
  ///
  /// **Throws:**
  /// - AssertionError if index is not between 1 and 5
  ///
  /// **Example:**
  /// ```dart
  /// final path = CarouselAssets.getImagePath(1);
  /// // Returns: 'assets/images/carousel/carousel_1.png'
  /// ```
  ///
  /// **Validates: Requirement 6.1** - Images stored in assets/images/carousel/
  /// **Validates: Requirement 6.5** - Sequential naming carousel_1.png through carousel_5.png
  static String getImagePath(int index) {
    assert(
      index >= 1 && index <= 5,
      'Carousel index must be between 1 and 5. Received: $index',
    );
    return '${_baseAssetPath}carousel_$index.png';
  }

  /// Returns a list of all carousel image asset paths.
  ///
  /// Generates paths for all 5 carousel images in sequential order.
  /// Useful for batch operations like preloading all images.
  ///
  /// **Returns:**
  /// - List of 5 asset paths in order from carousel_1.png to carousel_5.png
  ///
  /// **Example:**
  /// ```dart
  /// final allPaths = CarouselAssets.getAllImagePaths();
  /// // Returns: [
  /// //   'assets/images/carousel/carousel_1.png',
  /// //   'assets/images/carousel/carousel_2.png',
  /// //   'assets/images/carousel/carousel_3.png',
  /// //   'assets/images/carousel/carousel_4.png',
  /// //   'assets/images/carousel/carousel_5.png',
  /// // ]
  ///
  /// // Usage for preloading:
  /// for (final path in CarouselAssets.getAllImagePaths()) {
  ///   await precacheImage(AssetImage(path), context);
  /// }
  /// ```
  ///
  /// **Validates: Requirement 6.1** - Manages all carousel image assets
  static List<String> getAllImagePaths() {
    return List.generate(5, (i) => getImagePath(i + 1));
  }
}

/// Configuration constants for carousel behavior and styling.
///
/// Centralizes all carousel-related constants including timing, dimensions,
/// colors, and animation parameters.
class CarouselConfig {
  // Private constructor to prevent instantiation
  CarouselConfig._();

  // Carousel content
  static const int imageCount = 5;

  // Timing configuration
  static const Duration autoPlayInterval = Duration(seconds: 3);
  static const Duration transitionDuration = Duration(milliseconds: 300);
  static const Curve transitionCurve = Curves.easeInOut;

  // Image dimensions
  static const double maxWidth = 300.0;
  static const double maxHeight = 350.0;
  static const double borderRadius = 20.0;

  // Gesture configuration
  static const double minSwipeDistance = 50.0;

  // Indicator styling
  static const double activeIndicatorWidth = 24.0;
  static const double inactiveIndicatorWidth = 8.0;
  static const double indicatorHeight = 8.0;
  static const double indicatorSpacing = 8.0;
  static const Color activeIndicatorColor = Colors.white;
  static final Color inactiveIndicatorColor = Colors.white.withValues(
    alpha: 0.4,
  );
}
