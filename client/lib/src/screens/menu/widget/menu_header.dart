import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/reservation/reservation_screen.dart';
// Add this import for navigation

class MenuHeader extends StatelessWidget {
  final double scrollOffset;
  final bool isScrolling;
  final double parallaxFactor;
  final Animation<double> opacityAnimation;

  // Use const constructor for better performance
  const MenuHeader({
    super.key,
    required this.scrollOffset,
    required this.isScrolling,
    this.parallaxFactor = 0.5,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.sizeOf(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Pre-calculate values outside layout calculations
    final headerParallaxOffset = scrollOffset * parallaxFactor;
    final headerScaleValue = 1.0 - (scrollOffset * 0.0005).clamp(0.0, 0.15);
    final headerBlurValue = (scrollOffset * 0.05).clamp(0.0, 10.0);
    final clampedParallaxOffset = headerParallaxOffset.clamp(0.0, 150.0);
    final alignmentValue = (0.5 - headerParallaxOffset / 500).clamp(-1.0, 1.0);
    final progressWidth = mediaQuery.width * (scrollOffset / 1000).clamp(0.0, 1.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      top: -clampedParallaxOffset,
      left: 0,
      right: 0,
      height: 200,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: headerScaleValue,
        alignment: Alignment.topCenter,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background with gradient fallback for missing image
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDarkMode ? Colors.white : Colors.black,
                    Colors.transparent,
                  ],
                  stops: const [0.7, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  image: DecorationImage(
                    image: const AssetImage('assets/images/food_background.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      colorScheme.shadow.withOpacity(0.35),
                      BlendMode.darken,
                    ),
                    alignment: Alignment(0, alignmentValue),
                    onError: (_, __) {
                      // Silent fallback to gradient when image fails to load
                    },
                  ),
                ),
              ),
            ),

            // Only apply blur effect when actually scrolling and blur is visible
            if (isScrolling && headerBlurValue > 0.5)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: headerBlurValue,
                  sigmaY: headerBlurValue,
                ),
                child: const ColoredBox(color: Colors.transparent),
              ),
            
            // Scroll progress indicator - wrap with RepaintBoundary
            Positioned(
              bottom: 0,
              left: 0,
              child: RepaintBoundary(
                child: FadeTransition(
                  opacity: opacityAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    color: colorScheme.primary,
                    width: progressWidth,
                  ),
                ),
              ),
            ),

            // Centered reservation button with animation
            Positioned(
              top: 80, // Position in the middle of the header
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.calendar_month_rounded, size: 24),
                      label: const Text(
                        'Reserve Your Table',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReservationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Scroll progress indicator - wrap with RepaintBoundary
            Positioned(
              bottom: 0,
              left: 0,
              child: RepaintBoundary(
                child: FadeTransition(
                  opacity: opacityAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    color: colorScheme.primary,
                    width: progressWidth,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Remove the _buildReservationButton method as it's no longer needed
}