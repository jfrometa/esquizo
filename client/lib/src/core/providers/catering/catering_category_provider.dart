import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_category_model.dart';
 
part 'catering_category_provider.g.dart';

/// Provider for the catering category repository
@riverpod
class CateringCategoryRepository extends _$CateringCategoryRepository {
  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a stream of all catering categories, ordered by display order
  @override
  Stream<List<CateringCategory>> build() {
    return _firestore
        .collection('cateringCategories')
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringCategory.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// Adds a new catering category to the database
  Future<void> addCategory(CateringCategory category) async {
    final data = category.toJson();
    data.remove('id'); // Remove ID as Firestore will generate one
    
    await _firestore.collection('cateringCategories').add(data);
  }

  /// Updates an existing catering category in the database
  Future<void> updateCategory(CateringCategory category) async {
    final data = category.toJson();
    data.remove('id'); // Remove ID as it's in the document path
    
    await _firestore
        .collection('cateringCategories')
        .doc(category.id)
        .update(data);
  }

  /// Deletes a catering category from the database
  Future<void> deleteCategory(String id) async {
    await _firestore.collection('cateringCategories').doc(id).delete();
  }

  /// Updates the active status of a category
  Future<void> toggleCategoryStatus(String id, bool isActive) async {
    await _firestore
        .collection('cateringCategories')
        .doc(id)
        .update({'isActive': isActive});
  }

  /// Updates the display order of multiple categories
  Future<void> reorderCategories(List<CateringCategory> categories) async {
    // Use batch write for better performance
    final batch = _firestore.batch();
    
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      batch.update(
        _firestore.collection('cateringCategories').doc(category.id),
        {'displayOrder': i},
      );
    }
    
    await batch.commit();
  }

  /// Gets a single category by ID
  Future<CateringCategory?> getCategoryById(String id) async {
    final doc = await _firestore.collection('cateringCategories').doc(id).get();
    if (!doc.exists) return null;
    
    return CateringCategory.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }
}

/// Provider for the currently selected category
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  CateringCategory? build() => null;

  /// Sets the selected category
  void setSelectedCategory(CateringCategory? category) {
    state = category;
  }

  /// Clears the selected category
  void clearSelectedCategory() {
    state = null;
  }
}

/// Provider for active categories only
@riverpod
Stream<List<CateringCategory>> activeCategories(ActiveCategoriesRef ref) {
  return FirebaseFirestore.instance
      .collection('cateringCategories')
      .where('isActive', isEqualTo: true)
      .orderBy('displayOrder')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CateringCategory.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList());
}

/// Provider for searching categories by name
@riverpod
Stream<List<CateringCategory>> searchCategories(
  SearchCategoriesRef ref, 
  String searchTerm
) {
  final firestoreQuery = searchTerm.isEmpty
      ? FirebaseFirestore.instance
          .collection('cateringCategories')
          .orderBy('displayOrder')
      : FirebaseFirestore.instance
          .collection('cateringCategories')
          .orderBy('name');
  
  final searchTermLower = searchTerm.toLowerCase();
  
  return firestoreQuery
      .snapshots()
      .map((snapshot) {
        final docs = snapshot.docs
            .map((doc) => CateringCategory.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();
            
        if (searchTerm.isNotEmpty) {
          // Filter by search term
          return docs
              .where((category) => 
                  category.name.toLowerCase().contains(searchTermLower) ||
                  category.description.toLowerCase().contains(searchTermLower) ||
                  category.tags.any((tag) => tag.toLowerCase().contains(searchTermLower)))
              .toList()
              // Sort by relevance
              ..sort((a, b) {
                final aNameMatch = a.name.toLowerCase() == searchTermLower;
                final bNameMatch = b.name.toLowerCase() == searchTermLower;
                
                if (aNameMatch && !bNameMatch) return -1;
                if (!aNameMatch && bNameMatch) return 1;
                
                return a.displayOrder.compareTo(b.displayOrder);
              });
        }
        
        return docs;
      });
}