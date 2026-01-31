import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';

part 'available_items_for_packages_provider.g.dart';

/// Repository for managing available catering items/dishes
@riverpod
class AvailableItemsRepository extends _$AvailableItemsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<CateringDish>> build() async {
    final businessId = ref.watch(currentBusinessIdProvider);
    // Fetch all available dishes from business-scoped collection
    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringDishes')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add the document ID to the data
      return CateringDish.fromJson(data);
    }).toList();
  }

  /// Get dishes by category
  Future<List<CateringDish>> getDishesByCategory(String category) async {
    final businessId = ref.read(currentBusinessIdProvider);
    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringDishes')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return CateringDish.fromJson(data);
    }).toList();
  }

  /// Get dishes for a specific package
  Future<List<CateringDish>> getDishesForPackage(String packageId) async {
    final businessId = ref.read(currentBusinessIdProvider);
    final packageDoc = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringPackages')
        .doc(packageId)
        .get();

    if (!packageDoc.exists) {
      return [];
    }

    final packageData = packageDoc.data()!;
    final dishIds = List<String>.from(packageData['dishIds'] ?? []);

    if (dishIds.isEmpty) {
      return [];
    }

    // Chunks of 10 for Firestore 'in' query limitation
    List<CateringDish> result = [];

    for (int i = 0; i < dishIds.length; i += 10) {
      final chunkEnd = (i + 10 < dishIds.length) ? i + 10 : dishIds.length;
      final chunk = dishIds.sublist(i, chunkEnd);

      final snapshot = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('cateringDishes')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      result.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CateringDish.fromJson(data);
      }));
    }

    return result;
  }

  /// Search for dishes by name
  Future<List<CateringDish>> searchDishes(String query) async {
    final businessId = ref.read(currentBusinessIdProvider);
    // This is a simplified search - consider implementing more advanced
    // search with Algolia or Cloud Functions if needed
    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('cateringDishes')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return CateringDish.fromJson(data);
    }).toList();
  }

  /// Filter dishes by dietary restrictions
  Future<List<CateringDish>> getDishesByDietaryRestrictions(
      List<String> restrictions) async {
    final businessId = ref.read(currentBusinessIdProvider);
    // This implementation assumes dishes have a 'dietaryRestrictions' array field
    // that contains strings like 'vegetarian', 'vegan', 'gluten-free', etc.

    // For each restriction, we need to perform a separate query and then
    // combine the results, since Firestore doesn't support OR queries on array-contains
    Set<CateringDish> result = {};

    for (final restriction in restrictions) {
      final snapshot = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('cateringDishes')
          .where('dietaryRestrictions', arrayContains: restriction)
          .get();

      result.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CateringDish.fromJson(data);
      }));
    }

    return result.toList();
  }
}

/// Provider for available items by category
@riverpod
Future<List<CateringDish>> availableItemsByCategory(
  Ref ref,
  String category,
) async {
  final repository = ref.watch(availableItemsRepositoryProvider.notifier);
  return repository.getDishesByCategory(category);
}

/// Provider for items in a specific package
@riverpod
Future<List<CateringDish>> availableItemsForPackage(
  Ref ref,
  String packageId,
) async {
  final repository = ref.watch(availableItemsRepositoryProvider.notifier);
  return repository.getDishesForPackage(packageId);
}

/// Provider for searching dishes
@riverpod
Future<List<CateringDish>> searchAvailableItems(
  Ref ref,
  String query,
) async {
  final repository = ref.watch(availableItemsRepositoryProvider.notifier);
  return repository.searchDishes(query);
}

/// Provider for dietary restriction filtering
@riverpod
Future<List<CateringDish>> dietaryFilteredItems(
  Ref ref,
  List<String> restrictions,
) async {
  final repository = ref.watch(availableItemsRepositoryProvider.notifier);
  return repository.getDishesByDietaryRestrictions(restrictions);
}

/// Stream provider for real-time updates of all available dishes
@riverpod
Stream<List<CateringDish>> availableItemsStream(Ref ref) {
  return FirebaseFirestore.instance
      .collection('cateringDishes')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CateringDish.fromJson(data);
          }).toList());
}

/// Simplified provider to get featured dishes
@riverpod
Future<List<CateringDish>> featuredItems(Ref ref) async {
  return FirebaseFirestore.instance
      .collection('cateringDishes')
      .where('featured', isEqualTo: true)
      .limit(5)
      .get()
      .then((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CateringDish.fromJson(data);
          }).toList());
}

/// Provider for getting popular dishes (based on order count)
@riverpod
Future<List<CateringDish>> popularItems(Ref ref) async {
  return FirebaseFirestore.instance
      .collection('cateringDishes')
      .orderBy('orderCount', descending: true)
      .limit(10)
      .get()
      .then((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CateringDish.fromJson(data);
          }).toList());
}

/// Provider for getting all catering packages
@riverpod
Stream<List<CateringPackage>> cateringPackages(Ref ref) {
  return FirebaseFirestore.instance
      .collection('cateringPackages')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;

            // Add default values for missing icon fields
            if (!data.containsKey('iconCodePoint')) {
              data['iconCodePoint'] =
                  0xe491; // Default icon code (e.g., restaurant icon)
            }
            if (!data.containsKey('iconFontFamily')) {
              data['iconFontFamily'] = 'MaterialIcons';
            }

            // Convert the map to a CateringOrder object
            return CateringPackage.fromJson(data);
          }).toList());
}

/// Provider for getting the details of a specific package with its dishes
@riverpod
Future<Map<String, dynamic>> packageWithItems(
  Ref ref,
  String packageId,
) async {
  final packageDoc = await FirebaseFirestore.instance
      .collection('cateringPackages')
      .doc(packageId)
      .get();

  if (!packageDoc.exists) {
    throw Exception('Package not found');
  }

  final packageData = packageDoc.data()!;
  packageData['id'] = packageDoc.id;

  final dishes =
      await ref.watch(availableItemsForPackageProvider(packageId).future);

  return {
    'package': packageData,
    'dishes': dishes,
  };
}
