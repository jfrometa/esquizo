// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authProvidersHash() => r'9dccb7b820c87f43149f9e81644c6030ddfed8f9';

/// See also [authProviders].
@ProviderFor(authProviders)
final authProvidersProvider = AutoDisposeProvider<
    List<
        firebase_ui
        .AuthProvider<firebase_ui.AuthListener, AuthCredential>>>.internal(
  authProviders,
  name: r'authProvidersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authProvidersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthProvidersRef = AutoDisposeProviderRef<
    List<firebase_ui.AuthProvider<firebase_ui.AuthListener, AuthCredential>>>;
String _$authRepositoryHash() => r'd013510f985ef12e76b30ac69fab30d30cdf1a2d';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<UnifiedAuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = ProviderRef<UnifiedAuthRepository>;
String _$authStateChangesHash() => r'87f81aab10098a63ba6ea360754c55743e0785c5';

/// See also [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = AutoDisposeStreamProvider<User?>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<User?>;
String _$isAnonymousHash() => r'f0ca3f3cdf3633cb308589105bd3d99b1478ed75';

/// See also [isAnonymous].
@ProviderFor(isAnonymous)
final isAnonymousProvider = AutoDisposeProvider<bool>.internal(
  isAnonymous,
  name: r'isAnonymousProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isAnonymousHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAnonymousRef = AutoDisposeProviderRef<bool>;
String _$authServiceHash() => r'0d0e6d85c325a484e839f0d0b4a53a6c6e97f4a0';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<UnifiedAuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<UnifiedAuthService>;
String _$firebaseUserHash() => r'cf67b53adc2089226643720d3d791b0c911b9a7e';

/// See also [firebaseUser].
@ProviderFor(firebaseUser)
final firebaseUserProvider = AutoDisposeStreamProvider<User?>.internal(
  firebaseUser,
  name: r'firebaseUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseUserRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserIdHash() => r'65678ba5cb0d5d8030f3b0e2af6df9c7ef848e69';

/// See also [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeProvider<String?>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserIdRef = AutoDisposeProviderRef<String?>;
String _$isCurrentUserHash() => r'e7e57de282f932033e6724e467ccd745cdf35807';

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

/// See also [isCurrentUser].
@ProviderFor(isCurrentUser)
const isCurrentUserProvider = IsCurrentUserFamily();

/// See also [isCurrentUser].
class IsCurrentUserFamily extends Family<AsyncValue<bool>> {
  /// See also [isCurrentUser].
  const IsCurrentUserFamily();

  /// See also [isCurrentUser].
  IsCurrentUserProvider call(
    String email,
  ) {
    return IsCurrentUserProvider(
      email,
    );
  }

  @override
  IsCurrentUserProvider getProviderOverride(
    covariant IsCurrentUserProvider provider,
  ) {
    return call(
      provider.email,
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
  String? get name => r'isCurrentUserProvider';
}

/// See also [isCurrentUser].
class IsCurrentUserProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [isCurrentUser].
  IsCurrentUserProvider(
    String email,
  ) : this._internal(
          (ref) => isCurrentUser(
            ref as IsCurrentUserRef,
            email,
          ),
          from: isCurrentUserProvider,
          name: r'isCurrentUserProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isCurrentUserHash,
          dependencies: IsCurrentUserFamily._dependencies,
          allTransitiveDependencies:
              IsCurrentUserFamily._allTransitiveDependencies,
          email: email,
        );

  IsCurrentUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.email,
  }) : super.internal();

  final String email;

  @override
  Override overrideWith(
    FutureOr<bool> Function(IsCurrentUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsCurrentUserProvider._internal(
        (ref) => create(ref as IsCurrentUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        email: email,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsCurrentUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsCurrentUserProvider && other.email == email;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, email.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsCurrentUserRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `email` of this provider.
  String get email;
}

class _IsCurrentUserProviderElement
    extends AutoDisposeFutureProviderElement<bool> with IsCurrentUserRef {
  _IsCurrentUserProviderElement(super.provider);

  @override
  String get email => (origin as IsCurrentUserProvider).email;
}

String _$currentUserHash() => r'afc36324d1faf433ca2ab2b1a883057aaee04aac';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeStreamProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeStreamProviderRef<AppUser?>;
String _$hasRoleHash() => r'a791f490aa2292136723194240a19fb9ccc4d2a8';

/// See also [hasRole].
@ProviderFor(hasRole)
const hasRoleProvider = HasRoleFamily();

/// See also [hasRole].
class HasRoleFamily extends Family<bool> {
  /// See also [hasRole].
  const HasRoleFamily();

  /// See also [hasRole].
  HasRoleProvider call(
    String role,
  ) {
    return HasRoleProvider(
      role,
    );
  }

  @override
  HasRoleProvider getProviderOverride(
    covariant HasRoleProvider provider,
  ) {
    return call(
      provider.role,
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
  String? get name => r'hasRoleProvider';
}

/// See also [hasRole].
class HasRoleProvider extends AutoDisposeProvider<bool> {
  /// See also [hasRole].
  HasRoleProvider(
    String role,
  ) : this._internal(
          (ref) => hasRole(
            ref as HasRoleRef,
            role,
          ),
          from: hasRoleProvider,
          name: r'hasRoleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasRoleHash,
          dependencies: HasRoleFamily._dependencies,
          allTransitiveDependencies: HasRoleFamily._allTransitiveDependencies,
          role: role,
        );

  HasRoleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
  }) : super.internal();

  final String role;

  @override
  Override overrideWith(
    bool Function(HasRoleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasRoleProvider._internal(
        (ref) => create(ref as HasRoleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _HasRoleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasRoleProvider && other.role == role;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HasRoleRef on AutoDisposeProviderRef<bool> {
  /// The parameter `role` of this provider.
  String get role;
}

class _HasRoleProviderElement extends AutoDisposeProviderElement<bool>
    with HasRoleRef {
  _HasRoleProviderElement(super.provider);

  @override
  String get role => (origin as HasRoleProvider).role;
}

String _$authStateHash() => r'3977f7549bc45855abead851fdff1b7bb1dbfb20';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeProvider<AuthState>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeProviderRef<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
