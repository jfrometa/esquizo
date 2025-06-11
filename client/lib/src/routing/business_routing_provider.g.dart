// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_routing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$businessIdFromUrlHash() => r'498c1d832c5d51ab31747b25e65e9d16b63cf7c7';

/// Provider that extracts business ID from the current URL path
///
/// Copied from [businessIdFromUrl].
@ProviderFor(businessIdFromUrl)
final businessIdFromUrlProvider = AutoDisposeProvider<String?>.internal(
  businessIdFromUrl,
  name: r'businessIdFromUrlProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessIdFromUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessIdFromUrlRef = AutoDisposeProviderRef<String?>;
String _$isBusinessUrlAccessHash() =>
    r'ab78448a89504f7813b157f60bced1380a40696a';

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
    r'c02ae01e6c51df28f1cdb07162416782b2caea9e';

/// Provider to get the current business route prefix
/// Returns the business ID if accessing via business URL, null otherwise
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
String _$urlAwareBusinessIdHash() =>
    r'2e44726c0d99d573a9d0e6a2fed8c13738565fa7';

/// Provider for URL-aware business ID
/// This provider combines URL-based business ID with fallback to local storage
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
