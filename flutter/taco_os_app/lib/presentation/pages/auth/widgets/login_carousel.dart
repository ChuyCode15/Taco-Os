import 'package:flutter/material.dart';
import 'dart:async';
import 'carousel_config.dart';
import 'carousel_image_item.dart';
import 'carousel_indicators.dart';

/// Main carousel component for the login page.
///
/// Displays an interactive image carousel with automatic advancement,
/// manual swipe navigation, and position indicators. The carousel features
/// 5 images that automatically cycle every 3 seconds while allowing users
/// to manually swipe through them.
///
/// **Features:**
/// - Automatic image advancement every 3 seconds
/// - Manual swipe navigation (left/right)
/// - Bi-directional wraparound (first ↔ last)
/// - Visual position indicators
/// - Smooth transitions with ease-in-out curve
/// - Timer reset on user interaction
///
/// **Validates: Requirements 1.1, 1.2**
///
/// Example usage:
/// ```dart
/// Widget _buildContentSection() {
///   return Center(
///     child: Column(
///       children: [
///         const LoginCarousel(),
///         const SizedBox(height: 24),
///         Text('Tu negocio al alcance de tu mano'),
///       ],
///     ),
///   );
/// }
/// ```
class LoginCarousel extends StatefulWidget {
  const LoginCarousel({super.key});

  @override
  State<LoginCarousel> createState() => _LoginCarouselState();
}

/// State class for LoginCarousel managing page controller, timer, and current page.
///
/// **State Properties:**
/// - `_pageController`: Controls PageView navigation and animations
/// - `_autoAdvanceTimer`: Periodic timer for automatic page advancement
/// - `_currentPage`: Current active page index (0-4)
///
/// **Lifecycle:**
/// - `initState`: Initialize controller, start timer, preload images
/// - `dispose`: Cancel timer and dispose controller to prevent memory leaks
///
/// **Validates: Requirements 1.1, 1.2, 2.1, 2.2, 2.3, 2.4**
class _LoginCarouselState extends State<LoginCarousel> {
  /// Controller for programmatic page navigation and animations.
  ///
  /// Initialized with page 0 to display the first image by default.
  late PageController _pageController;

  /// Timer for automatic page advancement.
  ///
  /// Fires every 3 seconds to advance to the next page.
  /// Cancelled and restarted when user interacts with the carousel.
  Timer? _autoAdvanceTimer;

  /// Current active page index (0-based, 0-4 for 5 images).
  ///
  /// Updated when page changes through automatic advancement or user swipe.
  /// Used to highlight the correct position indicator.
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Initialize PageController with first page
    _pageController = PageController(initialPage: 0);

    // Delay timer start until after first frame to ensure PageView is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAutoAdvance();
        _preloadImages();
      }
    });
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Starts the automatic page advancement timer.
  ///
  /// Creates a periodic timer that fires every 3 seconds (CarouselConfig.autoPlayInterval)
  /// to automatically advance to the next page.
  ///
  /// **Validates: Requirement 2.1** - Automatic advancement every 3 seconds
  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(
      CarouselConfig.autoPlayInterval,
      (_) => _autoAdvance(),
    );
  }

  /// Stops the automatic page advancement timer.
  ///
  /// Cancels the timer and sets it to null. Called when user interacts
  /// with the carousel to reset the auto-advance countdown.
  ///
  /// **Validates: Requirement 2.3** - Reset timer on user interaction
  void _stopAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  /// Advances to the next page with animation.
  ///
  /// Calculates the next page index with wraparound (4 → 0) and animates
  /// to that page using the configured transition duration and curve.
  ///
  /// Guards against calling after widget is disposed by checking `mounted`.
  ///
  /// **Validates: Requirement 2.2** - Wraparound from last to first
  void _autoAdvance() {
    if (!mounted) return;

    final nextPage = (_currentPage + 1) % CarouselConfig.imageCount;
    _pageController.animateToPage(
      nextPage,
      duration: CarouselConfig.transitionDuration,
      curve: CarouselConfig.transitionCurve,
    );
  }

  /// Callback when page changes (auto-advance or user swipe).
  ///
  /// Updates the current page index, stops the existing timer, and starts
  /// a fresh timer to resume automatic advancement after 3 seconds.
  ///
  /// **Parameters:**
  /// - [page]: New page index (0-4)
  ///
  /// **Validates: Requirement 2.4** - Resume auto-advance 3 seconds after interaction
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Restart timer with fresh 3-second countdown
    _stopAutoAdvance();
    _startAutoAdvance();
  }

  /// Preloads all carousel images to prevent loading delays during transitions.
  ///
  /// Iterates through all carousel image paths and preloads them using
  /// Flutter's `precacheImage`. Catches and logs any loading failures
  /// without blocking the carousel initialization.
  ///
  /// **Validates: Requirement 8.1** - Preload all images on initialization
  Future<void> _preloadImages() async {
    for (final imagePath in CarouselConfig.getAllImagePaths()) {
      try {
        await precacheImage(AssetImage(imagePath), context);
      } catch (e) {
        debugPrint('Failed to preload image: $imagePath');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Column(
      children: [
        // Carousel PageView - Full screen dimensions
        SizedBox(
          width: CarouselConfig.maxWidth ?? screenWidth,
          height: CarouselConfig.maxHeight ?? screenHeight * 0.6,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: CarouselConfig.imageCount,
            itemBuilder: (context, index) {
              return CarouselImageItem(index: index);
            },
          ),
        ),

        const SizedBox(height: 16),

        // Position Indicators
        CarouselIndicators(
          currentIndex: _currentPage,
          pageCount: CarouselConfig.imageCount,
        ),
      ],
    );
  }
}
