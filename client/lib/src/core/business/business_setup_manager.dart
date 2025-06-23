// File: lib/src/core/setup/business_setup_manager.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'dart:async';

import '../firebase/firebase_providers.dart';
import '../local_storange/local_storage_service.dart';
import '../business/business_features_service.dart';

// Manages the business setup process
class BusinessSetupManager {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;
  final LocalStorageService _localStorageService;

  BusinessSetupManager({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
    required FirebaseDatabase database,
    required LocalStorageService localStorageService,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth,
        _database = database,
        _localStorageService = localStorageService;

  // Check if a business is set up
  Future<bool> isBusinessSetup() async {
    try {
      // Get stored business ID
      final businessId = await _localStorageService.getString('businessId');
      if (businessId == null || businessId.isEmpty) {
        return false;
      }

      // Check if business exists in Firestore and is active
      final businessDoc =
          await _firestore.collection('businesses').doc(businessId).get();

      if (!businessDoc.exists) {
        return false;
      }

      final data = businessDoc.data() ?? {};
      final isActive = data['isActive'] as bool? ?? true;

      return isActive;
    } catch (e) {
      debugPrint('Error checking business setup: $e');
      return false;
    }
  }

  // Create a new business configuration
  Future<BusinessCreationResult> createBusinessConfig({
    required String businessName,
    required String businessType,
    required Color primaryColor,
    required Color secondaryColor,
    required Color tertiaryColor,
    required Color accentColor,
    File? logoLight,
    File? logoDark,
    File? coverImage,
    Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? address,
  }) async {
    try {
      // Generate a business ID from name
      final businessId = _generateBusinessId(businessName);

      // Generate a business slug from name (for URL routing)
      final businessSlug = await _generateUniqueSlug(businessName);

      // Upload logos if provided
      String logoLightUrl = '';
      String logoDarkUrl = '';
      String coverImageUrl = '';

      if (logoLight != null) {
        logoLightUrl = await _uploadFile(logoLight, '$businessId/logo_light');
      }

      if (logoDark != null) {
        logoDarkUrl = await _uploadFile(logoDark, '$businessId/logo_dark');
      }

      if (coverImage != null) {
        coverImageUrl =
            await _uploadFile(coverImage, '$businessId/cover_image');
      }

      // Create business document
      final businessData = {
        'name': businessName,
        'type': businessType,
        'slug': businessSlug,
        'logoUrl': logoLightUrl,
        'logoDarkUrl': logoDarkUrl,
        'coverImageUrl': coverImageUrl,
        'description': '',
        'contactInfo': contactInfo ?? {},
        'address': address ?? {},
        'hours': {},
        'settings': {
          'primaryColor': _colorToHex(primaryColor),
          'secondaryColor': _colorToHex(secondaryColor),
          'tertiaryColor': _colorToHex(tertiaryColor),
          'accentColor': _colorToHex(accentColor),
          'darkMode': false,
          'currency': 'USD',
          'taxRate': 0.0,
          'serviceCharge': 0.0,
        },
        'features': [
          'online_ordering',
          'table_management',
        ],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .set(businessData);

      // Create business relationship to establish ownership
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('business_relationships').add({
          'businessId': businessId,
          'userId': currentUser.uid,
          'role': 'owner',
          'email': currentUser.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint(
            '✅ Business relationship created: ${currentUser.uid} -> $businessId');
      } else {
        debugPrint(
            '⚠️ No authenticated user found, skipping business relationship creation');
      }

      // Save business ID to local storage
      await _localStorageService.setString('businessId', businessId);

      // Initialize business features in Realtime Database
      await _initializeBusinessFeaturesInRTDB(businessId, businessType);

      return BusinessCreationResult(
          businessId: businessId, businessSlug: businessSlug);
    } catch (e) {
      debugPrint('Error creating business config: $e');
      throw Exception('Failed to create business configuration: $e');
    }
  }

  // Update an existing business configuration
  Future<void> updateBusinessConfig({
    required String businessId,
    String? businessName,
    String? businessType,
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? accentColor,
    File? logoLight,
    File? logoDark,
    File? coverImage,
    Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? address,
    Map<String, dynamic>? hours,
    Map<String, dynamic>? settings,
    List<String>? features,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update fields if provided
      if (businessName != null) {
        updateData['name'] = businessName;
      }

      if (businessType != null) {
        updateData['type'] = businessType;
      }

      // Upload new logos if provided
      if (logoLight != null) {
        final logoUrl = await _uploadFile(logoLight, '$businessId/logo_light');
        updateData['logoUrl'] = logoUrl;
      }

      if (logoDark != null) {
        final logoDarkUrl =
            await _uploadFile(logoDark, '$businessId/logo_dark');
        updateData['logoDarkUrl'] = logoDarkUrl;
      }

      if (coverImage != null) {
        final coverUrl =
            await _uploadFile(coverImage, '$businessId/cover_image');
        updateData['coverImageUrl'] = coverUrl;
      }

      // Update contact info if provided
      if (contactInfo != null) {
        updateData['contactInfo'] = contactInfo;
      }

      // Update address if provided
      if (address != null) {
        updateData['address'] = address;
      }

      // Update hours if provided
      if (hours != null) {
        updateData['hours'] = hours;
      }

      // Update settings with colors if provided
      if (settings != null ||
          primaryColor != null ||
          secondaryColor != null ||
          tertiaryColor != null ||
          accentColor != null) {
        // Get current settings first
        final businessDoc =
            await _firestore.collection('businesses').doc(businessId).get();

        Map<String, dynamic> currentSettings = {};
        if (businessDoc.exists && businessDoc.data()?['settings'] != null) {
          currentSettings =
              Map<String, dynamic>.from(businessDoc.data()!['settings']);
        }

        // Merge with new settings
        final updatedSettings = {...currentSettings, ...(settings ?? {})};

        // Add colors if provided
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

        updateData['settings'] = updatedSettings;
      }

      // Update features if provided
      if (features != null) {
        updateData['features'] = features;
      }

      // Update Firestore document
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .update(updateData);
    } catch (e) {
      debugPrint('Error updating business config: $e');
      throw Exception('Failed to update business configuration: $e');
    }
  }

  // Initialize business features in Firebase Realtime Database based on business type
  // This uses Material Design 3 principles to ensure a coherent user experience
  Future<void> _initializeBusinessFeaturesInRTDB(
      String businessId, String businessType) async {
    try {
      debugPrint(
          '🔄 Initializing business features in RTDB for $businessId (type: $businessType)');

      // Get database reference for this business
      final businessRef = _database.ref('business/$businessId');

      // Set up features and UI based on business type using our helper methods
      final BusinessFeatures features =
          _getDefaultFeaturesForBusinessType(businessType);
      final BusinessUI ui = _getDefaultUIForBusinessType(businessType);

      // Log what we're setting up
      debugPrint('📊 Business features configuration:');
      debugPrint('  - Catering: ${features.catering}');
      debugPrint('  - Meal Plans: ${features.mealPlans}');
      debugPrint('  - In-Dine: ${features.inDine}');
      debugPrint('  - Staff: ${features.staff}');
      debugPrint('  - Kitchen: ${features.kitchen}');
      debugPrint('  - Reservations: ${features.reservations}');

      debugPrint('🎨 Business UI configuration:');
      debugPrint('  - Landing Page: ${ui.landingPage}');
      debugPrint('  - Orders: ${ui.orders}');

      // Create the updates for both features and UI
      final updates = {
        'features': features.toMap(),
        'ui': ui.toMap(),
        'metadata': {
          'lastUpdated': ServerValue.timestamp,
          'businessType': businessType,
          'version': '1.0',
        }
      };

      // Update Realtime Database
      await businessRef.update(updates);

      debugPrint('✅ Business features initialized in RTDB for $businessId');

      // Verify the data was written correctly
      final snapshot = await businessRef.get();
      if (snapshot.exists) {
        debugPrint('✓ Verification successful - data written to RTDB');
      } else {
        debugPrint(
            '⚠️ Verification warning - could not confirm data was written');
      }
    } catch (e) {
      debugPrint('❌ Error initializing business features in RTDB: $e');
      // Don't throw here - we want business creation to succeed even if RTDB fails

      // Try a fallback approach with a simpler write
      try {
        debugPrint('🔄 Attempting fallback initialization');
        final businessRef = _database.ref('business/$businessId');

        // Create minimal updates with default values
        final fallbackUpdates = {
          'features': const BusinessFeatures().toMap(),
          'ui': const BusinessUI().toMap(),
        };

        await businessRef.update(fallbackUpdates);
        debugPrint('✅ Fallback initialization successful');
      } catch (fallbackError) {
        debugPrint('❌❌ Fallback initialization also failed: $fallbackError');
      }
    }
  }

  // Get default features based on business type
  BusinessFeatures _getDefaultFeaturesForBusinessType(String businessType) {
    // Set defaults based on type of business following Material Design 3 best practices
    // Each business type gets a tailored experience with only relevant features
    debugPrint('🎯 Configuring features for business type: $businessType');

    switch (businessType.toLowerCase()) {
      case 'restaurant':
        // Full-service restaurants typically need all features
        return const BusinessFeatures(
          catering: true, // Restaurants often offer catering services
          mealPlans: true, // Meal subscription/plans are common for restaurants
          inDine: true, // In-restaurant dining is core functionality
          staff: true, // Staff management for waitstaff, hosts, etc.
          kitchen: true, // Kitchen display system for order management
          reservations: true, // Table reservations
        );

      case 'cafe':
        // Cafes usually have simpler operations
        return const BusinessFeatures(
          catering: true, // Small event catering is common
          mealPlans: false, // Subscription plans less common for cafes
          inDine: true, // In-cafe seating is typical
          staff: true, // Staff scheduling for baristas and servers
          kitchen: true, // Simple kitchen operations
          reservations: false, // Typically don't need reservations
        );

      case 'food_truck':
        // Mobile food businesses have limited space and services
        return const BusinessFeatures(
          catering: true, // Event catering is often a major revenue source
          mealPlans: false, // Typically don't offer subscription plans
          inDine: false, // No in-house dining
          staff: true, // Small staff management
          kitchen: true, // Mobile kitchen management
          reservations: false, // No reservations needed
        );

      case 'catering':
        // Catering-focused businesses
        return const BusinessFeatures(
          catering: true, // Core business function
          mealPlans: true, // Often offer recurring meal plans
          inDine: false, // Typically no restaurant space
          staff: true, // Event staff management
          kitchen: true, // Kitchen operations
          reservations: false, // Event booking, not table reservations
        );

      case 'ghost_kitchen':
        // Delivery-only restaurants
        return const BusinessFeatures(
          catering: true, // May offer catering
          mealPlans: true, // Subscription meals common for ghost kitchens
          inDine: false, // No dining room by definition
          staff: true, // Kitchen staff
          kitchen: true, // Core functionality
          reservations: false, // No dining room = no reservations
        );

      case 'bakery':
        return const BusinessFeatures(
          catering: true, // Often cater events
          mealPlans: false, // Rarely offer meal subscriptions
          inDine: true, // May have small café section
          staff: true, // Staff scheduling
          kitchen: true, // Baking operations
          reservations: false, // Typically don't take reservations
        );

      default:
        // Default to all features enabled for unknown business types
        debugPrint(
            '⚠️ Unknown business type: $businessType - using default configuration');
        return const BusinessFeatures();
    }
  }

  // Get default UI configuration based on business type
  BusinessUI _getDefaultUIForBusinessType(String businessType) {
    // Configure UI components based on business type and Material Design 3 best practices
    // Focus on simplified, task-oriented UIs tailored to each business model
    debugPrint('🖼 Configuring UI for business type: $businessType');

    switch (businessType.toLowerCase()) {
      case 'restaurant':
        // Full-service restaurants benefit from all UI components
        return const BusinessUI(
          landingPage: true, // Landing page creates brand presence
          orders: true, // Order management is essential
        );

      case 'cafe':
        // Cafes typically want a landing page to showcase atmosphere
        return const BusinessUI(
          landingPage: true, // Showcase cafe ambiance and specials
          orders: true, // Order tracking for customers
        );

      case 'food_truck':
        // Mobile businesses need simplified UI
        return const BusinessUI(
          landingPage: true, // Location information and schedule
          orders: true, // Order tracking is important
        );

      case 'ghost_kitchen':
        // Delivery-only operations need functional UI without branding focus
        return const BusinessUI(
          landingPage: false, // Skip landing page - go straight to ordering
          orders: true, // Focus on order management
        );

      case 'catering':
        // Catering businesses focus on showcasing services
        return const BusinessUI(
          landingPage: true, // Showcase services and gallery
          orders: true, // Event/order management
        );

      case 'bakery':
        return const BusinessUI(
          landingPage: true, // Showcase products
          orders: true, // Order management
        );

      case 'quick_service':
        // Fast food or quick service
        return const BusinessUI(
          landingPage: false, // Skip to menu for faster ordering
          orders: true, // Focus on order management
        );

      default:
        // Default to all UI elements enabled for unknown business types
        debugPrint(
            '⚠️ Unknown business type: $businessType - using default UI configuration');
        return const BusinessUI();
    }
  }

  // Generate a business ID from name
  String _generateBusinessId(String businessName) {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final nameSlug = businessName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return '${nameSlug}_$timestamp';
  }

  // Upload a file to Firebase Storage
  Future<String> _uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  // Convert Color to hex string
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  // Generate a unique slug for the business
  Future<String> _generateUniqueSlug(String businessName) async {
    String baseSlug = businessName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens

    if (baseSlug.isEmpty) {
      baseSlug = 'business';
    }

    // Check if the slug already exists
    String finalSlug = baseSlug;
    int counter = 1;

    while (await _slugExists(finalSlug)) {
      finalSlug = '$baseSlug-$counter';
      counter++;
    }

    return finalSlug;
  }

  // Check if a slug already exists in Firestore
  Future<bool> _slugExists(String slug) async {
    try {
      final querySnapshot = await _firestore
          .collection('businesses')
          .where('slug', isEqualTo: slug)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking slug existence: $e');
      return false; // Assume it doesn't exist if there's an error
    }
  }
}

// Result class for business creation
class BusinessCreationResult {
  final String businessId;
  final String businessSlug;

  const BusinessCreationResult({
    required this.businessId,
    required this.businessSlug,
  });
}

// Provider for BusinessSetupManager
final businessSetupManagerProvider = Provider<BusinessSetupManager>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  final auth = ref.watch(firebaseAuthProvider);
  final database = ref.watch(firebaseDatabaseProvider);
  final localStorage = ref.watch(localStorageServiceProvider);

  return BusinessSetupManager(
    firestore: firestore,
    storage: storage,
    auth: auth,
    database: database,
    localStorageService: localStorage,
  );
});

// Provider to check if business is set up
final isBusinessSetupProvider = FutureProvider<bool>((ref) async {
  final setupManager = ref.watch(businessSetupManagerProvider);
  return setupManager.isBusinessSetup();
});

// Default business colors provider
final defaultBusinessColorsProvider = Provider<Map<String, Color>>((ref) {
  return {
    'primary': Colors.deepPurple,
    'secondary': Colors.teal,
    'tertiary': Colors.amber,
    'accent': Colors.pinkAccent,
  };
});

// Selected business colors provider for setup
final selectedBusinessColorsProvider =
    StateNotifierProvider<SelectedBusinessColorsNotifier, Map<String, Color>>(
        (ref) {
  final defaultColors = ref.watch(defaultBusinessColorsProvider);
  return SelectedBusinessColorsNotifier(defaultColors);
});

// Notifier for selected business colors
class SelectedBusinessColorsNotifier extends StateNotifier<Map<String, Color>> {
  SelectedBusinessColorsNotifier(Map<String, Color> initialColors)
      : super(initialColors);

  void updateColor(String key, Color color) {
    state = {...state, key: color};
  }

  void reset(Map<String, Color> defaultColors) {
    state = defaultColors;
  }
}
