// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catering_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedItemHash() => r'4e1794a2d67c8c03e17b9a053d4d214172d9385b';

/// See also [selectedItem].
@ProviderFor(selectedItem)
final selectedItemProvider = AutoDisposeProvider<CateringItem>.internal(
  selectedItem,
  name: r'selectedItemProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedItemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedItemRef = AutoDisposeProviderRef<CateringItem>;
String _$itemsByCategoryHash() => r'5b7b06d936a2794acd357dc5976a405bc4d28571';

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

/// See also [itemsByCategory].
@ProviderFor(itemsByCategory)
const itemsByCategoryProvider = ItemsByCategoryFamily();

/// See also [itemsByCategory].
class ItemsByCategoryFamily extends Family<AsyncValue<List<CateringItem>>> {
  /// See also [itemsByCategory].
  const ItemsByCategoryFamily();

  /// See also [itemsByCategory].
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

/// See also [itemsByCategory].
class ItemsByCategoryProvider
    extends AutoDisposeStreamProvider<List<CateringItem>> {
  /// See also [itemsByCategory].
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

String _$highlightedItemsHash() => r'498a655b79c761f994d1922c9bc336fe1cbc8970';

/// See also [highlightedItems].
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

/// See also [itemCategories].
@ProviderFor(itemCategories)
const itemCategoriesProvider = ItemCategoriesFamily();

/// See also [itemCategories].
class ItemCategoriesFamily extends Family<List<CateringCategory>> {
  /// See also [itemCategories].
  const ItemCategoriesFamily();

  /// See also [itemCategories].
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

/// See also [itemCategories].
class ItemCategoriesProvider
    extends AutoDisposeProvider<List<CateringCategory>> {
  /// See also [itemCategories].
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

String _$cateringItemRepositoryHash() =>
    r'52f0018e677fdbd6db82381f025f3cdb6ea106b7';

/// See also [CateringItemRepository].
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
