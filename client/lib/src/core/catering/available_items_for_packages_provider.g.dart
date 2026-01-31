// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_items_for_packages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableItemsByCategoryHash() =>
    r'8568f1e38588db2ff844f113b77621852ff9b715';

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

/// Provider for available items by category
///
/// Copied from [availableItemsByCategory].
@ProviderFor(availableItemsByCategory)
const availableItemsByCategoryProvider = AvailableItemsByCategoryFamily();

/// Provider for available items by category
///
/// Copied from [availableItemsByCategory].
class AvailableItemsByCategoryFamily
    extends Family<AsyncValue<List<CateringDish>>> {
  /// Provider for available items by category
  ///
  /// Copied from [availableItemsByCategory].
  const AvailableItemsByCategoryFamily();

  /// Provider for available items by category
  ///
  /// Copied from [availableItemsByCategory].
  AvailableItemsByCategoryProvider call(
    String category,
  ) {
    return AvailableItemsByCategoryProvider(
      category,
    );
  }

  @override
  AvailableItemsByCategoryProvider getProviderOverride(
    covariant AvailableItemsByCategoryProvider provider,
  ) {
    return call(
      provider.category,
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
  String? get name => r'availableItemsByCategoryProvider';
}

/// Provider for available items by category
///
/// Copied from [availableItemsByCategory].
class AvailableItemsByCategoryProvider
    extends AutoDisposeFutureProvider<List<CateringDish>> {
  /// Provider for available items by category
  ///
  /// Copied from [availableItemsByCategory].
  AvailableItemsByCategoryProvider(
    String category,
  ) : this._internal(
          (ref) => availableItemsByCategory(
            ref as AvailableItemsByCategoryRef,
            category,
          ),
          from: availableItemsByCategoryProvider,
          name: r'availableItemsByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableItemsByCategoryHash,
          dependencies: AvailableItemsByCategoryFamily._dependencies,
          allTransitiveDependencies:
              AvailableItemsByCategoryFamily._allTransitiveDependencies,
          category: category,
        );

  AvailableItemsByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    FutureOr<List<CateringDish>> Function(AvailableItemsByCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableItemsByCategoryProvider._internal(
        (ref) => create(ref as AvailableItemsByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CateringDish>> createElement() {
    return _AvailableItemsByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableItemsByCategoryProvider &&
        other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableItemsByCategoryRef
    on AutoDisposeFutureProviderRef<List<CateringDish>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _AvailableItemsByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<CateringDish>>
    with AvailableItemsByCategoryRef {
  _AvailableItemsByCategoryProviderElement(super.provider);

  @override
  String get category => (origin as AvailableItemsByCategoryProvider).category;
}

String _$availableItemsForPackageHash() =>
    r'518134cab5ab4656d9be105039b6d92c5d782fb7';

/// Provider for items in a specific package
///
/// Copied from [availableItemsForPackage].
@ProviderFor(availableItemsForPackage)
const availableItemsForPackageProvider = AvailableItemsForPackageFamily();

/// Provider for items in a specific package
///
/// Copied from [availableItemsForPackage].
class AvailableItemsForPackageFamily
    extends Family<AsyncValue<List<CateringDish>>> {
  /// Provider for items in a specific package
  ///
  /// Copied from [availableItemsForPackage].
  const AvailableItemsForPackageFamily();

  /// Provider for items in a specific package
  ///
  /// Copied from [availableItemsForPackage].
  AvailableItemsForPackageProvider call(
    String packageId,
  ) {
    return AvailableItemsForPackageProvider(
      packageId,
    );
  }

  @override
  AvailableItemsForPackageProvider getProviderOverride(
    covariant AvailableItemsForPackageProvider provider,
  ) {
    return call(
      provider.packageId,
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
  String? get name => r'availableItemsForPackageProvider';
}

/// Provider for items in a specific package
///
/// Copied from [availableItemsForPackage].
class AvailableItemsForPackageProvider
    extends AutoDisposeFutureProvider<List<CateringDish>> {
  /// Provider for items in a specific package
  ///
  /// Copied from [availableItemsForPackage].
  AvailableItemsForPackageProvider(
    String packageId,
  ) : this._internal(
          (ref) => availableItemsForPackage(
            ref as AvailableItemsForPackageRef,
            packageId,
          ),
          from: availableItemsForPackageProvider,
          name: r'availableItemsForPackageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableItemsForPackageHash,
          dependencies: AvailableItemsForPackageFamily._dependencies,
          allTransitiveDependencies:
              AvailableItemsForPackageFamily._allTransitiveDependencies,
          packageId: packageId,
        );

  AvailableItemsForPackageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.packageId,
  }) : super.internal();

  final String packageId;

  @override
  Override overrideWith(
    FutureOr<List<CateringDish>> Function(AvailableItemsForPackageRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableItemsForPackageProvider._internal(
        (ref) => create(ref as AvailableItemsForPackageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        packageId: packageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CateringDish>> createElement() {
    return _AvailableItemsForPackageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableItemsForPackageProvider &&
        other.packageId == packageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, packageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableItemsForPackageRef
    on AutoDisposeFutureProviderRef<List<CateringDish>> {
  /// The parameter `packageId` of this provider.
  String get packageId;
}

class _AvailableItemsForPackageProviderElement
    extends AutoDisposeFutureProviderElement<List<CateringDish>>
    with AvailableItemsForPackageRef {
  _AvailableItemsForPackageProviderElement(super.provider);

  @override
  String get packageId =>
      (origin as AvailableItemsForPackageProvider).packageId;
}

String _$searchAvailableItemsHash() =>
    r'be6c444b3ab67acadf7c13cbb475e77b9558ef87';

/// Provider for searching dishes
///
/// Copied from [searchAvailableItems].
@ProviderFor(searchAvailableItems)
const searchAvailableItemsProvider = SearchAvailableItemsFamily();

/// Provider for searching dishes
///
/// Copied from [searchAvailableItems].
class SearchAvailableItemsFamily
    extends Family<AsyncValue<List<CateringDish>>> {
  /// Provider for searching dishes
  ///
  /// Copied from [searchAvailableItems].
  const SearchAvailableItemsFamily();

  /// Provider for searching dishes
  ///
  /// Copied from [searchAvailableItems].
  SearchAvailableItemsProvider call(
    String query,
  ) {
    return SearchAvailableItemsProvider(
      query,
    );
  }

  @override
  SearchAvailableItemsProvider getProviderOverride(
    covariant SearchAvailableItemsProvider provider,
  ) {
    return call(
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
  String? get name => r'searchAvailableItemsProvider';
}

/// Provider for searching dishes
///
/// Copied from [searchAvailableItems].
class SearchAvailableItemsProvider
    extends AutoDisposeFutureProvider<List<CateringDish>> {
  /// Provider for searching dishes
  ///
  /// Copied from [searchAvailableItems].
  SearchAvailableItemsProvider(
    String query,
  ) : this._internal(
          (ref) => searchAvailableItems(
            ref as SearchAvailableItemsRef,
            query,
          ),
          from: searchAvailableItemsProvider,
          name: r'searchAvailableItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchAvailableItemsHash,
          dependencies: SearchAvailableItemsFamily._dependencies,
          allTransitiveDependencies:
              SearchAvailableItemsFamily._allTransitiveDependencies,
          query: query,
        );

  SearchAvailableItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<CateringDish>> Function(SearchAvailableItemsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchAvailableItemsProvider._internal(
        (ref) => create(ref as SearchAvailableItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CateringDish>> createElement() {
    return _SearchAvailableItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchAvailableItemsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchAvailableItemsRef
    on AutoDisposeFutureProviderRef<List<CateringDish>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchAvailableItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<CateringDish>>
    with SearchAvailableItemsRef {
  _SearchAvailableItemsProviderElement(super.provider);

  @override
  String get query => (origin as SearchAvailableItemsProvider).query;
}

String _$dietaryFilteredItemsHash() =>
    r'10a2efa0c99ab7b3487e5d4f308ca4f7cec660d4';

/// Provider for dietary restriction filtering
///
/// Copied from [dietaryFilteredItems].
@ProviderFor(dietaryFilteredItems)
const dietaryFilteredItemsProvider = DietaryFilteredItemsFamily();

/// Provider for dietary restriction filtering
///
/// Copied from [dietaryFilteredItems].
class DietaryFilteredItemsFamily
    extends Family<AsyncValue<List<CateringDish>>> {
  /// Provider for dietary restriction filtering
  ///
  /// Copied from [dietaryFilteredItems].
  const DietaryFilteredItemsFamily();

  /// Provider for dietary restriction filtering
  ///
  /// Copied from [dietaryFilteredItems].
  DietaryFilteredItemsProvider call(
    List<String> restrictions,
  ) {
    return DietaryFilteredItemsProvider(
      restrictions,
    );
  }

  @override
  DietaryFilteredItemsProvider getProviderOverride(
    covariant DietaryFilteredItemsProvider provider,
  ) {
    return call(
      provider.restrictions,
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
  String? get name => r'dietaryFilteredItemsProvider';
}

/// Provider for dietary restriction filtering
///
/// Copied from [dietaryFilteredItems].
class DietaryFilteredItemsProvider
    extends AutoDisposeFutureProvider<List<CateringDish>> {
  /// Provider for dietary restriction filtering
  ///
  /// Copied from [dietaryFilteredItems].
  DietaryFilteredItemsProvider(
    List<String> restrictions,
  ) : this._internal(
          (ref) => dietaryFilteredItems(
            ref as DietaryFilteredItemsRef,
            restrictions,
          ),
          from: dietaryFilteredItemsProvider,
          name: r'dietaryFilteredItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dietaryFilteredItemsHash,
          dependencies: DietaryFilteredItemsFamily._dependencies,
          allTransitiveDependencies:
              DietaryFilteredItemsFamily._allTransitiveDependencies,
          restrictions: restrictions,
        );

  DietaryFilteredItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.restrictions,
  }) : super.internal();

  final List<String> restrictions;

  @override
  Override overrideWith(
    FutureOr<List<CateringDish>> Function(DietaryFilteredItemsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DietaryFilteredItemsProvider._internal(
        (ref) => create(ref as DietaryFilteredItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        restrictions: restrictions,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CateringDish>> createElement() {
    return _DietaryFilteredItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DietaryFilteredItemsProvider &&
        other.restrictions == restrictions;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, restrictions.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DietaryFilteredItemsRef
    on AutoDisposeFutureProviderRef<List<CateringDish>> {
  /// The parameter `restrictions` of this provider.
  List<String> get restrictions;
}

class _DietaryFilteredItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<CateringDish>>
    with DietaryFilteredItemsRef {
  _DietaryFilteredItemsProviderElement(super.provider);

  @override
  List<String> get restrictions =>
      (origin as DietaryFilteredItemsProvider).restrictions;
}

String _$availableItemsStreamHash() =>
    r'572aac1beca5afb271612b0acdfc622460692c01';

/// Stream provider for real-time updates of all available dishes
///
/// Copied from [availableItemsStream].
@ProviderFor(availableItemsStream)
final availableItemsStreamProvider =
    AutoDisposeStreamProvider<List<CateringDish>>.internal(
  availableItemsStream,
  name: r'availableItemsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableItemsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableItemsStreamRef
    = AutoDisposeStreamProviderRef<List<CateringDish>>;
String _$featuredItemsHash() => r'6d1fbf28f9c320339f3d3fb3e79763400cebf3dd';

/// Simplified provider to get featured dishes
///
/// Copied from [featuredItems].
@ProviderFor(featuredItems)
final featuredItemsProvider =
    AutoDisposeFutureProvider<List<CateringDish>>.internal(
  featuredItems,
  name: r'featuredItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$featuredItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeaturedItemsRef = AutoDisposeFutureProviderRef<List<CateringDish>>;
String _$popularItemsHash() => r'06a8ce1c167c16a76d8e52dde59153d9ef594067';

/// Provider for getting popular dishes (based on order count)
///
/// Copied from [popularItems].
@ProviderFor(popularItems)
final popularItemsProvider =
    AutoDisposeFutureProvider<List<CateringDish>>.internal(
  popularItems,
  name: r'popularItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$popularItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PopularItemsRef = AutoDisposeFutureProviderRef<List<CateringDish>>;
String _$cateringPackagesHash() => r'7be0dd7598262d4b8ba3ff91dbf0a0a691af17bd';

/// Provider for getting all catering packages
///
/// Copied from [cateringPackages].
@ProviderFor(cateringPackages)
final cateringPackagesProvider =
    AutoDisposeStreamProvider<List<CateringPackage>>.internal(
  cateringPackages,
  name: r'cateringPackagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cateringPackagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CateringPackagesRef
    = AutoDisposeStreamProviderRef<List<CateringPackage>>;
String _$packageWithItemsHash() => r'468738f135fd21991669ff801d1ccaf9ecf49dca';

/// Provider for getting the details of a specific package with its dishes
///
/// Copied from [packageWithItems].
@ProviderFor(packageWithItems)
const packageWithItemsProvider = PackageWithItemsFamily();

/// Provider for getting the details of a specific package with its dishes
///
/// Copied from [packageWithItems].
class PackageWithItemsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for getting the details of a specific package with its dishes
  ///
  /// Copied from [packageWithItems].
  const PackageWithItemsFamily();

  /// Provider for getting the details of a specific package with its dishes
  ///
  /// Copied from [packageWithItems].
  PackageWithItemsProvider call(
    String packageId,
  ) {
    return PackageWithItemsProvider(
      packageId,
    );
  }

  @override
  PackageWithItemsProvider getProviderOverride(
    covariant PackageWithItemsProvider provider,
  ) {
    return call(
      provider.packageId,
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
  String? get name => r'packageWithItemsProvider';
}

/// Provider for getting the details of a specific package with its dishes
///
/// Copied from [packageWithItems].
class PackageWithItemsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider for getting the details of a specific package with its dishes
  ///
  /// Copied from [packageWithItems].
  PackageWithItemsProvider(
    String packageId,
  ) : this._internal(
          (ref) => packageWithItems(
            ref as PackageWithItemsRef,
            packageId,
          ),
          from: packageWithItemsProvider,
          name: r'packageWithItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$packageWithItemsHash,
          dependencies: PackageWithItemsFamily._dependencies,
          allTransitiveDependencies:
              PackageWithItemsFamily._allTransitiveDependencies,
          packageId: packageId,
        );

  PackageWithItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.packageId,
  }) : super.internal();

  final String packageId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(PackageWithItemsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PackageWithItemsProvider._internal(
        (ref) => create(ref as PackageWithItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        packageId: packageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _PackageWithItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PackageWithItemsProvider && other.packageId == packageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, packageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PackageWithItemsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `packageId` of this provider.
  String get packageId;
}

class _PackageWithItemsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with PackageWithItemsRef {
  _PackageWithItemsProviderElement(super.provider);

  @override
  String get packageId => (origin as PackageWithItemsProvider).packageId;
}

String _$availableItemsRepositoryHash() =>
    r'd41da709a65c6f12cd9ae96bd57f67c089d3403f';

/// Repository for managing available catering items/dishes
///
/// Copied from [AvailableItemsRepository].
@ProviderFor(AvailableItemsRepository)
final availableItemsRepositoryProvider = AutoDisposeAsyncNotifierProvider<
    AvailableItemsRepository, List<CateringDish>>.internal(
  AvailableItemsRepository.new,
  name: r'availableItemsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableItemsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AvailableItemsRepository
    = AutoDisposeAsyncNotifier<List<CateringDish>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
