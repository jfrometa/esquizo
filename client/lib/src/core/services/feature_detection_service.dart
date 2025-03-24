import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business/business_config_provider.dart';

class FeatureDetectionService {
  final List<String> _enabledFeatures;
  final Map<String, dynamic> _settings;
  
  FeatureDetectionService({
    required List<String> enabledFeatures,
    required Map<String, dynamic> settings,
  }) : 
    _enabledFeatures = enabledFeatures,
    _settings = settings;
  
  // Check if a feature is enabled
  bool isFeatureEnabled(String featureKey) {
    return _enabledFeatures.contains(featureKey);
  }
  
  // Get a setting with a default value
  T getSetting<T>(String key, T defaultValue) {
    if (_settings.containsKey(key)) {
      final value = _settings[key];
      if (value is T) {
        return value;
      }
    }
    return defaultValue;
  }
  
  // Check if the business type matches
  bool isBusinessType(String type) {
    return getSetting<String>('businessType', 'generic') == type;
  }
  
  // Check if multiple features are all enabled
  bool areAllFeaturesEnabled(List<String> featureKeys) {
    return featureKeys.every(isFeatureEnabled);
  }
  
  // Check if any of the features are enabled
  bool isAnyFeatureEnabled(List<String> featureKeys) {
    return featureKeys.any(isFeatureEnabled);
  }
}

// Provider for feature detection service
final featureDetectionServiceProvider = Provider<FeatureDetectionService>((ref) {
  final features = ref.watch(businessFeaturesProvider);
  final settings = ref.watch(businessSettingsProvider);
  
  return FeatureDetectionService(
    enabledFeatures: features,
    settings: settings,
  );
});

// Provider to check if a feature is enabled
final isFeatureEnabledProvider = Provider.family<bool, String>((ref, featureKey) {
  final featureService = ref.watch(featureDetectionServiceProvider);
  return featureService.isFeatureEnabled(featureKey);
});

// Provider to get a setting with a default value
final settingProvider = Provider.family<dynamic, ({String key, dynamic defaultValue})>((ref, params) {
  final featureService = ref.watch(featureDetectionServiceProvider);
  return featureService.getSetting(params.key, params.defaultValue);
});