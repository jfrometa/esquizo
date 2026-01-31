// Copy the _isValidBusinessSlug function from app_router.dart
import 'package:flutter/foundation.dart';

bool _isValidBusinessSlug(String slug) {
  // Business slugs should:
  // - Be at least 2 characters long
  // - Not contain spaces or special routing characters
  // - Only contain lowercase letters, numbers, and hyphens
  // - Not start or end with hyphens
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#')) {
    return false;
  }
  if (slug.startsWith('-') || slug.endsWith('-')) return false;
  if (slug.contains('--')) return false; // No consecutive hyphens

  // Check valid pattern: lowercase letters, numbers, and hyphens only
  final validPattern = RegExp(r'^[a-z0-9-]+$');
  if (!validPattern.hasMatch(slug)) return false;

  // Check against reserved words (including default routes)
  final reservedSlugs = {
    'admin',
    'api',
    'www',
    'app',
    'help',
    'support',
    'about',
    'contact',
    'signin',
    'signup',
    'login',
    'logout',
    'register',
    'dashboard',
    'settings',
    'profile',
    'account',
    'billing',
    'pricing',
    'terms',
    'privacy',
    'legal',
    'security',
    'status',
    'blog',
    'news',
    'docs',
    'documentation',
    'guide',
    'tutorial',
    'faq',
    'mail',
    'email',
    'static',
    'assets',
    'images',
    'css',
    'js',
    'javascript',
    'fonts',
    'menu', // Default route
    'carrito', // Default route
    'cuenta', // Default route
    'ordenes', // Default route
    'startup',
    'error',
    'onboarding',
    'business-setup',
    'admin-setup'
  };

  return !reservedSlugs.contains(slug);
}

void main() {
  debugPrint('Testing business slug validation:');

  final testSlugs = [
    'g3',
    'kako',
    'restaurant-name',
    'admin',
    'menu',
    'test123',
    'a',
    'very-long-business-name-that-exceeds-fifty-characters'
  ];

  for (final slug in testSlugs) {
    final isValid = _isValidBusinessSlug(slug);
    debugPrint('  $slug: ${isValid ? 'VALID' : 'INVALID'}');
  }
}
