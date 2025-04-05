import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

import 'package:starter_architecture_flutter_firebase/src/core/api_services/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/business/business_config_provider.dart';

/// Generic catalog item model that represents products, dishes, or any sellable item
class CatalogItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final bool isAvailable;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.isAvailable = true,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory CatalogItem.fromFirestore(cloud_firestore.DocumentSnapshot doc) {
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
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as cloud_firestore.Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as cloud_firestore.Timestamp).toDate()
          : null,
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
      'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
    };
  }

  CatalogItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    bool? isAvailable,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      isAvailable: isAvailable ?? this.isAvailable,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CatalogItem &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ price.hashCode ^ categoryId.hashCode;
  }
}

/// Generic catalog category model
class CatalogCategory {
  final String id;
  final String name;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final String? description;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CatalogCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.description,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory CatalogCategory.fromFirestore(cloud_firestore.DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CatalogCategory(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      description: data['description'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as cloud_firestore.Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as cloud_firestore.Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'description': description,
      'tags': tags,
      'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
    };
  }

  CatalogCategory copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatalogCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CatalogCategory &&
        other.id == id &&
        other.name == name &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ sortOrder.hashCode;
  }
}

/// Cache wrapper class for catalog data
class CatalogCache {
  final DateTime timestamp;
  final int ttlMinutes;
  final dynamic data;

  CatalogCache({
    required this.timestamp,
    required this.data,
    this.ttlMinutes = 30, // Default 30 minutes cache
  });

  bool get isValid {
    final now = DateTime.now();
    final expirationTime = timestamp.add(Duration(minutes: ttlMinutes));
    return now.isBefore(expirationTime);
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'ttlMinutes': ttlMinutes,
        'data': data,
      };

  factory CatalogCache.fromJson(Map<String, dynamic> json) {
    return CatalogCache(
      timestamp: DateTime.parse(json['timestamp']),
      ttlMinutes: json['ttlMinutes'] ?? 30,
      data: json['data'],
    );
  }
}

/// Unified service for handling all catalog and product related functionality
/// This consolidates logic from CatalogService, ProductService, and related providers
class CatalogService {
  final cloud_firestore.FirebaseFirestore _firestore;
  final String _businessId;
  final Map<String, String> _collectionPaths = {};
  final String _catalogType;


  /// Constructor with dependency injection for testing
  CatalogService({
    required cloud_firestore.FirebaseFirestore firestore,
    required String catalogType,
    required String businessId,
  })  : _firestore = firestore,
        _catalogType = catalogType,
        _businessId = businessId {
    // Initialize collection paths for different catalog types
    _initializeCollectionPaths();
  }

  /// Initialize collection paths for different catalog types
  void _initializeCollectionPaths() {
    // Main catalog types
    _collectionPaths['menu_items'] = 'businesses/$_businessId/menu_items';
    _collectionPaths['menu_categories'] =
        'businesses/$_businessId/menu_categories';
    _collectionPaths['product_items'] = 'businesses/$_businessId/product_items';
    _collectionPaths['product_categories'] =
        'businesses/$_businessId/product_categories';
    _collectionPaths['room_items'] = 'businesses/$_businessId/room_items';
    _collectionPaths['room_categories'] =
        'businesses/$_businessId/room_categories';
  }

  /// Get collection reference for items by catalog type
  cloud_firestore.CollectionReference _getItemsCollection(String catalogType) {
    final path = _collectionPaths['${catalogType}_items'] ??
        'businesses/$_businessId/${catalogType}_items';
    return _firestore.collection(path);
  }

  /// Get collection reference for categories by catalog type
  cloud_firestore.CollectionReference _getCategoriesCollection(
      String catalogType) {
    final path = _collectionPaths['${catalogType}_categories'] ??
        'businesses/$_businessId/${catalogType}_categories';
    return _firestore.collection(path);
  }

  // ============= CATEGORY OPERATIONS =============

  /// Get all categories for a specific catalog type with caching
  Stream<List<CatalogCategory>> getCategories(String catalogType) {
    final categoriesCollection = _getCategoriesCollection(catalogType);

    return categoriesCollection
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      try {
        // Parse categories with error handling for each document
        final categories = <CatalogCategory>[];
        for (final doc in snapshot.docs) {
          try {
            categories.add(CatalogCategory.fromFirestore(doc));
          } catch (e) {
            debugPrint('Error parsing category ${doc.id}: $e');
          }
        }

        // Update cache for faster access
        _updateCategoriesCache(catalogType, categories);

        return categories;
      } catch (e) {
        debugPrint('Error processing categories snapshot: $e');
        return <CatalogCategory>[];
      }
    });
  }

  /// Get active categories only
  Stream<List<CatalogCategory>> getActiveCategories(String catalogType) {
    final categoriesCollection = _getCategoriesCollection(catalogType);

    return categoriesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => CatalogCategory.fromFirestore(doc))
            .toList();
      } catch (e) {
        debugPrint('Error processing active categories: $e');
        return <CatalogCategory>[];
      }
    });
  }

  /// Get a single category by ID
  Future<CatalogCategory?> getCategoryById(
      String catalogType, String categoryId) async {
    try {
      final doc = await _getCategoriesCollection(catalogType)
          .doc(categoryId)
          .get(const cloud_firestore.GetOptions(
              source: cloud_firestore.Source.serverAndCache));

      if (!doc.exists) return null;

      return CatalogCategory.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching category: $e');
      return null;
    }
  }

  /// Create a new category
  Future<String> createCategory(
      String catalogType, CatalogCategory category) async {
    try {
      // Check for duplicate name
      final existingCategories = await _getCategoriesCollection(catalogType)
          .where('name', isEqualTo: category.name)
          .limit(1)
          .get();

      if (existingCategories.docs.isNotEmpty) {
        throw Exception('A category with this name already exists');
      }

      // Create the category
      final docRef = await _getCategoriesCollection(catalogType)
          .add(category.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating category: $e');
      rethrow;
    }
  }

  /// Update an existing category
  Future<void> updateCategory(
      String catalogType, CatalogCategory category) async {
    try {
      // Check for duplicate name (excluding this category)
      final existingCategories = await _getCategoriesCollection(catalogType)
          .where('name', isEqualTo: category.name)
          .where(cloud_firestore.FieldPath.documentId,
              isNotEqualTo: category.id)
          .limit(1)
          .get();

      if (existingCategories.docs.isNotEmpty) {
        throw Exception('Another category with this name already exists');
      }

      await _getCategoriesCollection(catalogType)
          .doc(category.id)
          .update(category.toFirestore());
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  /// Delete a category with checks for associated items
  Future<void> deleteCategory(String catalogType, String categoryId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Check if there are items in this category
        final items = await _getItemsCollection(catalogType)
            .where('categoryId', isEqualTo: categoryId)
            .limit(1)
            .get();

        if (items.docs.isNotEmpty) {
          throw Exception('Cannot delete category with associated items');
        }

        // If no items, proceed with deletion
        transaction
            .delete(_getCategoriesCollection(catalogType).doc(categoryId));
      });
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  /// Update category sort order
  Future<void> updateCategorySortOrder(
      String catalogType, String categoryId, int newSortOrder) async {
    try {
      await _getCategoriesCollection(catalogType).doc(categoryId).update({
        'sortOrder': newSortOrder,
        'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating category sort order: $e');
      rethrow;
    }
  }

  /// Reorder multiple categories at once
  Future<void> reorderCategories(
      String catalogType, List<CatalogCategory> categories) async {
    try {
      final batch = _firestore.batch();

      for (var i = 0; i < categories.length; i++) {
        final category = categories[i];
        batch.update(
          _getCategoriesCollection(catalogType).doc(category.id),
          {'sortOrder': i},
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error reordering categories: $e');
      rethrow;
    }
  }

  /// Toggle category active status
  Future<void> toggleCategoryStatus(
      String catalogType, String categoryId, bool isActive) async {
    try {
      await _getCategoriesCollection(catalogType).doc(categoryId).update({
        'isActive': isActive,
        'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error toggling category status: $e');
      rethrow;
    }
  }

  // ============= ITEM OPERATIONS =============

  /// Get all items for a specific catalog type
  Stream<List<CatalogItem>> getItems(String catalogType) {
    final itemsCollection = _getItemsCollection(catalogType);

    return itemsCollection.orderBy('name').snapshots().map((snapshot) {
      try {
        // Parse items with error handling
        final items = <CatalogItem>[];
        for (final doc in snapshot.docs) {
          try {
            items.add(CatalogItem.fromFirestore(doc));
          } catch (e) {
            debugPrint('Error parsing item ${doc.id}: $e');
          }
        }

        // Update cache
        _updateItemsCache(catalogType, items);

        return items;
      } catch (e) {
        debugPrint('Error processing items snapshot: $e');
        return <CatalogItem>[];
      }
    });
  }

  /// Get items by category
  Stream<List<CatalogItem>> getItemsByCategory(
      String catalogType, String categoryId) {
    return _getItemsCollection(catalogType)
        .where('categoryId', isEqualTo: categoryId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => CatalogItem.fromFirestore(doc))
            .toList();
      } catch (e) {
        debugPrint('Error processing items by category: $e');
        return <CatalogItem>[];
      }
    });
  }

  /// Get a specific item by ID
  Future<CatalogItem?> getItemById(String catalogType, String itemId) async {
    try {
      final doc = await _getItemsCollection(catalogType).doc(itemId).get(
          const cloud_firestore.GetOptions(
              source: cloud_firestore.Source.serverAndCache));

      if (!doc.exists) return null;

      return CatalogItem.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching item: $e');
      return null;
    }
  }

  /// Add a new item
  Future<String> addItem(String catalogType, CatalogItem item) async {
    try {
      // Validate the category exists
      final categoryDoc = await _getCategoriesCollection(catalogType)
          .doc(item.categoryId)
          .get();

      if (!categoryDoc.exists) {
        throw Exception('Category does not exist');
      }

      // Create with new ID or use provided ID
      final docRef = item.id.isEmpty
          ? _getItemsCollection(catalogType).doc()
          : _getItemsCollection(catalogType).doc(item.id);

      final newItem = item.id.isEmpty
          ? CatalogItem(
              id: docRef.id,
              name: item.name,
              description: item.description,
              price: item.price,
              imageUrl: item.imageUrl,
              categoryId: item.categoryId,
              isAvailable: item.isAvailable,
              metadata: item.metadata,
            )
          : item;

      // Use a map with all fields to ensure createdAt is set for new items
      final itemData = newItem.toFirestore();
      if (item.id.isEmpty) {
        itemData['createdAt'] = cloud_firestore.FieldValue.serverTimestamp();
      }

      await docRef.set(itemData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding item: $e');
      rethrow;
    }
  }

  /// Update an existing item
  Future<void> updateItem(String catalogType, CatalogItem item) async {
    try {
      await _getItemsCollection(catalogType)
          .doc(item.id)
          .update(item.toFirestore());
    } catch (e) {
      debugPrint('Error updating item: $e');
      rethrow;
    }
  }

  /// Delete an item
  Future<void> deleteItem(String catalogType, String itemId) async {
    try {
      // Check if this item is referenced elsewhere before deleting
      // This could be expanded based on business rules

      await _getItemsCollection(catalogType).doc(itemId).delete();
    } catch (e) {
      debugPrint('Error deleting item: $e');
      rethrow;
    }
  }

  /// Update item availability
  Future<void> updateItemAvailability(
      String catalogType, String itemId, bool isAvailable) async {
    try {
      await _getItemsCollection(catalogType).doc(itemId).update({
        'isAvailable': isAvailable,
        'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating item availability: $e');
      rethrow;
    }
  }

  /// Toggle item featured status
  Future<void> toggleItemFeatured(
      String catalogType, String itemId, bool isFeatured) async {
    try {
      await _getItemsCollection(catalogType).doc(itemId).update({
        'metadata.featured': isFeatured,
        'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error toggling featured status: $e');
      rethrow;
    }
  }

  /// Get featured items for a catalog type
  Future<List<CatalogItem>> getFeaturedItems(String catalogType) async {
    try {
      // Try to get from cache first
      final cachedItems = await _loadFeaturedItemsFromCache(catalogType);
      if (cachedItems != null) {
        return cachedItems;
      }

      // If not in cache, get from Firestore
      final snapshot = await _getItemsCollection(catalogType)
          .where('metadata.featured', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .orderBy('name')
          .get();

      final items =
          snapshot.docs.map((doc) => CatalogItem.fromFirestore(doc)).toList();

      // Cache the results
      await _cacheFeaturedItems(catalogType, items);

      return items;
    } catch (e) {
      debugPrint('Error fetching featured items: $e');
      return [];
    }
  }

  /// Search items by name or description
  Future<List<CatalogItem>> searchItems(
      String catalogType, String query) async {
    try {
      if (query.isEmpty) {
        // If query is empty, return all items
        final snapshot = await _getItemsCollection(catalogType)
            .orderBy('name')
            .limit(20) // Limit results for performance
            .get();

        return snapshot.docs
            .map((doc) => CatalogItem.fromFirestore(doc))
            .toList();
      }

      // Convert query to lowercase for case-insensitive comparison
      final lowerQuery = query.toLowerCase();

      // Get all items (this could be optimized with a proper search backend)
      final snapshot =
          await _getItemsCollection(catalogType).orderBy('name').get();

      // Filter client-side for search
      // (not efficient for large datasets - consider Algolia or similar)
      return snapshot.docs
          .map((doc) => CatalogItem.fromFirestore(doc))
          .where((item) =>
              item.name.toLowerCase().contains(lowerQuery) ||
              item.description.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      debugPrint('Error searching items: $e');
      return [];
    }
  }

  // ============= INVENTORY METHODS =============

  /// Update inventory level for an item
  Future<void> updateInventoryLevel(
      String catalogType, String itemId, int quantity) async {
    try {
      await _getItemsCollection(catalogType).doc(itemId).update({
        'metadata.inventoryLevel': quantity,
        'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating inventory level: $e');
      rethrow;
    }
  }

  /// Check if an item is in stock
  Future<bool> isItemInStock(String catalogType, String itemId) async {
    try {
      final item = await getItemById(catalogType, itemId);
      if (item == null) return false;

      // Check if item is available
      if (!item.isAvailable) return false;

      // Check inventory level if tracked
      final inventoryLevel = item.metadata['inventoryLevel'];
      if (inventoryLevel != null && inventoryLevel is int) {
        return inventoryLevel > 0;
      }

      // If inventory not tracked, assume in stock if available
      return true;
    } catch (e) {
      debugPrint('Error checking stock: $e');
      return false;
    }
  }

  /// Get items with low inventory
  Future<List<CatalogItem>> getLowInventoryItems(
      String catalogType, int threshold) async {
    try {
      // Firestore doesn't support querying on nested fields with conditions easily
      // So we fetch all items and filter client-side
      final snapshot = await _getItemsCollection(catalogType)
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => CatalogItem.fromFirestore(doc))
          .where((item) {
        final inventoryLevel = item.metadata['inventoryLevel'];
        return inventoryLevel != null &&
            inventoryLevel is int &&
            inventoryLevel <= threshold;
      }).toList();
    } catch (e) {
      debugPrint('Error getting low inventory items: $e');
      return [];
    }
  }

  // ============= ANALYTICS METHODS =============

  /// Get most popular items based on order history
  Future<List<CatalogItem>> getMostPopularItems(String catalogType,
      {int limit = 10}) async {
    try {
      // This is a placeholder for integration with order analytics
      // In a real implementation, you would query orders collection
      // and aggregate item quantities, then fetch the items by ID

      // Mock implementation - in real app, replace with actual query
      final snapshot = await _getItemsCollection(catalogType)
          .orderBy('metadata.orderCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CatalogItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting popular items: $e');
      return [];
    }
  }

  /// Get least popular items based on order history
  Future<List<CatalogItem>> getLeastPopularItems(String catalogType,
      {int limit = 10}) async {
    try {
      // Similar to getMostPopularItems, but for least popular
      final snapshot = await _getItemsCollection(catalogType)
          .orderBy('metadata.orderCount')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CatalogItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting least popular items: $e');
      return [];
    }
  }

  // ============= SEASONAL MENU METHODS =============

  /// Create or update a seasonal menu
  Future<String> createSeasonalMenu(String name, DateTime startDate,
      DateTime endDate, List<String> itemIds) async {
    try {
      final data = {
        'name': name,
        'startDate': cloud_firestore.Timestamp.fromDate(startDate),
        'endDate': cloud_firestore.Timestamp.fromDate(endDate),
        'itemIds': itemIds,
        'isActive': true,
        'createdAt': cloud_firestore.FieldValue.serverTimestamp(),
        'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('businesses')
          .doc(_businessId)
          .collection('seasonal_menus')
          .add(data);

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating seasonal menu: $e');
      rethrow;
    }
  }

  /// Get active seasonal menus
  Future<List<Map<String, dynamic>>> getActiveSeasonalMenus() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('businesses')
          .doc(_businessId)
          .collection('seasonal_menus')
          .where('startDate',
              isLessThanOrEqualTo: cloud_firestore.Timestamp.fromDate(now))
          .where('endDate',
              isGreaterThanOrEqualTo: cloud_firestore.Timestamp.fromDate(now))
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint('Error getting seasonal menus: $e');
      return [];
    }
  }

  // ============= CACHING METHODS =============

  /// Update categories cache
  Future<void> _updateCategoriesCache(
      String catalogType, List<CatalogCategory> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'catalog_categories_$_businessId$catalogType';

      final cacheData = CatalogCache(
        timestamp: DateTime.now(),
        data: categories
            .map((cat) => cat.toFirestore()..addAll({'id': cat.id}))
            .toList(),
      );

      await prefs.setString(cacheKey, jsonEncode(cacheData.toJson()));
    } catch (e) {
      debugPrint('Error caching categories: $e');
    }
  }

  /// Load categories from cache
  Future<List<CatalogCategory>?> _loadCategoriesFromCache(
      String catalogType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'catalog_categories_$_businessId$catalogType';

      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return null;

      final cache = CatalogCache.fromJson(jsonDecode(cachedData));
      if (!cache.isValid) return null;

      final List<dynamic> data = cache.data;
      return data
          .map((item) => CatalogCategory(
                id: item['id'],
                name: item['name'] ?? '',
                imageUrl: item['imageUrl'] ?? '',
                sortOrder: item['sortOrder'] ?? 0,
                isActive: item['isActive'] ?? true,
                description: item['description'],
                tags: List<String>.from(item['tags'] ?? []),
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading categories cache: $e');
      return null;
    }
  }

  /// Update items cache
  Future<void> _updateItemsCache(
      String catalogType, List<CatalogItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'catalog_items_$_businessId$catalogType';

      final cacheData = CatalogCache(
        timestamp: DateTime.now(),
        data: items
            .map((item) => item.toFirestore()..addAll({'id': item.id}))
            .toList(),
      );

      await prefs.setString(cacheKey, jsonEncode(cacheData.toJson()));
    } catch (e) {
      debugPrint('Error caching items: $e');
    }
  }

  /// Load items from cache
  Future<List<CatalogItem>?> _loadItemsFromCache(String catalogType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'catalog_items_$_businessId$catalogType';

      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return null;

      final cache = CatalogCache.fromJson(jsonDecode(cachedData));
      if (!cache.isValid) return null;

      final List<dynamic> data = cache.data;
      return data
          .map((item) => CatalogItem(
                id: item['id'],
                name: item['name'] ?? '',
                description: item['description'] ?? '',
                price: (item['price'] ?? 0).toDouble(),
                imageUrl: item['imageUrl'] ?? '',
                categoryId: item['categoryId'] ?? '',
                isAvailable: item['isAvailable'] ?? true,
                metadata: item['metadata'] ?? {},
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading items cache: $e');
      return null;
    }
  }

  /// Cache featured items
  Future<void> _cacheFeaturedItems(
      String catalogType, List<CatalogItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'catalog_featured_$_businessId$catalogType';

      final cacheData = CatalogCache(
        timestamp: DateTime.now(),
        data: items
            .map((item) => item.toFirestore()..addAll({'id': item.id}))
            .toList(),
      );

      await prefs.setString(cacheKey, jsonEncode(cacheData.toJson()));
    } catch (e) {
      debugPrint('Error caching featured items: $e');
    }
  }

  /// Load featured items from cache
  Future<List<CatalogItem>?> _loadFeaturedItemsFromCache(
      String catalogType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'catalog_featured_$_businessId$catalogType';

      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return null;

      final cache = CatalogCache.fromJson(jsonDecode(cachedData));
      if (!cache.isValid) return null;

      final List<dynamic> data = cache.data;
      return data
          .map((item) => CatalogItem(
                id: item['id'],
                name: item['name'] ?? '',
                description: item['description'] ?? '',
                price: (item['price'] ?? 0).toDouble(),
                imageUrl: item['imageUrl'] ?? '',
                categoryId: item['categoryId'] ?? '',
                isAvailable: item['isAvailable'] ?? true,
                metadata: item['metadata'] ?? {},
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading featured items cache: $e');
      return null;
    }
  }

  /// Clear all catalog caches
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = <String>[];

      // Find all catalog-related cache keys
      prefs.getKeys().forEach((key) {
        if (key.startsWith('catalog_')) {
          keysToRemove.add(key);
        }
      });

      // Remove all catalog caches
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing catalog cache: $e');
    }
  }
}

/// Riverpod provider for the Unified Catalog Service
// final catalogServiceProvider = Provider<CatalogService>((ref) {
//   final firestore = ref.watch(firebaseFirestoreProvider);
//   final businessId = ref.watch(currentBusinessIdProvider);

//   return CatalogService(
//     firestore: firestore,
//     businessId: businessId,
//     catalogType: catalogType,
//   );
// });

// /// Provider for the current catalog type
final currentCatalogTypeProvider = StateProvider<String>((ref) => 'menu');

// Provider for catalog service
final catalogServiceProvider =
    Provider.family<CatalogService, String>((ref, catalogType) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final businessId = ref.watch(currentBusinessIdProvider);

  return CatalogService(
    firestore: firestore,
    businessId: businessId,
    catalogType: catalogType,
  );
});

// ============= CATEGORY PROVIDERS =============

/// Provider for categories in a specific catalog type
final catalogCategoriesProvider =
    StreamProvider.family<List<CatalogCategory>, String>((ref, catalogType) {
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  return catalogService.getCategories(catalogType);
});

/// Provider for active categories only
final activeCatalogCategoriesProvider =
    StreamProvider.family<List<CatalogCategory>, String>((ref, catalogType) {
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  return catalogService.getActiveCategories(catalogType);
});

/// Provider for a single category
final catalogCategoryProvider = FutureProvider.family<CatalogCategory?,
    ({String catalogType, String categoryId})>((ref, params) {
  final catalogService = ref.watch(catalogServiceProvider(params.catalogType));
  return catalogService.getCategoryById(params.catalogType, params.categoryId);
});

// ============= ITEM PROVIDERS =============

/// Provider for all items in a catalog type
final catalogItemsProvider =
    StreamProvider.family<List<CatalogItem>, String>((ref, catalogType) {
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  return catalogService.getItems(catalogType);
});

/// Provider for items by category
final catalogItemsByCategoryProvider = StreamProvider.family<List<CatalogItem>,
    ({String catalogType, String categoryId})>((ref, params) {
  final catalogService = ref.watch(catalogServiceProvider(params.catalogType));
  return catalogService.getItemsByCategory(
      params.catalogType, params.categoryId);
});

/// Provider for a single item
final catalogItemProvider =
    FutureProvider.family<CatalogItem?, ({String catalogType, String itemId})>(
        (ref, params) {
  final catalogService = ref.watch(catalogServiceProvider(params.catalogType));
  return catalogService.getItemById(params.catalogType, params.itemId);
});

/// Provider for featured items
final featuredItemsProvider =
    FutureProvider.family<List<CatalogItem>, String>((ref, catalogType) {
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  return catalogService.getFeaturedItems(catalogType);
});

/// Provider for searching items
final searchItemsProvider = FutureProvider.family<List<CatalogItem>,
    ({String catalogType, String query})>((ref, params) {
  final catalogService = ref.watch(catalogServiceProvider(params.catalogType));
  return catalogService.searchItems(params.catalogType, params.query);
});

/// Provider for items with low inventory
final lowInventoryItemsProvider = FutureProvider.family<List<CatalogItem>,
    ({String catalogType, int threshold})>((ref, params) {
  final catalogService = ref.watch(catalogServiceProvider(params.catalogType));
  return catalogService.getLowInventoryItems(
      params.catalogType, params.threshold);
});

/// Provider for most popular items
final popularItemsProvider =
    FutureProvider.family<List<CatalogItem>, String>((ref, catalogType) {
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  return catalogService.getMostPopularItems(catalogType);
});

/// Provider for seasonal menus
final seasonalMenusProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, catalogType) {
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  return catalogService.getActiveSeasonalMenus();
});
 