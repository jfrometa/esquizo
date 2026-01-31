import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'business_config_service.dart';
import 'business_constants.dart';
import '../local_storange/local_storage_service.dart';
import '../firebase/firebase_providers.dart';
import '../../routing/business_routing_provider.dart';

part 'business_config_provider.g.dart';

// OPTIMIZED: Provider for business ID with better rebuild control
@riverpod
class CurrentBusinessId extends _$CurrentBusinessId {
  @override
  String build() {
    final urlAwareAsync = ref.watch(urlAwareBusinessIdProvider);
    return urlAwareAsync.maybeWhen(
      data: (businessId) => businessId,
      orElse: () => BusinessConstants.defaultBusinessId,
    );
  }

  // Public method to set the business ID from outside the notifier
  void setBusinessId(String businessId) {
    if (state == businessId) return;
    state = businessId;
  }
}

// Provider to initialize business ID from storage (now used by URL-aware provider)
@riverpod
Future<String> initBusinessId(Ref ref) async {
  final localStorage = ref.watch(localStorageServiceProvider);
  final businessId = await localStorage.getString('businessId');

  // Return the business ID or default (kako)
  return businessId ?? BusinessConstants.defaultBusinessId;
}

// Provider for business config service
@riverpod
BusinessConfigService businessConfigService(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final database = ref.watch(firebaseDatabaseProvider);
  return BusinessConfigService(firestore: firestore, database: database);
}

// Provider for business configuration
@riverpod
Stream<BusinessConfig?> businessConfig(Ref ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  final configService = ref.watch(businessConfigServiceProvider);
  return configService.streamBusinessConfig(businessId);
}

// Provider to fetch business config once (useful for initial check)
@riverpod
Future<BusinessConfig?> businessConfigOnce(Ref ref) async {
  final businessId = ref.watch(currentBusinessIdProvider);
  final configService = ref.watch(businessConfigServiceProvider);
  return await configService.getBusinessConfig(businessId);
}

// Provider for business type
@riverpod
String businessType(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.type ?? 'restaurant',
    loading: () => 'restaurant',
    error: (_, __) => 'restaurant',
  );
}

// Provider for business name
@riverpod
String businessName(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.name ?? 'Restaurant App',
    loading: () => 'Restaurant App',
    error: (_, __) => 'Restaurant App',
  );
}

// Provider for business features
@riverpod
List<String> businessFeatures(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.features ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
}

// Provider to check if a specific feature is enabled
@riverpod
bool hasFeature(Ref ref, String feature) {
  final features = ref.watch(businessFeaturesProvider);
  return features.contains(feature);
}

// Provider for business settings
@riverpod
Map<String, dynamic> businessSettings(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.settings ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
}

// Provider for a specific business setting with default value
@riverpod
dynamic businessSetting(Ref ref, String key, dynamic defaultValue) {
  final settings = ref.watch(businessSettingsProvider);
  return settings[key] ?? defaultValue;
}

// Provider for primary color from business settings
@riverpod
Color primaryColor(Ref ref) {
  final settings = ref.watch(businessSettingsProvider);
  final colorHex = settings['primaryColor'] as String?;
  if (colorHex != null && colorHex.isNotEmpty) {
    try {
      return _hexToColor(colorHex);
    } catch (e) {
      debugPrint('Error parsing primary color: $e');
    }
  }
  return Colors.deepPurple; // Default primary color
}

@riverpod
Color secondaryColor(Ref ref) {
  final settings = ref.watch(businessSettingsProvider);
  final colorHex = settings['secondaryColor'] as String?;
  if (colorHex != null && colorHex.isNotEmpty) {
    try {
      return _hexToColor(colorHex);
    } catch (e) {
      debugPrint('Error parsing secondary color: $e');
    }
  }
  return Colors.teal; // Default secondary color
}

@riverpod
Color tertiaryColor(Ref ref) {
  final settings = ref.watch(businessSettingsProvider);
  final colorHex = settings['tertiaryColor'] as String?;
  if (colorHex != null && colorHex.isNotEmpty) {
    try {
      return _hexToColor(colorHex);
    } catch (e) {
      debugPrint('Error parsing tertiary color: $e');
    }
  }
  return Colors.amber; // Default tertiary color
}

@riverpod
Color accentColor(Ref ref) {
  final settings = ref.watch(businessSettingsProvider);
  final colorHex = settings['accentColor'] as String?;
  if (colorHex != null && colorHex.isNotEmpty) {
    try {
      return _hexToColor(colorHex);
    } catch (e) {
      debugPrint('Error parsing accent color: $e');
    }
  }
  return Colors.pinkAccent; // Default accent color
}

@riverpod
bool isDarkModeEnabled(Ref ref) {
  final settings = ref.watch(businessSettingsProvider);
  return settings['darkMode'] as bool? ?? false;
}

@riverpod
bool useSystemTheme(Ref ref) {
  final settings = ref.watch(businessSettingsProvider);
  return settings['useSystemTheme'] as bool? ?? true;
}

@riverpod
String businessLogoUrl(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.logoUrl ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
}

@riverpod
String businessDarkLogoUrl(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) =>
        config?.settings['logoDarkUrl'] as String? ?? config?.logoUrl ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
}

@riverpod
String businessCoverImageUrl(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.coverImageUrl ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
}

@riverpod
bool isBusinessConfigured(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config != null,
    loading: () => false,
    error: (_, __) => false,
  );
}

@riverpod
Map<String, dynamic> businessContactInfo(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.contactInfo ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
}

@riverpod
Map<String, dynamic> businessAddress(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.address ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
}

@riverpod
Map<String, dynamic> businessHours(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.hours ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
}

@riverpod
String businessDescription(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.description ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
}

@riverpod
bool businessIsActive(Ref ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.isActive ?? true,
    loading: () => true,
    error: (_, __) => true,
  );
}

@riverpod
Map<String, Color> businessThemeColors(Ref ref) {
  final primaryColor = ref.watch(primaryColorProvider);
  final secondaryColor = ref.watch(secondaryColorProvider);
  final tertiaryColor = ref.watch(tertiaryColorProvider);
  final accentColor = ref.watch(accentColorProvider);

  return {
    'primary': primaryColor,
    'secondary': secondaryColor,
    'tertiary': tertiaryColor,
    'accent': accentColor,
  };
}

// Helper function to convert hex color to Color
Color _hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}
