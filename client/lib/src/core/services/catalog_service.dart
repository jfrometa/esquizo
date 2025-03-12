import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generic catalog item model that can be extended for specific use cases
class CatalogItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final bool isAvailable;
  final Map<String, dynamic> metadata;

  CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.isAvailable = true,
    this.metadata = const {},
  });

  factory CatalogItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CatalogItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'metadata': metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Generic catalog category model
class CatalogCategory {
  final String id;
  final String name;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;

  CatalogCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CatalogCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CatalogCategory(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Generic catalog service that can be extended or used directly
class CatalogService {
  final FirebaseFirestore _firestore;
  final String _businessId;
  final String _catalogType;
  
  CatalogService({
    FirebaseFirestore? firestore,
    required String businessId,
    required String catalogType,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _businessId = businessId,
    _catalogType = catalogType;
  
  // Collection references with dynamic paths based on business and catalog type
  CollectionReference get _categoriesCollection => 
      _firestore.collection('businesses').doc(_businessId).collection('${_catalogType}_categories');
  
  CollectionReference get _itemsCollection => 
      _firestore.collection('businesses').doc(_businessId).collection('${_catalogType}_items');
  
  // Get all categories
  Stream<List<CatalogCategory>> getCategories() {
    return _categoriesCollection
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CatalogCategory.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get all items
  Stream<List<CatalogItem>> getItems() {
    return _itemsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CatalogItem.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get items by category with caching for performance
  Stream<List<CatalogItem>> getItemsByCategory(String categoryId) {
    return _itemsCollection
        .where('categoryId', isEqualTo: categoryId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CatalogItem.fromFirestore(doc))
              .toList();
        });
  }
  
  // Additional methods for CRUD operations
  // ...
}