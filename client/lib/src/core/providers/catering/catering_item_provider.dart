import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_category_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_category_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';
 
 part 'catering_item_provider.g.dart';

@riverpod
class CateringItemRepository extends _$CateringItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<CateringItem>> build() {
    return _firestore
        .collection('cateringItems')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringItem.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Future<void> addItem(CateringItem item) async {
    await _firestore.collection('cateringItems').add(item.toJson()..remove('id'));
  }

  Future<void> updateItem(CateringItem item) async {
    await _firestore
        .collection('cateringItems')
        .doc(item.id)
        .update(item.toJson()..remove('id'));
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection('cateringItems').doc(id).delete();
  }

  Future<void> toggleItemStatus(String id, bool isActive) async {
    await _firestore
        .collection('cateringItems')
        .doc(id)
        .update({'isActive': isActive});
  }

  Future<void> toggleHighlighted(String id, bool isHighlighted) async {
    await _firestore
        .collection('cateringItems')
        .doc(id)
        .update({'isHighlighted': isHighlighted});
  }
}

@riverpod
CateringItem selectedItem(SelectedItemRef ref) {
  return CateringItem.empty();
}

@riverpod
Stream<List<CateringItem>> itemsByCategory(
  ItemsByCategoryRef ref,
  String categoryId,
) {
  return FirebaseFirestore.instance
      .collection('cateringItems')
      .where('categoryIds', arrayContains: categoryId)
      .where('isActive', isEqualTo: true)
      .orderBy('name')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CateringItem.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList());
}

@riverpod
Stream<List<CateringItem>> highlightedItems(HighlightedItemsRef ref) {
  return FirebaseFirestore.instance
      .collection('cateringItems')
      .where('isHighlighted', isEqualTo: true)
      .where('isActive', isEqualTo: true)
      .orderBy('name')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CateringItem.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList());
}

@riverpod
List<CateringCategory> itemCategories(
  ItemCategoriesRef ref,
  CateringItem item,
) {
  final allCategories = ref.watch(cateringCategoryRepositoryProvider).valueOrNull ?? [];
  return allCategories
      .where((category) => item.categoryIds.contains(category.id))
      .toList();
}