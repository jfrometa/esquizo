// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_catering_package_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$packageCategoriesHash() => r'f9a75f9c0464606a73b60a4e48defb05b8845dcf';

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

/// FOXTROT: Integration providers with other catering components
/// These providers come from the third implementation
/// Get categories for a specific package
///
/// Copied from [packageCategories].
@ProviderFor(packageCategories)
const packageCategoriesProvider = PackageCategoriesFamily();

/// FOXTROT: Integration providers with other catering components
/// These providers come from the third implementation
/// Get categories for a specific package
///
/// Copied from [packageCategories].
class PackageCategoriesFamily extends Family<List<CateringCategory>> {
  /// FOXTROT: Integration providers with other catering components
  /// These providers come from the third implementation
  /// Get categories for a specific package
  ///
  /// Copied from [packageCategories].
  const PackageCategoriesFamily();

  /// FOXTROT: Integration providers with other catering components
  /// These providers come from the third implementation
  /// Get categories for a specific package
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

/// FOXTROT: Integration providers with other catering components
/// These providers come from the third implementation
/// Get categories for a specific package
///
/// Copied from [packageCategories].
class PackageCategoriesProvider
    extends AutoDisposeProvider<List<CateringCategory>> {
  /// FOXTROT: Integration providers with other catering components
  /// These providers come from the third implementation
  /// Get categories for a specific package
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

String _$availableItemsForPackageHash() =>
    r'e32e012967d1e075c21ad49a84e07e4d10cf8968';

/// Get all available items for package selection
///
/// Copied from [availableItemsForPackage].
@ProviderFor(availableItemsForPackage)
final availableItemsForPackageProvider =
    AutoDisposeProvider<List<CateringItem>>.internal(
  availableItemsForPackage,
  name: r'availableItemsForPackageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableItemsForPackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableItemsForPackageRef
    = AutoDisposeProviderRef<List<CateringItem>>;
String _$unifiedCateringPackageRepositoryHash() =>
    r'66e7878999fbfd0ee054722fa41303542dca13e8';

/// Unified repository for all catering package operations
/// Combines functionality from multiple providers
///
/// Copied from [UnifiedCateringPackageRepository].
@ProviderFor(UnifiedCateringPackageRepository)
final unifiedCateringPackageRepositoryProvider =
    AutoDisposeStreamNotifierProvider<UnifiedCateringPackageRepository,
        List<CateringPackage>>.internal(
  UnifiedCateringPackageRepository.new,
  name: r'unifiedCateringPackageRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unifiedCateringPackageRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnifiedCateringPackageRepository
    = AutoDisposeStreamNotifier<List<CateringPackage>>;
String _$selectedCateringPackageHash() =>
    r'b4a010d53f51af0b400e5a84b1711ad9a8cafd25';

/// ECHO: Provider for the selected package
/// Stateful implementation for package selection with StateNotifier pattern
///
/// Copied from [SelectedCateringPackage].
@ProviderFor(SelectedCateringPackage)
final selectedCateringPackageProvider = AutoDisposeNotifierProvider<
    SelectedCateringPackage, CateringPackage?>.internal(
  SelectedCateringPackage.new,
  name: r'selectedCateringPackageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCateringPackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCateringPackage = AutoDisposeNotifier<CateringPackage?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
