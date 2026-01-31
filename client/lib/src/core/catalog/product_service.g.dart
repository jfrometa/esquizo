// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productServiceHash() => r'69aefe47057d2d492815631aded3314ab2a6ed8f';

/// See also [productService].
@ProviderFor(productService)
final productServiceProvider = AutoDisposeProvider<ProductService>.internal(
  productService,
  name: r'productServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductServiceRef = AutoDisposeProviderRef<ProductService>;
String _$menuCategoriesHash() => r'fdcc05126f6645233c85442fdd10a6822c58db49';

/// See also [menuCategories].
@ProviderFor(menuCategories)
final menuCategoriesProvider =
    AutoDisposeStreamProvider<List<MenuCategory>>.internal(
  menuCategories,
  name: r'menuCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$menuCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MenuCategoriesRef = AutoDisposeStreamProviderRef<List<MenuCategory>>;
String _$menuProductsHash() => r'b88173cdc87a7b1a11fbd1420f415f3073777cc4';

/// See also [menuProducts].
@ProviderFor(menuProducts)
final menuProductsProvider = AutoDisposeStreamProvider<List<MenuItem>>.internal(
  menuProducts,
  name: r'menuProductsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$menuProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MenuProductsRef = AutoDisposeStreamProviderRef<List<MenuItem>>;
String _$categoryProductsHash() => r'f6cf6484fa0d5fb0038f74e7ef6d73f895134caf';

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

/// See also [categoryProducts].
@ProviderFor(categoryProducts)
const categoryProductsProvider = CategoryProductsFamily();

/// See also [categoryProducts].
class CategoryProductsFamily extends Family<AsyncValue<List<MenuItem>>> {
  /// See also [categoryProducts].
  const CategoryProductsFamily();

  /// See also [categoryProducts].
  CategoryProductsProvider call(
    String categoryId,
  ) {
    return CategoryProductsProvider(
      categoryId,
    );
  }

  @override
  CategoryProductsProvider getProviderOverride(
    covariant CategoryProductsProvider provider,
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
  String? get name => r'categoryProductsProvider';
}

/// See also [categoryProducts].
class CategoryProductsProvider
    extends AutoDisposeStreamProvider<List<MenuItem>> {
  /// See also [categoryProducts].
  CategoryProductsProvider(
    String categoryId,
  ) : this._internal(
          (ref) => categoryProducts(
            ref as CategoryProductsRef,
            categoryId,
          ),
          from: categoryProductsProvider,
          name: r'categoryProductsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryProductsHash,
          dependencies: CategoryProductsFamily._dependencies,
          allTransitiveDependencies:
              CategoryProductsFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategoryProductsProvider._internal(
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
    Stream<List<MenuItem>> Function(CategoryProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryProductsProvider._internal(
        (ref) => create(ref as CategoryProductsRef),
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
  AutoDisposeStreamProviderElement<List<MenuItem>> createElement() {
    return _CategoryProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryProductsProvider && other.categoryId == categoryId;
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
mixin CategoryProductsRef on AutoDisposeStreamProviderRef<List<MenuItem>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CategoryProductsProviderElement
    extends AutoDisposeStreamProviderElement<List<MenuItem>>
    with CategoryProductsRef {
  _CategoryProductsProviderElement(super.provider);

  @override
  String get categoryId => (origin as CategoryProductsProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
