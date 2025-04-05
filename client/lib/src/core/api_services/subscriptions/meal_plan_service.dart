import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';
 

// Service for handling Meal Plan CRUD operations
class MealPlanService {
  final FirebaseFirestore _firestore;
  final String businessId;

  MealPlanService(this._firestore, this.businessId);

  // Collection references
  CollectionReference get _mealPlansRef => 
      _firestore.collection('businesses/$businessId/mealPlans');
  
  CollectionReference get _categoriesRef => 
      _firestore.collection('businesses/$businessId/mealPlanCategories');
  
  CollectionReference get _consumedItemsRef => 
      _firestore.collection('businesses/$businessId/consumedItems');
  
  CollectionReference get _mealPlanItemsRef => 
      _firestore.collection('businesses/$businessId/mealPlanItems');

  // MEAL PLANS CRUD
  Stream<List<MealPlan>> getAllMealPlansStream() {
    return _mealPlansRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MealPlan.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  Stream<List<MealPlan>> getMealPlansByCategoryStream(String categoryId) {
    return _mealPlansRef
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MealPlan.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  Stream<List<MealPlan>> getActiveMealPlansStream() {
    return _mealPlansRef
        .where('isAvailable', isEqualTo: true)
        .where('status', isEqualTo: MealPlanStatus.active.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MealPlan.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  Stream<MealPlan?> getMealPlanByIdStream(String id) {
    return _mealPlansRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MealPlan.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    });
  }

  Future<MealPlan?> getMealPlanById(String id) async {
    final doc = await _mealPlansRef.doc(id).get();
    if (!doc.exists) return null;
    return MealPlan.fromMap({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Future<List<MealPlan>> getMealPlansByOwner(String ownerId) async {
    final snapshot = await _mealPlansRef
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      return MealPlan.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
  }

  Future<String> createMealPlan(MealPlan mealPlan) async {
    final data = mealPlan.toMap();
    final docRef = await _mealPlansRef.add(data);
    return docRef.id;
  }

  Future<void> updateMealPlan(MealPlan mealPlan) async {
    final data = mealPlan.toMap();
    // Update the updatedAt timestamp
    data['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    await _mealPlansRef.doc(mealPlan.id).update(data);
  }

  Future<void> deleteMealPlan(String id) async {
    // First check if there are consumed items
    final snapshot = await _consumedItemsRef
        .where('mealPlanId', isEqualTo: id)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      // Cannot delete meal plan with consumed items
      throw Exception('Cannot delete meal plan with consumed items');
    }
    
    await _mealPlansRef.doc(id).delete();
  }

  Future<void> toggleMealPlanAvailability(String id, bool isAvailable) async {
    await _mealPlansRef.doc(id).update({
      'isAvailable': isAvailable,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateMealPlanStatus(String id, MealPlanStatus status) async {
    await _mealPlansRef.doc(id).update({
      'status': status.name,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // CATEGORIES CRUD
  Stream<List<MealPlanCategory>> getCategoriesStream() {
    return _categoriesRef
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MealPlanCategory.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  Future<List<MealPlanCategory>> getCategories() async {
    final snapshot = await _categoriesRef.orderBy('sortOrder').get();
    return snapshot.docs.map((doc) {
      return MealPlanCategory.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
  }

  Future<String> createCategory(MealPlanCategory category) async {
    final data = category.toMap();
    final docRef = await _categoriesRef.add(data);
    return docRef.id;
  }

  Future<void> updateCategory(MealPlanCategory category) async {
    await _categoriesRef.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    // Check if category has meal plans
    final plansSnapshot = await _mealPlansRef
        .where('categoryId', isEqualTo: id)
        .limit(1)
        .get();
    
    if (plansSnapshot.docs.isNotEmpty) {
      throw Exception('Cannot delete category with meal plans');
    }
    
    await _categoriesRef.doc(id).delete();
  }

  Future<void> toggleCategoryActive(String id, bool isActive) async {
    await _categoriesRef.doc(id).update({'isActive': isActive});
  }

  // CONSUMED ITEMS
  Future<List<ConsumedItem>> getConsumedItems(String mealPlanId) async {
    final snapshot = await _consumedItemsRef
        .where('mealPlanId', isEqualTo: mealPlanId)
        .orderBy('consumedAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      return ConsumedItem.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
  }

  Stream<List<ConsumedItem>> getConsumedItemsStream(String mealPlanId) {
    return _consumedItemsRef
        .where('mealPlanId', isEqualTo: mealPlanId)
        .orderBy('consumedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConsumedItem.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  Future<String> addConsumedItem(ConsumedItem item) async {
    final data = item.toMap();
    final docRef = await _consumedItemsRef.add(data);
    
    // Update meal plan's remaining meals count
    final mealPlan = await getMealPlanById(item.mealPlanId);
    if (mealPlan != null) {
      await _mealPlansRef.doc(item.mealPlanId).update({
        'mealsRemaining': mealPlan.mealsRemaining - 1,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
    
    return docRef.id;
  }

  Future<void> deleteConsumedItem(String id, String mealPlanId) async {
    await _consumedItemsRef.doc(id).delete();
    
    // Update meal plan's remaining meals count
    final mealPlan = await getMealPlanById(mealPlanId);
    if (mealPlan != null) {
      await _mealPlansRef.doc(mealPlanId).update({
        'mealsRemaining': mealPlan.mealsRemaining + 1,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // MEAL PLAN ITEMS
  Future<List<MealPlanItem>> getMealPlanItems() async {
    final snapshot = await _mealPlanItemsRef
        .where('isAvailable', isEqualTo: true)
        .orderBy('name')
        .get();
    
    return snapshot.docs.map((doc) {
      return MealPlanItem.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
  }

  Stream<List<MealPlanItem>> getMealPlanItemsStream() {
    return _mealPlanItemsRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MealPlanItem.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  Future<String> createMealPlanItem(MealPlanItem item) async {
    final data = item.toMap();
    final docRef = await _mealPlanItemsRef.add(data);
    return docRef.id;
  }

  Future<void> updateMealPlanItem(MealPlanItem item) async {
    await _mealPlanItemsRef.doc(item.id).update(item.toMap());
  }

  Future<void> deleteMealPlanItem(String id) async {
    // Check if item is used in any meal plan
    final plansSnapshot = await _mealPlansRef
        .where('allowedItemIds', arrayContains: id)
        .limit(1)
        .get();
    
    if (plansSnapshot.docs.isNotEmpty) {
      throw Exception('Cannot delete item that is used in meal plans');
    }
    
    await _mealPlanItemsRef.doc(id).delete();
  }

  Future<void> toggleMealPlanItemAvailability(String id, bool isAvailable) async {
    await _mealPlanItemsRef.doc(id).update({'isAvailable': isAvailable});
  }
}

// Provider for MealPlanService
final mealPlanServiceProvider = Provider<MealPlanService>((ref) {
  final firestore = FirebaseFirestore.instance;
  // Normally you would get this from your authentication or config
  final businessId = ref.watch(currentBusinessIdProvider);
  return MealPlanService(firestore, businessId);
});

// Current business ID provider (this would normally come from your auth system)
// final currentBusinessIdProvider = StateProvider<String>((ref) => 'default_business');

// Providers for accessing meal plans
final mealPlansProvider = StreamProvider<List<MealPlan>>((ref) {
  final mealPlanService = ref.watch(mealPlanServiceProvider);
  return mealPlanService.getAllMealPlansStream();
});

final customerMealPlansProvider = StreamProvider<List<MealPlan>>((ref) {
  final service = ref.watch(mealPlanServiceProvider);
  final customerId = ref.watch(currentUserIdProvider) ?? 'no ide';
  return service.getMealPlansByOwner(customerId).asStream();
});

final activeMealPlansProvider = StreamProvider<List<MealPlan>>((ref) {
  final mealPlanService = ref.watch(mealPlanServiceProvider);
  return mealPlanService.getActiveMealPlansStream();
});

final mealPlansByCategoryProvider = StreamProvider.family<List<MealPlan>, String>((ref, categoryId) {
  final mealPlanService = ref.watch(mealPlanServiceProvider);
  return mealPlanService.getMealPlansByCategoryStream(categoryId);
});

final mealPlanProvider = StreamProvider.family<MealPlan?, String>((ref, id) {
  final mealPlanService = ref.watch(mealPlanServiceProvider);
  return mealPlanService.getMealPlanByIdStream(id);
});

// Categories provider
final mealPlanCategoriesProvider = StreamProvider<List<MealPlanCategory>>((ref) {
  final mealPlanService = ref.watch(mealPlanServiceProvider);
  return mealPlanService.getCategoriesStream();
});

// Consumed items provider
final consumedItemsProvider = StreamProvider.family<List<ConsumedItem>, String>((ref, mealPlanId) {
  final mealPlanService = ref.watch(mealPlanServiceProvider);
  return mealPlanService.getConsumedItemsStream(mealPlanId);
});

// Meal plan items provider
final mealPlanItemsProvider = StreamProvider<List<MealPlanItem>>((ref) {
  final mealPlanService = ref.watch(mealPlanServiceProvider);
  return mealPlanService.getMealPlanItemsStream();
});