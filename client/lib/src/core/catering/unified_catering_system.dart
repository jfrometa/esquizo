import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_category_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';

part 'unified_catering_system.g.dart';

/// Constants for caching keys
class CateringCacheKeys {
  static const String cateringOrder = 'cateringOrder';
  static const String manualQuote = 'manualQuote';
  static const String categoryCache = 'catering_categories';
  static const String packageCache = 'catering_packages';
  static const String itemCache = 'catering_items';
  static const String cacheTTL = 'catering_cache_ttl';

  // TTL in minutes for cache
  static const int defaultCacheTTL = 30;
}

/// Wrapper class for cache metadata
class CacheMetadata {
  final DateTime timestamp;
  final int ttlMinutes;

  CacheMetadata({
    required this.timestamp,
    this.ttlMinutes = CateringCacheKeys.defaultCacheTTL,
  });

  bool get isValid {
    final now = DateTime.now();
    final expirationTime = timestamp.add(Duration(minutes: ttlMinutes));
    return now.isBefore(expirationTime);
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'ttlMinutes': ttlMinutes,
      };

  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      timestamp: DateTime.parse(json['timestamp']),
      ttlMinutes: json['ttlMinutes'] ?? CateringCacheKeys.defaultCacheTTL,
    );
  }
}

abstract class BaseCateringRepository<T> {
  final cloud_firestore.FirebaseFirestore _firestore;
  final String _collectionPath;
  final String _cacheKey;

  BaseCateringRepository({
    required cloud_firestore.FirebaseFirestore firestore,
    required String collectionPath,
    required String cacheKey,
  })  : _firestore = firestore,
        _collectionPath = collectionPath,
        _cacheKey = cacheKey;

  // Methods to be implemented by subclasses
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T item);

  // Base query with caching - fixed implementation without mergeWith
  Stream<List<T>> getAll({bool useCache = true}) {
    final collection = _firestore.collection(_collectionPath);

    // Create a controller for our combined stream
    final controller = StreamController<List<T>>.broadcast();

    // Store the last emitted value to help with deduplication
    List<T>? lastEmittedValue;

    // If useCache is true, try to get from cache first
    if (useCache) {
      _loadFromCache().then((cachedItems) {
        if (cachedItems != null && !controller.isClosed) {
          // Cache exists, deliver it immediately
          controller.add(cachedItems);
          lastEmittedValue = cachedItems;
        }
      });
    }

    // Stream from Firestore
    final streamSubscription = collection
        .snapshots()
        .map((snapshot) => _processSnapshot(snapshot))
        .handleError((error) {
      debugPrint('Error in Firestore stream: $error');
      // Don't rethrow - let the stream continue with empty list
      return <T>[];
    }).listen(
      (data) {
        // Only add the data if it's different from the last emitted value
        if (!controller.isClosed && !_areListsEqual(data, lastEmittedValue)) {
          controller.add(data);
          lastEmittedValue = data;
        }
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
    );

    // Make sure to clean up when the controller is closed
    controller.onCancel = () {
      streamSubscription.cancel();
    };

    return controller.stream;
  }

  // Process snapshot with error handling
  List<T> _processSnapshot(cloud_firestore.QuerySnapshot snapshot) {
    try {
      final result = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              debugPrint('Error parsing document ${doc.id}: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<T>()
          .toList();

      // Update cache with the latest data
      _saveToCache(result);

      return result;
    } catch (e) {
      debugPrint('Error processing snapshot: $e');
      return <T>[];
    }
  }

  // Compare lists for equality (used for deduplication)
  bool _areListsEqual(List<T>? a, List<T>? b) {
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Save to cache
  Future<void> _saveToCache(List<T> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = items.map((item) {
        final json = toJson(item);
        return json;
      }).toList();

      final cacheData = {
        'items': itemsJson,
        'metadata': CacheMetadata(
          timestamp: DateTime.now(),
        ).toJson(),
      };

      await prefs.setString(_cacheKey, jsonEncode(cacheData));
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  // Load from cache
  Future<List<T>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString(_cacheKey);

      if (cacheString == null) return null;

      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final metadata = CacheMetadata.fromJson(cacheData['metadata']);

      // Check if cache is still valid
      if (!metadata.isValid) {
        // Cache expired, return null to fetch from Firestore
        return null;
      }

      final itemsJson = cacheData['items'] as List;
      return itemsJson.map((itemJson) => fromJson(itemJson)).toList();
    } catch (e) {
      debugPrint('Error loading from cache: $e');
      return null;
    }
  }
}

/// Unified Catering Category Repository
@riverpod
class CateringCategoryRepository extends _$CateringCategoryRepository {
  late BaseCateringRepository<CateringCategory> _repository;

  @override
  Stream<List<CateringCategory>> build() {
    final firestore = ref.watch(firebaseFirestoreProvider);

    _repository = _CateringCategoryRepositoryImpl(
      firestore: firestore,
      collectionPath: 'cateringCategories',
      cacheKey: CateringCacheKeys.categoryCache,
    );

    return _repository.getAll();
  }

  // Add a new category
  Future<void> addCategory(CateringCategory category) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    final data = category.toJson();
    data.remove('id'); // Remove ID as Firestore will generate one

    await firestore.collection('cateringCategories').add(data);
  }

  // Update a category
  Future<void> updateCategory(CateringCategory category) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    final data = category.toJson();
    data.remove('id'); // Remove ID as it's in the document path

    await firestore
        .collection('cateringCategories')
        .doc(category.id)
        .update(data);
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore.collection('cateringCategories').doc(id).delete();
  }

  // Toggle category status
  Future<void> toggleCategoryStatus(String id, bool isActive) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore
        .collection('cateringCategories')
        .doc(id)
        .update({'isActive': isActive});
  }

  // Update category order
  Future<void> reorderCategories(List<CateringCategory> categories) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    final batch = firestore.batch();

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      batch.update(
        firestore.collection('cateringCategories').doc(category.id),
        {'displayOrder': i},
      );
    }

    await batch.commit();
  }

  // Get active categories only
  Stream<List<CateringCategory>> getActiveCategories() {
    final firestore = ref.read(firebaseFirestoreProvider);

    return firestore
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

  // Search categories by name
  Stream<List<CateringCategory>> searchCategories(String searchTerm) {
    final firestore = ref.read(firebaseFirestoreProvider);
    final searchTermLower = searchTerm.toLowerCase();

    final firestoreQuery = searchTerm.isEmpty
        ? firestore.collection('cateringCategories').orderBy('displayOrder')
        : firestore.collection('cateringCategories').orderBy('name');

    return firestoreQuery.snapshots().map((snapshot) {
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
                category.tags
                    .any((tag) => tag.toLowerCase().contains(searchTermLower)))
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

  // Get a single category by ID with caching
  Future<CateringCategory?> getCategoryById(String id) async {
    final firestore = ref.read(firebaseFirestoreProvider);

    try {
      final doc = await firestore.collection('cateringCategories').doc(id).get(
          const cloud_firestore.GetOptions(
              source: cloud_firestore.Source.serverAndCache));

      if (!doc.exists) return null;

      return CateringCategory.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting category by ID: $e');
      return null;
    }
  }
}

// Implementation of BaseCateringRepository for categories
class _CateringCategoryRepositoryImpl
    extends BaseCateringRepository<CateringCategory> {
  _CateringCategoryRepositoryImpl({
    required cloud_firestore.FirebaseFirestore firestore,
    required String collectionPath,
    required String cacheKey,
  }) : super(
          firestore: firestore,
          collectionPath: collectionPath,
          cacheKey: cacheKey,
        );

  @override
  CateringCategory fromJson(Map<String, dynamic> json) {
    return CateringCategory.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(CateringCategory item) {
    return item.toJson();
  }
}

/// Unified Catering Item Repository
@riverpod
class CateringItemRepository extends _$CateringItemRepository {
  late BaseCateringRepository<CateringItem> _repository;

  @override
  Stream<List<CateringItem>> build() {
    final firestore = ref.watch(firebaseFirestoreProvider);

    _repository = _CateringItemRepositoryImpl(
      firestore: firestore,
      collectionPath: 'cateringItems',
      cacheKey: CateringCacheKeys.itemCache,
    );

    return _repository.getAll();
  }

  // Add a new item
  Future<void> addItem(CateringItem item) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore
        .collection('cateringItems')
        .add(item.toJson()..remove('id'));
  }

  // Update an item
  Future<void> updateItem(CateringItem item) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore
        .collection('cateringItems')
        .doc(item.id)
        .update(item.toJson()..remove('id'));
  }

  // Delete an item
  Future<void> deleteItem(String id) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore.collection('cateringItems').doc(id).delete();
  }

  // Toggle item status
  Future<void> toggleItemStatus(String id, bool isActive) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore
        .collection('cateringItems')
        .doc(id)
        .update({'isActive': isActive});
  }

  // Toggle highlighted status
  Future<void> toggleHighlighted(String id, bool isHighlighted) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore
        .collection('cateringItems')
        .doc(id)
        .update({'isHighlighted': isHighlighted});
  }

  // Get items by category
  Stream<List<CateringItem>> getItemsByCategory(String categoryId) {
    final firestore = ref.read(firebaseFirestoreProvider);

    return firestore
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

  // Get highlighted items
  Stream<List<CateringItem>> getHighlightedItems() {
    final firestore = ref.read(firebaseFirestoreProvider);

    return firestore
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

  // Search items by name
  Stream<List<CateringItem>> searchItems(String searchTerm) {
    final firestore = ref.read(firebaseFirestoreProvider);
    final searchTermLower = searchTerm.toLowerCase();

    return firestore
        .collection('cateringItems')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => CateringItem.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      if (searchTerm.isEmpty) return items;

      return items
          .where((item) =>
              item.name.toLowerCase().contains(searchTermLower) ||
              item.description.toLowerCase().contains(searchTermLower))
          .toList()
        ..sort((a, b) {
          final aNameMatch = a.name.toLowerCase() == searchTermLower;
          final bNameMatch = b.name.toLowerCase() == searchTermLower;

          if (aNameMatch && !bNameMatch) return -1;
          if (!aNameMatch && bNameMatch) return 1;

          return 0;
        });
    });
  }

  // Get a specific item by ID with caching
  Future<CateringItem?> getItemById(String id) async {
    final firestore = ref.read(firebaseFirestoreProvider);

    try {
      final doc = await firestore.collection('cateringItems').doc(id).get(
          const cloud_firestore.GetOptions(
              source: cloud_firestore.Source.serverAndCache));

      if (!doc.exists) return null;

      return CateringItem.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting item by ID: $e');
      return null;
    }
  }
}

// Implementation of BaseCateringRepository for items
class _CateringItemRepositoryImpl extends BaseCateringRepository<CateringItem> {
  _CateringItemRepositoryImpl({
    required cloud_firestore.FirebaseFirestore firestore,
    required String collectionPath,
    required String cacheKey,
  }) : super(
          firestore: firestore,
          collectionPath: collectionPath,
          cacheKey: cacheKey,
        );

  @override
  CateringItem fromJson(Map<String, dynamic> json) {
    return CateringItem.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(CateringItem item) {
    return item.toJson();
  }
}

/// Unified Catering Package Repository
@riverpod
class CateringPackageRepository extends _$CateringPackageRepository {
  late BaseCateringRepository<CateringPackage> _repository;

  @override
  Stream<List<CateringPackage>> build() {
    final firestore = ref.watch(firebaseFirestoreProvider);

    _repository = _CateringPackageRepositoryImpl(
      firestore: firestore,
      collectionPath: 'cateringPackages',
      cacheKey: CateringCacheKeys.packageCache,
    );

    return _repository.getAll();
  }

  /// Adds a new catering package to the database
  Future<void> addPackage(CateringPackage package) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    final data = package.toJson();
    data.remove('id'); // Remove ID as Firestore will generate one

    await firestore.collection('cateringPackages').add(data);
  }

  /// Updates an existing catering package in the database
  Future<void> updatePackage(CateringPackage package) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    final data = package.toJson();
    data.remove('id'); // Remove ID as it's in the document path

    await firestore.collection('cateringPackages').doc(package.id).update(data);
  }

  /// Deletes a catering package from the database
  Future<void> deletePackage(String id) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore.collection('cateringPackages').doc(id).delete();
  }

  /// Updates the active status of a package
  Future<void> togglePackageStatus(String id, bool isActive) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore
        .collection('cateringPackages')
        .doc(id)
        .update({'isActive': isActive});
  }

  /// Updates the promoted status of a package
  Future<void> togglePromotedStatus(String id, bool isPromoted) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore
        .collection('cateringPackages')
        .doc(id)
        .update({'isPromoted': isPromoted});
  }

  /// Gets a single package by ID with caching
  Future<CateringPackage?> getPackageById(String id) async {
    final firestore = ref.read(firebaseFirestoreProvider);

    try {
      final doc = await firestore.collection('cateringPackages').doc(id).get(
          const cloud_firestore.GetOptions(
              source: cloud_firestore.Source.serverAndCache));

      if (!doc.exists) return null;

      return CateringPackage.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting package by ID: $e');
      return null;
    }
  }

  /// Get active packages only with caching
  Stream<List<CateringPackage>> getActivePackages() {
    final firestore = ref.read(firebaseFirestoreProvider);

    return firestore
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

  /// Get promoted packages only
  Stream<List<CateringPackage>> getPromotedPackages() {
    final firestore = ref.read(firebaseFirestoreProvider);

    return firestore
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

  /// Get packages by category
  Stream<List<CateringPackage>> getPackagesByCategory(String categoryId) {
    final firestore = ref.read(firebaseFirestoreProvider);

    return firestore
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

  /// Search packages by name or description
  Stream<List<CateringPackage>> searchPackages(String searchTerm) {
    final firestore = ref.read(firebaseFirestoreProvider);

    if (searchTerm.isEmpty) {
      // If empty, get all active packages
      final firestoreQuery = firestore
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
    return firestore
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

  /// Get package details for catering order
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

// Implementation of BaseCateringRepository for packages
class _CateringPackageRepositoryImpl
    extends BaseCateringRepository<CateringPackage> {
  _CateringPackageRepositoryImpl({
    required cloud_firestore.FirebaseFirestore firestore,
    required String collectionPath,
    required String cacheKey,
  }) : super(
          firestore: firestore,
          collectionPath: collectionPath,
          cacheKey: cacheKey,
        );

  @override
  CateringPackage fromJson(Map<String, dynamic> json) {
    return CateringPackage.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(CateringPackage item) {
    return item.toJson();
  }
}

/// Unified Catering Order Repository
@riverpod
class CateringOrderRepository extends _$CateringOrderRepository {
  final cloud_firestore.FirebaseFirestore _firestore =
      cloud_firestore.FirebaseFirestore.instance;
  Timer? _saveDebounce;

  @override
  FutureOr<CateringOrderItem?> build() async {
    return _loadCateringOrder();
  }

  // SECTION: Local State Management (SharedPreferences)

  // Load catering order from SharedPreferences
  Future<CateringOrderItem?> _loadCateringOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedOrder = prefs.getString(CateringCacheKeys.cateringOrder);
    if (serializedOrder != null) {
      try {
        return CateringOrderItem.fromJson(jsonDecode(serializedOrder));
      } catch (e) {
        debugPrint('Error loading catering order: $e');
        return null;
      }
    }
    return null;
  }

  // Save catering order to SharedPreferences
  Future<void> _saveCateringOrder(CateringOrderItem? order) async {
    final prefs = await SharedPreferences.getInstance();
    if (order != null) {
      await prefs.setString(
          CateringCacheKeys.cateringOrder, jsonEncode(order.toJson()));
    } else {
      await prefs.remove(CateringCacheKeys.cateringOrder);
    }
  }

  // Update with debounce
  void _updateStateWithDebounce(CateringOrderItem? newState) {
    state = AsyncData(newState);

    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveCateringOrder(newState);
    });
  }

  // SECTION: Cart Management

  // Add a new dish to the active order
  void addCateringItem(CateringDish dish) {
    final currentState = state.valueOrNull;

    if (currentState == null) {
      // Create a new order with default values
      _updateStateWithDebounce(CateringOrderItem.legacy(
        title: '',
        img: '',
        description: '',
        dishes: [dish],
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: 'salado',
        adicionales: '',
        peopleCount: 0,
        isQuote: false,
      ));
    } else if (currentState.isLegacyItem) {
      // Handle legacy mode - check if dish already exists (comparing by title)
      bool dishExists = currentState.dishes
          .any((existingDish) => existingDish.title == dish.title);

      if (!dishExists) {
        // Only add if the dish doesn't exist
        _updateStateWithDebounce(currentState.copyWith(
          dishes: [...currentState.dishes, dish],
        ));
      }
    } else {
      // Handle modern mode - convert the current order to legacy first
      final legacyItem = CateringOrderItem.legacy(
        title: currentState.name,
        img: '',
        description: currentState.notes,
        dishes: [dish],
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: 'salado',
        adicionales: '',
        peopleCount: 0,
        isQuote: false,
      );
      _updateStateWithDebounce(legacyItem);
    }
  }

  // Finalize order details
  void finalizeCateringOrder({
    required String title,
    required String img,
    required String description,
    required bool hasChef,
    required String alergias,
    required String eventType,
    required String preferencia,
    required String adicionales,
    required int cantidadPersonas,
    bool isQuote = false,
  }) {
    final currentState = state.valueOrNull;

    if (currentState != null && currentState.isLegacyItem) {
      // Update existing legacy order
      _updateStateWithDebounce(currentState.copyWith(
        title: title,
        img: img,
        description: description,
        hasChef: hasChef,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
        peopleCount: cantidadPersonas,
        isQuote: isQuote,
      ));
    } else {
      // Create a new legacy order
      _updateStateWithDebounce(CateringOrderItem.legacy(
        title: title,
        img: img,
        description: description,
        dishes: currentState?.dishes ?? [],
        hasChef: hasChef,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
        peopleCount: cantidadPersonas,
        isQuote: isQuote,
      ));
    }
  }

  // Update a specific dish by index
  void updateDish(int index, CateringDish updatedDish) {
    final currentState = state.valueOrNull;

    if (currentState != null &&
        currentState.isLegacyItem &&
        index >= 0 &&
        index < currentState.dishes.length) {
      final updatedDishes = List<CateringDish>.from(currentState.dishes);
      updatedDishes[index] = updatedDish; // Update dish at the specified index
      _updateStateWithDebounce(currentState.copyWith(
        dishes: updatedDishes,
      ));
    }
  }

  // Clear the active order
  void clearCateringOrder() {
    _updateStateWithDebounce(null);
  }

  // Remove a specific dish from the order by index
  void removeFromCart(int index) {
    final currentState = state.valueOrNull;

    if (currentState != null &&
        currentState.isLegacyItem &&
        index >= 0 &&
        index < currentState.dishes.length) {
      final updatedDishes = List<CateringDish>.from(currentState.dishes)
        ..removeAt(index); // Remove dish at the specified index
      _updateStateWithDebounce(currentState.copyWith(
        dishes: updatedDishes,
      ));
    }
  }

  // SECTION: Firestore Operations

  // Convert CateringOrderItem to CateringOrder for Firestore
  CateringOrder _convertToFirestoreOrder(CateringOrderItem item,
      {required String userId,
      required DateTime eventDate,
      String? customerName}) {
    return CateringOrder.fromLegacyItem(
      item,
      customerId: userId,
      customerName: customerName,
      eventDate: eventDate,
    );
  }

  // Submit current cart/order to Firestore
  Future<String?> submitCurrentOrder({
    required String userId,
    required DateTime eventDate,
    String? customerName,
  }) async {
    final currentState = state.valueOrNull;

    if (currentState == null ||
        !currentState.isLegacyItem ||
        currentState.dishes.isEmpty) {
      return null; // Nothing to submit
    }

    // Convert local state to Firestore model
    final order = _convertToFirestoreOrder(
      currentState,
      userId: userId,
      eventDate: eventDate,
      customerName: customerName,
    );

    // Save to Firestore
    final docRef = await _firestore
        .collection('cateringOrders')
        .add(order.toJson()..remove('id'));

    // Clear the cart after submission
    clearCateringOrder();

    return docRef.id;
  }

  // Get a specific order from Firestore with caching
  Future<CateringOrder?> getOrder(String id) async {
    try {
      final doc = await _firestore.collection('cateringOrders').doc(id).get(
          const cloud_firestore.GetOptions(
              source: cloud_firestore.Source.serverAndCache));

      if (!doc.exists) return null;

      return CateringOrder.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('Error getting order: $e');
      return null;
    }
  }

  // Stream a specific order
  Stream<CateringOrder> streamOrder(String orderId) {
    return _firestore
        .collection('cateringOrders')
        .doc(orderId)
        .snapshots()
        .map((doc) => CateringOrder.fromJson({
              'id': doc.id,
              ...doc.data()!,
            }));
  }

  // Get all catering orders (admin)
  Stream<List<CateringOrder>> getAllOrders() {
    return _firestore
        .collection('cateringOrders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  // Get orders for a specific user
  Stream<List<CateringOrder>> getUserOrders(String userId) {
    return _firestore
        .collection('cateringOrders')
        .where('customerId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  // Update an existing order
  Future<void> updateFirestoreOrder(CateringOrder order) async {
    await _firestore
        .collection('cateringOrders')
        .doc(order.id)
        .update(order.toJson()..remove('id'));
  }

  // Update order status
  Future<void> updateOrderStatus(String id, CateringOrderStatus status) async {
    await _firestore.collection('cateringOrders').doc(id).update({
      'status': status.name,
      'lastStatusUpdate': cloud_firestore.FieldValue.serverTimestamp(),
    });
  }

  // SECTION: Manual Quote

  // Load manual quote from SharedPreferences
  Future<CateringOrderItem?> loadManualQuote() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedQuote = prefs.getString(CateringCacheKeys.manualQuote);
    if (serializedQuote != null) {
      try {
        return CateringOrderItem.fromJson(jsonDecode(serializedQuote));
      } catch (e) {
        debugPrint('Error loading manual quote: $e');
        return null;
      }
    }
    return null;
  }

  // Save manual quote to SharedPreferences
  Future<void> saveManualQuote(CateringOrderItem? quote) async {
    final prefs = await SharedPreferences.getInstance();
    if (quote != null) {
      await prefs.setString(
          CateringCacheKeys.manualQuote, jsonEncode(quote.toJson()));
    } else {
      await prefs.remove(CateringCacheKeys.manualQuote);
    }
  }

  // Create a new empty quote
  Future<CateringOrderItem> createEmptyQuote() async {
    final quote = CateringOrderItem.legacy(
      title: 'Quote',
      img: '',
      description: '',
      dishes: [],
      hasChef: false,
      alergias: '',
      eventType: '',
      preferencia: '',
      adicionales: '',
      peopleCount: 0,
      isQuote: true,
    );

    await saveManualQuote(quote);
    return quote;
  }

  // Submit quote as order
  Future<String?> submitQuoteAsOrder({
    required String userId,
    String? userName,
    required DateTime eventDate,
  }) async {
    final quote = await loadManualQuote();

    if (quote == null || !quote.isLegacyItem || quote.dishes.isEmpty) {
      return null; // Nothing to submit
    }

    final order = CateringOrder.fromLegacyItem(
      quote,
      customerId: userId,
      customerName: userName,
      eventDate: eventDate,
      status: CateringOrderStatus.pending,
    );

    // Use Firebase to save the order
    final docRef = await _firestore
        .collection('cateringOrders')
        .add(order.toJson()..remove('id'));

    // Clear the quote after submission
    await saveManualQuote(null);

    return docRef.id;
  }
}

// SECTION: Notifier Providers

/// Provider for the selected category
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

/// Provider for the selected package
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

/// Provider for the selected item
@riverpod
class SelectedItem extends _$SelectedItem {
  @override
  CateringItem? build() => null;

  /// Sets the selected item
  void setSelectedItem(CateringItem? item) {
    state = item;
  }

  /// Clears the selected item
  void clearSelectedItem() {
    state = null;
  }
}

// SECTION: Convenience Providers

/// Provider for active categories
@riverpod
Stream<List<CateringCategory>> activeCategories(ActiveCategoriesRef ref) {
  final categoryRepo = ref.watch(cateringCategoryRepositoryProvider.notifier);
  return categoryRepo.getActiveCategories();
}

/// Provider for searching categories
@riverpod
Stream<List<CateringCategory>> searchCategories(
  SearchCategoriesRef ref,
  String searchTerm,
) {
  final categoryRepo = ref.watch(cateringCategoryRepositoryProvider.notifier);
  return categoryRepo.searchCategories(searchTerm);
}

/// Provider for active packages
@riverpod
Stream<List<CateringPackage>> activePackages(ActivePackagesRef ref) {
  final packageRepo = ref.watch(cateringPackageRepositoryProvider.notifier);
  return packageRepo.getActivePackages();
}

/// Provider for promoted packages
@riverpod
Stream<List<CateringPackage>> promotedPackages(PromotedPackagesRef ref) {
  final packageRepo = ref.watch(cateringPackageRepositoryProvider.notifier);
  return packageRepo.getPromotedPackages();
}

/// Provider for packages by category
@riverpod
Stream<List<CateringPackage>> packagesByCategory(
  PackagesByCategoryRef ref,
  String categoryId,
) {
  final packageRepo = ref.watch(cateringPackageRepositoryProvider.notifier);
  return packageRepo.getPackagesByCategory(categoryId);
}

/// Provider for searching packages
@riverpod
Stream<List<CateringPackage>> searchPackages(
  SearchPackagesRef ref,
  String searchTerm,
) {
  final packageRepo = ref.watch(cateringPackageRepositoryProvider.notifier);
  return packageRepo.searchPackages(searchTerm);
}

/// Provider for items by category
@riverpod
Stream<List<CateringItem>> itemsByCategory(
  ItemsByCategoryRef ref,
  String categoryId,
) {
  final itemRepo = ref.watch(cateringItemRepositoryProvider.notifier);
  return itemRepo.getItemsByCategory(categoryId);
}

/// Provider for highlighted items
@riverpod
Stream<List<CateringItem>> highlightedItems(HighlightedItemsRef ref) {
  final itemRepo = ref.watch(cateringItemRepositoryProvider.notifier);
  return itemRepo.getHighlightedItems();
}

/// Provider for item categories
@riverpod
List<CateringCategory> itemCategories(
  ItemCategoriesRef ref,
  CateringItem item,
) {
  final allCategories =
      ref.watch(cateringCategoryRepositoryProvider).valueOrNull ?? [];
  return allCategories
      .where((category) => item.categoryIds.contains(category.id))
      .toList();
}

/// Provider for package categories
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

// Legacy providers for backward compatibility

/// Legacy provider for the selected category
@Deprecated('Use selectedCategoryProvider instead')
final legacySelectedCategoryProvider = Provider<CateringCategory?>((ref) {
  return ref.watch(selectedCategoryProvider);
});

/// Legacy provider for the selected package
@Deprecated('Use selectedPackageProvider instead')
final legacySelectedPackageProvider = Provider<CateringPackage?>((ref) {
  return ref.watch(selectedPackageProvider);
});

/// Legacy provider for the catering category repository
@Deprecated('Use cateringCategoryRepositoryProvider instead')
final legacyCateringCategoryRepositoryProvider =
    Provider<CateringCategoryRepository>((ref) {
  return ref.watch(cateringCategoryRepositoryProvider.notifier);
});

/// Legacy provider for the catering item repository
@Deprecated('Use cateringItemRepositoryProvider instead')
final legacyCateringItemRepositoryProvider =
    Provider<CateringItemRepository>((ref) {
  return ref.watch(cateringItemRepositoryProvider.notifier);
});

/// Legacy provider for the catering package repository
@Deprecated('Use cateringPackageRepositoryProvider instead')
final legacyCateringPackageRepositoryProvider =
    Provider<CateringPackageRepository>((ref) {
  return ref.watch(cateringPackageRepositoryProvider.notifier);
});

/// Legacy provider for the catering order repository
@Deprecated('Use cateringOrderRepositoryProvider instead')
final legacyCateringOrderRepositoryProvider =
    Provider<CateringOrderRepository>((ref) {
  return ref.watch(cateringOrderRepositoryProvider.notifier);
});
