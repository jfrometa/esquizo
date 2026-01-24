// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$initBusinessIdHash() => r'5debb328417ef44f12907a4735afe07ca33da92e';

/// See also [initBusinessId].
@ProviderFor(initBusinessId)
final initBusinessIdProvider = AutoDisposeFutureProvider<String>.internal(
  initBusinessId,
  name: r'initBusinessIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initBusinessIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitBusinessIdRef = AutoDisposeFutureProviderRef<String>;
String _$businessConfigServiceHash() =>
    r'3d18bf6be46299f7dfe09c4c497d69844e5b0b11';

/// See also [businessConfigService].
@ProviderFor(businessConfigService)
final businessConfigServiceProvider =
    AutoDisposeProvider<BusinessConfigService>.internal(
  businessConfigService,
  name: r'businessConfigServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessConfigServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessConfigServiceRef
    = AutoDisposeProviderRef<BusinessConfigService>;
String _$businessConfigHash() => r'aa23ec50a7f069bfa0ca02876ccaa00cdddcd51c';

/// See also [businessConfig].
@ProviderFor(businessConfig)
final businessConfigProvider =
    AutoDisposeStreamProvider<BusinessConfig?>.internal(
  businessConfig,
  name: r'businessConfigProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessConfigRef = AutoDisposeStreamProviderRef<BusinessConfig?>;
String _$businessConfigOnceHash() =>
    r'5179ca07dc6e5c8dd0b647901d132fbfbfae9dac';

/// See also [businessConfigOnce].
@ProviderFor(businessConfigOnce)
final businessConfigOnceProvider =
    AutoDisposeFutureProvider<BusinessConfig?>.internal(
  businessConfigOnce,
  name: r'businessConfigOnceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessConfigOnceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessConfigOnceRef = AutoDisposeFutureProviderRef<BusinessConfig?>;
String _$businessTypeHash() => r'c68fb9c0267a37075caf4fe53dd39f9d0a13e1e6';

/// See also [businessType].
@ProviderFor(businessType)
final businessTypeProvider = AutoDisposeProvider<String>.internal(
  businessType,
  name: r'businessTypeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$businessTypeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessTypeRef = AutoDisposeProviderRef<String>;
String _$businessNameHash() => r'f595a0d717b5bfb9c1e33a3992d5abc1b378363b';

/// See also [businessName].
@ProviderFor(businessName)
final businessNameProvider = AutoDisposeProvider<String>.internal(
  businessName,
  name: r'businessNameProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$businessNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessNameRef = AutoDisposeProviderRef<String>;
String _$businessFeaturesHash() => r'7c5806a554e13223b2cf1555ec0bedfd6a1b9a39';

/// See also [businessFeatures].
@ProviderFor(businessFeatures)
final businessFeaturesProvider = AutoDisposeProvider<List<String>>.internal(
  businessFeatures,
  name: r'businessFeaturesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessFeaturesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessFeaturesRef = AutoDisposeProviderRef<List<String>>;
String _$hasFeatureHash() => r'3666732b41dac2c4d4b916b020166b3e0d05c2e1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [hasFeature].
@ProviderFor(hasFeature)
const hasFeatureProvider = HasFeatureFamily();

/// See also [hasFeature].
class HasFeatureFamily extends Family<bool> {
  /// See also [hasFeature].
  const HasFeatureFamily();

  /// See also [hasFeature].
  HasFeatureProvider call(
    String feature,
  ) {
    return HasFeatureProvider(
      feature,
    );
  }

  @override
  HasFeatureProvider getProviderOverride(
    covariant HasFeatureProvider provider,
  ) {
    return call(
      provider.feature,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'hasFeatureProvider';
}

/// See also [hasFeature].
class HasFeatureProvider extends AutoDisposeProvider<bool> {
  /// See also [hasFeature].
  HasFeatureProvider(
    String feature,
  ) : this._internal(
          (ref) => hasFeature(
            ref as HasFeatureRef,
            feature,
          ),
          from: hasFeatureProvider,
          name: r'hasFeatureProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasFeatureHash,
          dependencies: HasFeatureFamily._dependencies,
          allTransitiveDependencies:
              HasFeatureFamily._allTransitiveDependencies,
          feature: feature,
        );

  HasFeatureProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feature,
  }) : super.internal();

  final String feature;

  @override
  Override overrideWith(
    bool Function(HasFeatureRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasFeatureProvider._internal(
        (ref) => create(ref as HasFeatureRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feature: feature,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _HasFeatureProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasFeatureProvider && other.feature == feature;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feature.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HasFeatureRef on AutoDisposeProviderRef<bool> {
  /// The parameter `feature` of this provider.
  String get feature;
}

class _HasFeatureProviderElement extends AutoDisposeProviderElement<bool>
    with HasFeatureRef {
  _HasFeatureProviderElement(super.provider);

  @override
  String get feature => (origin as HasFeatureProvider).feature;
}

String _$businessSettingsHash() => r'e5b0893982d60a68ae68c51789e8534974b2ee52';

/// See also [businessSettings].
@ProviderFor(businessSettings)
final businessSettingsProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
  businessSettings,
  name: r'businessSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessSettingsRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$businessSettingHash() => r'90a76f26475a808ac85fb6e1dd83d252bcd6b4f8';

/// See also [businessSetting].
@ProviderFor(businessSetting)
const businessSettingProvider = BusinessSettingFamily();

/// See also [businessSetting].
class BusinessSettingFamily extends Family<dynamic> {
  /// See also [businessSetting].
  const BusinessSettingFamily();

  /// See also [businessSetting].
  BusinessSettingProvider call(
    String key,
    dynamic defaultValue,
  ) {
    return BusinessSettingProvider(
      key,
      defaultValue,
    );
  }

  @override
  BusinessSettingProvider getProviderOverride(
    covariant BusinessSettingProvider provider,
  ) {
    return call(
      provider.key,
      provider.defaultValue,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'businessSettingProvider';
}

/// See also [businessSetting].
class BusinessSettingProvider extends AutoDisposeProvider<dynamic> {
  /// See also [businessSetting].
  BusinessSettingProvider(
    String key,
    dynamic defaultValue,
  ) : this._internal(
          (ref) => businessSetting(
            ref as BusinessSettingRef,
            key,
            defaultValue,
          ),
          from: businessSettingProvider,
          name: r'businessSettingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$businessSettingHash,
          dependencies: BusinessSettingFamily._dependencies,
          allTransitiveDependencies:
              BusinessSettingFamily._allTransitiveDependencies,
          key: key,
          defaultValue: defaultValue,
        );

  BusinessSettingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
    required this.defaultValue,
  }) : super.internal();

  final String key;
  final dynamic defaultValue;

  @override
  Override overrideWith(
    dynamic Function(BusinessSettingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BusinessSettingProvider._internal(
        (ref) => create(ref as BusinessSettingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
        defaultValue: defaultValue,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<dynamic> createElement() {
    return _BusinessSettingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessSettingProvider &&
        other.key == key &&
        other.defaultValue == defaultValue;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);
    hash = _SystemHash.combine(hash, defaultValue.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BusinessSettingRef on AutoDisposeProviderRef<dynamic> {
  /// The parameter `key` of this provider.
  String get key;

  /// The parameter `defaultValue` of this provider.
  dynamic get defaultValue;
}

class _BusinessSettingProviderElement
    extends AutoDisposeProviderElement<dynamic> with BusinessSettingRef {
  _BusinessSettingProviderElement(super.provider);

  @override
  String get key => (origin as BusinessSettingProvider).key;
  @override
  dynamic get defaultValue => (origin as BusinessSettingProvider).defaultValue;
}

String _$primaryColorHash() => r'c684d863d0b028a15760bc8c437c47239580ce9a';

/// See also [primaryColor].
@ProviderFor(primaryColor)
final primaryColorProvider = AutoDisposeProvider<Color>.internal(
  primaryColor,
  name: r'primaryColorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$primaryColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrimaryColorRef = AutoDisposeProviderRef<Color>;
String _$secondaryColorHash() => r'24a9003b646efdc952179e940e315107c4f6deb9';

/// See also [secondaryColor].
@ProviderFor(secondaryColor)
final secondaryColorProvider = AutoDisposeProvider<Color>.internal(
  secondaryColor,
  name: r'secondaryColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secondaryColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecondaryColorRef = AutoDisposeProviderRef<Color>;
String _$tertiaryColorHash() => r'dccd114a684edbe55fa6289af036b239f7f1abcc';

/// See also [tertiaryColor].
@ProviderFor(tertiaryColor)
final tertiaryColorProvider = AutoDisposeProvider<Color>.internal(
  tertiaryColor,
  name: r'tertiaryColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tertiaryColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TertiaryColorRef = AutoDisposeProviderRef<Color>;
String _$accentColorHash() => r'1f44a2259a39c8d8d15af8bdeb70e605fb5dca14';

/// See also [accentColor].
@ProviderFor(accentColor)
final accentColorProvider = AutoDisposeProvider<Color>.internal(
  accentColor,
  name: r'accentColorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accentColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccentColorRef = AutoDisposeProviderRef<Color>;
String _$isDarkModeEnabledHash() => r'ea69ba9e3bb61a3bf75860286f67966b2f9237cd';

/// See also [isDarkModeEnabled].
@ProviderFor(isDarkModeEnabled)
final isDarkModeEnabledProvider = AutoDisposeProvider<bool>.internal(
  isDarkModeEnabled,
  name: r'isDarkModeEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isDarkModeEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsDarkModeEnabledRef = AutoDisposeProviderRef<bool>;
String _$useSystemThemeHash() => r'7c0a68b6d1d11eb4bf3213fc1252f054ebe83e26';

/// See also [useSystemTheme].
@ProviderFor(useSystemTheme)
final useSystemThemeProvider = AutoDisposeProvider<bool>.internal(
  useSystemTheme,
  name: r'useSystemThemeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$useSystemThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UseSystemThemeRef = AutoDisposeProviderRef<bool>;
String _$businessLogoUrlHash() => r'7d6468dc09a471a6cb057b00ee5c54d7fbe906c0';

/// See also [businessLogoUrl].
@ProviderFor(businessLogoUrl)
final businessLogoUrlProvider = AutoDisposeProvider<String>.internal(
  businessLogoUrl,
  name: r'businessLogoUrlProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessLogoUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessLogoUrlRef = AutoDisposeProviderRef<String>;
String _$businessDarkLogoUrlHash() =>
    r'36f28e409694663a41de36a2a93fb4ab07137a8b';

/// See also [businessDarkLogoUrl].
@ProviderFor(businessDarkLogoUrl)
final businessDarkLogoUrlProvider = AutoDisposeProvider<String>.internal(
  businessDarkLogoUrl,
  name: r'businessDarkLogoUrlProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessDarkLogoUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessDarkLogoUrlRef = AutoDisposeProviderRef<String>;
String _$businessCoverImageUrlHash() =>
    r'd2fb14fccc00a9d224832fbb0a918d9c8fdc871e';

/// See also [businessCoverImageUrl].
@ProviderFor(businessCoverImageUrl)
final businessCoverImageUrlProvider = AutoDisposeProvider<String>.internal(
  businessCoverImageUrl,
  name: r'businessCoverImageUrlProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessCoverImageUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessCoverImageUrlRef = AutoDisposeProviderRef<String>;
String _$isBusinessConfiguredHash() =>
    r'1675818627722c1a264aec63a932dfe64fe680d5';

/// See also [isBusinessConfigured].
@ProviderFor(isBusinessConfigured)
final isBusinessConfiguredProvider = AutoDisposeProvider<bool>.internal(
  isBusinessConfigured,
  name: r'isBusinessConfiguredProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isBusinessConfiguredHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsBusinessConfiguredRef = AutoDisposeProviderRef<bool>;
String _$businessContactInfoHash() =>
    r'6c85e6e5e69718b8869bbb4effa9c793e3861be6';

/// See also [businessContactInfo].
@ProviderFor(businessContactInfo)
final businessContactInfoProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
  businessContactInfo,
  name: r'businessContactInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessContactInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessContactInfoRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$businessAddressHash() => r'ee35c2c72a9741a0bd9095261d9203935dae26d5';

/// See also [businessAddress].
@ProviderFor(businessAddress)
final businessAddressProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
  businessAddress,
  name: r'businessAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessAddressRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$businessHoursHash() => r'd819b74e160f495ac9f3dea49302c1d675313358';

/// See also [businessHours].
@ProviderFor(businessHours)
final businessHoursProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
  businessHours,
  name: r'businessHoursProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessHoursHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessHoursRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$businessDescriptionHash() =>
    r'9ade49c5398b45d5c11b1de8ef3389911a4e5c36';

/// See also [businessDescription].
@ProviderFor(businessDescription)
final businessDescriptionProvider = AutoDisposeProvider<String>.internal(
  businessDescription,
  name: r'businessDescriptionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessDescriptionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessDescriptionRef = AutoDisposeProviderRef<String>;
String _$businessIsActiveHash() => r'a6c7ebd3f8aa0eef24d2b82ff8267d19fc1d1d5d';

/// See also [businessIsActive].
@ProviderFor(businessIsActive)
final businessIsActiveProvider = AutoDisposeProvider<bool>.internal(
  businessIsActive,
  name: r'businessIsActiveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessIsActiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessIsActiveRef = AutoDisposeProviderRef<bool>;
String _$businessThemeColorsHash() =>
    r'51ece1f22c4d441b652631a289a27471e9f60d2e';

/// See also [businessThemeColors].
@ProviderFor(businessThemeColors)
final businessThemeColorsProvider =
    AutoDisposeProvider<Map<String, Color>>.internal(
  businessThemeColors,
  name: r'businessThemeColorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessThemeColorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessThemeColorsRef = AutoDisposeProviderRef<Map<String, Color>>;
String _$currentBusinessIdHash() => r'ebb6a621a2c01d4790dec627307ed4ea93fc74af';

/// See also [CurrentBusinessId].
@ProviderFor(CurrentBusinessId)
final currentBusinessIdProvider =
    AutoDisposeNotifierProvider<CurrentBusinessId, String>.internal(
  CurrentBusinessId.new,
  name: r'currentBusinessIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBusinessIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentBusinessId = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
