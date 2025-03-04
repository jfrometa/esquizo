import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class MenuHeader extends StatelessWidget {
  final double scrollOffset;
  final bool isScrolling;
  final double parallaxFactor;
  final Animation<double> opacityAnimation;

  const MenuHeader({
    Key? key,
    required this.scrollOffset,
    required this.isScrolling,
    this.parallaxFactor = 0.5,
    required this.opacityAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    
    // Calculate parallax effect transforms
    final headerParallaxOffset = scrollOffset * parallaxFactor;
    final headerScaleValue = 1.0 - (scrollOffset * 0.0005).clamp(0.0, 0.15);
    final headerBlurValue = (scrollOffset * 0.05).clamp(0.0, 10.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      top: -headerParallaxOffset.clamp(0.0, 150.0),
      left: 0,
      right: 0,
      height: 200, // Fixed height for header
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: headerScaleValue,
        alignment: Alignment.topCenter,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with dynamic alignment based on scroll
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
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
                      ColorsPaletteRedonda.primary,
                      ColorsPaletteRedonda.primary.withOpacity(0.8),
                    ],
                  ),
                  image: DecorationImage(
                    image: const AssetImage('assets/images/food_background.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.35),
                      BlendMode.darken,
                    ),
                    alignment: Alignment(
                      0,
                      (0.5 - headerParallaxOffset / 500).clamp(-1.0, 1.0),
                    ),
                  ),
                ),
              ),
            ),

            // Conditional blur effect based on scroll
            if (isScrolling)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: headerBlurValue),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: value,
                      sigmaY: value,
                    ),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  );
                },
              ),
            
            // Scroll progress indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: opacityAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2,
                  color: colorScheme.primary,
                  width: mediaQuery.size.width * 
                      (scrollOffset / 1000).clamp(0.0, 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}