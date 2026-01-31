// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_slug_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$businessSlugServiceHash() =>
    r'233002b30d152def811713d9c5f98e5e8b0450aa';

/// See also [businessSlugService].
@ProviderFor(businessSlugService)
final businessSlugServiceProvider = Provider<BusinessSlugService>.internal(
  businessSlugService,
  name: r'businessSlugServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessSlugServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessSlugServiceRef = ProviderRef<BusinessSlugService>;
String _$businessIdFromSlugHash() =>
    r'e26eee5dfd4695c5b893bfe1c42ab4f651b7015c';

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

/// See also [businessIdFromSlug].
@ProviderFor(businessIdFromSlug)
const businessIdFromSlugProvider = BusinessIdFromSlugFamily();

/// See also [businessIdFromSlug].
class BusinessIdFromSlugFamily extends Family<AsyncValue<String?>> {
  /// See also [businessIdFromSlug].
  const BusinessIdFromSlugFamily();

  /// See also [businessIdFromSlug].
  BusinessIdFromSlugProvider call(
    String slug,
  ) {
    return BusinessIdFromSlugProvider(
      slug,
    );
  }

  @override
  BusinessIdFromSlugProvider getProviderOverride(
    covariant BusinessIdFromSlugProvider provider,
  ) {
    return call(
      provider.slug,
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
  String? get name => r'businessIdFromSlugProvider';
}

/// See also [businessIdFromSlug].
class BusinessIdFromSlugProvider extends AutoDisposeFutureProvider<String?> {
  /// See also [businessIdFromSlug].
  BusinessIdFromSlugProvider(
    String slug,
  ) : this._internal(
          (ref) => businessIdFromSlug(
            ref as BusinessIdFromSlugRef,
            slug,
          ),
          from: businessIdFromSlugProvider,
          name: r'businessIdFromSlugProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$businessIdFromSlugHash,
          dependencies: BusinessIdFromSlugFamily._dependencies,
          allTransitiveDependencies:
              BusinessIdFromSlugFamily._allTransitiveDependencies,
          slug: slug,
        );

  BusinessIdFromSlugProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Override overrideWith(
    FutureOr<String?> Function(BusinessIdFromSlugRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BusinessIdFromSlugProvider._internal(
        (ref) => create(ref as BusinessIdFromSlugRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _BusinessIdFromSlugProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessIdFromSlugProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BusinessIdFromSlugRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _BusinessIdFromSlugProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with BusinessIdFromSlugRef {
  _BusinessIdFromSlugProviderElement(super.provider);

  @override
  String get slug => (origin as BusinessIdFromSlugProvider).slug;
}

String _$slugFromBusinessIdHash() =>
    r'b857a51851c01c58239f8d161766b8e38682c484';

/// See also [slugFromBusinessId].
@ProviderFor(slugFromBusinessId)
const slugFromBusinessIdProvider = SlugFromBusinessIdFamily();

/// See also [slugFromBusinessId].
class SlugFromBusinessIdFamily extends Family<AsyncValue<String?>> {
  /// See also [slugFromBusinessId].
  const SlugFromBusinessIdFamily();

  /// See also [slugFromBusinessId].
  SlugFromBusinessIdProvider call(
    String businessId,
  ) {
    return SlugFromBusinessIdProvider(
      businessId,
    );
  }

  @override
  SlugFromBusinessIdProvider getProviderOverride(
    covariant SlugFromBusinessIdProvider provider,
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
  String? get name => r'slugFromBusinessIdProvider';
}

/// See also [slugFromBusinessId].
class SlugFromBusinessIdProvider extends AutoDisposeFutureProvider<String?> {
  /// See also [slugFromBusinessId].
  SlugFromBusinessIdProvider(
    String businessId,
  ) : this._internal(
          (ref) => slugFromBusinessId(
            ref as SlugFromBusinessIdRef,
            businessId,
          ),
          from: slugFromBusinessIdProvider,
          name: r'slugFromBusinessIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$slugFromBusinessIdHash,
          dependencies: SlugFromBusinessIdFamily._dependencies,
          allTransitiveDependencies:
              SlugFromBusinessIdFamily._allTransitiveDependencies,
          businessId: businessId,
        );

  SlugFromBusinessIdProvider._internal(
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
    FutureOr<String?> Function(SlugFromBusinessIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SlugFromBusinessIdProvider._internal(
        (ref) => create(ref as SlugFromBusinessIdRef),
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
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _SlugFromBusinessIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SlugFromBusinessIdProvider &&
        other.businessId == businessId;
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
mixin SlugFromBusinessIdRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `businessId` of this provider.
  String get businessId;
}

class _SlugFromBusinessIdProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with SlugFromBusinessIdRef {
  _SlugFromBusinessIdProviderElement(super.provider);

  @override
  String get businessId => (origin as SlugFromBusinessIdProvider).businessId;
}

String _$slugAvailabilityHash() => r'5a88c782ccdb24f58e3483bcbea9a7afbeef4dbf';

/// See also [slugAvailability].
@ProviderFor(slugAvailability)
const slugAvailabilityProvider = SlugAvailabilityFamily();

/// See also [slugAvailability].
class SlugAvailabilityFamily extends Family<AsyncValue<bool>> {
  /// See also [slugAvailability].
  const SlugAvailabilityFamily();

  /// See also [slugAvailability].
  SlugAvailabilityProvider call(
    String slug,
  ) {
    return SlugAvailabilityProvider(
      slug,
    );
  }

  @override
  SlugAvailabilityProvider getProviderOverride(
    covariant SlugAvailabilityProvider provider,
  ) {
    return call(
      provider.slug,
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
  String? get name => r'slugAvailabilityProvider';
}

/// See also [slugAvailability].
class SlugAvailabilityProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [slugAvailability].
  SlugAvailabilityProvider(
    String slug,
  ) : this._internal(
          (ref) => slugAvailability(
            ref as SlugAvailabilityRef,
            slug,
          ),
          from: slugAvailabilityProvider,
          name: r'slugAvailabilityProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$slugAvailabilityHash,
          dependencies: SlugAvailabilityFamily._dependencies,
          allTransitiveDependencies:
              SlugAvailabilityFamily._allTransitiveDependencies,
          slug: slug,
        );

  SlugAvailabilityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Override overrideWith(
    FutureOr<bool> Function(SlugAvailabilityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SlugAvailabilityProvider._internal(
        (ref) => create(ref as SlugAvailabilityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _SlugAvailabilityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SlugAvailabilityProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SlugAvailabilityRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _SlugAvailabilityProviderElement
    extends AutoDisposeFutureProviderElement<bool> with SlugAvailabilityRef {
  _SlugAvailabilityProviderElement(super.provider);

  @override
  String get slug => (origin as SlugAvailabilityProvider).slug;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
