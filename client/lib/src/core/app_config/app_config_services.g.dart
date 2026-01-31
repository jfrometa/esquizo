// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_services.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseInitializationHash() =>
    r'100346960924409e609f0825f8c9486c379e03da';

/// See also [firebaseInitialization].
@ProviderFor(firebaseInitialization)
final firebaseInitializationProvider =
    AutoDisposeFutureProvider<FirebaseApp>.internal(
  firebaseInitialization,
  name: r'firebaseInitializationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseInitializationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseInitializationRef = AutoDisposeFutureProviderRef<FirebaseApp>;
String _$localStorageInitHash() => r'94ed1d6391f5092ea14320483687303392b72028';

/// See also [localStorageInit].
@ProviderFor(localStorageInit)
final localStorageInitProvider = AutoDisposeFutureProvider<void>.internal(
  localStorageInit,
  name: r'localStorageInitProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localStorageInitHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalStorageInitRef = AutoDisposeFutureProviderRef<void>;
String _$businessConfigInitHash() =>
    r'3f3285496fa38ac80fbd362511864e28b494c111';

/// See also [businessConfigInit].
@ProviderFor(businessConfigInit)
final businessConfigInitProvider =
    AutoDisposeFutureProvider<BusinessConfig?>.internal(
  businessConfigInit,
  name: r'businessConfigInitProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessConfigInitHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessConfigInitRef = AutoDisposeFutureProviderRef<BusinessConfig?>;
String _$appStartupHash() => r'bc6e9a9405675c025783ae62c17238ea49a5925c';

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
String _$isSetupCompleteHash() => r'abb9f5f047ca76647aa9ff55047fc17add282bb1';

/// See also [isSetupComplete].
@ProviderFor(isSetupComplete)
final isSetupCompleteProvider = AutoDisposeProvider<bool>.internal(
  isSetupComplete,
  name: r'isSetupCompleteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSetupCompleteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsSetupCompleteRef = AutoDisposeProviderRef<bool>;
String _$shouldShowSetupScreenHash() =>
    r'2baf169adbdd7a422969126ea2c4cafda59efe19';

/// See also [shouldShowSetupScreen].
@ProviderFor(shouldShowSetupScreen)
final shouldShowSetupScreenProvider = AutoDisposeProvider<bool>.internal(
  shouldShowSetupScreen,
  name: r'shouldShowSetupScreenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shouldShowSetupScreenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShouldShowSetupScreenRef = AutoDisposeProviderRef<bool>;
String _$isFirebaseInitializedHash() =>
    r'ec160ef8a11c614090d567ddac228ca076402952';

/// See also [IsFirebaseInitialized].
@ProviderFor(IsFirebaseInitialized)
final isFirebaseInitializedProvider =
    NotifierProvider<IsFirebaseInitialized, bool>.internal(
  IsFirebaseInitialized.new,
  name: r'isFirebaseInitializedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isFirebaseInitializedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IsFirebaseInitialized = Notifier<bool>;
String _$appStartupResultStatusHash() =>
    r'55ee75a603ebac40fcbc8d1208816f20188a291a';

/// See also [AppStartupResultStatus].
@ProviderFor(AppStartupResultStatus)
final appStartupResultStatusProvider =
    NotifierProvider<AppStartupResultStatus, AppStartupResult?>.internal(
  AppStartupResultStatus.new,
  name: r'appStartupResultStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStartupResultStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppStartupResultStatus = Notifier<AppStartupResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
