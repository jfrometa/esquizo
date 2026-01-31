// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogServiceHash() => r'0ecd41892913a14f2201dfc2906cd2a14a685efa';

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

/// See also [catalogService].
@ProviderFor(catalogService)
const catalogServiceProvider = CatalogServiceFamily();

/// See also [catalogService].
class CatalogServiceFamily extends Family<CatalogService> {
  /// See also [catalogService].
  const CatalogServiceFamily();

  /// See also [catalogService].
  CatalogServiceProvider call(
    String catalogType,
  ) {
    return CatalogServiceProvider(
      catalogType,
    );
  }

  @override
  CatalogServiceProvider getProviderOverride(
    covariant CatalogServiceProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'catalogServiceProvider';
}

/// See also [catalogService].
class CatalogServiceProvider extends AutoDisposeProvider<CatalogService> {
  /// See also [catalogService].
  CatalogServiceProvider(
    String catalogType,
  ) : this._internal(
          (ref) => catalogService(
            ref as CatalogServiceRef,
            catalogType,
          ),
          from: catalogServiceProvider,
          name: r'catalogServiceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$catalogServiceHash,
          dependencies: CatalogServiceFamily._dependencies,
          allTransitiveDependencies:
              CatalogServiceFamily._allTransitiveDependencies,
          catalogType: catalogType,
        );

  CatalogServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
  }) : super.internal();

  final String catalogType;

  @override
  Override overrideWith(
    CatalogService Function(CatalogServiceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CatalogServiceProvider._internal(
        (ref) => create(ref as CatalogServiceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<CatalogService> createElement() {
    return _CatalogServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogServiceProvider && other.catalogType == catalogType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CatalogServiceRef on AutoDisposeProviderRef<CatalogService> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;
}

class _CatalogServiceProviderElement
    extends AutoDisposeProviderElement<CatalogService> with CatalogServiceRef {
  _CatalogServiceProviderElement(super.provider);

  @override
  String get catalogType => (origin as CatalogServiceProvider).catalogType;
}

String _$catalogCategoriesHash() => r'43a35c632df0e7f3d94bf5e8aa30593923ff6d2f';

/// Provider for categories in a specific catalog type
///
/// Copied from [catalogCategories].
@ProviderFor(catalogCategories)
const catalogCategoriesProvider = CatalogCategoriesFamily();

/// Provider for categories in a specific catalog type
///
/// Copied from [catalogCategories].
class CatalogCategoriesFamily
    extends Family<AsyncValue<List<CatalogCategory>>> {
  /// Provider for categories in a specific catalog type
  ///
  /// Copied from [catalogCategories].
  const CatalogCategoriesFamily();

  /// Provider for categories in a specific catalog type
  ///
  /// Copied from [catalogCategories].
  CatalogCategoriesProvider call(
    String catalogType,
  ) {
    return CatalogCategoriesProvider(
      catalogType,
    );
  }

  @override
  CatalogCategoriesProvider getProviderOverride(
    covariant CatalogCategoriesProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'catalogCategoriesProvider';
}

/// Provider for categories in a specific catalog type
///
/// Copied from [catalogCategories].
class CatalogCategoriesProvider
    extends AutoDisposeStreamProvider<List<CatalogCategory>> {
  /// Provider for categories in a specific catalog type
  ///
  /// Copied from [catalogCategories].
  CatalogCategoriesProvider(
    String catalogType,
  ) : this._internal(
          (ref) => catalogCategories(
            ref as CatalogCategoriesRef,
            catalogType,
          ),
          from: catalogCategoriesProvider,
          name: r'catalogCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$catalogCategoriesHash,
          dependencies: CatalogCategoriesFamily._dependencies,
          allTransitiveDependencies:
              CatalogCategoriesFamily._allTransitiveDependencies,
          catalogType: catalogType,
        );

  CatalogCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
  }) : super.internal();

  final String catalogType;

  @override
  Override overrideWith(
    Stream<List<CatalogCategory>> Function(CatalogCategoriesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CatalogCategoriesProvider._internal(
        (ref) => create(ref as CatalogCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CatalogCategory>> createElement() {
    return _CatalogCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogCategoriesProvider &&
        other.catalogType == catalogType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CatalogCategoriesRef
    on AutoDisposeStreamProviderRef<List<CatalogCategory>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;
}

class _CatalogCategoriesProviderElement
    extends AutoDisposeStreamProviderElement<List<CatalogCategory>>
    with CatalogCategoriesRef {
  _CatalogCategoriesProviderElement(super.provider);

  @override
  String get catalogType => (origin as CatalogCategoriesProvider).catalogType;
}

String _$activeCatalogCategoriesHash() =>
    r'98d35b9959fa5ab2be5d8b1cea720de85f3b5e96';

/// Provider for active categories only
///
/// Copied from [activeCatalogCategories].
@ProviderFor(activeCatalogCategories)
const activeCatalogCategoriesProvider = ActiveCatalogCategoriesFamily();

/// Provider for active categories only
///
/// Copied from [activeCatalogCategories].
class ActiveCatalogCategoriesFamily
    extends Family<AsyncValue<List<CatalogCategory>>> {
  /// Provider for active categories only
  ///
  /// Copied from [activeCatalogCategories].
  const ActiveCatalogCategoriesFamily();

  /// Provider for active categories only
  ///
  /// Copied from [activeCatalogCategories].
  ActiveCatalogCategoriesProvider call(
    String catalogType,
  ) {
    return ActiveCatalogCategoriesProvider(
      catalogType,
    );
  }

  @override
  ActiveCatalogCategoriesProvider getProviderOverride(
    covariant ActiveCatalogCategoriesProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'activeCatalogCategoriesProvider';
}

/// Provider for active categories only
///
/// Copied from [activeCatalogCategories].
class ActiveCatalogCategoriesProvider
    extends AutoDisposeStreamProvider<List<CatalogCategory>> {
  /// Provider for active categories only
  ///
  /// Copied from [activeCatalogCategories].
  ActiveCatalogCategoriesProvider(
    String catalogType,
  ) : this._internal(
          (ref) => activeCatalogCategories(
            ref as ActiveCatalogCategoriesRef,
            catalogType,
          ),
          from: activeCatalogCategoriesProvider,
          name: r'activeCatalogCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activeCatalogCategoriesHash,
          dependencies: ActiveCatalogCategoriesFamily._dependencies,
          allTransitiveDependencies:
              ActiveCatalogCategoriesFamily._allTransitiveDependencies,
          catalogType: catalogType,
        );

  ActiveCatalogCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
  }) : super.internal();

  final String catalogType;

  @override
  Override overrideWith(
    Stream<List<CatalogCategory>> Function(ActiveCatalogCategoriesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveCatalogCategoriesProvider._internal(
        (ref) => create(ref as ActiveCatalogCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CatalogCategory>> createElement() {
    return _ActiveCatalogCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveCatalogCategoriesProvider &&
        other.catalogType == catalogType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActiveCatalogCategoriesRef
    on AutoDisposeStreamProviderRef<List<CatalogCategory>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;
}

class _ActiveCatalogCategoriesProviderElement
    extends AutoDisposeStreamProviderElement<List<CatalogCategory>>
    with ActiveCatalogCategoriesRef {
  _ActiveCatalogCategoriesProviderElement(super.provider);

  @override
  String get catalogType =>
      (origin as ActiveCatalogCategoriesProvider).catalogType;
}

String _$catalogCategoryHash() => r'0e51002f9b80b536599ebe404c9eee2353c5da01';

/// Provider for a single category
///
/// Copied from [catalogCategory].
@ProviderFor(catalogCategory)
const catalogCategoryProvider = CatalogCategoryFamily();

/// Provider for a single category
///
/// Copied from [catalogCategory].
class CatalogCategoryFamily extends Family<AsyncValue<CatalogCategory?>> {
  /// Provider for a single category
  ///
  /// Copied from [catalogCategory].
  const CatalogCategoryFamily();

  /// Provider for a single category
  ///
  /// Copied from [catalogCategory].
  CatalogCategoryProvider call(
    String catalogType,
    String categoryId,
  ) {
    return CatalogCategoryProvider(
      catalogType,
      categoryId,
    );
  }

  @override
  CatalogCategoryProvider getProviderOverride(
    covariant CatalogCategoryProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'catalogCategoryProvider';
}

/// Provider for a single category
///
/// Copied from [catalogCategory].
class CatalogCategoryProvider
    extends AutoDisposeFutureProvider<CatalogCategory?> {
  /// Provider for a single category
  ///
  /// Copied from [catalogCategory].
  CatalogCategoryProvider(
    String catalogType,
    String categoryId,
  ) : this._internal(
          (ref) => catalogCategory(
            ref as CatalogCategoryRef,
            catalogType,
            categoryId,
          ),
          from: catalogCategoryProvider,
          name: r'catalogCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$catalogCategoryHash,
          dependencies: CatalogCategoryFamily._dependencies,
          allTransitiveDependencies:
              CatalogCategoryFamily._allTransitiveDependencies,
          catalogType: catalogType,
          categoryId: categoryId,
        );

  CatalogCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
    required this.categoryId,
  }) : super.internal();

  final String catalogType;
  final String categoryId;

  @override
  Override overrideWith(
    FutureOr<CatalogCategory?> Function(CatalogCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CatalogCategoryProvider._internal(
        (ref) => create(ref as CatalogCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CatalogCategory?> createElement() {
    return _CatalogCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogCategoryProvider &&
        other.catalogType == catalogType &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CatalogCategoryRef on AutoDisposeFutureProviderRef<CatalogCategory?> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;

  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CatalogCategoryProviderElement
    extends AutoDisposeFutureProviderElement<CatalogCategory?>
    with CatalogCategoryRef {
  _CatalogCategoryProviderElement(super.provider);

  @override
  String get catalogType => (origin as CatalogCategoryProvider).catalogType;
  @override
  String get categoryId => (origin as CatalogCategoryProvider).categoryId;
}

String _$catalogItemsHash() => r'e981e87d86085057094e0b294b08a3a221e4d55f';

/// Provider for all items in a catalog type
///
/// Copied from [catalogItems].
@ProviderFor(catalogItems)
const catalogItemsProvider = CatalogItemsFamily();

/// Provider for all items in a catalog type
///
/// Copied from [catalogItems].
class CatalogItemsFamily extends Family<AsyncValue<List<CatalogItem>>> {
  /// Provider for all items in a catalog type
  ///
  /// Copied from [catalogItems].
  const CatalogItemsFamily();

  /// Provider for all items in a catalog type
  ///
  /// Copied from [catalogItems].
  CatalogItemsProvider call(
    String catalogType,
  ) {
    return CatalogItemsProvider(
      catalogType,
    );
  }

  @override
  CatalogItemsProvider getProviderOverride(
    covariant CatalogItemsProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'catalogItemsProvider';
}

/// Provider for all items in a catalog type
///
/// Copied from [catalogItems].
class CatalogItemsProvider
    extends AutoDisposeStreamProvider<List<CatalogItem>> {
  /// Provider for all items in a catalog type
  ///
  /// Copied from [catalogItems].
  CatalogItemsProvider(
    String catalogType,
  ) : this._internal(
          (ref) => catalogItems(
            ref as CatalogItemsRef,
            catalogType,
          ),
          from: catalogItemsProvider,
          name: r'catalogItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$catalogItemsHash,
          dependencies: CatalogItemsFamily._dependencies,
          allTransitiveDependencies:
              CatalogItemsFamily._allTransitiveDependencies,
          catalogType: catalogType,
        );

  CatalogItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
  }) : super.internal();

  final String catalogType;

  @override
  Override overrideWith(
    Stream<List<CatalogItem>> Function(CatalogItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CatalogItemsProvider._internal(
        (ref) => create(ref as CatalogItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CatalogItem>> createElement() {
    return _CatalogItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogItemsProvider && other.catalogType == catalogType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CatalogItemsRef on AutoDisposeStreamProviderRef<List<CatalogItem>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;
}

class _CatalogItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<CatalogItem>>
    with CatalogItemsRef {
  _CatalogItemsProviderElement(super.provider);

  @override
  String get catalogType => (origin as CatalogItemsProvider).catalogType;
}

String _$catalogItemsByCategoryHash() =>
    r'810dad408afc099d8362b3cea1351a2ab6a69ac1';

/// Provider for items by category
///
/// Copied from [catalogItemsByCategory].
@ProviderFor(catalogItemsByCategory)
const catalogItemsByCategoryProvider = CatalogItemsByCategoryFamily();

/// Provider for items by category
///
/// Copied from [catalogItemsByCategory].
class CatalogItemsByCategoryFamily
    extends Family<AsyncValue<List<CatalogItem>>> {
  /// Provider for items by category
  ///
  /// Copied from [catalogItemsByCategory].
  const CatalogItemsByCategoryFamily();

  /// Provider for items by category
  ///
  /// Copied from [catalogItemsByCategory].
  CatalogItemsByCategoryProvider call(
    String catalogType,
    String categoryId,
  ) {
    return CatalogItemsByCategoryProvider(
      catalogType,
      categoryId,
    );
  }

  @override
  CatalogItemsByCategoryProvider getProviderOverride(
    covariant CatalogItemsByCategoryProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'catalogItemsByCategoryProvider';
}

/// Provider for items by category
///
/// Copied from [catalogItemsByCategory].
class CatalogItemsByCategoryProvider
    extends AutoDisposeStreamProvider<List<CatalogItem>> {
  /// Provider for items by category
  ///
  /// Copied from [catalogItemsByCategory].
  CatalogItemsByCategoryProvider(
    String catalogType,
    String categoryId,
  ) : this._internal(
          (ref) => catalogItemsByCategory(
            ref as CatalogItemsByCategoryRef,
            catalogType,
            categoryId,
          ),
          from: catalogItemsByCategoryProvider,
          name: r'catalogItemsByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$catalogItemsByCategoryHash,
          dependencies: CatalogItemsByCategoryFamily._dependencies,
          allTransitiveDependencies:
              CatalogItemsByCategoryFamily._allTransitiveDependencies,
          catalogType: catalogType,
          categoryId: categoryId,
        );

  CatalogItemsByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
    required this.categoryId,
  }) : super.internal();

  final String catalogType;
  final String categoryId;

  @override
  Override overrideWith(
    Stream<List<CatalogItem>> Function(CatalogItemsByCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CatalogItemsByCategoryProvider._internal(
        (ref) => create(ref as CatalogItemsByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CatalogItem>> createElement() {
    return _CatalogItemsByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogItemsByCategoryProvider &&
        other.catalogType == catalogType &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CatalogItemsByCategoryRef
    on AutoDisposeStreamProviderRef<List<CatalogItem>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;

  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CatalogItemsByCategoryProviderElement
    extends AutoDisposeStreamProviderElement<List<CatalogItem>>
    with CatalogItemsByCategoryRef {
  _CatalogItemsByCategoryProviderElement(super.provider);

  @override
  String get catalogType =>
      (origin as CatalogItemsByCategoryProvider).catalogType;
  @override
  String get categoryId =>
      (origin as CatalogItemsByCategoryProvider).categoryId;
}

String _$catalogItemHash() => r'5f143a673ccb891cb157b27b80ffbeb23f32cbd6';

/// Provider for a single item
///
/// Copied from [catalogItem].
@ProviderFor(catalogItem)
const catalogItemProvider = CatalogItemFamily();

/// Provider for a single item
///
/// Copied from [catalogItem].
class CatalogItemFamily extends Family<AsyncValue<CatalogItem?>> {
  /// Provider for a single item
  ///
  /// Copied from [catalogItem].
  const CatalogItemFamily();

  /// Provider for a single item
  ///
  /// Copied from [catalogItem].
  CatalogItemProvider call(
    String catalogType,
    String itemId,
  ) {
    return CatalogItemProvider(
      catalogType,
      itemId,
    );
  }

  @override
  CatalogItemProvider getProviderOverride(
    covariant CatalogItemProvider provider,
  ) {
    return call(
      provider.catalogType,
      provider.itemId,
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
  String? get name => r'catalogItemProvider';
}

/// Provider for a single item
///
/// Copied from [catalogItem].
class CatalogItemProvider extends AutoDisposeFutureProvider<CatalogItem?> {
  /// Provider for a single item
  ///
  /// Copied from [catalogItem].
  CatalogItemProvider(
    String catalogType,
    String itemId,
  ) : this._internal(
          (ref) => catalogItem(
            ref as CatalogItemRef,
            catalogType,
            itemId,
          ),
          from: catalogItemProvider,
          name: r'catalogItemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$catalogItemHash,
          dependencies: CatalogItemFamily._dependencies,
          allTransitiveDependencies:
              CatalogItemFamily._allTransitiveDependencies,
          catalogType: catalogType,
          itemId: itemId,
        );

  CatalogItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
    required this.itemId,
  }) : super.internal();

  final String catalogType;
  final String itemId;

  @override
  Override overrideWith(
    FutureOr<CatalogItem?> Function(CatalogItemRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CatalogItemProvider._internal(
        (ref) => create(ref as CatalogItemRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CatalogItem?> createElement() {
    return _CatalogItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogItemProvider &&
        other.catalogType == catalogType &&
        other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CatalogItemRef on AutoDisposeFutureProviderRef<CatalogItem?> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;

  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _CatalogItemProviderElement
    extends AutoDisposeFutureProviderElement<CatalogItem?> with CatalogItemRef {
  _CatalogItemProviderElement(super.provider);

  @override
  String get catalogType => (origin as CatalogItemProvider).catalogType;
  @override
  String get itemId => (origin as CatalogItemProvider).itemId;
}

String _$featuredItemsHash() => r'714d8dd37cb954544ecab8c95285ed2001497163';

/// Provider for featured items
///
/// Copied from [featuredItems].
@ProviderFor(featuredItems)
const featuredItemsProvider = FeaturedItemsFamily();

/// Provider for featured items
///
/// Copied from [featuredItems].
class FeaturedItemsFamily extends Family<AsyncValue<List<CatalogItem>>> {
  /// Provider for featured items
  ///
  /// Copied from [featuredItems].
  const FeaturedItemsFamily();

  /// Provider for featured items
  ///
  /// Copied from [featuredItems].
  FeaturedItemsProvider call(
    String catalogType,
  ) {
    return FeaturedItemsProvider(
      catalogType,
    );
  }

  @override
  FeaturedItemsProvider getProviderOverride(
    covariant FeaturedItemsProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'featuredItemsProvider';
}

/// Provider for featured items
///
/// Copied from [featuredItems].
class FeaturedItemsProvider
    extends AutoDisposeFutureProvider<List<CatalogItem>> {
  /// Provider for featured items
  ///
  /// Copied from [featuredItems].
  FeaturedItemsProvider(
    String catalogType,
  ) : this._internal(
          (ref) => featuredItems(
            ref as FeaturedItemsRef,
            catalogType,
          ),
          from: featuredItemsProvider,
          name: r'featuredItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$featuredItemsHash,
          dependencies: FeaturedItemsFamily._dependencies,
          allTransitiveDependencies:
              FeaturedItemsFamily._allTransitiveDependencies,
          catalogType: catalogType,
        );

  FeaturedItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
  }) : super.internal();

  final String catalogType;

  @override
  Override overrideWith(
    FutureOr<List<CatalogItem>> Function(FeaturedItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeaturedItemsProvider._internal(
        (ref) => create(ref as FeaturedItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CatalogItem>> createElement() {
    return _FeaturedItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeaturedItemsProvider && other.catalogType == catalogType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeaturedItemsRef on AutoDisposeFutureProviderRef<List<CatalogItem>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;
}

class _FeaturedItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<CatalogItem>>
    with FeaturedItemsRef {
  _FeaturedItemsProviderElement(super.provider);

  @override
  String get catalogType => (origin as FeaturedItemsProvider).catalogType;
}

String _$searchItemsHash() => r'6aeda0fded421b0c66c70fa13091a08ff0b545d3';

/// Provider for searching items
///
/// Copied from [searchItems].
@ProviderFor(searchItems)
const searchItemsProvider = SearchItemsFamily();

/// Provider for searching items
///
/// Copied from [searchItems].
class SearchItemsFamily extends Family<AsyncValue<List<CatalogItem>>> {
  /// Provider for searching items
  ///
  /// Copied from [searchItems].
  const SearchItemsFamily();

  /// Provider for searching items
  ///
  /// Copied from [searchItems].
  SearchItemsProvider call(
    String catalogType,
    String query,
  ) {
    return SearchItemsProvider(
      catalogType,
      query,
    );
  }

  @override
  SearchItemsProvider getProviderOverride(
    covariant SearchItemsProvider provider,
  ) {
    return call(
      provider.catalogType,
      provider.query,
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
  String? get name => r'searchItemsProvider';
}

/// Provider for searching items
///
/// Copied from [searchItems].
class SearchItemsProvider extends AutoDisposeFutureProvider<List<CatalogItem>> {
  /// Provider for searching items
  ///
  /// Copied from [searchItems].
  SearchItemsProvider(
    String catalogType,
    String query,
  ) : this._internal(
          (ref) => searchItems(
            ref as SearchItemsRef,
            catalogType,
            query,
          ),
          from: searchItemsProvider,
          name: r'searchItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchItemsHash,
          dependencies: SearchItemsFamily._dependencies,
          allTransitiveDependencies:
              SearchItemsFamily._allTransitiveDependencies,
          catalogType: catalogType,
          query: query,
        );

  SearchItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
    required this.query,
  }) : super.internal();

  final String catalogType;
  final String query;

  @override
  Override overrideWith(
    FutureOr<List<CatalogItem>> Function(SearchItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchItemsProvider._internal(
        (ref) => create(ref as SearchItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CatalogItem>> createElement() {
    return _SearchItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchItemsProvider &&
        other.catalogType == catalogType &&
        other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchItemsRef on AutoDisposeFutureProviderRef<List<CatalogItem>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;

  /// The parameter `query` of this provider.
  String get query;
}

class _SearchItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<CatalogItem>>
    with SearchItemsRef {
  _SearchItemsProviderElement(super.provider);

  @override
  String get catalogType => (origin as SearchItemsProvider).catalogType;
  @override
  String get query => (origin as SearchItemsProvider).query;
}

String _$lowInventoryItemsHash() => r'5f8595362ff45480d35201c7557b44f781675a02';

/// Provider for items with low inventory
///
/// Copied from [lowInventoryItems].
@ProviderFor(lowInventoryItems)
const lowInventoryItemsProvider = LowInventoryItemsFamily();

/// Provider for items with low inventory
///
/// Copied from [lowInventoryItems].
class LowInventoryItemsFamily extends Family<AsyncValue<List<CatalogItem>>> {
  /// Provider for items with low inventory
  ///
  /// Copied from [lowInventoryItems].
  const LowInventoryItemsFamily();

  /// Provider for items with low inventory
  ///
  /// Copied from [lowInventoryItems].
  LowInventoryItemsProvider call(
    String catalogType,
    int threshold,
  ) {
    return LowInventoryItemsProvider(
      catalogType,
      threshold,
    );
  }

  @override
  LowInventoryItemsProvider getProviderOverride(
    covariant LowInventoryItemsProvider provider,
  ) {
    return call(
      provider.catalogType,
      provider.threshold,
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
  String? get name => r'lowInventoryItemsProvider';
}

/// Provider for items with low inventory
///
/// Copied from [lowInventoryItems].
class LowInventoryItemsProvider
    extends AutoDisposeFutureProvider<List<CatalogItem>> {
  /// Provider for items with low inventory
  ///
  /// Copied from [lowInventoryItems].
  LowInventoryItemsProvider(
    String catalogType,
    int threshold,
  ) : this._internal(
          (ref) => lowInventoryItems(
            ref as LowInventoryItemsRef,
            catalogType,
            threshold,
          ),
          from: lowInventoryItemsProvider,
          name: r'lowInventoryItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lowInventoryItemsHash,
          dependencies: LowInventoryItemsFamily._dependencies,
          allTransitiveDependencies:
              LowInventoryItemsFamily._allTransitiveDependencies,
          catalogType: catalogType,
          threshold: threshold,
        );

  LowInventoryItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
    required this.threshold,
  }) : super.internal();

  final String catalogType;
  final int threshold;

  @override
  Override overrideWith(
    FutureOr<List<CatalogItem>> Function(LowInventoryItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LowInventoryItemsProvider._internal(
        (ref) => create(ref as LowInventoryItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
        threshold: threshold,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CatalogItem>> createElement() {
    return _LowInventoryItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LowInventoryItemsProvider &&
        other.catalogType == catalogType &&
        other.threshold == threshold;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);
    hash = _SystemHash.combine(hash, threshold.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LowInventoryItemsRef on AutoDisposeFutureProviderRef<List<CatalogItem>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;

  /// The parameter `threshold` of this provider.
  int get threshold;
}

class _LowInventoryItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<CatalogItem>>
    with LowInventoryItemsRef {
  _LowInventoryItemsProviderElement(super.provider);

  @override
  String get catalogType => (origin as LowInventoryItemsProvider).catalogType;
  @override
  int get threshold => (origin as LowInventoryItemsProvider).threshold;
}

String _$popularItemsHash() => r'6b3de4a8795fcbf2d62456b4d73bfb02d630b601';

/// Provider for most popular items
///
/// Copied from [popularItems].
@ProviderFor(popularItems)
const popularItemsProvider = PopularItemsFamily();

/// Provider for most popular items
///
/// Copied from [popularItems].
class PopularItemsFamily extends Family<AsyncValue<List<CatalogItem>>> {
  /// Provider for most popular items
  ///
  /// Copied from [popularItems].
  const PopularItemsFamily();

  /// Provider for most popular items
  ///
  /// Copied from [popularItems].
  PopularItemsProvider call(
    String catalogType,
  ) {
    return PopularItemsProvider(
      catalogType,
    );
  }

  @override
  PopularItemsProvider getProviderOverride(
    covariant PopularItemsProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'popularItemsProvider';
}

/// Provider for most popular items
///
/// Copied from [popularItems].
class PopularItemsProvider
    extends AutoDisposeFutureProvider<List<CatalogItem>> {
  /// Provider for most popular items
  ///
  /// Copied from [popularItems].
  PopularItemsProvider(
    String catalogType,
  ) : this._internal(
          (ref) => popularItems(
            ref as PopularItemsRef,
            catalogType,
          ),
          from: popularItemsProvider,
          name: r'popularItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$popularItemsHash,
          dependencies: PopularItemsFamily._dependencies,
          allTransitiveDependencies:
              PopularItemsFamily._allTransitiveDependencies,
          catalogType: catalogType,
        );

  PopularItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
  }) : super.internal();

  final String catalogType;

  @override
  Override overrideWith(
    FutureOr<List<CatalogItem>> Function(PopularItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PopularItemsProvider._internal(
        (ref) => create(ref as PopularItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CatalogItem>> createElement() {
    return _PopularItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PopularItemsProvider && other.catalogType == catalogType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PopularItemsRef on AutoDisposeFutureProviderRef<List<CatalogItem>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;
}

class _PopularItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<CatalogItem>>
    with PopularItemsRef {
  _PopularItemsProviderElement(super.provider);

  @override
  String get catalogType => (origin as PopularItemsProvider).catalogType;
}

String _$seasonalMenusHash() => r'65df75bbbec7490b809365e7f2598cf1ce65956a';

/// Provider for seasonal menus
///
/// Copied from [seasonalMenus].
@ProviderFor(seasonalMenus)
const seasonalMenusProvider = SeasonalMenusFamily();

/// Provider for seasonal menus
///
/// Copied from [seasonalMenus].
class SeasonalMenusFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Provider for seasonal menus
  ///
  /// Copied from [seasonalMenus].
  const SeasonalMenusFamily();

  /// Provider for seasonal menus
  ///
  /// Copied from [seasonalMenus].
  SeasonalMenusProvider call(
    String catalogType,
  ) {
    return SeasonalMenusProvider(
      catalogType,
    );
  }

  @override
  SeasonalMenusProvider getProviderOverride(
    covariant SeasonalMenusProvider provider,
  ) {
    return call(
      provider.catalogType,
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
  String? get name => r'seasonalMenusProvider';
}

/// Provider for seasonal menus
///
/// Copied from [seasonalMenus].
class SeasonalMenusProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Provider for seasonal menus
  ///
  /// Copied from [seasonalMenus].
  SeasonalMenusProvider(
    String catalogType,
  ) : this._internal(
          (ref) => seasonalMenus(
            ref as SeasonalMenusRef,
            catalogType,
          ),
          from: seasonalMenusProvider,
          name: r'seasonalMenusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$seasonalMenusHash,
          dependencies: SeasonalMenusFamily._dependencies,
          allTransitiveDependencies:
              SeasonalMenusFamily._allTransitiveDependencies,
          catalogType: catalogType,
        );

  SeasonalMenusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.catalogType,
  }) : super.internal();

  final String catalogType;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(SeasonalMenusRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeasonalMenusProvider._internal(
        (ref) => create(ref as SeasonalMenusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        catalogType: catalogType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _SeasonalMenusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonalMenusProvider && other.catalogType == catalogType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, catalogType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeasonalMenusRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `catalogType` of this provider.
  String get catalogType;
}

class _SeasonalMenusProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with SeasonalMenusRef {
  _SeasonalMenusProviderElement(super.provider);

  @override
  String get catalogType => (origin as SeasonalMenusProvider).catalogType;
}

String _$currentCatalogTypeHash() =>
    r'f7d55e3feec4aea2582a9698eb1f509469e0eeef';

/// Riverpod provider for the Unified Catalog Service
///
/// Copied from [CurrentCatalogType].
@ProviderFor(CurrentCatalogType)
final currentCatalogTypeProvider =
    AutoDisposeNotifierProvider<CurrentCatalogType, String>.internal(
  CurrentCatalogType.new,
  name: r'currentCatalogTypeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentCatalogTypeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentCatalogType = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
