// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_routing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentRouteLocationHash() =>
    r'3baf83b721b80d0678b3b94382fe0df885d8cf08';

/// Provider that gets the current route location without circular dependencies
/// OPTIMIZED: Uses direct browser URL reading instead of watching goRouter
///
/// Copied from [currentRouteLocation].
@ProviderFor(currentRouteLocation)
final currentRouteLocationProvider = AutoDisposeProvider<String>.internal(
  currentRouteLocation,
  name: r'currentRouteLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentRouteLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentRouteLocationRef = AutoDisposeProviderRef<String>;
String _$initialUrlPathHash() => r'75fc4ac43cc13a500761048641d2845ff6bd1c5c';

/// Provider for immediate URL detection during app startup
/// This runs once at startup to capture the initial URL before routing begins
///
/// Copied from [initialUrlPath].
@ProviderFor(initialUrlPath)
final initialUrlPathProvider = AutoDisposeProvider<String>.internal(
  initialUrlPath,
  name: r'initialUrlPathProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialUrlPathHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitialUrlPathRef = AutoDisposeProviderRef<String>;
String _$earlyBusinessSlugHash() => r'fe39ce531ded36da86708d63e23581a769a04407';

/// Provider for early business slug detection during app startup
/// This provides immediate business context before routing is fully initialized
///
/// Copied from [earlyBusinessSlug].
@ProviderFor(earlyBusinessSlug)
final earlyBusinessSlugProvider = AutoDisposeProvider<String?>.internal(
  earlyBusinessSlug,
  name: r'earlyBusinessSlugProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$earlyBusinessSlugHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EarlyBusinessSlugRef = AutoDisposeProviderRef<String?>;
String _$businessSlugFromUrlHash() =>
    r'086f5dc072b77ca905a4c2f40efc61b44e4be37d';

/// Provider that extracts business slug from the current URL path
/// Now reactive to route changes via currentRouteLocation AND detects initial URL
///
/// Copied from [businessSlugFromUrl].
@ProviderFor(businessSlugFromUrl)
final businessSlugFromUrlProvider = AutoDisposeProvider<String?>.internal(
  businessSlugFromUrl,
  name: r'businessSlugFromUrlProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessSlugFromUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessSlugFromUrlRef = AutoDisposeProviderRef<String?>;
String _$isBusinessUrlAccessHash() =>
    r'3389707112a8149cf8ac3838f0fadfece049b583';

/// Provider to check if current access is via business-specific URL
///
/// Copied from [isBusinessUrlAccess].
@ProviderFor(isBusinessUrlAccess)
final isBusinessUrlAccessProvider = AutoDisposeProvider<bool>.internal(
  isBusinessUrlAccess,
  name: r'isBusinessUrlAccessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isBusinessUrlAccessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsBusinessUrlAccessRef = AutoDisposeProviderRef<bool>;
String _$businessRoutePrefixHash() =>
    r'cef868800657cbc8174f28eccf2034883825ecd6';

/// Provider to get the current business route prefix (slug)
/// Returns the business slug if accessing via business URL, null otherwise
///
/// Copied from [businessRoutePrefix].
@ProviderFor(businessRoutePrefix)
final businessRoutePrefixProvider = AutoDisposeProvider<String?>.internal(
  businessRoutePrefix,
  name: r'businessRoutePrefixProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessRoutePrefixHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessRoutePrefixRef = AutoDisposeProviderRef<String?>;
String _$currentBusinessSlugHash() =>
    r'5c75cc882fbd7b707fe1fde730fdc25fd07daa61';

/// Provider to get the current business slug from URL
/// This is an alias for businessSlugFromUrlProvider for clearer usage
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
String _$urlAwareBusinessIdHash() =>
    r'5c52f3def1911dfea937684bd98d69225632d599';

/// Provider for URL-aware business ID
/// This provider combines URL-based business slug with fallback to local storage
/// OPTIMIZED: Reduces unnecessary rebuilds by using ref.read for services
///
/// Copied from [UrlAwareBusinessId].
@ProviderFor(UrlAwareBusinessId)
final urlAwareBusinessIdProvider =
    AutoDisposeAsyncNotifierProvider<UrlAwareBusinessId, String>.internal(
  UrlAwareBusinessId.new,
  name: r'urlAwareBusinessIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$urlAwareBusinessIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UrlAwareBusinessId = AutoDisposeAsyncNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
