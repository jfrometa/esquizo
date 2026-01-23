import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_category_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_item_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_category_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';

part 'unified_catering_package_providers.g.dart';

/// Unified repository for all catering package operations
/// Combines functionality from multiple providers
@riverpod
class UnifiedCateringPackageRepository
    extends _$UnifiedCateringPackageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<CateringPackage>> build() {
    // ALPHA: Core implementation present in all repositories using business-scoped collection
    final businessId = ref.watch(currentBusinessIdProvider);
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringPackage.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  // SECTION: Core Package Operations

  /// ALPHA: Adds a new catering package to the database
  /// Implementation consistent across all repositories
  Future<void> addPackage(CateringPackage package) async {
    final businessId = ref.read(currentBusinessIdProvider);
    final data = package.toJson();
    data.remove('id'); // Remove ID as Firestore will generate one
    data['businessId'] = businessId; // Ensure business ID is set

    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .add(data);
  }

  /// ALPHA: Updates an existing catering package in the database
  /// Implementation consistent across all repositories
  Future<void> updatePackage(CateringPackage package) async {
    final businessId = ref.read(currentBusinessIdProvider);
    final data = package.toJson();
    data.remove('id'); // Remove ID as it's in the document path

    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .doc(package.id)
        .update(data);
  }

  /// ALPHA: Deletes a catering package from the database
  /// Implementation consistent across all repositories
  Future<void> deletePackage(String id) async {
    final businessId = ref.read(currentBusinessIdProvider);
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .doc(id)
        .delete();
  }

  /// ALPHA: Updates the active status of a package
  /// Implementation consistent across all repositories
  Future<void> togglePackageStatus(String id, bool isActive) async {
    final businessId = ref.read(currentBusinessIdProvider);
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .doc(id)
        .update({'isActive': isActive});
  }

  /// ALPHA: Updates the promoted status of a package
  /// Named togglePromotedStatus in some places and togglePromoted in others
  Future<void> togglePromotedStatus(String id, bool isPromoted) async {
    final businessId = ref.read(currentBusinessIdProvider);
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .doc(id)
        .update({'isPromoted': isPromoted});
  }

  /// BRAVO: Updates the promoted status of a package (alternate name)
  /// Equivalent to togglePromotedStatus but preserving the alternate name for compatibility
  @Deprecated('Use togglePromotedStatus instead')
  Future<void> togglePromoted(String id, bool isPromoted) async {
    await togglePromotedStatus(id, isPromoted);
  }

  /// BRAVO: Gets a single package by ID
  /// From first repository implementation
  Future<CateringPackage?> getPackageById(String id) async {
    final businessId = ref.read(currentBusinessIdProvider);
    final doc = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .doc(id)
        .get();
    if (!doc.exists) return null;

    return CateringPackage.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  // SECTION: Extended Queries

  /// CHARLIE: Get active packages only
  /// Extracted from activePackages provider into repository for consistency
  Stream<List<CateringPackage>> getActivePackages() {
    final businessId = ref.read(currentBusinessIdProvider);
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringPackage.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// CHARLIE: Get promoted packages only
  /// Extracted from promotedPackages provider into repository for consistency
  Stream<List<CateringPackage>> getPromotedPackages() {
    final businessId = ref.read(currentBusinessIdProvider);
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .where('isActive', isEqualTo: true)
        .where('isPromoted', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringPackage.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// CHARLIE: Get packages by category
  /// Extracted from packagesByCategory provider into repository for consistency
  Stream<List<CateringPackage>> getPackagesByCategory(String categoryId) {
    final businessId = ref.read(currentBusinessIdProvider);
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .where('categoryIds', arrayContains: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringPackage.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// CHARLIE: Search packages by name or description
  /// Extracted from searchPackages provider into repository for consistency
  Stream<List<CateringPackage>> searchPackages(String searchTerm) {
    final businessId = ref.read(currentBusinessIdProvider);
    if (searchTerm.isEmpty) {
      // If empty, get all active packages
      final firestoreQuery = _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('cateringPackages')
          .where('isActive', isEqualTo: true)
          .orderBy('name');

      return firestoreQuery.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => CateringPackage.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList());
    }

    final searchTermLower = searchTerm.toLowerCase();

    // Firestore doesn't support case-insensitive searching directly,
    // so we'll fetch and filter client-side
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => CateringPackage.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .where((package) =>
              package.name.toLowerCase().contains(searchTermLower) ||
              package.description.toLowerCase().contains(searchTermLower))
          .toList();

      return docs;
    });
  }

  // SECTION: Integration with CateringOrderProvider

  /// DELTA: Get package details for catering order
  /// For integration with CateringOrderProvider
  Future<List<CateringPackage>> getPackagesForOrder(
      List<String> packageIds) async {
    if (packageIds.isEmpty) return [];

    final packages = <CateringPackage>[];

    // We'll use individual gets instead of a where-in query since
    // Firestore has a limit of 10 items in array-contains-any queries
    for (final id in packageIds) {
      final package = await getPackageById(id);
      if (package != null) {
        packages.add(package);
      }
    }

    return packages;
  }
}

/// ECHO: Provider for the selected package
/// Stateful implementation for package selection with StateNotifier pattern
@riverpod
class SelectedCateringPackage extends _$SelectedCateringPackage {
  @override
  CateringPackage? build() => null;

  /// Sets the selected package
  void setSelectedPackage(CateringPackage? package) {
    state = package;
  }

  /// Clears the selected package
  void clearSelectedPackage() {
    state = null;
  }
}

/// Alternative StateNotifier implementation for SelectedCateringPackage
/// This is used for legacy provider compatibility
class SelectedCateringPackageNotifier extends StateNotifier<CateringPackage?> {
  SelectedCateringPackageNotifier() : super(null);

  CateringPackage? get value => state;

  /// Sets the selected package
  void setSelectedPackage(CateringPackage? package) {
    state = package;
  }

  /// Clears the selected package
  void clearSelectedPackage() {
    state = null;
  }
}

/// FOXTROT: Integration providers with other catering components
/// These providers come from the third implementation

/// Get categories for a specific package
@riverpod
List<CateringCategory> packageCategories(
  PackageCategoriesRef ref,
  CateringPackage package,
) {
  final allCategories =
      ref.watch(cateringCategoryRepositoryProvider).valueOrNull ?? [];
  return allCategories
      .where((category) => package.categoryIds.contains(category.id))
      .toList();
}

/// Get all available items for package selection
@riverpod
List<CateringItem> availableItemsForPackage(AvailableItemsForPackageRef ref) {
  // Most likely the cateringItemRepositoryProvider already gives us access to the items
  return ref.watch(cateringItemRepositoryProvider).valueOrNull ?? [];
}

/// Convenience provider for available items using traditional Provider pattern
/// This uses a different name to avoid collision with the generated provider
final availableItemsProvider = Provider<List<CateringItem>>((ref) {
  // Simply forward the value from the autogenerated provider
  return ref.watch(availableItemsForPackageProvider) ?? [];
});

// SECTION: Convenience Providers

/// Main provider for accessing the UnifiedCateringPackageRepository
final unifiedCateringPackageProvider =
    Provider<UnifiedCateringPackageRepository>((ref) {
  // Access the notifier through the ref
  return ref.read(unifiedCateringPackageRepositoryProvider.notifier);
});

/// Provider for all packages stream
/// Access the raw stream for compatibility with existing code
final allCateringPackagesProvider =
    Provider<Stream<List<CateringPackage>>>((ref) {
  // First get the repository instance
  final repository =
      ref.read(unifiedCateringPackageRepositoryProvider.notifier);

  // Then get the stream from the repository's build method
  return repository.build();
});

/// CHARLIE: Provider for active packages only
/// Uses the repository's getActivePackages method
final activeCateringPackagesProvider =
    Provider<Stream<List<CateringPackage>>>((ref) {
  return ref.watch(unifiedCateringPackageProvider).getActivePackages();
});

/// CHARLIE: Provider for promoted packages only
/// Uses the repository's getPromotedPackages method
final promotedCateringPackagesProvider =
    Provider<Stream<List<CateringPackage>>>((ref) {
  return ref.watch(unifiedCateringPackageProvider).getPromotedPackages();
});

/// CHARLIE: Provider for packages by category
/// Uses the repository's getPackagesByCategory method
final packagesByCategoryProvider =
    Provider.family<Stream<List<CateringPackage>>, String>((ref, categoryId) {
  return ref
      .watch(unifiedCateringPackageProvider)
      .getPackagesByCategory(categoryId);
});

/// CHARLIE: Provider for searching packages
/// Uses the repository's searchPackages method
final searchCateringPackagesProvider =
    Provider.family<Stream<List<CateringPackage>>, String>((ref, searchTerm) {
  return ref.watch(unifiedCateringPackageProvider).searchPackages(searchTerm);
});

/// DELTA: Provider for packages by IDs (for order integration)
/// Uses the repository's getPackagesForOrder method
final packagesForOrderProvider =
    FutureProvider.family<List<CateringPackage>, List<String>>(
        (ref, packageIds) async {
  return ref
      .watch(unifiedCateringPackageProvider)
      .getPackagesForOrder(packageIds);
});

// Correct way to access the repository in modern Riverpod
extension UnifiedCateringPackageRepositoryX
    on AutoDisposeStreamNotifierProviderImpl<UnifiedCateringPackageRepository,
        List<CateringPackage>> {
  /// Provider that gives access to the repository instance
  Provider<UnifiedCateringPackageRepository> get repositoryProvider =>
      Provider<UnifiedCateringPackageRepository>((ref) => ref.watch(notifier));
}

/// Legacy provider that wraps unifiedCateringPackageRepositoryProvider
/// Ensures backward compatibility with code using cateringPackageRepositoryProvider
@Deprecated('Use unifiedCateringPackageRepositoryProvider instead')
final cateringPackageRepositoryProvider =
    Provider<UnifiedCateringPackageRepository>((ref) {
  return ref.read(unifiedCateringPackageRepositoryProvider.notifier);
});

/// Legacy provider that wraps selectedCateringPackageProvider
/// Ensures backward compatibility with code using selectedPackageProvider
@Deprecated('Use selectedCateringPackageProvider instead')
final selectedPackageProvider =
    StateNotifierProvider<SelectedCateringPackageNotifier, CateringPackage?>(
        (ref) {
  // Create a new StateNotifier instance that syncs with the new provider
  final notifier = SelectedCateringPackageNotifier();

  // Sync changes from the riverpod provider to the StateNotifier
  ref.listen(selectedCateringPackageProvider, (previous, next) {
    if (next != notifier.value) {
      notifier.setSelectedPackage(next);
    }
  });

  return notifier;
});

/// Legacy provider that wraps selectedCateringPackageProvider
/// Alternate implementation that returns an empty package instead of null
@Deprecated('Use selectedCateringPackageProvider instead')
final selectedPackageEmptyProvider = Provider<CateringPackage>((ref) {
  return ref.watch(selectedCateringPackageProvider) ?? CateringPackage.empty();
});

/// Legacy provider that wraps activeCateringPackagesProvider
/// Ensures backward compatibility with code using activePackagesProvider
@Deprecated('Use activeCateringPackagesProvider instead')
final activePackagesProvider = Provider<Stream<List<CateringPackage>>>((ref) {
  return ref.watch(activeCateringPackagesProvider);
});

/// Legacy provider that wraps promotedCateringPackagesProvider
/// Ensures backward compatibility with code using promotedPackagesProvider
@Deprecated('Use promotedCateringPackagesProvider instead')
final promotedPackagesProvider = Provider<Stream<List<CateringPackage>>>((ref) {
  return ref.watch(promotedCateringPackagesProvider);
});

/// Legacy provider that wraps packagesByCategoryProvider
/// Ensures backward compatibility with code using packagesByCategoryProvider
@Deprecated('Use packagesByCategoryProvider instead')
final packagesByCategoryLegacyProvider =
    Provider.family<Stream<List<CateringPackage>>, String>((ref, categoryId) {
  return ref.watch(packagesByCategoryProvider(categoryId));
});

/// Legacy provider that wraps searchCateringPackagesProvider
/// Ensures backward compatibility with code using searchPackagesProvider
@Deprecated('Use searchCateringPackagesProvider instead')
final searchPackagesProvider =
    Provider.family<Stream<List<CateringPackage>>, String>((ref, searchTerm) {
  return ref.watch(searchCateringPackagesProvider(searchTerm));
});
