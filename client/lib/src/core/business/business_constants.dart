// Business constants for routing and configuration
// Single source of truth for default business values

/// Centralized business constants used throughout the app
abstract class BusinessConstants {
  /// The default business slug used when no specific business is specified
  /// This is the primary business that loads at the root URL
  static const String defaultSlug = 'kako';

  /// The default business ID used for database lookups
  static const String defaultBusinessId = 'kako';

  /// Minimum length for valid business slugs
  static const int minSlugLength = 2;

  /// Maximum length for valid business slugs
  static const int maxSlugLength = 50;

  /// Check if a given slug is the default business
  static bool isDefaultBusiness(String? slug) {
    return slug == null || slug.isEmpty || slug == defaultSlug;
  }

  /// Get the effective slug (returns default if null/empty)
  static String effectiveSlug(String? slug) {
    return (slug == null || slug.isEmpty) ? defaultSlug : slug;
  }
}
