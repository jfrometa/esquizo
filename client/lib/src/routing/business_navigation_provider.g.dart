// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentBusinessNavigationHash() =>
    r'7a0d78a2eb6ca611bbeca5569057246b1b5d5f2c';

/// Provider for current business navigation info
/// FIXED: Use ref.read for urlBusinessSlug to avoid circular dependency
///
/// Copied from [currentBusinessNavigation].
@ProviderFor(currentBusinessNavigation)
final currentBusinessNavigationProvider =
    AutoDisposeProvider<BusinessNavigationInfo?>.internal(
  currentBusinessNavigation,
  name: r'currentBusinessNavigationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBusinessNavigationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentBusinessNavigationRef
    = AutoDisposeProviderRef<BusinessNavigationInfo?>;
String _$shouldOptimizeNavigationHash() =>
    r'3f4c7bfbac7b6094171baac3c67bccb2d342dcd1';

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

/// Provider to check if navigation should be optimized (same business)
/// FIXED: Use ref.read to avoid circular dependency with currentBusinessNavigationProvider
///
/// Copied from [shouldOptimizeNavigation].
@ProviderFor(shouldOptimizeNavigation)
const shouldOptimizeNavigationProvider = ShouldOptimizeNavigationFamily();

/// Provider to check if navigation should be optimized (same business)
/// FIXED: Use ref.read to avoid circular dependency with currentBusinessNavigationProvider
///
/// Copied from [shouldOptimizeNavigation].
class ShouldOptimizeNavigationFamily extends Family<bool> {
  /// Provider to check if navigation should be optimized (same business)
  /// FIXED: Use ref.read to avoid circular dependency with currentBusinessNavigationProvider
  ///
  /// Copied from [shouldOptimizeNavigation].
  const ShouldOptimizeNavigationFamily();

  /// Provider to check if navigation should be optimized (same business)
  /// FIXED: Use ref.read to avoid circular dependency with currentBusinessNavigationProvider
  ///
  /// Copied from [shouldOptimizeNavigation].
  ShouldOptimizeNavigationProvider call(
    String targetBusinessSlug,
    String targetRoute,
  ) {
    return ShouldOptimizeNavigationProvider(
      targetBusinessSlug,
      targetRoute,
    );
  }

  @override
  ShouldOptimizeNavigationProvider getProviderOverride(
    covariant ShouldOptimizeNavigationProvider provider,
  ) {
    return call(
      provider.targetBusinessSlug,
      provider.targetRoute,
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
  String? get name => r'shouldOptimizeNavigationProvider';
}

/// Provider to check if navigation should be optimized (same business)
/// FIXED: Use ref.read to avoid circular dependency with currentBusinessNavigationProvider
///
/// Copied from [shouldOptimizeNavigation].
class ShouldOptimizeNavigationProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if navigation should be optimized (same business)
  /// FIXED: Use ref.read to avoid circular dependency with currentBusinessNavigationProvider
  ///
  /// Copied from [shouldOptimizeNavigation].
  ShouldOptimizeNavigationProvider(
    String targetBusinessSlug,
    String targetRoute,
  ) : this._internal(
          (ref) => shouldOptimizeNavigation(
            ref as ShouldOptimizeNavigationRef,
            targetBusinessSlug,
            targetRoute,
          ),
          from: shouldOptimizeNavigationProvider,
          name: r'shouldOptimizeNavigationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shouldOptimizeNavigationHash,
          dependencies: ShouldOptimizeNavigationFamily._dependencies,
          allTransitiveDependencies:
              ShouldOptimizeNavigationFamily._allTransitiveDependencies,
          targetBusinessSlug: targetBusinessSlug,
          targetRoute: targetRoute,
        );

  ShouldOptimizeNavigationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.targetBusinessSlug,
    required this.targetRoute,
  }) : super.internal();

  final String targetBusinessSlug;
  final String targetRoute;

  @override
  Override overrideWith(
    bool Function(ShouldOptimizeNavigationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShouldOptimizeNavigationProvider._internal(
        (ref) => create(ref as ShouldOptimizeNavigationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        targetBusinessSlug: targetBusinessSlug,
        targetRoute: targetRoute,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _ShouldOptimizeNavigationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShouldOptimizeNavigationProvider &&
        other.targetBusinessSlug == targetBusinessSlug &&
        other.targetRoute == targetRoute;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, targetBusinessSlug.hashCode);
    hash = _SystemHash.combine(hash, targetRoute.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShouldOptimizeNavigationRef on AutoDisposeProviderRef<bool> {
  /// The parameter `targetBusinessSlug` of this provider.
  String get targetBusinessSlug;

  /// The parameter `targetRoute` of this provider.
  String get targetRoute;
}

class _ShouldOptimizeNavigationProviderElement
    extends AutoDisposeProviderElement<bool> with ShouldOptimizeNavigationRef {
  _ShouldOptimizeNavigationProviderElement(super.provider);

  @override
  String get targetBusinessSlug =>
      (origin as ShouldOptimizeNavigationProvider).targetBusinessSlug;
  @override
  String get targetRoute =>
      (origin as ShouldOptimizeNavigationProvider).targetRoute;
}

String _$businessNavigationControllerHash() =>
    r'e64f3b9bde8856485e5cfc4b545d06c2eef95d46';

/// Provider for optimized business navigation state
///
/// Copied from [BusinessNavigationController].
@ProviderFor(BusinessNavigationController)
final businessNavigationControllerProvider = AutoDisposeNotifierProvider<
    BusinessNavigationController, BusinessNavigationState?>.internal(
  BusinessNavigationController.new,
  name: r'businessNavigationControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessNavigationControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BusinessNavigationController
    = AutoDisposeNotifier<BusinessNavigationState?>;
String _$cachedBusinessContextHash() =>
    r'fbd50a7ab7fc037a60ef20ae6e483518ae03a8f1';

abstract class _$CachedBusinessContext
    extends BuildlessAutoDisposeNotifier<BusinessContext?> {
  late final String businessSlug;

  BusinessContext? build(
    String businessSlug,
  );
}

/// Provider for cached business context - prevents re-fetching
/// Enhanced with TTL-based cache invalidation
///
/// Copied from [CachedBusinessContext].
@ProviderFor(CachedBusinessContext)
const cachedBusinessContextProvider = CachedBusinessContextFamily();

/// Provider for cached business context - prevents re-fetching
/// Enhanced with TTL-based cache invalidation
///
/// Copied from [CachedBusinessContext].
class CachedBusinessContextFamily extends Family<BusinessContext?> {
  /// Provider for cached business context - prevents re-fetching
  /// Enhanced with TTL-based cache invalidation
  ///
  /// Copied from [CachedBusinessContext].
  const CachedBusinessContextFamily();

  /// Provider for cached business context - prevents re-fetching
  /// Enhanced with TTL-based cache invalidation
  ///
  /// Copied from [CachedBusinessContext].
  CachedBusinessContextProvider call(
    String businessSlug,
  ) {
    return CachedBusinessContextProvider(
      businessSlug,
    );
  }

  @override
  CachedBusinessContextProvider getProviderOverride(
    covariant CachedBusinessContextProvider provider,
  ) {
    return call(
      provider.businessSlug,
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
  String? get name => r'cachedBusinessContextProvider';
}

/// Provider for cached business context - prevents re-fetching
/// Enhanced with TTL-based cache invalidation
///
/// Copied from [CachedBusinessContext].
class CachedBusinessContextProvider extends AutoDisposeNotifierProviderImpl<
    CachedBusinessContext, BusinessContext?> {
  /// Provider for cached business context - prevents re-fetching
  /// Enhanced with TTL-based cache invalidation
  ///
  /// Copied from [CachedBusinessContext].
  CachedBusinessContextProvider(
    String businessSlug,
  ) : this._internal(
          () => CachedBusinessContext()..businessSlug = businessSlug,
          from: cachedBusinessContextProvider,
          name: r'cachedBusinessContextProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cachedBusinessContextHash,
          dependencies: CachedBusinessContextFamily._dependencies,
          allTransitiveDependencies:
              CachedBusinessContextFamily._allTransitiveDependencies,
          businessSlug: businessSlug,
        );

  CachedBusinessContextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.businessSlug,
  }) : super.internal();

  final String businessSlug;

  @override
  BusinessContext? runNotifierBuild(
    covariant CachedBusinessContext notifier,
  ) {
    return notifier.build(
      businessSlug,
    );
  }

  @override
  Override overrideWith(CachedBusinessContext Function() create) {
    return ProviderOverride(
      origin: this,
      override: CachedBusinessContextProvider._internal(
        () => create()..businessSlug = businessSlug,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        businessSlug: businessSlug,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CachedBusinessContext, BusinessContext?>
      createElement() {
    return _CachedBusinessContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CachedBusinessContextProvider &&
        other.businessSlug == businessSlug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, businessSlug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CachedBusinessContextRef
    on AutoDisposeNotifierProviderRef<BusinessContext?> {
  /// The parameter `businessSlug` of this provider.
  String get businessSlug;
}

class _CachedBusinessContextProviderElement
    extends AutoDisposeNotifierProviderElement<CachedBusinessContext,
        BusinessContext?> with CachedBusinessContextRef {
  _CachedBusinessContextProviderElement(super.provider);

  @override
  String get businessSlug =>
      (origin as CachedBusinessContextProvider).businessSlug;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
