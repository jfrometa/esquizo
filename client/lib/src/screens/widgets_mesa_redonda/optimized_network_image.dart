import 'package:flutter/material.dart';

class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final bool enableMemoryCache;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.enableMemoryCache = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPlaceholder = Container(
      width: width,
      height: height,
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.image,
          size: 24,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );

    final defaultError = Container(
      width: width,
      height: height,
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: 24,
          color: Theme.of(context).colorScheme.error.withOpacity(0.5),
        ),
      ),
    );

    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: frame != null
              ? child
              : placeholder ?? defaultPlaceholder,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? defaultError;
      },
      // Memory cache settings can be important for performance
      cacheWidth: enableMemoryCache ? _calculateCacheWidth(width) : null,
      cacheHeight: enableMemoryCache ? _calculateCacheHeight(height) : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return placeholder ?? defaultPlaceholder;
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  // Calculate optimal cache dimensions to avoid storing unnecessarily large images in memory
  int? _calculateCacheWidth(double? width) {
    if (width == null) return null;
    // Limit cache size for better memory usage
    return (width * 2).round(); // Account for high-density displays with 2x factor
  }

  int? _calculateCacheHeight(double? height) {
    if (height == null) return null;
    return (height * 2).round();
  }
}