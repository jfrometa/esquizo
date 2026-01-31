// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preference_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userPreferencesRepositoryHash() =>
    r'26d22885ec2776891a58701998e5d05f4ffc95e7';

/// See also [userPreferencesRepository].
@ProviderFor(userPreferencesRepository)
final userPreferencesRepositoryProvider =
    AutoDisposeProvider<OptimizedUserPreferencesRepository>.internal(
  userPreferencesRepository,
  name: r'userPreferencesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userPreferencesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserPreferencesRepositoryRef
    = AutoDisposeProviderRef<OptimizedUserPreferencesRepository>;
String _$userPreferencesHash() => r'cb7dcb010ed5751c422f06801599016fb541b554';

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

/// See also [userPreferences].
@ProviderFor(userPreferences)
const userPreferencesProvider = UserPreferencesFamily();

/// See also [userPreferences].
class UserPreferencesFamily extends Family<AsyncValue<UserPreferences>> {
  /// See also [userPreferences].
  const UserPreferencesFamily();

  /// See also [userPreferences].
  UserPreferencesProvider call(
    String userId,
  ) {
    return UserPreferencesProvider(
      userId,
    );
  }

  @override
  UserPreferencesProvider getProviderOverride(
    covariant UserPreferencesProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userPreferencesProvider';
}

/// See also [userPreferences].
class UserPreferencesProvider
    extends AutoDisposeStreamProvider<UserPreferences> {
  /// See also [userPreferences].
  UserPreferencesProvider(
    String userId,
  ) : this._internal(
          (ref) => userPreferences(
            ref as UserPreferencesRef,
            userId,
          ),
          from: userPreferencesProvider,
          name: r'userPreferencesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userPreferencesHash,
          dependencies: UserPreferencesFamily._dependencies,
          allTransitiveDependencies:
              UserPreferencesFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserPreferencesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<UserPreferences> Function(UserPreferencesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserPreferencesProvider._internal(
        (ref) => create(ref as UserPreferencesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<UserPreferences> createElement() {
    return _UserPreferencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPreferencesProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserPreferencesRef on AutoDisposeStreamProviderRef<UserPreferences> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserPreferencesProviderElement
    extends AutoDisposeStreamProviderElement<UserPreferences>
    with UserPreferencesRef {
  _UserPreferencesProviderElement(super.provider);

  @override
  String get userId => (origin as UserPreferencesProvider).userId;
}

String _$appThemeModeHash() => r'93b5419d7a5ba28b46622b1214baa32e03db67a9';

/// See also [AppThemeMode].
@ProviderFor(AppThemeMode)
final appThemeModeProvider =
    AutoDisposeNotifierProvider<AppThemeMode, ThemeMode>.internal(
  AppThemeMode.new,
  name: r'appThemeModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppThemeMode = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
