// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_catering_system.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeCategoriesHash() => r'6a9366a4d162932f4ebf2988dfd704f723dc73c8';

/// Provider for active categories
///
/// Copied from [activeCategories].
@ProviderFor(activeCategories)
final activeCategoriesProvider =
    AutoDisposeStreamProvider<List<CateringCategory>>.internal(
  activeCategories,
  name: r'activeCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCategoriesRef
    = AutoDisposeStreamProviderRef<List<CateringCategory>>;
String _$searchCategoriesHash() => r'62847004dea85f3a107a94bc48755e00eeffd8b2';

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

/// Provider for searching categories
///
/// Copied from [searchCategories].
@ProviderFor(searchCategories)
const searchCategoriesProvider = SearchCategoriesFamily();

/// Provider for searching categories
///
/// Copied from [searchCategories].
class SearchCategoriesFamily
    extends Family<AsyncValue<List<CateringCategory>>> {
  /// Provider for searching categories
  ///
  /// Copied from [searchCategories].
  const SearchCategoriesFamily();

  /// Provider for searching categories
  ///
  /// Copied from [searchCategories].
  SearchCategoriesProvider call(
    String searchTerm,
  ) {
    return SearchCategoriesProvider(
      searchTerm,
    );
  }

  @override
  SearchCategoriesProvider getProviderOverride(
    covariant SearchCategoriesProvider provider,
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
  String? get name => r'searchCategoriesProvider';
}

/// Provider for searching categories
///
/// Copied from [searchCategories].
class SearchCategoriesProvider
    extends AutoDisposeStreamProvider<List<CateringCategory>> {
  /// Provider for searching categories
  ///
  /// Copied from [searchCategories].
  SearchCategoriesProvider(
    String searchTerm,
  ) : this._internal(
          (ref) => searchCategories(
            ref as SearchCategoriesRef,
            searchTerm,
          ),
          from: searchCategoriesProvider,
          name: r'searchCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchCategoriesHash,
          dependencies: SearchCategoriesFamily._dependencies,
          allTransitiveDependencies:
              SearchCategoriesFamily._allTransitiveDependencies,
          searchTerm: searchTerm,
        );

  SearchCategoriesProvider._internal(
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
    Stream<List<CateringCategory>> Function(SearchCategoriesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchCategoriesProvider._internal(
        (ref) => create(ref as SearchCategoriesRef),
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
  AutoDisposeStreamProviderElement<List<CateringCategory>> createElement() {
    return _SearchCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchCategoriesProvider && other.searchTerm == searchTerm;
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
mixin SearchCategoriesRef
    on AutoDisposeStreamProviderRef<List<CateringCategory>> {
  /// The parameter `searchTerm` of this provider.
  String get searchTerm;
}

class _SearchCategoriesProviderElement
    extends AutoDisposeStreamProviderElement<List<CateringCategory>>
    with SearchCategoriesRef {
  _SearchCategoriesProviderElement(super.provider);

  @override
  String get searchTerm => (origin as SearchCategoriesProvider).searchTerm;
}

String _$activePackagesHash() => r'30b916218b147a547fcc1cf3f395b1c2d2de2260';

/// Provider for active packages
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
String _$promotedPackagesHash() => r'5630152b86faf4e1a489e75f1e8462ef331bdd15';

/// Provider for promoted packages
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
    r'b43ffd00e5e7c6920b8840481b56313331456584';

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

String _$searchPackagesHash() => r'2eadbad18a72cdf988f5de3da30dc1ebef6511d6';

/// Provider for searching packages
///
/// Copied from [searchPackages].
@ProviderFor(searchPackages)
const searchPackagesProvider = SearchPackagesFamily();

/// Provider for searching packages
///
/// Copied from [searchPackages].
class SearchPackagesFamily extends Family<AsyncValue<List<CateringPackage>>> {
  /// Provider for searching packages
  ///
  /// Copied from [searchPackages].
  const SearchPackagesFamily();

  /// Provider for searching packages
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

/// Provider for searching packages
///
/// Copied from [searchPackages].
class SearchPackagesProvider
    extends AutoDisposeStreamProvider<List<CateringPackage>> {
  /// Provider for searching packages
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

String _$itemsByCategoryHash() => r'87d82049649c62486a7000dc6a9063b4c3939c6f';

/// Provider for items by category
///
/// Copied from [itemsByCategory].
@ProviderFor(itemsByCategory)
const itemsByCategoryProvider = ItemsByCategoryFamily();

/// Provider for items by category
///
/// Copied from [itemsByCategory].
class ItemsByCategoryFamily extends Family<AsyncValue<List<CateringItem>>> {
  /// Provider for items by category
  ///
  /// Copied from [itemsByCategory].
  const ItemsByCategoryFamily();

  /// Provider for items by category
  ///
  /// Copied from [itemsByCategory].
  ItemsByCategoryProvider call(
    String categoryId,
  ) {
    return ItemsByCategoryProvider(
      categoryId,
    );
  }

  @override
  ItemsByCategoryProvider getProviderOverride(
    covariant ItemsByCategoryProvider provider,
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
  String? get name => r'itemsByCategoryProvider';
}

/// Provider for items by category
///
/// Copied from [itemsByCategory].
class ItemsByCategoryProvider
    extends AutoDisposeStreamProvider<List<CateringItem>> {
  /// Provider for items by category
  ///
  /// Copied from [itemsByCategory].
  ItemsByCategoryProvider(
    String categoryId,
  ) : this._internal(
          (ref) => itemsByCategory(
            ref as ItemsByCategoryRef,
            categoryId,
          ),
          from: itemsByCategoryProvider,
          name: r'itemsByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemsByCategoryHash,
          dependencies: ItemsByCategoryFamily._dependencies,
          allTransitiveDependencies:
              ItemsByCategoryFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  ItemsByCategoryProvider._internal(
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
    Stream<List<CateringItem>> Function(ItemsByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemsByCategoryProvider._internal(
        (ref) => create(ref as ItemsByCategoryRef),
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
  AutoDisposeStreamProviderElement<List<CateringItem>> createElement() {
    return _ItemsByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsByCategoryProvider && other.categoryId == categoryId;
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
mixin ItemsByCategoryRef on AutoDisposeStreamProviderRef<List<CateringItem>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _ItemsByCategoryProviderElement
    extends AutoDisposeStreamProviderElement<List<CateringItem>>
    with ItemsByCategoryRef {
  _ItemsByCategoryProviderElement(super.provider);

  @override
  String get categoryId => (origin as ItemsByCategoryProvider).categoryId;
}

String _$highlightedItemsHash() => r'c5b1e020e8a7a3948cdd087f594989639edc461f';

/// Provider for highlighted items
///
/// Copied from [highlightedItems].
@ProviderFor(highlightedItems)
final highlightedItemsProvider =
    AutoDisposeStreamProvider<List<CateringItem>>.internal(
  highlightedItems,
  name: r'highlightedItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$highlightedItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HighlightedItemsRef = AutoDisposeStreamProviderRef<List<CateringItem>>;
String _$itemCategoriesHash() => r'8a234eb9dae61246b1f298722ddbbe2f680b346e';

/// Provider for item categories
///
/// Copied from [itemCategories].
@ProviderFor(itemCategories)
const itemCategoriesProvider = ItemCategoriesFamily();

/// Provider for item categories
///
/// Copied from [itemCategories].
class ItemCategoriesFamily extends Family<List<CateringCategory>> {
  /// Provider for item categories
  ///
  /// Copied from [itemCategories].
  const ItemCategoriesFamily();

  /// Provider for item categories
  ///
  /// Copied from [itemCategories].
  ItemCategoriesProvider call(
    CateringItem item,
  ) {
    return ItemCategoriesProvider(
      item,
    );
  }

  @override
  ItemCategoriesProvider getProviderOverride(
    covariant ItemCategoriesProvider provider,
  ) {
    return call(
      provider.item,
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
  String? get name => r'itemCategoriesProvider';
}

/// Provider for item categories
///
/// Copied from [itemCategories].
class ItemCategoriesProvider
    extends AutoDisposeProvider<List<CateringCategory>> {
  /// Provider for item categories
  ///
  /// Copied from [itemCategories].
  ItemCategoriesProvider(
    CateringItem item,
  ) : this._internal(
          (ref) => itemCategories(
            ref as ItemCategoriesRef,
            item,
          ),
          from: itemCategoriesProvider,
          name: r'itemCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemCategoriesHash,
          dependencies: ItemCategoriesFamily._dependencies,
          allTransitiveDependencies:
              ItemCategoriesFamily._allTransitiveDependencies,
          item: item,
        );

  ItemCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.item,
  }) : super.internal();

  final CateringItem item;

  @override
  Override overrideWith(
    List<CateringCategory> Function(ItemCategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemCategoriesProvider._internal(
        (ref) => create(ref as ItemCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        item: item,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<CateringCategory>> createElement() {
    return _ItemCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemCategoriesProvider && other.item == item;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, item.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemCategoriesRef on AutoDisposeProviderRef<List<CateringCategory>> {
  /// The parameter `item` of this provider.
  CateringItem get item;
}

class _ItemCategoriesProviderElement
    extends AutoDisposeProviderElement<List<CateringCategory>>
    with ItemCategoriesRef {
  _ItemCategoriesProviderElement(super.provider);

  @override
  CateringItem get item => (origin as ItemCategoriesProvider).item;
}

String _$packageCategoriesHash() => r'985d3d30d0d42ecf3aea67260cd9dcc1e5f820a0';

/// Provider for package categories
///
/// Copied from [packageCategories].
@ProviderFor(packageCategories)
const packageCategoriesProvider = PackageCategoriesFamily();

/// Provider for package categories
///
/// Copied from [packageCategories].
class PackageCategoriesFamily extends Family<List<CateringCategory>> {
  /// Provider for package categories
  ///
  /// Copied from [packageCategories].
  const PackageCategoriesFamily();

  /// Provider for package categories
  ///
  /// Copied from [packageCategories].
  PackageCategoriesProvider call(
    CateringPackage package,
  ) {
    return PackageCategoriesProvider(
      package,
    );
  }

  @override
  PackageCategoriesProvider getProviderOverride(
    covariant PackageCategoriesProvider provider,
  ) {
    return call(
      provider.package,
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
  String? get name => r'packageCategoriesProvider';
}

/// Provider for package categories
///
/// Copied from [packageCategories].
class PackageCategoriesProvider
    extends AutoDisposeProvider<List<CateringCategory>> {
  /// Provider for package categories
  ///
  /// Copied from [packageCategories].
  PackageCategoriesProvider(
    CateringPackage package,
  ) : this._internal(
          (ref) => packageCategories(
            ref as PackageCategoriesRef,
            package,
          ),
          from: packageCategoriesProvider,
          name: r'packageCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$packageCategoriesHash,
          dependencies: PackageCategoriesFamily._dependencies,
          allTransitiveDependencies:
              PackageCategoriesFamily._allTransitiveDependencies,
          package: package,
        );

  PackageCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.package,
  }) : super.internal();

  final CateringPackage package;

  @override
  Override overrideWith(
    List<CateringCategory> Function(PackageCategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PackageCategoriesProvider._internal(
        (ref) => create(ref as PackageCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        package: package,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<CateringCategory>> createElement() {
    return _PackageCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PackageCategoriesProvider && other.package == package;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, package.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PackageCategoriesRef on AutoDisposeProviderRef<List<CateringCategory>> {
  /// The parameter `package` of this provider.
  CateringPackage get package;
}

class _PackageCategoriesProviderElement
    extends AutoDisposeProviderElement<List<CateringCategory>>
    with PackageCategoriesRef {
  _PackageCategoriesProviderElement(super.provider);

  @override
  CateringPackage get package => (origin as PackageCategoriesProvider).package;
}

String _$cateringCategoryRepositoryHash() =>
    r'852a5a8a63de9c335438dc44f3f00dc9560d6f41';

/// Unified Catering Category Repository
///
/// Copied from [CateringCategoryRepository].
@ProviderFor(CateringCategoryRepository)
final cateringCategoryRepositoryProvider = AutoDisposeStreamNotifierProvider<
    CateringCategoryRepository, List<CateringCategory>>.internal(
  CateringCategoryRepository.new,
  name: r'cateringCategoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cateringCategoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CateringCategoryRepository
    = AutoDisposeStreamNotifier<List<CateringCategory>>;
String _$cateringItemRepositoryHash() =>
    r'3a7e40e8ee51bf6c7e0f31373eee4e4f021541f1';

/// Unified Catering Item Repository
///
/// Copied from [CateringItemRepository].
@ProviderFor(CateringItemRepository)
final cateringItemRepositoryProvider = AutoDisposeStreamNotifierProvider<
    CateringItemRepository, List<CateringItem>>.internal(
  CateringItemRepository.new,
  name: r'cateringItemRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cateringItemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CateringItemRepository
    = AutoDisposeStreamNotifier<List<CateringItem>>;
String _$cateringPackageRepositoryHash() =>
    r'ba507d00aff7477f188b33a484bd0037c65f5fae';

/// Unified Catering Package Repository
///
/// Copied from [CateringPackageRepository].
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
String _$cateringOrderRepositoryHash() =>
    r'f08e2364fb80f5f85ce6bb0f1b363be0177d0895';

/// Unified Catering Order Repository
///
/// Copied from [CateringOrderRepository].
@ProviderFor(CateringOrderRepository)
final cateringOrderRepositoryProvider = AutoDisposeAsyncNotifierProvider<
    CateringOrderRepository, CateringOrderItem?>.internal(
  CateringOrderRepository.new,
  name: r'cateringOrderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cateringOrderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CateringOrderRepository
    = AutoDisposeAsyncNotifier<CateringOrderItem?>;
String _$selectedCategoryHash() => r'9d2b91a376e7c7724d2932769dd8f24a5314b9de';

/// Provider for the selected category
///
/// Copied from [SelectedCategory].
@ProviderFor(SelectedCategory)
final selectedCategoryProvider =
    AutoDisposeNotifierProvider<SelectedCategory, CateringCategory?>.internal(
  SelectedCategory.new,
  name: r'selectedCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCategory = AutoDisposeNotifier<CateringCategory?>;
String _$selectedPackageHash() => r'672aca157d95a5389eaf4cad96402b725a88df09';

/// Provider for the selected package
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
String _$selectedItemHash() => r'4cdedc4a3e641af3079101243c94ea927c8b747c';

/// Provider for the selected item
///
/// Copied from [SelectedItem].
@ProviderFor(SelectedItem)
final selectedItemProvider =
    AutoDisposeNotifierProvider<SelectedItem, CateringItem?>.internal(
  SelectedItem.new,
  name: r'selectedItemProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedItemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedItem = AutoDisposeNotifier<CateringItem?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
