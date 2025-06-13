// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_business_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentBusinessIdFromContextHash() =>
    r'fb43520c752c741e0ec126c48fff5e84bf72eca2';

/// Provider for current business ID (simplified access)
///
/// Copied from [currentBusinessIdFromContext].
@ProviderFor(currentBusinessIdFromContext)
final currentBusinessIdFromContextProvider =
    AutoDisposeProvider<String>.internal(
  currentBusinessIdFromContext,
  name: r'currentBusinessIdFromContextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBusinessIdFromContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentBusinessIdFromContextRef = AutoDisposeProviderRef<String>;
String _$currentBusinessSlugFromContextHash() =>
    r'b8a3c7c41c359a62dac77335e727e1ec4c3b424e';

/// Provider for current business slug (simplified access)
///
/// Copied from [currentBusinessSlugFromContext].
@ProviderFor(currentBusinessSlugFromContext)
final currentBusinessSlugFromContextProvider =
    AutoDisposeProvider<String?>.internal(
  currentBusinessSlugFromContext,
  name: r'currentBusinessSlugFromContextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBusinessSlugFromContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentBusinessSlugFromContextRef = AutoDisposeProviderRef<String?>;
String _$isDefaultBusinessContextHash() =>
    r'b3ab44654a086c14df685a485e30e606d47d10eb';

/// Provider to check if currently using default business
///
/// Copied from [isDefaultBusinessContext].
@ProviderFor(isDefaultBusinessContext)
final isDefaultBusinessContextProvider = AutoDisposeProvider<bool>.internal(
  isDefaultBusinessContext,
  name: r'isDefaultBusinessContextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isDefaultBusinessContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsDefaultBusinessContextRef = AutoDisposeProviderRef<bool>;
String _$isBusinessSpecificContextHash() =>
    r'5558a9018c7c0db1967cbcac79a237a792c0ca14';

/// Provider to check if currently using business-specific context
///
/// Copied from [isBusinessSpecificContext].
@ProviderFor(isBusinessSpecificContext)
final isBusinessSpecificContextProvider = AutoDisposeProvider<bool>.internal(
  isBusinessSpecificContext,
  name: r'isBusinessSpecificContextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isBusinessSpecificContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsBusinessSpecificContextRef = AutoDisposeProviderRef<bool>;
String _$currentRoutingBusinessIdHash() =>
    r'097cf2dbd224be23bae06e6eaf766342c77bd015';

/// Provider that returns the current business ID based on routing context
/// - If on business-specific route (e.g., /g3), returns the business ID for that slug
/// - If on default route (e.g., /menu), returns the default business ID
///
/// Copied from [currentRoutingBusinessId].
@ProviderFor(currentRoutingBusinessId)
final currentRoutingBusinessIdProvider =
    AutoDisposeFutureProvider<String>.internal(
  currentRoutingBusinessId,
  name: r'currentRoutingBusinessIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentRoutingBusinessIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentRoutingBusinessIdRef = AutoDisposeFutureProviderRef<String>;
String _$isBusinessSpecificRoutingHash() =>
    r'3dc583c51a21f69794bc551c19314ee5cde086ac';

/// Provider that checks if we're currently in business-specific routing mode
///
/// Copied from [isBusinessSpecificRouting].
@ProviderFor(isBusinessSpecificRouting)
final isBusinessSpecificRoutingProvider = AutoDisposeProvider<bool>.internal(
  isBusinessSpecificRouting,
  name: r'isBusinessSpecificRoutingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isBusinessSpecificRoutingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsBusinessSpecificRoutingRef = AutoDisposeProviderRef<bool>;
String _$currentBusinessSlugHash() =>
    r'5c75cc882fbd7b707fe1fde730fdc25fd07daa61';

/// Provider that returns the current business slug (null for default routing)
///
/// Copied from [currentBusinessSlug].
@ProviderFor(currentBusinessSlug)
final currentBusinessSlugProvider = AutoDisposeProvider<String?>.internal(
  currentBusinessSlug,
  name: r'currentBusinessSlugProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBusinessSlugHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentBusinessSlugRef = AutoDisposeProviderRef<String?>;
String _$unifiedBusinessContextHash() =>
    r'cbb70aca669fdcfebe99ce4cb92439c1d77fbbfd';

/// Unified business context provider that watches for slug changes and manages business context
///
/// Copied from [UnifiedBusinessContext].
@ProviderFor(UnifiedBusinessContext)
final unifiedBusinessContextProvider = AutoDisposeAsyncNotifierProvider<
    UnifiedBusinessContext, BusinessContext>.internal(
  UnifiedBusinessContext.new,
  name: r'unifiedBusinessContextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unifiedBusinessContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnifiedBusinessContext = AutoDisposeAsyncNotifier<BusinessContext>;
String _$explicitBusinessContextHash() =>
    r'dc08c983c8df8942ea9e186e2aa94695c1bbd08a';

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

abstract class _$ExplicitBusinessContext
    extends BuildlessAutoDisposeAsyncNotifier<BusinessContext> {
  late final String businessSlug;

  FutureOr<BusinessContext> build(
    String businessSlug,
  );
}

/// Explicit business context provider that works with a specific business slug
/// This avoids race conditions with URL detection during navigation
///
/// Copied from [ExplicitBusinessContext].
@ProviderFor(ExplicitBusinessContext)
const explicitBusinessContextProvider = ExplicitBusinessContextFamily();

/// Explicit business context provider that works with a specific business slug
/// This avoids race conditions with URL detection during navigation
///
/// Copied from [ExplicitBusinessContext].
class ExplicitBusinessContextFamily
    extends Family<AsyncValue<BusinessContext>> {
  /// Explicit business context provider that works with a specific business slug
  /// This avoids race conditions with URL detection during navigation
  ///
  /// Copied from [ExplicitBusinessContext].
  const ExplicitBusinessContextFamily();

  /// Explicit business context provider that works with a specific business slug
  /// This avoids race conditions with URL detection during navigation
  ///
  /// Copied from [ExplicitBusinessContext].
  ExplicitBusinessContextProvider call(
    String businessSlug,
  ) {
    return ExplicitBusinessContextProvider(
      businessSlug,
    );
  }

  @override
  ExplicitBusinessContextProvider getProviderOverride(
    covariant ExplicitBusinessContextProvider provider,
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
  String? get name => r'explicitBusinessContextProvider';
}

/// Explicit business context provider that works with a specific business slug
/// This avoids race conditions with URL detection during navigation
///
/// Copied from [ExplicitBusinessContext].
class ExplicitBusinessContextProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ExplicitBusinessContext,
        BusinessContext> {
  /// Explicit business context provider that works with a specific business slug
  /// This avoids race conditions with URL detection during navigation
  ///
  /// Copied from [ExplicitBusinessContext].
  ExplicitBusinessContextProvider(
    String businessSlug,
  ) : this._internal(
          () => ExplicitBusinessContext()..businessSlug = businessSlug,
          from: explicitBusinessContextProvider,
          name: r'explicitBusinessContextProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$explicitBusinessContextHash,
          dependencies: ExplicitBusinessContextFamily._dependencies,
          allTransitiveDependencies:
              ExplicitBusinessContextFamily._allTransitiveDependencies,
          businessSlug: businessSlug,
        );

  ExplicitBusinessContextProvider._internal(
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
  FutureOr<BusinessContext> runNotifierBuild(
    covariant ExplicitBusinessContext notifier,
  ) {
    return notifier.build(
      businessSlug,
    );
  }

  @override
  Override overrideWith(ExplicitBusinessContext Function() create) {
    return ProviderOverride(
      origin: this,
      override: ExplicitBusinessContextProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ExplicitBusinessContext,
      BusinessContext> createElement() {
    return _ExplicitBusinessContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExplicitBusinessContextProvider &&
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
mixin ExplicitBusinessContextRef
    on AutoDisposeAsyncNotifierProviderRef<BusinessContext> {
  /// The parameter `businessSlug` of this provider.
  String get businessSlug;
}

class _ExplicitBusinessContextProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ExplicitBusinessContext,
        BusinessContext> with ExplicitBusinessContextRef {
  _ExplicitBusinessContextProviderElement(super.provider);

  @override
  String get businessSlug =>
      (origin as ExplicitBusinessContextProvider).businessSlug;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
