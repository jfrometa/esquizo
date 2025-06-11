// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_business_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentBusinessIdFromContextHash() =>
    r'2fa63471d960f33c522d6d9d921b797f3dc7c24f';

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
    r'5ffe3c78c7f8acd573d6d77302441fe2d8a92deb';

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
    r'092e40df5a66d4888fa7748e5ae307fff092b7ea';

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
    r'9e30b0d4e81a2ab7ebdfe069b3dbd1522b02f82e';

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
    r'2895a4adc93dca45b956a34961a8e223cd158c93';

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
    r'8d76adb93c6e999137be4266105c09f8436149c0';

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
    r'3cb2fc8802bc56c046a3585ef93d1851350f8b35';

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
    r'bdfa1e518fd881650b9505c3462bf08d670eb219';

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
    r'0ec2f2eb9a281523fc4f1e64549e74cb81d5c066';

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
