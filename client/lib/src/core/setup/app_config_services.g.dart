// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_services.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appStartupHash() => r'56579fd0f5dd8db5f2b8d4d6cc5d1197fec99aa3';

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
String _$eagerAdminStatusHash() => r'808469ba2ca1af76783a9c68c257e66dbfb17fa0';

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
