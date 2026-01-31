import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';

part 'business_features_service.g.dart';

/// Business features configuration model
class BusinessFeatures {
  final bool catering;
  final bool mealPlans;
  final bool inDine;
  final bool staff;
  final bool kitchen;
  final bool reservations;

  const BusinessFeatures({
    this.catering = true,
    this.mealPlans = true,
    this.inDine = true,
    this.staff = true,
    this.kitchen = true,
    this.reservations = true,
  });

  Map<String, dynamic> toMap() => {
        'catering': catering,
        'mealPlans': mealPlans,
        'inDine': inDine,
        'staff': staff,
        'kitchen': kitchen,
        'reservations': reservations,
      };

  factory BusinessFeatures.fromMap(Map<Object?, Object?> map) {
    return BusinessFeatures(
      catering: map['catering'] as bool? ?? true,
      mealPlans: map['mealPlans'] as bool? ?? true,
      inDine: map['inDine'] as bool? ?? true,
      staff: map['staff'] as bool? ?? true,
      kitchen: map['kitchen'] as bool? ?? true,
      reservations: map['reservations'] as bool? ?? true,
    );
  }

  BusinessFeatures copyWith({
    bool? catering,
    bool? mealPlans,
    bool? inDine,
    bool? staff,
    bool? kitchen,
    bool? reservations,
  }) {
    return BusinessFeatures(
      catering: catering ?? this.catering,
      mealPlans: mealPlans ?? this.mealPlans,
      inDine: inDine ?? this.inDine,
      staff: staff ?? this.staff,
      kitchen: kitchen ?? this.kitchen,
      reservations: reservations ?? this.reservations,
    );
  }
}

/// Business UI configuration model
class BusinessUI {
  final bool landingPage;
  final bool orders;

  const BusinessUI({
    this.landingPage = true,
    this.orders = true,
  });

  Map<String, dynamic> toMap() => {
        'landingPage': landingPage,
        'orders': orders,
      };

  factory BusinessUI.fromMap(Map<Object?, Object?> map) {
    return BusinessUI(
      landingPage: map['landingPage'] as bool? ?? true,
      orders: map['orders'] as bool? ?? true,
    );
  }

  BusinessUI copyWith({
    bool? landingPage,
    bool? orders,
  }) {
    return BusinessUI(
      landingPage: landingPage ?? this.landingPage,
      orders: orders ?? this.orders,
    );
  }
}

/// Service for managing business features and UI configuration in Firebase Realtime Database
class BusinessFeaturesService {
  final FirebaseDatabase _database;

  // Database references
  late final DatabaseReference _businessRef;

  // Private constructor for dependency injection
  BusinessFeaturesService({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance {
    _businessRef = _database.ref('business');
  }

  /// Get features configuration for a specific business
  Stream<BusinessFeatures> getBusinessFeatures(String businessId) {
    return _businessRef.child('$businessId/features').onValue.map((event) {
      try {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<Object?, Object?>;
          return BusinessFeatures.fromMap(data);
        } else {
          debugPrint('No features data found for business: $businessId');
          return const BusinessFeatures(); // Return defaults
        }
      } catch (e) {
        debugPrint('Error processing business features data: $e');
        return const BusinessFeatures(); // Return defaults on error
      }
    });
  }

  /// Get UI configuration for a specific business
  Stream<BusinessUI> getBusinessUI(String businessId) {
    return _businessRef.child('$businessId/ui').onValue.map((event) {
      try {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<Object?, Object?>;
          return BusinessUI.fromMap(data);
        } else {
          debugPrint('No UI data found for business: $businessId');
          return const BusinessUI(); // Return defaults
        }
      } catch (e) {
        debugPrint('Error processing business UI data: $e');
        return const BusinessUI(); // Return defaults on error
      }
    });
  }

  /// Update features configuration for a specific business
  Future<void> updateBusinessFeatures(
      String businessId, BusinessFeatures features) async {
    try {
      await _businessRef.child('$businessId/features').update(features.toMap());
      debugPrint('Business features updated successfully for: $businessId');
    } catch (e) {
      debugPrint('Error updating business features: $e');
      throw Exception('Failed to update business features: $e');
    }
  }

  /// Update UI configuration for a specific business
  Future<void> updateBusinessUI(String businessId, BusinessUI ui) async {
    try {
      await _businessRef.child('$businessId/ui').update(ui.toMap());
      debugPrint('Business UI updated successfully for: $businessId');
    } catch (e) {
      debugPrint('Error updating business UI: $e');
      throw Exception('Failed to update business UI: $e');
    }
  }

  /// Update a single feature for a business
  Future<void> updateBusinessFeature(
      String businessId, String feature, bool value) async {
    try {
      await _businessRef.child('$businessId/features').update({feature: value});
      debugPrint(
          'Business feature $feature updated to $value for: $businessId');
    } catch (e) {
      debugPrint('Error updating business feature: $e');
      throw Exception('Failed to update business feature: $e');
    }
  }

  /// Update a single UI component for a business
  Future<void> updateBusinessUIComponent(
      String businessId, String component, bool value) async {
    try {
      await _businessRef.child('$businessId/ui').update({component: value});
      debugPrint(
          'Business UI component $component updated to $value for: $businessId');
    } catch (e) {
      debugPrint('Error updating business UI component: $e');
      throw Exception('Failed to update business UI component: $e');
    }
  }

  /// Initialize a new business with default feature and UI settings (all true)
  Future<void> initializeDefaultBusiness(String businessId) async {
    try {
      debugPrint('Initializing default business settings for: $businessId');

      final defaultFeatures = const BusinessFeatures().toMap();
      final defaultUI = const BusinessUI().toMap();

      final updates = {
        'features': defaultFeatures,
        'ui': defaultUI,
      };

      await _businessRef.child(businessId).update(updates);

      debugPrint('Default business settings initialized for: $businessId');
    } catch (e) {
      debugPrint('Error initializing default business: $e');
      throw Exception('Failed to initialize default business settings: $e');
    }
  }

  /// Check if a business has a specific feature enabled
  Future<bool> isFeatureEnabled(String businessId, String feature) async {
    try {
      final snapshot =
          await _businessRef.child('$businessId/features/$feature').get();

      if (snapshot.exists) {
        return snapshot.value as bool? ?? true;
      } else {
        debugPrint(
            'Feature $feature not found for business: $businessId, defaulting to true');
        return true; // Default to enabled if not specified
      }
    } catch (e) {
      debugPrint('Error checking feature status: $e');
      return true; // Default to enabled on error
    }
  }

  /// Check if a business has a specific UI component enabled
  Future<bool> isUIComponentEnabled(String businessId, String component) async {
    try {
      final snapshot =
          await _businessRef.child('$businessId/ui/$component').get();

      if (snapshot.exists) {
        return snapshot.value as bool? ?? true;
      } else {
        debugPrint(
            'UI component $component not found for business: $businessId, defaulting to true');
        return true; // Default to enabled if not specified
      }
    } catch (e) {
      debugPrint('Error checking UI component status: $e');
      return true; // Default to enabled on error
    }
  }
}

/// Provider for BusinessFeaturesService
@Riverpod(keepAlive: true)
BusinessFeaturesService businessFeaturesService(Ref ref) {
  final database = ref.watch(firebaseDatabaseProvider);
  return BusinessFeaturesService(database: database);
}

/// Stream provider for business features
@riverpod
Stream<BusinessFeatures> businessFeatures(Ref ref, String businessId) {
  final service = ref.watch(businessFeaturesServiceProvider);
  return service.getBusinessFeatures(businessId);
}

/// Stream provider for business UI configuration
@riverpod
Stream<BusinessUI> businessUI(Ref ref, String businessId) {
  final service = ref.watch(businessFeaturesServiceProvider);
  return service.getBusinessUI(businessId);
}
