// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_services.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appStartupHash() => r'8e2fdd525b68b107544c66591b31b7c359ecfe2c';

/// See also [appStartup].
@ProviderFor(appStartup)
final appStartupProvider = FutureProvider<void>.internal(
  appStartup,
  name: r'appStartupProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appStartupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppStartupRef = FutureProviderRef<void>;
String _$eagerAdminStatusHash() => r'c4db1ce7e894c600c07b010420260277a5beed34';

/// Provider for checking admin status eagerly (helping with UI updates)
///
/// Copied from [eagerAdminStatus].
@ProviderFor(eagerAdminStatus)
final eagerAdminStatusProvider = AutoDisposeFutureProvider<bool>.internal(
  eagerAdminStatus,
  name: r'eagerAdminStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eagerAdminStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EagerAdminStatusRef = AutoDisposeFutureProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
