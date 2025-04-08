 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';
 
part 'catering_packages_provider.g.dart';

@riverpod
class CateringPackageRepository extends _$CateringPackageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<CateringPackage>> build() {
    return _firestore
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

  /// Adds a new catering package to the database
  Future<void> addPackage(CateringPackage package) async {
    final data = package.toJson();
    data.remove('id'); // Remove ID as Firestore will generate one
    
    await _firestore.collection('cateringPackages').add(data);
  }

  /// Updates an existing catering package in the database
  Future<void> updatePackage(CateringPackage package) async {
    final data = package.toJson();
    data.remove('id'); // Remove ID as it's in the document path
    
    await _firestore
        .collection('cateringPackages')
        .doc(package.id)
        .update(data);
  }

  /// Deletes a catering package from the database
  Future<void> deletePackage(String id) async {
    await _firestore.collection('cateringPackages').doc(id).delete();
  }

  /// Updates the active status of a package
  Future<void> togglePackageStatus(String id, bool isActive) async {
    await _firestore
        .collection('cateringPackages')
        .doc(id)
        .update({'isActive': isActive});
  }

  /// Updates the promoted status of a package
  Future<void> togglePromotedStatus(String id, bool isPromoted) async {
    await _firestore
        .collection('cateringPackages')
        .doc(id)
        .update({'isPromoted': isPromoted});
  }

  /// Gets a single package by ID
  Future<CateringPackage?> getPackageById(String id) async {
    final doc = await _firestore.collection('cateringPackages').doc(id).get();
    if (!doc.exists) return null;
    
    return CateringPackage.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }
}

/// Provider for the currently selected package
@riverpod
class SelectedPackage extends _$SelectedPackage {
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

/// Provider for active packages only
@riverpod
Stream<List<CateringPackage>> activePackages(ActivePackagesRef ref) {
  return FirebaseFirestore.instance
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

/// Provider for promoted packages only
@riverpod
Stream<List<CateringPackage>> promotedPackages(PromotedPackagesRef ref) {
  return FirebaseFirestore.instance
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

/// Provider for packages by category
@riverpod
Stream<List<CateringPackage>> packagesByCategory(
  PackagesByCategoryRef ref,
  String categoryId,
) {
  return FirebaseFirestore.instance
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

/// Provider for searching packages by name or description
@riverpod
Stream<List<CateringPackage>> searchPackages(
  SearchPackagesRef ref,
  String searchTerm,
) {
  if (searchTerm.isEmpty) {
    // If empty, get all active packages
    final firestoreQuery = FirebaseFirestore.instance
        .collection('cateringPackages')
        .where('isActive', isEqualTo: true)
        .orderBy('name');
        
    return firestoreQuery.snapshots().map((snapshot) => 
        snapshot.docs.map((doc) => CateringPackage.fromJson({
          'id': doc.id,
          ...doc.data(),
        })).toList());
  }
  
  final searchTermLower = searchTerm.toLowerCase();
  
  // Firestore doesn't support case-insensitive searching directly,
  // so we'll fetch and filter client-side
  return FirebaseFirestore.instance
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