import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'business_config_service.dart';

// Provider for business ID
final currentBusinessIdProvider = StateProvider<String>((ref) => 'default');

// Provider for business config service
final businessConfigServiceProvider = Provider<BusinessConfigService>((ref) {
  return BusinessConfigService();
});

// Provider for business configuration
final businessConfigProvider = StreamProvider<BusinessConfig?>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  final configService = ref.watch(businessConfigServiceProvider);
  return configService.streamBusinessConfig(businessId);
});

// Provider for business type
final businessTypeProvider = Provider<String>((ref) {
  final configAsync = ref.watch(businessConfigProvider);
  return configAsync.when(
    data: (config) => config?.type ?? 'generic',
    loading: () => 'generic',
    error: (_, __) => 'generic',
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
final businessSettingProvider = Provider.family<dynamic, ({String key, dynamic defaultValue})>((ref, params) {
  final settings = ref.watch(businessSettingsProvider);
  return settings[params.key] ?? params.defaultValue;
});