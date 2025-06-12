// File: lib/src/core/business/business_config_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusinessConfig {
  final String id;
  final String name;
  final String type; // restaurant, retail, service, etc.
  final String slug; // URL-friendly identifier for business-specific routing
  final String logoUrl;
  final String coverImageUrl;
  final String description;
  final Map<String, dynamic> contactInfo;
  final Map<String, dynamic> address;
  final Map<String, dynamic> hours;
  final Map<String, dynamic> settings;
  final List<String> features;
  final bool isActive;

  BusinessConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.slug,
    required this.logoUrl,
    required this.coverImageUrl,
    required this.description,
    required this.contactInfo,
    required this.address,
    required this.hours,
    required this.settings,
    required this.features,
    required this.isActive,
  });

  factory BusinessConfig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BusinessConfig(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'restaurant',
      slug: data['slug'] as String? ??
          BusinessConfig._generateSlugFromName(data['name'] as String? ?? ''),
      logoUrl: data['logoUrl'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      description: data['description'] as String? ?? '',
      contactInfo: Map<String, dynamic>.from(
          data['contactInfo'] as Map<dynamic, dynamic>? ?? {}),
      address: Map<String, dynamic>.from(
          data['address'] as Map<dynamic, dynamic>? ?? {}),
      hours: Map<String, dynamic>.from(
          data['hours'] as Map<dynamic, dynamic>? ?? {}),
      settings: Map<String, dynamic>.from(
          data['settings'] as Map<dynamic, dynamic>? ?? {}),
      features: List<String>.from(data['features'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'slug': slug,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'description': description,
      'contactInfo': contactInfo,
      'address': address,
      'hours': hours,
      'settings': settings,
      'features': features,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper method to generate slug from business name
  static String _generateSlugFromName(String businessName) {
    if (businessName.isEmpty) return 'business';

    // Character mapping for accented characters to their base equivalents
    const accentMap = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'ā': 'a',
      'ă': 'a',
      'ą': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'ē': 'e',
      'ĕ': 'e',
      'ę': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ī': 'i',
      'ĭ': 'i',
      'į': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'ō': 'o',
      'ŏ': 'o',
      'ő': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ū': 'u',
      'ŭ': 'u',
      'ů': 'u',
      'ñ': 'n',
      'ň': 'n',
      'ņ': 'n',
      'ç': 'c',
      'ć': 'c',
      'č': 'c',
      'ĉ': 'c',
      'ċ': 'c',
      'ß': 'ss',
      'ý': 'y',
      'ÿ': 'y',
      'ž': 'z',
      'ź': 'z',
      'ż': 'z',
      'š': 's',
      'ś': 's',
      'ş': 's',
      'đ': 'd',
      'ď': 'd',
      'ğ': 'g',
      'ģ': 'g',
      'ķ': 'k',
      'ļ': 'l',
      'ľ': 'l',
      'ł': 'l',
      'ř': 'r',
      'ŕ': 'r',
      'ŗ': 'r',
      'ť': 't',
      'ţ': 't',
    };

    String normalized = businessName.toLowerCase().trim();

    // Replace accented characters
    for (final entry in accentMap.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    String slug = normalized
        .replaceAll(
            RegExp(r'[^a-z0-9\s]'), '') // Remove remaining special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens

    // Truncate to maximum length (50 characters)
    if (slug.length > 50) {
      slug = slug.substring(0, 50);
      // Remove trailing hyphen if truncation created one
      if (slug.endsWith('-')) {
        slug = slug.substring(0, slug.length - 1);
      }
    }

    return slug;
  }

  // Helper method to generate a unique slug
  static String generateSlug(String businessName) {
    final baseSlug = _generateSlugFromName(businessName);
    return baseSlug.isEmpty ? 'business' : baseSlug;
  }

  // Helper method to validate slug format
  static bool isValidSlug(String slug) {
    if (slug.isEmpty || slug.length < 2 || slug.length > 50) {
      return false;
    }

    // Check if slug contains only lowercase letters, numbers, and hyphens
    final validPattern = RegExp(r'^[a-z0-9-]+$');
    if (!validPattern.hasMatch(slug)) {
      return false;
    }

    // Check if slug starts or ends with hyphen
    if (slug.startsWith('-') || slug.endsWith('-')) {
      return false;
    }

    // Check for consecutive hyphens
    if (slug.contains('--')) {
      return false;
    }

    // Check against reserved words
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
      'businesssetup', // normalized version without hyphen
      'admin-setup',
      'adminsetup' // normalized version without hyphen
    };

    return !reservedSlugs.contains(slug);
  }

  // Helper method to sanitize slug input
  static String sanitizeSlug(String input) {
    return _generateSlugFromName(input);
  }

  // Create a copy of this object with updated fields
  BusinessConfig copyWith({
    String? name,
    String? type,
    String? slug,
    String? logoUrl,
    String? coverImageUrl,
    String? description,
    Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? address,
    Map<String, dynamic>? hours,
    Map<String, dynamic>? settings,
    List<String>? features,
    bool? isActive,
  }) {
    return BusinessConfig(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      slug: slug ?? this.slug,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      description: description ?? this.description,
      contactInfo: contactInfo ?? Map<String, dynamic>.from(this.contactInfo),
      address: address ?? Map<String, dynamic>.from(this.address),
      hours: hours ?? Map<String, dynamic>.from(this.hours),
      settings: settings ?? Map<String, dynamic>.from(this.settings),
      features: features ?? List<String>.from(this.features),
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper method to check if a feature is enabled
  bool hasFeature(String feature) {
    return features.contains(feature);
  }

  // Helper method to get a setting with a default value
  T getSetting<T>(String key, T defaultValue) {
    if (settings.containsKey(key)) {
      final value = settings[key];
      if (value is T) {
        return value;
      }
    }
    return defaultValue;
  }

  // Helper method to update settings
  BusinessConfig updateSettings(Map<String, dynamic> newSettings) {
    final updatedSettings = Map<String, dynamic>.from(settings);
    updatedSettings.addAll(newSettings);
    return copyWith(settings: updatedSettings);
  }

  // Helper method to update theme colors
  BusinessConfig updateThemeColors({
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? accentColor,
  }) {
    final updatedSettings = Map<String, dynamic>.from(settings);

    if (primaryColor != null) {
      updatedSettings['primaryColor'] = _colorToHex(primaryColor);
    }

    if (secondaryColor != null) {
      updatedSettings['secondaryColor'] = _colorToHex(secondaryColor);
    }

    if (tertiaryColor != null) {
      updatedSettings['tertiaryColor'] = _colorToHex(tertiaryColor);
    }

    if (accentColor != null) {
      updatedSettings['accentColor'] = _colorToHex(accentColor);
    }

    return copyWith(settings: updatedSettings);
  }

  // Helper method to convert Color to hex string
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

class BusinessConfigService {
  final FirebaseFirestore _firestore;

  BusinessConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get business configuration
  Future<BusinessConfig?> getBusinessConfig(String businessId) async {
    try {
      final doc =
          await _firestore.collection('businesses').doc(businessId).get();
      if (doc.exists) {
        return BusinessConfig.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching business config: $e');
      return null;
    }
  }

  // Stream business configuration for real-time updates
  Stream<BusinessConfig?> streamBusinessConfig(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return BusinessConfig.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update business configuration
  Future<void> updateBusinessConfig(BusinessConfig config) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(config.id)
          .update(config.toFirestore());
    } catch (e) {
      debugPrint('Error updating business config: $e');
      throw Exception('Failed to update business configuration: $e');
    }
  }

  // Create a new business configuration
  Future<String> createBusinessConfig(BusinessConfig config) async {
    try {
      final docRef = await _firestore.collection('businesses').add({
        ...config.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating business config: $e');
      throw Exception('Failed to create business configuration: $e');
    }
  }

  // Create a business configuration with a specific ID
  Future<void> createBusinessConfigWithId(
      String id, BusinessConfig config) async {
    try {
      await _firestore.collection('businesses').doc(id).set({
        ...config.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating business config with ID: $e');
      throw Exception('Failed to create business configuration: $e');
    }
  }

  // Check if a business ID already exists
  Future<bool> businessIdExists(String businessId) async {
    try {
      final doc =
          await _firestore.collection('businesses').doc(businessId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking business ID: $e');
      return false;
    }
  }

  // Update theme colors for a business
  Future<void> updateBusinessThemeColors(
    String businessId, {
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? accentColor,
  }) async {
    try {
      final businessDoc =
          await _firestore.collection('businesses').doc(businessId).get();

      if (!businessDoc.exists) {
        throw Exception('Business not found');
      }

      final currentSettings =
          businessDoc.data()?['settings'] as Map<dynamic, dynamic>? ?? {};

      // Copy existing settings
      final settings = Map<String, dynamic>.from(currentSettings);

      // Update colors
      if (primaryColor != null) {
        settings['primaryColor'] = _colorToHex(primaryColor);
      }

      if (secondaryColor != null) {
        settings['secondaryColor'] = _colorToHex(secondaryColor);
      }

      if (tertiaryColor != null) {
        settings['tertiaryColor'] = _colorToHex(tertiaryColor);
      }

      if (accentColor != null) {
        settings['accentColor'] = _colorToHex(accentColor);
      }

      // Update Firestore
      await _firestore.collection('businesses').doc(businessId).update({
        'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating business theme colors: $e');
      throw Exception('Failed to update business theme colors: $e');
    }
  }

  // Helper method to convert Color to hex string
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
