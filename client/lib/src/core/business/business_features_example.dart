import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_service.dart';

/// Example class that demonstrates how to use the BusinessFeaturesService
class BusinessFeaturesExample {
  final WidgetRef ref;

  BusinessFeaturesExample(this.ref);

  /// Initialize a new business with all features and UI elements enabled
  Future<void> setupNewBusiness(String businessId) async {
    try {
      final service = ref.read(businessFeaturesServiceProvider);

      // This will initialize the business with ALL features and UI elements set to TRUE
      await service.initializeDefaultBusiness(businessId);

      debugPrint(
          '✅ Business $businessId initialized with all features enabled');
      debugPrint('Default initialization includes:');
      debugPrint(
          '  - All features enabled (catering, mealPlans, inDine, staff, kitchen, reservations)');
      debugPrint('  - All UI elements enabled (landingPage, orders)');

      // Verify initialization was successful by fetching the current state
      final features = await service.getBusinessFeatures(businessId).first;
      final ui = await service.getBusinessUI(businessId).first;

      debugPrint('\n📊 Verification of initialized business features:');
      _logFeatures(features, businessId);
      _logUIComponents(ui, businessId);
    } catch (e) {
      debugPrint('❌ Error initializing business $businessId: $e');
    }
  }

  /// Update specific UI components for a business - enables ALL UI components
  Future<void> customizeBusinessUI(String businessId) async {
    try {
      final service = ref.read(businessFeaturesServiceProvider);

      // Get current UI settings
      final currentUI = await service.getBusinessUI(businessId).first;
      debugPrint('Current UI settings before update:');
      _logUIComponents(currentUI, businessId);

      // Create a fully enabled UI model
      const fullyEnabledUI = BusinessUI(
        landingPage: true,
        orders: true,
      );

      // Update all UI components at once
      await service.updateBusinessUI(businessId, fullyEnabledUI);

      // Verify the update was successful
      final updatedUI = await service.getBusinessUI(businessId).first;
      debugPrint(
          '\n✅ All UI components are now enabled for business $businessId:');
      _logUIComponents(updatedUI, businessId);
    } catch (e) {
      debugPrint('❌ Error customizing business UI: $e');
    }
  }

  /// Update specific features for a business - enables ALL features
  Future<void> customizeBusinessFeatures(String businessId) async {
    try {
      final service = ref.read(businessFeaturesServiceProvider);

      // Get current feature settings
      final currentFeatures =
          await service.getBusinessFeatures(businessId).first;
      debugPrint('Current feature settings before update:');
      _logFeatures(currentFeatures, businessId);

      // Create a fully enabled features model
      const fullyEnabledFeatures = BusinessFeatures(
        catering: true,
        mealPlans: true,
        inDine: true,
        staff: true,
        kitchen: true,
        reservations: true,
      );

      // Update all features at once
      await service.updateBusinessFeatures(businessId, fullyEnabledFeatures);

      // Verify the update was successful
      final updatedFeatures =
          await service.getBusinessFeatures(businessId).first;
      debugPrint('\n✅ All features are now enabled for business $businessId:');
      _logFeatures(updatedFeatures, businessId);
    } catch (e) {
      debugPrint('❌ Error customizing business features: $e');
    }
  }

  /// Check which features/UI components are enabled for a business
  Future<void> checkBusinessSettings(String businessId) async {
    try {
      final service = ref.read(businessFeaturesServiceProvider);

      // Get current business features
      final features = await service.getBusinessFeatures(businessId).first;
      final ui = await service.getBusinessUI(businessId).first;

      debugPrint('\n🔍 Business $businessId Settings Check:');
      _logFeatures(features, businessId);
      _logUIComponents(ui, businessId);

      // Verify all settings are enabled
      final allFeaturesEnabled = _areAllFeaturesEnabled(features);
      final allUIEnabled = _areAllUIComponentsEnabled(ui);

      if (allFeaturesEnabled && allUIEnabled) {
        debugPrint(
            '\n✅ VERIFICATION SUCCESSFUL: All features and UI elements are ENABLED');
      } else {
        debugPrint(
            '\n⚠️ VERIFICATION FAILED: Not all features or UI elements are enabled');
        if (!allFeaturesEnabled) {
          debugPrint('  - Some features are still disabled');
        }
        if (!allUIEnabled) {
          debugPrint('  - Some UI components are still disabled');
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking business settings: $e');
    }
  }

  /// Get current feature settings and display them
  Future<void> monitorBusinessSettings(String businessId) async {
    try {
      final service = ref.read(businessFeaturesServiceProvider);

      // Get features
      final features = await service.getBusinessFeatures(businessId).first;
      // Get UI settings
      final ui = await service.getBusinessUI(businessId).first;

      debugPrint('\n📊 Current Business $businessId Settings:');
      _logFeatures(features, businessId);
      _logUIComponents(ui, businessId);
    } catch (e) {
      debugPrint('❌ Error monitoring business settings: $e');
    }
  }

  /// Helper method to log feature status
  void _logFeatures(BusinessFeatures features, String businessId) {
    debugPrint('Features for $businessId:');
    debugPrint(
        '  - Catering: ${features.catering ? '✅ ENABLED' : '❌ DISABLED'}');
    debugPrint(
        '  - Meal Plans: ${features.mealPlans ? '✅ ENABLED' : '❌ DISABLED'}');
    debugPrint('  - In Dine: ${features.inDine ? '✅ ENABLED' : '❌ DISABLED'}');
    debugPrint('  - Staff: ${features.staff ? '✅ ENABLED' : '❌ DISABLED'}');
    debugPrint('  - Kitchen: ${features.kitchen ? '✅ ENABLED' : '❌ DISABLED'}');
    debugPrint(
        '  - Reservations: ${features.reservations ? '✅ ENABLED' : '❌ DISABLED'}');
  }

  /// Helper method to log UI status
  void _logUIComponents(BusinessUI ui, String businessId) {
    debugPrint('UI Components for $businessId:');
    debugPrint(
        '  - Landing Page: ${ui.landingPage ? '✅ ENABLED' : '❌ DISABLED'}');
    debugPrint('  - Orders: ${ui.orders ? '✅ ENABLED' : '❌ DISABLED'}');
  }

  /// Check if all features are enabled
  bool _areAllFeaturesEnabled(BusinessFeatures features) {
    return features.catering &&
        features.mealPlans &&
        features.inDine &&
        features.staff &&
        features.kitchen &&
        features.reservations;
  }

  /// Check if all UI components are enabled
  bool _areAllUIComponentsEnabled(BusinessUI ui) {
    return ui.landingPage && ui.orders;
  }
}
