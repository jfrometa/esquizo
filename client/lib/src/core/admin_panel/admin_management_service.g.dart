// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_management_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isAdminHash() => r'9a06d001dac104e98ec829012e6663a6963476d8';

/// See also [isAdmin].
@ProviderFor(isAdmin)
final isAdminProvider = AutoDisposeFutureProvider<bool>.internal(
  isAdmin,
  name: r'isAdminProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAdminRef = AutoDisposeFutureProviderRef<bool>;
String _$refreshAdminStatusHash() =>
    r'7ae107993960eff42b6d8dbc4f0e3900a1e08e3b';

/// See also [refreshAdminStatus].
@ProviderFor(refreshAdminStatus)
final refreshAdminStatusProvider = AutoDisposeFutureProvider<void>.internal(
  refreshAdminStatus,
  name: r'refreshAdminStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$refreshAdminStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RefreshAdminStatusRef = AutoDisposeFutureProviderRef<void>;
String _$autoCheckAdminStatusHash() =>
    r'b0734aa009201aab14d346380046ef2635246b2f';

/// See also [autoCheckAdminStatus].
@ProviderFor(autoCheckAdminStatus)
final autoCheckAdminStatusProvider = AutoDisposeProvider<void>.internal(
  autoCheckAdminStatus,
  name: r'autoCheckAdminStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoCheckAdminStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AutoCheckAdminStatusRef = AutoDisposeProviderRef<void>;
String _$adminsStreamHash() => r'8de3e49d83ff056e4eac1240b14ac6bf7685a598';

/// See also [adminsStream].
@ProviderFor(adminsStream)
final adminsStreamProvider =
    AutoDisposeStreamProvider<List<AdminUser>>.internal(
  adminsStream,
  name: r'adminsStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminsStreamRef = AutoDisposeStreamProviderRef<List<AdminUser>>;
String _$unifiedAdminServiceHash() =>
    r'd775af273e3cc251fa62c3ac6e2693a46ff26f4a';

/// Unified admin service that handles all admin-related operations.
///
/// Copied from [UnifiedAdminService].
@ProviderFor(UnifiedAdminService)
final unifiedAdminServiceProvider = AutoDisposeNotifierProvider<
    UnifiedAdminService, UnifiedAdminService>.internal(
  UnifiedAdminService.new,
  name: r'unifiedAdminServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unifiedAdminServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnifiedAdminService = AutoDisposeNotifier<UnifiedAdminService>;
String _$cachedAdminStatusHash() => r'756110a9ae60a16bbe30deaee3e0f9be60c72015';

/// See also [CachedAdminStatus].
@ProviderFor(CachedAdminStatus)
final cachedAdminStatusProvider =
    AutoDisposeNotifierProvider<CachedAdminStatus, bool>.internal(
  CachedAdminStatus.new,
  name: r'cachedAdminStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cachedAdminStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CachedAdminStatus = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
