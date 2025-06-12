// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catering_packages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activePackagesHash() => r'334a5e15972efc55c370123e654a36be9ec882ba';

/// Provider for active packages only
///
/// Copied from [activePackages].
@ProviderFor(activePackages)
final activePackagesProvider =
    AutoDisposeStreamProvider<List<CateringPackage>>.internal(
  activePackages,
  name: r'activePackagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activePackagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivePackagesRef = AutoDisposeStreamProviderRef<List<CateringPackage>>;
String _$promotedPackagesHash() => r'c35c5e13441ca4f92e4e6ee301aa12ff53632635';

/// Provider for promoted packages only
///
/// Copied from [promotedPackages].
@ProviderFor(promotedPackages)
final promotedPackagesProvider =
    AutoDisposeStreamProvider<List<CateringPackage>>.internal(
  promotedPackages,
  name: r'promotedPackagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$promotedPackagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PromotedPackagesRef
    = AutoDisposeStreamProviderRef<List<CateringPackage>>;
String _$packagesByCategoryHash() =>
    r'64011302a6f5918dd03b9651fd3c882f387faa0e';

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

/// Provider for packages by category
///
/// Copied from [packagesByCategory].
@ProviderFor(packagesByCategory)
const packagesByCategoryProvider = PackagesByCategoryFamily();

/// Provider for packages by category
///
/// Copied from [packagesByCategory].
class PackagesByCategoryFamily
    extends Family<AsyncValue<List<CateringPackage>>> {
  /// Provider for packages by category
  ///
  /// Copied from [packagesByCategory].
  const PackagesByCategoryFamily();

  /// Provider for packages by category
  ///
  /// Copied from [packagesByCategory].
  PackagesByCategoryProvider call(
    String categoryId,
  ) {
    return PackagesByCategoryProvider(
      categoryId,
    );
  }

  @override
  PackagesByCategoryProvider getProviderOverride(
    covariant PackagesByCategoryProvider provider,
  ) {
    return call(
      provider.categoryId,
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
  String? get name => r'packagesByCategoryProvider';
}

/// Provider for packages by category
///
/// Copied from [packagesByCategory].
class PackagesByCategoryProvider
    extends AutoDisposeStreamProvider<List<CateringPackage>> {
  /// Provider for packages by category
  ///
  /// Copied from [packagesByCategory].
  PackagesByCategoryProvider(
    String categoryId,
  ) : this._internal(
          (ref) => packagesByCategory(
            ref as PackagesByCategoryRef,
            categoryId,
          ),
          from: packagesByCategoryProvider,
          name: r'packagesByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$packagesByCategoryHash,
          dependencies: PackagesByCategoryFamily._dependencies,
          allTransitiveDependencies:
              PackagesByCategoryFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  PackagesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    Stream<List<CateringPackage>> Function(PackagesByCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PackagesByCategoryProvider._internal(
        (ref) => create(ref as PackagesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CateringPackage>> createElement() {
    return _PackagesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PackagesByCategoryProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PackagesByCategoryRef
    on AutoDisposeStreamProviderRef<List<CateringPackage>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _PackagesByCategoryProviderElement
    extends AutoDisposeStreamProviderElement<List<CateringPackage>>
    with PackagesByCategoryRef {
  _PackagesByCategoryProviderElement(super.provider);

  @override
  String get categoryId => (origin as PackagesByCategoryProvider).categoryId;
}

String _$searchPackagesHash() => r'b6797557b23672bc5e75da05f68df1ce22b91049';

/// Provider for searching packages by name or description
///
/// Copied from [searchPackages].
@ProviderFor(searchPackages)
const searchPackagesProvider = SearchPackagesFamily();

/// Provider for searching packages by name or description
///
/// Copied from [searchPackages].
class SearchPackagesFamily extends Family<AsyncValue<List<CateringPackage>>> {
  /// Provider for searching packages by name or description
  ///
  /// Copied from [searchPackages].
  const SearchPackagesFamily();

  /// Provider for searching packages by name or description
  ///
  /// Copied from [searchPackages].
  SearchPackagesProvider call(
    String searchTerm,
  ) {
    return SearchPackagesProvider(
      searchTerm,
    );
  }

  @override
  SearchPackagesProvider getProviderOverride(
    covariant SearchPackagesProvider provider,
  ) {
    return call(
      provider.searchTerm,
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
  String? get name => r'searchPackagesProvider';
}

/// Provider for searching packages by name or description
///
/// Copied from [searchPackages].
class SearchPackagesProvider
    extends AutoDisposeStreamProvider<List<CateringPackage>> {
  /// Provider for searching packages by name or description
  ///
  /// Copied from [searchPackages].
  SearchPackagesProvider(
    String searchTerm,
  ) : this._internal(
          (ref) => searchPackages(
            ref as SearchPackagesRef,
            searchTerm,
          ),
          from: searchPackagesProvider,
          name: r'searchPackagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchPackagesHash,
          dependencies: SearchPackagesFamily._dependencies,
          allTransitiveDependencies:
              SearchPackagesFamily._allTransitiveDependencies,
          searchTerm: searchTerm,
        );

  SearchPackagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchTerm,
  }) : super.internal();

  final String searchTerm;

  @override
  Override overrideWith(
    Stream<List<CateringPackage>> Function(SearchPackagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchPackagesProvider._internal(
        (ref) => create(ref as SearchPackagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchTerm: searchTerm,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CateringPackage>> createElement() {
    return _SearchPackagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchPackagesProvider && other.searchTerm == searchTerm;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchTerm.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchPackagesRef on AutoDisposeStreamProviderRef<List<CateringPackage>> {
  /// The parameter `searchTerm` of this provider.
  String get searchTerm;
}

class _SearchPackagesProviderElement
    extends AutoDisposeStreamProviderElement<List<CateringPackage>>
    with SearchPackagesRef {
  _SearchPackagesProviderElement(super.provider);

  @override
  String get searchTerm => (origin as SearchPackagesProvider).searchTerm;
}

String _$cateringPackageRepositoryHash() =>
    r'ca9ca37dd18de2f0906b86312a5e9295c2797408';

/// See also [CateringPackageRepository].
@ProviderFor(CateringPackageRepository)
final cateringPackageRepositoryProvider = AutoDisposeStreamNotifierProvider<
    CateringPackageRepository, List<CateringPackage>>.internal(
  CateringPackageRepository.new,
  name: r'cateringPackageRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cateringPackageRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CateringPackageRepository
    = AutoDisposeStreamNotifier<List<CateringPackage>>;
String _$selectedPackageHash() => r'672aca157d95a5389eaf4cad96402b725a88df09';

/// Provider for the currently selected package
///
/// Copied from [SelectedPackage].
@ProviderFor(SelectedPackage)
final selectedPackageProvider =
    AutoDisposeNotifierProvider<SelectedPackage, CateringPackage?>.internal(
  SelectedPackage.new,
  name: r'selectedPackageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedPackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedPackage = AutoDisposeNotifier<CateringPackage?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
