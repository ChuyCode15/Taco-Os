import 'package:flutter/material.dart';
import 'carousel_config.dart';

/// Widget that displays a single carousel image item.
///
/// This widget renders an individual image from the carousel with proper
/// styling, dimensions, and error handling. It's designed to be used within
/// a PageView in the LoginCarousel component.
///
/// **Validates: Requirements 1.3, 1.5, 1.6, 6.4**
class CarouselImageItem extends StatelessWidget {
  /// The index of the carousel image to display (0-based).
  ///
  /// This index is used to generate the asset path through CarouselAssets.
  /// For example, index 0 displays carousel_1.png, index 1 displays carousel_2.png, etc.
  final int index;

  /// Creates a carousel image item widget.
  ///
  /// **Parameters:**
  /// - [index]: Zero-based index of the image (0-4)
  ///
  /// **Example:**
  /// ```dart
  /// CarouselImageItem(index: 0) // Displays carousel_1.png
  /// CarouselImageItem(index: 4) // Displays carousel_5.png
  /// ```
  const CarouselImageItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Get the image path using the index directly (0-4)
    final imagePath = CarouselConfig.getImagePath(index);

    return ClipRRect(
      borderRadius: BorderRadius.circular(CarouselConfig.borderRadius),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover, // Changed to cover to fill the entire space
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // Display error placeholder with app's primary blue color
          // when image fails to load
          return _buildErrorPlaceholder();
        },
      ),
    );
  }

  /// Builds the error placeholder UI when an image fails to load.
  ///
  /// The placeholder displays:
  /// - Background with app's primary blue color (#5B7FFF)
  /// - Icon indicating image loading failure
  /// - Text showing which image failed to load
  ///
  /// **Validates: Requirement 6.4** - Display placeholder with app's blue color
  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF5B7FFF), // App's primary blue color
        borderRadius: BorderRadius.circular(CarouselConfig.borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Image ${index + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
