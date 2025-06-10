// File: lib/src/core/setup/business_setup_manager.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';

import '../firebase/firebase_providers.dart';
import '../local_storange/local_storage_service.dart';

// Manages the business setup process
class BusinessSetupManager {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final LocalStorageService _localStorageService;

  BusinessSetupManager({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required LocalStorageService localStorageService,
  })  : _firestore = firestore,
        _storage = storage,
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
  Future<String> createBusinessConfig({
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

      // Save business ID to local storage
      await _localStorageService.setString('businessId', businessId);

      return businessId;
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
}

// Provider for BusinessSetupManager
final businessSetupManagerProvider = Provider<BusinessSetupManager>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  final localStorage = ref.watch(localStorageServiceProvider);

  return BusinessSetupManager(
    firestore: firestore,
    storage: storage,
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
