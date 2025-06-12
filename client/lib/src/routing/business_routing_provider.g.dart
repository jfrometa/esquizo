// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_routing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$businessSlugFromUrlHash() =>
    r'1c84a878a91d4398c0f970fcce6e87b3f0bcba24';

/// Provider that extracts business slug from the current URL path
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
    r'3cb2fc8802bc56c046a3585ef93d1851350f8b35';

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
    r'da54e379f98cd949616db3db916fd3c6a45fe478';

/// Provider for URL-aware business ID
/// This provider combines URL-based business slug with fallback to local storage
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
