// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catering_category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeCategoriesHash() => r'50220f31252c16a94a4ad46bf891d0892920b480';

/// Provider for active categories only
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
String _$searchCategoriesHash() => r'22f0889ccada18ed424ea041063e086c172b8918';

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

/// Provider for searching categories by name
///
/// Copied from [searchCategories].
@ProviderFor(searchCategories)
const searchCategoriesProvider = SearchCategoriesFamily();

/// Provider for searching categories by name
///
/// Copied from [searchCategories].
class SearchCategoriesFamily
    extends Family<AsyncValue<List<CateringCategory>>> {
  /// Provider for searching categories by name
  ///
  /// Copied from [searchCategories].
  const SearchCategoriesFamily();

  /// Provider for searching categories by name
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

/// Provider for searching categories by name
///
/// Copied from [searchCategories].
class SearchCategoriesProvider
    extends AutoDisposeStreamProvider<List<CateringCategory>> {
  /// Provider for searching categories by name
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

String _$cateringCategoryRepositoryHash() =>
    r'996d63749346685de81b6a79af307e7e4a72d9be';

/// Provider for the catering category repository
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
String _$selectedCategoryHash() => r'9d2b91a376e7c7724d2932769dd8f24a5314b9de';

/// Provider for the currently selected category
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
