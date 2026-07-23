import 'package:flutter/material.dart';
import 'carousel_config.dart';

/// Widget that displays page position indicators for the carousel.
///
/// Shows a row of dots where the active page has different styling (larger width,
/// full white color) compared to inactive pages (smaller width, 40% opacity).
///
/// **Validates Requirements: 4.1, 4.2, 4.3, 4.4, 4.5**
///
/// Example usage:
/// ```dart
/// CarouselIndicators(
///   currentIndex: 2,
///   pageCount: 5,
/// )
/// ```
class CarouselIndicators extends StatelessWidget {
  /// The current active page index (0-based)
  final int currentIndex;

  /// Total number of pages in the carousel
  final int pageCount;

  const CarouselIndicators({
    super.key,
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) => _buildIndicator(index)),
    );
  }

  /// Builds a single indicator dot
  ///
  /// Active indicator: 24px width, 8px height, white color
  /// Inactive indicator: 8px width, 8px height, 40% white opacity
  Widget _buildIndicator(int index) {
    final isActive = index == currentIndex;

    return Container(
      width: isActive
          ? CarouselConfig.activeIndicatorWidth
          : CarouselConfig.inactiveIndicatorWidth,
      height: CarouselConfig.indicatorHeight,
      margin: EdgeInsets.symmetric(
        horizontal: CarouselConfig.indicatorSpacing / 2,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? CarouselConfig.activeIndicatorColor
            : CarouselConfig.inactiveIndicatorColor,
        borderRadius: BorderRadius.circular(
          CarouselConfig.indicatorBorderRadius,
        ),
      ),
    );
  }
}
