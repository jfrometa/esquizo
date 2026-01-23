import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';

void main() {
  group('Business Slug Generation Utility Tests', () {
    test('slug generation for various business name formats', () {
      final testCases = [
        {
          'name': 'Café & Restaurante "El Patrón"',
          'expected': 'cafe-restaurante-el-patron',
          'description':
              'Business name with accented characters and special symbols'
        },
        {
          'name': 'Restaurant 123 & Café 2024',
          'expected': 'restaurant-123-cafe-2024',
          'description': 'Business name with numbers and ampersand'
        },
        {
          'name': 'The   Best    Pizza Place!!!',
          'expected': 'the-best-pizza-place',
          'description':
              'Business name with multiple spaces and exclamation marks'
        },
        {
          'name': 'José\'s Taco & Burrito Bar',
          'expected': 'joses-taco-burrito-bar',
          'description': 'Business name with apostrophe and accented character'
        },
        {
          'name': 'München Bier Haus',
          'expected': 'munchen-bier-haus',
          'description': 'German business name with umlaut'
        },
        {
          'name': 'La Niña Bonita',
          'expected': 'la-nina-bonita',
          'description': 'Spanish business name with tilde'
        },
        {
          'name':
              'This is a very long restaurant name that exceeds normal length limits for business names in most systems and should be truncated properly',
          'expected': null, // We'll check length constraint instead
          'description': 'Very long business name that should be truncated'
        },
        {
          'name': '123 Pizza Place',
          'expected': '123-pizza-place',
          'description': 'Business name starting with numbers'
        },
        {
          'name': 'A',
          'expected': null, // Too short, will be invalid
          'description': 'Single character business name (too short)'
        },
        {
          'name': '',
          'expected': 'business',
          'description': 'Empty business name (fallback)'
        }
      ];

      for (final testCase in testCases) {
        final businessName = testCase['name'] as String;
        final expectedSlug = testCase['expected'];
        final description = testCase['description'] as String;

        print('\n--- Testing: $description ---');
        print('Input: "$businessName"');

        final generatedSlug = BusinessConfig.generateSlug(businessName);
        print('Generated slug: "$generatedSlug"');
        print('Length: ${generatedSlug.length}');
        print('Is valid: ${BusinessConfig.isValidSlug(generatedSlug)}');

        // Validate constraints
        expect(generatedSlug.length, lessThanOrEqualTo(50),
            reason: 'Slug should not exceed 50 characters');

        if (expectedSlug != null) {
          expect(generatedSlug, equals(expectedSlug),
              reason: 'Generated slug should match expected for: $description');
          expect(BusinessConfig.isValidSlug(generatedSlug), isTrue,
              reason: 'Generated slug should be valid for: $description');
        }

        // Test that all generated slugs follow the format rules
        if (generatedSlug.isNotEmpty) {
          expect(RegExp(r'^[a-z0-9-]+$').hasMatch(generatedSlug), isTrue,
              reason:
                  'Slug should only contain lowercase letters, numbers, and hyphens');
          expect(generatedSlug.startsWith('-'), isFalse,
              reason: 'Slug should not start with hyphen');
          expect(generatedSlug.endsWith('-'), isFalse,
              reason: 'Slug should not end with hyphen');
          expect(generatedSlug.contains('--'), isFalse,
              reason: 'Slug should not contain consecutive hyphens');
        }
      }
    });

    test('slug generation edge cases and unicode handling', () {
      final unicodeTestCases = [
        {
          'name': 'Sushi 寿司 Restaurant',
          'description': 'Japanese characters (should be removed)'
        },
        {
          'name': 'Кафе Москва',
          'description': 'Cyrillic characters (should be removed)'
        },
        {
          'name': 'مطعم الشام',
          'description': 'Arabic characters (should be removed)'
        },
        {'name': 'Café Français', 'description': 'French accented characters'},
        {'name': 'Straße Restaurant', 'description': 'German eszett character'},
      ];

      for (final testCase in unicodeTestCases) {
        final businessName = testCase['name'] as String;
        final description = testCase['description'] as String;

        print('\n--- Testing Unicode: $description ---');
        print('Input: "$businessName"');

        final generatedSlug = BusinessConfig.generateSlug(businessName);
        print('Generated slug: "$generatedSlug"');

        // Should produce a valid slug or fallback
        if (generatedSlug.isNotEmpty) {
          expect(BusinessConfig.isValidSlug(generatedSlug), isTrue,
              reason: 'Unicode input should produce valid slug or fallback');
        }
      }
    });

    test('reserved word handling', () {
      final reservedWords = [
        'admin',
        'api',
        'signin',
        'signup',
        'dashboard',
        'settings',
        'menu',
        'business-setup'
      ];

      for (final word in reservedWords) {
        print('\n--- Testing reserved word: $word ---');
        final slug = BusinessConfig.generateSlug(word);
        print('Generated slug: "$slug"');
        print('Is valid: ${BusinessConfig.isValidSlug(slug)}');

        // Reserved words should not be valid slugs
        expect(BusinessConfig.isValidSlug(slug), isFalse,
            reason: '$word should be rejected as reserved word');
      }
    });

    test('slug sanitization utility', () {
      final testInputs = [
        'Normal Restaurant Name',
        'UPPERCASE RESTAURANT',
        'Restaurant!!!   With   Weird    Spacing!!!',
        '---Leading-and-trailing-hyphens---',
        'Multiple---Consecutive---Hyphens',
      ];

      for (final input in testInputs) {
        print('\n--- Testing sanitization: "$input" ---');
        final sanitized = BusinessConfig.sanitizeSlug(input);
        print('Sanitized: "$sanitized"');

        if (sanitized.isNotEmpty) {
          expect(RegExp(r'^[a-z0-9-]+$').hasMatch(sanitized), isTrue,
              reason: 'Sanitized slug should only contain valid characters');
        }
      }
    });
  });
}
