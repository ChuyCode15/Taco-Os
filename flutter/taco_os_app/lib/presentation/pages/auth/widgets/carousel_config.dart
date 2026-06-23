import 'package:flutter/material.dart';

/// Configuration class for the login page image carousel
///
/// This class centralizes all carousel behavior constants including:
/// - Image count and asset paths
/// - Animation durations and curves
/// - Dimensions and styling
/// - Indicator appearance
///
/// Validates Requirements: 1.3, 2.1, 4.3, 4.4, 5.2, 5.3
class CarouselConfig {
  // Private constructor to prevent instantiation
  CarouselConfig._();

  // Image Configuration
  /// Total number of images in the carousel
  static const int imageCount = 5;

  // Timing Configuration
  /// Interval between automatic page transitions
  static const Duration autoPlayInterval = Duration(seconds: 3);

  /// Duration of the transition animation between pages
  static const Duration transitionDuration = Duration(milliseconds: 300);

  /// Animation curve for smooth transitions
  static const Curve transitionCurve = Curves.easeInOut;

  // Dimension Configuration
  /// Maximum width of the carousel container (null means full screen width)
  static const double? maxWidth = null;

  /// Maximum height of the carousel container (null means use available height)
  static const double? maxHeight = null;

  /// Border radius for rounded corners of carousel images
  static const double borderRadius = 20.0;

  /// Minimum swipe distance to trigger page change (handled by PageView default)
  static const double minSwipeDistance = 50.0;

  // Indicator Styling Configuration
  /// Width of the active page indicator
  static const double activeIndicatorWidth = 24.0;

  /// Width of inactive page indicators
  static const double inactiveIndicatorWidth = 8.0;

  /// Height of all page indicators (active and inactive)
  static const double indicatorHeight = 8.0;

  /// Spacing between indicator dots
  static const double indicatorSpacing = 8.0;

  /// Border radius for indicator dots
  static const double indicatorBorderRadius = 4.0;

  // Color Configuration
  /// Color of the active page indicator
  static const Color activeIndicatorColor = Colors.white;

  /// Color of inactive page indicators (white with 40% opacity)
  static final Color inactiveIndicatorColor = Colors.white.withValues(
    alpha: 0.4,
  );

  /// Background color for image loading error placeholder
  static const Color errorPlaceholderColor = Color(0xFF5B7FFF);

  /// Icon color for error placeholder
  static final Color errorIconColor = Colors.white.withValues(alpha: 0.5);

  /// Text color for error placeholder
  static final Color errorTextColor = Colors.white.withValues(alpha: 0.7);

  // Asset Path Configuration
  static const String _baseAssetPath = 'assets/images/carousel/';

  /// Returns the asset path for a carousel image at the given index
  ///
  /// [index] must be between 0 and 4 (inclusive)
  /// Returns path like 'assets/images/carousel/carousel_1.png'
  static String getImagePath(int index) {
    assert(
      index >= 0 && index < imageCount,
      'Carousel index must be between 0 and ${imageCount - 1}',
    );
    return '${_baseAssetPath}carousel_${index + 1}.png';
  }

  /// Returns a list of all carousel image asset paths
  static List<String> getAllImagePaths() {
    return List.generate(imageCount, (i) => getImagePath(i));
  }
}
