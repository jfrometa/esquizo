import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

// Optimize ParallaxHeader with RepaintBoundary
class EnhancedHeroSection extends StatelessWidget {
  final double scrollOffset;
  
  const EnhancedHeroSection({
    super.key,
    required this.scrollOffset,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    
    // Height calculation with parallax effect
    final heroHeight = isMobile ? size.height * 0.85 : size.height * 0.75;
    final parallaxOffset = scrollOffset * 0.4;
    
    return Container(
      width: double.infinity,
      height: heroHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: Stack(
        children: [
          // Background image with parallax effect - Wrapped in RepaintBoundary for better performance
          
             Positioned(
              top: -parallaxOffset.clamp(0.0, 100.0),
              left: 0,
              right: 0,
              height: heroHeight + 100, // Extra height for parallax
              child: RepaintBoundary(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.5),
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcOver,
                  // Use the OptimizedNetworkImage for better image loading
                  child: SizedBox.shrink()
                  
                  //  OptimizedNetworkImage(
                  //   imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
                  //   width: double.infinity,
                  //   height: double.infinity,
                  //   fit: BoxFit.cover,
                  //   backgroundColor: colorScheme.primary,
                  // ),
                ),
              ),
            ),
          
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withOpacity(0.3),
                  colorScheme.primary.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                      child: ClipOval(
                      child: Image.asset(
                        'assets/appIcon.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return const Icon(Icons.image_not_supported, size: 80);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Kako',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 36 : 48,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Experiencia Gastronómica Excepcional',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: isMobile ? 18 : 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Disfruta de comidas exquisitas, saludables y con presentación impecable, entregadas directamente a tu puerta o servidas en nuestro elegante restaurante.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isMobile ? 14 : 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.goNamed(AppRoute.home.name),
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Ver Menú'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Scroll indicator at bottom - Only build if needed (performance optimization)
          if (scrollOffset < 10)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: scrollOffset < 10 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      Text(
                        'Explorar',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
