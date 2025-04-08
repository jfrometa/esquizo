// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allNavigationDestinationsHash() =>
    r'91fe991dd79577ed6905d32fb37381f26bba9c61';

/// Provider for all possible navigation destinations (including admin)
///
/// Copied from [allNavigationDestinations].
@ProviderFor(allNavigationDestinations)
final allNavigationDestinationsProvider =
    AutoDisposeProvider<List<NavigationDestinationItem>>.internal(
  allNavigationDestinations,
  name: r'allNavigationDestinationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allNavigationDestinationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllNavigationDestinationsRef
    = AutoDisposeProviderRef<List<NavigationDestinationItem>>;
String _$navigationDestinationsHash() =>
    r'5360a811483875bc39541a14361dd3b5f137c594';

/// Provider for visible navigation destinations
///
/// Copied from [navigationDestinations].
@ProviderFor(navigationDestinations)
final navigationDestinationsProvider =
    AutoDisposeProvider<List<NavigationDestinationItem>>.internal(
  navigationDestinations,
  name: r'navigationDestinationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$navigationDestinationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NavigationDestinationsRef
    = AutoDisposeProviderRef<List<NavigationDestinationItem>>;
String _$findTabIndexFromPathHash() =>
    r'75ecc7288c5d14e60b99711dba2d3eb30fbd1aaa';

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

/// Provider to determine the current tab index based on a path
///
/// Copied from [findTabIndexFromPath].
@ProviderFor(findTabIndexFromPath)
const findTabIndexFromPathProvider = FindTabIndexFromPathFamily();

/// Provider to determine the current tab index based on a path
///
/// Copied from [findTabIndexFromPath].
class FindTabIndexFromPathFamily extends Family<int> {
  /// Provider to determine the current tab index based on a path
  ///
  /// Copied from [findTabIndexFromPath].
  const FindTabIndexFromPathFamily();

  /// Provider to determine the current tab index based on a path
  ///
  /// Copied from [findTabIndexFromPath].
  FindTabIndexFromPathProvider call(
    String path,
  ) {
    return FindTabIndexFromPathProvider(
      path,
    );
  }

  @override
  FindTabIndexFromPathProvider getProviderOverride(
    covariant FindTabIndexFromPathProvider provider,
  ) {
    return call(
      provider.path,
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
  String? get name => r'findTabIndexFromPathProvider';
}

/// Provider to determine the current tab index based on a path
///
/// Copied from [findTabIndexFromPath].
class FindTabIndexFromPathProvider extends AutoDisposeProvider<int> {
  /// Provider to determine the current tab index based on a path
  ///
  /// Copied from [findTabIndexFromPath].
  FindTabIndexFromPathProvider(
    String path,
  ) : this._internal(
          (ref) => findTabIndexFromPath(
            ref as FindTabIndexFromPathRef,
            path,
          ),
          from: findTabIndexFromPathProvider,
          name: r'findTabIndexFromPathProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$findTabIndexFromPathHash,
          dependencies: FindTabIndexFromPathFamily._dependencies,
          allTransitiveDependencies:
              FindTabIndexFromPathFamily._allTransitiveDependencies,
          path: path,
        );

  FindTabIndexFromPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  Override overrideWith(
    int Function(FindTabIndexFromPathRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FindTabIndexFromPathProvider._internal(
        (ref) => create(ref as FindTabIndexFromPathRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _FindTabIndexFromPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FindTabIndexFromPathProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FindTabIndexFromPathRef on AutoDisposeProviderRef<int> {
  /// The parameter `path` of this provider.
  String get path;
}

class _FindTabIndexFromPathProviderElement
    extends AutoDisposeProviderElement<int> with FindTabIndexFromPathRef {
  _FindTabIndexFromPathProviderElement(super.provider);

  @override
  String get path => (origin as FindTabIndexFromPathProvider).path;
}

String _$selectedTabPathHash() => r'5b318f1dbb4ba23970dd7c8d0dc679fc82b3351e';

/// Provider for the current selected tab path
///
/// Copied from [selectedTabPath].
@ProviderFor(selectedTabPath)
final selectedTabPathProvider = AutoDisposeProvider<String>.internal(
  selectedTabPath,
  name: r'selectedTabPathProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTabPathHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedTabPathRef = AutoDisposeProviderRef<String>;
String _$isAdminPathHash() => r'9db287a7bc1856dd06a8b9bf974d8c734f9f2bda';

/// Check if the current path is an admin path
///
/// Copied from [isAdminPath].
@ProviderFor(isAdminPath)
const isAdminPathProvider = IsAdminPathFamily();

/// Check if the current path is an admin path
///
/// Copied from [isAdminPath].
class IsAdminPathFamily extends Family<bool> {
  /// Check if the current path is an admin path
  ///
  /// Copied from [isAdminPath].
  const IsAdminPathFamily();

  /// Check if the current path is an admin path
  ///
  /// Copied from [isAdminPath].
  IsAdminPathProvider call(
    String path,
  ) {
    return IsAdminPathProvider(
      path,
    );
  }

  @override
  IsAdminPathProvider getProviderOverride(
    covariant IsAdminPathProvider provider,
  ) {
    return call(
      provider.path,
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
  String? get name => r'isAdminPathProvider';
}

/// Check if the current path is an admin path
///
/// Copied from [isAdminPath].
class IsAdminPathProvider extends AutoDisposeProvider<bool> {
  /// Check if the current path is an admin path
  ///
  /// Copied from [isAdminPath].
  IsAdminPathProvider(
    String path,
  ) : this._internal(
          (ref) => isAdminPath(
            ref as IsAdminPathRef,
            path,
          ),
          from: isAdminPathProvider,
          name: r'isAdminPathProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isAdminPathHash,
          dependencies: IsAdminPathFamily._dependencies,
          allTransitiveDependencies:
              IsAdminPathFamily._allTransitiveDependencies,
          path: path,
        );

  IsAdminPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  Override overrideWith(
    bool Function(IsAdminPathRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsAdminPathProvider._internal(
        (ref) => create(ref as IsAdminPathRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsAdminPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsAdminPathProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsAdminPathRef on AutoDisposeProviderRef<bool> {
  /// The parameter `path` of this provider.
  String get path;
}

class _IsAdminPathProviderElement extends AutoDisposeProviderElement<bool>
    with IsAdminPathRef {
  _IsAdminPathProviderElement(super.provider);

  @override
  String get path => (origin as IsAdminPathProvider).path;
}

String _$selectedTabIndexHash() => r'cb32a883205a2c2ef3cb77e5d163e6672ae7580b';

/// Provider for the current selected tab index (for StatefulShellRoute)
///
/// Copied from [SelectedTabIndex].
@ProviderFor(SelectedTabIndex)
final selectedTabIndexProvider =
    AutoDisposeNotifierProvider<SelectedTabIndex, int>.internal(
  SelectedTabIndex.new,
  name: r'selectedTabIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTabIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedTabIndex = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
