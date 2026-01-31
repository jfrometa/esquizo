// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_features_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$businessFeaturesServiceHash() =>
    r'5a3f52a5819e3a5f19dbaaa2bd7a178c07d888df';

/// Provider for BusinessFeaturesService
///
/// Copied from [businessFeaturesService].
@ProviderFor(businessFeaturesService)
final businessFeaturesServiceProvider =
    Provider<BusinessFeaturesService>.internal(
  businessFeaturesService,
  name: r'businessFeaturesServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessFeaturesServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessFeaturesServiceRef = ProviderRef<BusinessFeaturesService>;
String _$businessFeaturesHash() => r'0e862ff520f8f0a097412471acc0a517fdef4d59';

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

/// Stream provider for business features
///
/// Copied from [businessFeatures].
@ProviderFor(businessFeatures)
const businessFeaturesProvider = BusinessFeaturesFamily();

/// Stream provider for business features
///
/// Copied from [businessFeatures].
class BusinessFeaturesFamily extends Family<AsyncValue<BusinessFeatures>> {
  /// Stream provider for business features
  ///
  /// Copied from [businessFeatures].
  const BusinessFeaturesFamily();

  /// Stream provider for business features
  ///
  /// Copied from [businessFeatures].
  BusinessFeaturesProvider call(
    String businessId,
  ) {
    return BusinessFeaturesProvider(
      businessId,
    );
  }

  @override
  BusinessFeaturesProvider getProviderOverride(
    covariant BusinessFeaturesProvider provider,
  ) {
    return call(
      provider.businessId,
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
  String? get name => r'businessFeaturesProvider';
}

/// Stream provider for business features
///
/// Copied from [businessFeatures].
class BusinessFeaturesProvider
    extends AutoDisposeStreamProvider<BusinessFeatures> {
  /// Stream provider for business features
  ///
  /// Copied from [businessFeatures].
  BusinessFeaturesProvider(
    String businessId,
  ) : this._internal(
          (ref) => businessFeatures(
            ref as BusinessFeaturesRef,
            businessId,
          ),
          from: businessFeaturesProvider,
          name: r'businessFeaturesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$businessFeaturesHash,
          dependencies: BusinessFeaturesFamily._dependencies,
          allTransitiveDependencies:
              BusinessFeaturesFamily._allTransitiveDependencies,
          businessId: businessId,
        );

  BusinessFeaturesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.businessId,
  }) : super.internal();

  final String businessId;

  @override
  Override overrideWith(
    Stream<BusinessFeatures> Function(BusinessFeaturesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BusinessFeaturesProvider._internal(
        (ref) => create(ref as BusinessFeaturesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        businessId: businessId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<BusinessFeatures> createElement() {
    return _BusinessFeaturesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessFeaturesProvider && other.businessId == businessId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, businessId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BusinessFeaturesRef on AutoDisposeStreamProviderRef<BusinessFeatures> {
  /// The parameter `businessId` of this provider.
  String get businessId;
}

class _BusinessFeaturesProviderElement
    extends AutoDisposeStreamProviderElement<BusinessFeatures>
    with BusinessFeaturesRef {
  _BusinessFeaturesProviderElement(super.provider);

  @override
  String get businessId => (origin as BusinessFeaturesProvider).businessId;
}

String _$businessUIHash() => r'98692a7901aec07924e4a00767fcdaa1fe41ba4b';

/// Stream provider for business UI configuration
///
/// Copied from [businessUI].
@ProviderFor(businessUI)
const businessUIProvider = BusinessUIFamily();

/// Stream provider for business UI configuration
///
/// Copied from [businessUI].
class BusinessUIFamily extends Family<AsyncValue<BusinessUI>> {
  /// Stream provider for business UI configuration
  ///
  /// Copied from [businessUI].
  const BusinessUIFamily();

  /// Stream provider for business UI configuration
  ///
  /// Copied from [businessUI].
  BusinessUIProvider call(
    String businessId,
  ) {
    return BusinessUIProvider(
      businessId,
    );
  }

  @override
  BusinessUIProvider getProviderOverride(
    covariant BusinessUIProvider provider,
  ) {
    return call(
      provider.businessId,
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
  String? get name => r'businessUIProvider';
}

/// Stream provider for business UI configuration
///
/// Copied from [businessUI].
class BusinessUIProvider extends AutoDisposeStreamProvider<BusinessUI> {
  /// Stream provider for business UI configuration
  ///
  /// Copied from [businessUI].
  BusinessUIProvider(
    String businessId,
  ) : this._internal(
          (ref) => businessUI(
            ref as BusinessUIRef,
            businessId,
          ),
          from: businessUIProvider,
          name: r'businessUIProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$businessUIHash,
          dependencies: BusinessUIFamily._dependencies,
          allTransitiveDependencies:
              BusinessUIFamily._allTransitiveDependencies,
          businessId: businessId,
        );

  BusinessUIProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.businessId,
  }) : super.internal();

  final String businessId;

  @override
  Override overrideWith(
    Stream<BusinessUI> Function(BusinessUIRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BusinessUIProvider._internal(
        (ref) => create(ref as BusinessUIRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        businessId: businessId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<BusinessUI> createElement() {
    return _BusinessUIProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessUIProvider && other.businessId == businessId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, businessId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BusinessUIRef on AutoDisposeStreamProviderRef<BusinessUI> {
  /// The parameter `businessId` of this provider.
  String get businessId;
}

class _BusinessUIProviderElement
    extends AutoDisposeStreamProviderElement<BusinessUI> with BusinessUIRef {
  _BusinessUIProviderElement(super.provider);

  @override
  String get businessId => (origin as BusinessUIProvider).businessId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
