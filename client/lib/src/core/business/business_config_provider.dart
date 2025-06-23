// File: lib/src/core/business/business_config_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'business_config_service.dart';
import '../local_storange/local_storage_service.dart';
import '../firebase/firebase_providers.dart';
import '../../routing/business_routing_provider.dart';

// OPTIMIZED: Provider for business ID with better rebuild control
// Uses a StateNotifier pattern to avoid rebuilding on every async state change
final currentBusinessIdProvider =
    StateNotifierProvider<_CurrentBusinessIdNotifier, String>((ref) {
  return _CurrentBusinessIdNotifier(ref);
});

class _CurrentBusinessIdNotifier extends StateNotifier<String> {
  final Ref _ref;
  String? _lastResolvedId;

  _CurrentBusinessIdNotifier(this._ref) : super('default') {
    _initializeBusinessId();
  }

  void _initializeBusinessId() {
    // Listen to the URL-aware business ID changes
    _ref.listen(urlAwareBusinessIdProvider, (previous, next) {
      next.whenData((businessId) {
        if (_lastResolvedId != businessId) {
          debugPrint('🔄 Business ID changed: $_lastResolvedId -> $businessId');
          _lastResolvedId = businessId;
          state = businessId;
        }
      });
    });

    // Get initial value
    final urlAwareAsync = _ref.read(urlAwareBusinessIdProvider);
    urlAwareAsync.whenData((businessId) {
      debugPrint('✅ Initial business ID: $businessId');
      _lastResolvedId = businessId;
      state = businessId;
    });
  }

  // Public method to set the business ID from outside the notifier
  void setBusinessId(String businessId) {
    if (_lastResolvedId != businessId) {
      debugPrint(
          '🔄 [setBusinessId] Business ID changed: \\$_lastResolvedId -> \\$businessId');
      _lastResolvedId = businessId;
      state = businessId;
    }
  }
}

// Provider to initialize business ID from storage (now used by URL-aware provider)
final initBusinessIdProvider = FutureProvider<String>((ref) async {
  final localStorage = ref.watch(localStorageServiceProvider);
  final businessId = await localStorage.getString('businessId');

  // Return the business ID or default
  return businessId ?? 'default';
});

// Provider for business config service
final businessConfigServiceProvider = Provider<BusinessConfigService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final database = ref.watch(firebaseDatabaseProvider);
  return BusinessConfigService(firestore: firestore, database: database);
});

// Provider for business configuration
final businessConfigProvider = StreamProvider<BusinessConfig?>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  final configService = ref.watch(businessConfigServiceProvider);
  return configService.streamBusinessConfig(businessId);
});

// Provider to fetch business config once (useful for initial check)
final businessConfigOnceProvider = FutureProvider<BusinessConfig?>((ref) async {
  final businessId = ref.watch(currentBusinessIdProvider);
  final configService = ref.watch(businessConfigServiceProvider);
  return await configService.getBusinessConfig(businessId);
});

// Provider for business type
final businessTypeProvider = Provider<String>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.type ?? 'restaurant',
    loading: () => 'restaurant',
    error: (_, __) => 'restaurant',
  );
});

// Provider for business name
final businessNameProvider = Provider<String>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.name ?? 'Restaurant App',
    loading: () => 'Restaurant App',
    error: (_, __) => 'Restaurant App',
  );
});

// Provider for business features
final businessFeaturesProvider = Provider<List<String>>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.features ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider to check if a specific feature is enabled
final hasFeatureProvider = Provider.family<bool, String>((ref, feature) {
  final features = ref.watch(businessFeaturesProvider);
  return features.contains(feature);
});

// Provider for business settings
final businessSettingsProvider = Provider<Map<String, dynamic>>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.settings ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
});

// Provider for a specific business setting with default value
final businessSettingProvider =
    Provider.family<dynamic, ({String key, dynamic defaultValue})>(
        (ref, params) {
  final settings = ref.watch(businessSettingsProvider);
  return settings[params.key] ?? params.defaultValue;
});

// Provider for primary color from business settings
final primaryColorProvider = Provider<Color>((ref) {
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
});

// Provider for secondary color from business settings
final secondaryColorProvider = Provider<Color>((ref) {
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
});

// Provider for tertiary color from business settings
final tertiaryColorProvider = Provider<Color>((ref) {
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
});

// Provider for accent color from business settings
final accentColorProvider = Provider<Color>((ref) {
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
});

// Provider for checking if dark mode is enabled
final isDarkModeEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(businessSettingsProvider);
  return settings['darkMode'] as bool? ?? false;
});

// Provider for checking if system theme should be used
final useSystemThemeProvider = Provider<bool>((ref) {
  final settings = ref.watch(businessSettingsProvider);
  return settings['useSystemTheme'] as bool? ?? true;
});

// Provider for business logo URL
final businessLogoUrlProvider = Provider<String>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.logoUrl ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
});

// Provider for business dark logo URL
final businessDarkLogoUrlProvider = Provider<String>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) =>
        config?.settings['logoDarkUrl'] as String? ?? config?.logoUrl ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
});

// Provider for business cover image URL
final businessCoverImageUrlProvider = Provider<String>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.coverImageUrl ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
});

// Provider for checking if business is properly set up
final isBusinessConfiguredProvider = Provider<bool>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider for contact info
final businessContactInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.contactInfo ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
});

// Provider for business address
final businessAddressProvider = Provider<Map<String, dynamic>>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.address ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
});

// Provider for business hours
final businessHoursProvider = Provider<Map<String, dynamic>>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.hours ?? {},
    loading: () => {},
    error: (_, __) => {},
  );
});

// Provider for business description
final businessDescriptionProvider = Provider<String>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.description ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
});

// Provider for business active status
final businessIsActiveProvider = Provider<bool>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.isActive ?? true,
    loading: () => true,
    error: (_, __) => true,
  );
});

// Provider for all business theme colors
final businessThemeColorsProvider = Provider<Map<String, Color>>((ref) {
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
});

// Helper function to convert hex color to Color
Color _hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}
