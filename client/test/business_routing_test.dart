// Test file to verify business routing architecture implementation
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';

void main() {
  group('Business Routing Architecture Tests', () {
    test('Business slug extraction works correctly', () {
      // Test business slug extraction from various URL patterns
      expect(extractBusinessSlugFromPath('/g2'), equals('g2'));
      expect(extractBusinessSlugFromPath('/g2/menu'), equals('g2'));
      expect(extractBusinessSlugFromPath('/restaurant-name'),
          equals('restaurant-name'));
      expect(extractBusinessSlugFromPath('/restaurant-name/carrito'),
          equals('restaurant-name'));

      // Test system routes that should not be treated as business slugs
      expect(extractBusinessSlugFromPath('/admin'), isNull);
      expect(extractBusinessSlugFromPath('/signin'), isNull);
      expect(extractBusinessSlugFromPath('/business-setup'), isNull);
      expect(
          extractBusinessSlugFromPath('/menu'), isNull); // Default route access
      expect(extractBusinessSlugFromPath('/carrito'),
          isNull); // Default route access

      // Test edge cases
      expect(extractBusinessSlugFromPath('/'), isNull);
      expect(extractBusinessSlugFromPath(''), isNull);
    });

    test('Business slug validation works correctly', () {
      // Valid business slugs
      expect(_isValidBusinessSlug('g2'), isTrue);
      expect(_isValidBusinessSlug('restaurant'), isTrue);
      expect(_isValidBusinessSlug('my-restaurant'), isTrue);
      expect(_isValidBusinessSlug('restaurant123'), isTrue);

      // Invalid business slugs
      expect(_isValidBusinessSlug('a'), isFalse); // Too short
      expect(_isValidBusinessSlug(''), isFalse); // Empty
      expect(
          _isValidBusinessSlug('-restaurant'), isFalse); // Starts with hyphen
      expect(_isValidBusinessSlug('restaurant-'), isFalse); // Ends with hyphen
      expect(
          _isValidBusinessSlug('restaurant--name'), isFalse); // Double hyphen
      expect(
          _isValidBusinessSlug('restaurant name'), isFalse); // Contains space
      expect(_isValidBusinessSlug('restaurant?'),
          isFalse); // Contains special char
    });
  });
}

/// Helper function to test slug validation (copied from business_routing_provider.dart)
bool _isValidBusinessSlug(String slug) {
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#'))
    return false;
  if (slug.startsWith('-') || slug.endsWith('-')) return false;
  if (slug.contains('--')) return false;

  final validPattern = RegExp(r'^[a-z0-9-]+$');
  if (!validPattern.hasMatch(slug)) return false;

  return true;
}
