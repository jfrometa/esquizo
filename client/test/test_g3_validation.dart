// Test the business slug validation for 'g3'
import 'package:flutter/foundation.dart';

bool isValidBusinessSlug(String slug) {
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#')) {
    return false;
  }
  if (slug.startsWith('-') || slug.endsWith('-')) return false;
  if (slug.contains('--')) return false;

  final validPattern = RegExp(r'^[a-z0-9-]+$');
  if (!validPattern.hasMatch(slug)) return false;

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
    'menu',
    'carrito',
    'cuenta',
    'ordenes',
    'startup',
    'error',
    'onboarding',
    'business-setup',
    'admin-setup'
  };

  return !reservedSlugs.contains(slug);
}

void main() {
  debugPrint('Testing g3 slug validation:');
  debugPrint('g3 is valid: ${isValidBusinessSlug('g3')}');
  debugPrint('Length: ${'g3'.length}');
  debugPrint('Pattern match: ${RegExp(r'^[a-z0-9-]+$').hasMatch('g3')}');
  debugPrint('Reserved check: ${!{'admin', 'menu', 'carrito'}.contains('g3')}');

  // Test other potential issues
  debugPrint('\nAdditional tests:');
  debugPrint('Empty string: ${isValidBusinessSlug('')}');
  debugPrint('Single char: ${isValidBusinessSlug('a')}');
  debugPrint('menu (reserved): ${isValidBusinessSlug('menu')}');
  debugPrint('admin (reserved): ${isValidBusinessSlug('admin')}');
  debugPrint('kako: ${isValidBusinessSlug('kako')}');
}
