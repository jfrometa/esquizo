import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';

part 'cart_service.g.dart';

/// Unified Cart model that contains all cart-related functionality
class Cart {
  final List<CartItem> items;
  final String? specialInstructions;
  final String? resourceId;
  final bool isDelivery;
  final int peopleCount;
  final double deliveryFee;
  final double taxRate;
  final double serviceFee;
  final String businessId;
  final String? userId;

  const Cart({
    this.items = const [],
    this.specialInstructions,
    this.resourceId,
    this.isDelivery = false,
    this.peopleCount = 1,
    this.deliveryFee = 0.0,
    this.taxRate = 0.0775, // 7.75% default tax rate
    this.serviceFee = 0.0,
    required this.businessId,
    this.userId,
  });

  // ===== GETTERS =====

  /// Total number of items in the cart
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal of all items before taxes and fees
  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + (item.numericPrice * item.quantity));

  /// Tax amount based on the tax rate
  double get tax => subtotal * taxRate;

  /// Total including taxes and fees
  double get total =>
      subtotal + tax + (isDelivery ? deliveryFee : 0) + serviceFee;

  /// All meal plan items
  List<CartItem> get mealPlans =>
      items.where((item) => item.isMealSubscription).toList();

  /// All meal plan dish items
  List<CartItem> get mealPlanDishes =>
      items.where((item) => item.isMealPlanDish).toList();

  /// All catering items
  List<CartItem> get cateringItems =>
      items.where((item) => item.foodType == 'Catering').toList();

  /// All regular items (not meal plans or catering)
  List<CartItem> get regularItems => items
      .where((item) =>
          !item.isMealSubscription &&
          !item.isMealPlanDish &&
          item.foodType != 'Catering')
      .toList();

  // ===== METHODS =====

  /// Create a copy of the cart with updated fields
  Cart copyWith({
    List<CartItem>? items,
    String? specialInstructions,
    String? resourceId,
    bool? isDelivery,
    int? peopleCount,
    double? deliveryFee,
    double? taxRate,
    double? serviceFee,
    String? businessId,
    String? userId,
  }) {
    return Cart(
      items: items ?? this.items,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      resourceId: resourceId ?? this.resourceId,
      isDelivery: isDelivery ?? this.isDelivery,
      peopleCount: peopleCount ?? this.peopleCount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxRate: taxRate ?? this.taxRate,
      serviceFee: serviceFee ?? this.serviceFee,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
    );
  }

  /// Add an item to the cart, merging with existing identical items
  Cart addItem(CartItem item) {
    // Check if item already exists
    int existingIndex = items.indexWhere((i) =>
        i.id == item.id &&
        i.isMealSubscription == item.isMealSubscription &&
        i.isMealPlanDish == item.isMealPlanDish &&
        i.foodType == item.foodType);

    if (existingIndex >= 0) {
      // Update quantity of existing item
      List<CartItem> updatedItems = List.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
      return copyWith(items: updatedItems);
    } else {
      // Add new item
      return copyWith(items: [...items, item]);
    }
  }

  /// Remove an item at the specified index
  Cart removeItem(int index) {
    if (index < 0 || index >= items.length) return this;
    List<CartItem> updatedItems = List.from(items);
    updatedItems.removeAt(index);
    return copyWith(items: updatedItems);
  }

  /// Remove item by ID
  Cart removeItemById(String id) {
    return copyWith(
      items: items.where((item) => item.id != id).toList(),
    );
  }

  /// Update quantity of an item at specific index
  Cart updateItemQuantity(int index, int quantity) {
    if (index < 0 || index >= items.length) return this;
    if (quantity <= 0) return removeItem(index);

    List<CartItem> updatedItems = List.from(items);
    updatedItems[index] = updatedItems[index].copyWith(quantity: quantity);
    return copyWith(items: updatedItems);
  }

  /// Increment quantity of a catering item
  Cart incrementCateringQuantity(String title) {
    List<CartItem> updatedItems = items.map((item) {
      if (item.title == title && item.foodType == 'Catering') {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems);
  }

  /// Decrement quantity of a catering item
  Cart decrementCateringQuantity(String title) {
    List<CartItem> updatedItems = [];

    for (final item in items) {
      if (item.title == title && item.foodType == 'Catering') {
        if (item.quantity > 1) {
          updatedItems.add(item.copyWith(quantity: item.quantity - 1));
        }
        // If quantity would be 0, don't add it back
      } else {
        updatedItems.add(item);
      }
    }

    return copyWith(items: updatedItems);
  }

  /// Increment quantity of a regular dish
  Cart incrementQuantity(String title) {
    List<CartItem> updatedItems = items.map((item) {
      if (item.title == title &&
          !item.isMealSubscription &&
          item.foodType != 'Catering') {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems);
  }

  /// Decrement quantity of a regular dish
  Cart decrementQuantity(String title) {
    List<CartItem> updatedItems = [];

    for (final item in items) {
      if (item.title == title && !item.isMealSubscription) {
        if (item.quantity > 1) {
          updatedItems.add(item.copyWith(quantity: item.quantity - 1));
        }
        // If quantity would be 0, don't add it back
      } else {
        updatedItems.add(item);
      }
    }

    return copyWith(items: updatedItems);
  }

  /// Add a new item to the cart with flexible options
  Cart addToCart(
    Map<String, dynamic> item,
    int quantity, {
    bool isMealSubscription = false,
    int totalMeals = 0,
    bool isCatering = false,
    int peopleCount = 0,
    String? sideRequest,
    Map<String, dynamic> options = const {},
    String? notes,
  }) {
    if (isCatering) {
      // Handle Catering
      final existingIndex = items.indexWhere(
        (cartItem) =>
            cartItem.title == item['title'] && cartItem.foodType == 'Catering',
      );

      if (existingIndex >= 0) {
        // Update existing catering order
        List<CartItem> updatedItems = List.from(items);
        updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
          quantity: updatedItems[existingIndex].quantity + quantity,
          peopleCount: peopleCount,
          sideRequest: sideRequest,
        );
        return copyWith(items: updatedItems);
      } else {
        // Create new catering item
        final newItem = CartItem(
          id: item['id'] ?? 'no id',
          img: item['img'],
          title: item['title'],
          description: item['description'],
          pricing: item['pricing'],
          ingredients: List<String>.from(item['ingredients']),
          isSpicy: false,
          foodType: 'Catering',
          quantity: quantity,
          peopleCount: peopleCount,
          sideRequest: sideRequest ?? '',
          hasChef: item['hasChef'] ?? false,
          alergias: item['alergias'] ?? '',
          eventType: item['eventType'] ?? '',
          preferencia: item['preferencia'] ?? 'salado',
          isOffer: false,
          options: options,
          notes: notes,
        );
        return copyWith(items: [...items, newItem]);
      }
    } else if (isMealSubscription) {
      // Handle Meal Subscriptions
      final existingPlanIndex = items.indexWhere(
        (cartItem) =>
            cartItem.title == item['title'] && cartItem.isMealSubscription,
      );

      if (existingPlanIndex != -1) {
        // Existing plan found, don't allow duplicates
        return this;
      } else {
        // No existing plan, add new meal subscription to cart
        final newPlan = CartItem(
          id: item['id'] ?? 'no id',
          img: item['img'] ?? '',
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          pricing: item['pricing'] ?? '',
          offertPricing: item['offertPricing'] ?? '',
          ingredients: List<String>.from(item['ingredients'] ?? []),
          isSpicy: item['isSpicy'] ?? false,
          foodType: item['foodType'] ?? 'Subscripcion',
          quantity: 1,
          hasChef: item['hasChef'],
          isOffer: item.containsKey('offertPricing') &&
              item['offertPricing'] != null,
          isMealSubscription: true,
          totalMeals: totalMeals,
          remainingMeals: totalMeals,
          peopleCount: item['peopleCount'] ?? 1,
          options: options,
          notes: notes,
        );
        return copyWith(items: [...items, newPlan]);
      }
    } else {
      // Handle Regular Dish
      final existingIndex = items.indexWhere(
        (cartItem) =>
            cartItem.title == item['title'] && !cartItem.isMealSubscription,
      );

      if (existingIndex >= 0) {
        // Update existing dish
        List<CartItem> updatedItems = List.from(items);
        updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
          quantity: updatedItems[existingIndex].quantity + quantity,
        );
        return copyWith(items: updatedItems);
      } else {
        // Add new regular dish
        try {
          final newDish = CartItem(
            id: item['id'] ?? 'no id',
            img: item['img'],
            title: item['title'],
            description: item['description'],
            pricing: item['pricing'].toString(),
            offertPricing: item['offertPricing'] ?? '',
            ingredients: List<String>.from(item['ingredients'] ?? []),
            isSpicy: item['isSpicy'] ?? false,
            foodType: item['foodType'] ?? '',
            hasChef: item['hasChef'] ?? false,
            quantity: quantity,
            isOffer: item.containsKey('offertPricing') &&
                item['offertPricing'] != null,
            options: options,
            notes: notes,
          );
          return copyWith(items: [...items, newDish]);
        } catch (e) {
          debugPrint('Error adding item to cart: $e');
          // Return the cart unchanged if there was an error
          return this;
        }
      }
    }
  }

  /// Add a meal plan dish to cart
  Cart addMealPlanDishToCart(Map<String, dynamic> item, int quantity) {
    final existingIndex = items.indexWhere(
      (cartItem) => cartItem.title == item['title'] && cartItem.isMealPlanDish,
    );

    if (existingIndex >= 0) {
      // Update existing dish
      List<CartItem> updatedItems = List.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      return copyWith(items: updatedItems);
    } else {
      // Add new meal plan dish
      final newDish = CartItem(
        id: item['id'] ?? 'no id',
        img: item['img'],
        title: item['title'],
        description: item['description'],
        pricing: item['pricing'],
        offertPricing: item['offertPricing'],
        ingredients: List<String>.from(item['ingredients']),
        isSpicy: item['isSpicy'],
        foodType: item['foodType'],
        quantity: quantity,
        isOffer:
            item.containsKey('offertPricing') && item['offertPricing'] != null,
        isMealPlanDish: true,
      );
      return copyWith(items: [...items, newDish]);
    }
  }

  /// Consume a meal from a meal plan
  Cart consumeMeal(String title) {
    final currentDateTime = DateTime.now();
    List<CartItem> updatedItems = items.map((item) {
      if (item.title == title &&
          item.isMealSubscription &&
          currentDateTime.isBefore(item.expirationDate) &&
          item.remainingMeals > 0) {
        return item.copyWith(remainingMeals: item.remainingMeals - 1);
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems);
  }

  /// Update meal plan when a meal is consumed
  Cart updateMealPlan(
      String mealPlanTitle, CartItem dish, String regularAddress) {
    final currentDateTime = DateTime.now();

    // First, update the meal plan's remaining meals
    List<CartItem> updatedItems = items.map((item) {
      if (item.title == mealPlanTitle &&
          item.isMealSubscription &&
          item.remainingMeals > 0 &&
          currentDateTime.isBefore(item.expirationDate)) {
        return item.copyWith(remainingMeals: item.remainingMeals - 1);
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems);
  }

  /// Confirm meal plan consumption with multiple dishes
  Cart confirmMealPlanConsumption(
      String mealPlanId, List<String> dishIds, String address) {
    // Find the meal plan
    final mealPlanIndex = items.indexWhere(
      (item) => item.id == mealPlanId && item.isMealSubscription,
    );

    if (mealPlanIndex < 0) {
      throw Exception('Meal plan not found');
    }

    // Find all the dishes
    List<CartItem> dishesToConsume = [];
    for (final dishId in dishIds) {
      final dish = items.firstWhere(
        (item) => item.id == dishId && item.isMealPlanDish,
        orElse: () => throw Exception('Dish not found: $dishId'),
      );
      dishesToConsume.add(dish);
    }

    // Calculate total dishes to consume
    int totalDishes =
        dishesToConsume.fold(0, (sum, item) => sum + item.quantity);

    // Check if enough meals remaining
    if (items[mealPlanIndex].remainingMeals < totalDishes) {
      throw Exception('Not enough meals remaining in the meal plan');
    }

    // Update the meal plan's remaining meals
    List<CartItem> updatedItems = List.from(items);
    updatedItems[mealPlanIndex] = updatedItems[mealPlanIndex].copyWith(
      remainingMeals: updatedItems[mealPlanIndex].remainingMeals - totalDishes,
    );

    // Remove consumed dishes from cart
    updatedItems = updatedItems
        .where((item) => !dishIds.contains(item.id) || !item.isMealPlanDish)
        .toList();

    return copyWith(items: updatedItems);
  }

  /// Remove expired meal plans
  Cart removeExpiredPlans() {
    final currentDateTime = DateTime.now();
    return copyWith(
      items: items
          .where((item) =>
              !item.isMealSubscription ||
              currentDateTime.isBefore(item.expirationDate))
          .toList(),
    );
  }

  /// Update special instructions
  Cart updateSpecialInstructions(String? instructions) {
    return copyWith(specialInstructions: instructions);
  }

  /// Update resource ID
  Cart updateResourceId(String? resourceId) {
    return copyWith(resourceId: resourceId);
  }

  /// Update delivery option
  Cart updateDeliveryOption(bool isDelivery) {
    return copyWith(isDelivery: isDelivery);
  }

  /// Update people count
  Cart updatePeopleCount(int count) {
    return copyWith(peopleCount: count);
  }

  /// Clear all items from the cart
  Cart clear() {
    return copyWith(items: []);
  }

  // ===== SERIALIZATION =====

  /// Convert cart to JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'specialInstructions': specialInstructions,
      'resourceId': resourceId,
      'isDelivery': isDelivery,
      'peopleCount': peopleCount,
      'deliveryFee': deliveryFee,
      'taxRate': taxRate,
      'serviceFee': serviceFee,
      'businessId': businessId,
      'userId': userId,
    };
  }

  /// Create cart from JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Cart(
      items: itemsList,
      specialInstructions: json['specialInstructions'] as String?,
      resourceId: json['resourceId'] as String?,
      isDelivery: json['isDelivery'] as bool? ?? false,
      peopleCount: json['peopleCount'] as int? ?? 1,
      deliveryFee: json['deliveryFee'] as double? ?? 0.0,
      taxRate: json['taxRate'] as double? ?? 0.0775,
      serviceFee: json['serviceFee'] as double? ?? 0.0,
      businessId: json['businessId'] as String? ?? 'default',
      userId: json['userId'] as String?,
    );
  }

  /// Convert cart to JSON string
  static String serialize(Cart cart) {
    return jsonEncode(cart.toJson());
  }

  /// Create cart from JSON string
  static Cart deserialize(String jsonString) {
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return Cart.fromJson(jsonData);
  }
}

/// Unified service to manage the cart state and persistence
class CartService {
  Cart _cart;
  Timer? _saveDebounce;

  /// Constructor that supports both direct parameters and Ref-based initialization
  CartService({
    required String businessId,
    String? userId,
  }) : _cart = Cart(businessId: businessId, userId: userId);

  /// Get current cart state
  Cart get cart => _cart;

  // ===== PERSISTENCE METHODS =====

  /// Load cart from SharedPreferences
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? serializedCart = prefs.getString('cart');
      if (serializedCart != null && serializedCart.isNotEmpty) {
        try {
          _cart = Cart.deserialize(serializedCart);
        } catch (e) {
          debugPrint('Error deserializing cart: $e');
          _cart = Cart(
              businessId: _cart.businessId,
              userId: _cart
                  .userId); // Initialize empty cart on deserialization error
        }
      } else {
        _cart = Cart(
            businessId: _cart.businessId,
            userId: _cart.userId); // Initialize empty cart if no data
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
      _cart = Cart(
          businessId: _cart.businessId,
          userId: _cart.userId); // Initialize empty cart on any error
    }
  }

  /// Save cart to SharedPreferences with debounce
  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String serializedCart = Cart.serialize(_cart);
      await prefs.setString('cart', serializedCart);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  /// Save cart with debounce to prevent excessive writes
  void _debounceSaveCart() {
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), saveCart);
  }

  // ===== CART OPERATIONS =====

  /// Update the cart's user ID
  void updateUserId(String? userId) {
    _cart = _cart.copyWith(userId: userId);
    _debounceSaveCart();
  }

  /// Update the cart's business ID
  void updateBusinessId(String businessId) {
    _cart = _cart.copyWith(businessId: businessId);
    _debounceSaveCart();
  }

  /// Add an item to the cart
  void addItem(CartItem item) {
    _cart = _cart.addItem(item);
    _debounceSaveCart();
  }

  /// Add to cart with flexible options
  void addToCart(
    Map<String, dynamic> item,
    int quantity, {
    bool isMealSubscription = false,
    int totalMeals = 0,
    bool isCatering = false,
    int peopleCount = 0,
    String? sideRequest,
    Map<String, dynamic> options = const {},
    String? notes,
  }) {
    _cart = _cart.addToCart(
      item,
      quantity,
      isMealSubscription: isMealSubscription,
      totalMeals: totalMeals,
      isCatering: isCatering,
      peopleCount: peopleCount,
      sideRequest: sideRequest,
      options: options,
      notes: notes,
    );
    _debounceSaveCart();
  }

  /// Remove an item at specific index
  void removeItem(int index) {
    _cart = _cart.removeItem(index);
    _debounceSaveCart();
  }

  /// Remove item by ID
  void removeItemById(String id) {
    _cart = _cart.removeItemById(id);
    _debounceSaveCart();
  }

  /// Update quantity of an item at specific index
  void updateItemQuantity(int index, int quantity) {
    _cart = _cart.updateItemQuantity(index, quantity);
    _debounceSaveCart();
  }

  /// Increment quantity of a catering item
  void incrementCateringQuantity(String title) {
    _cart = _cart.incrementCateringQuantity(title);
    _debounceSaveCart();
  }

  /// Decrement quantity of a catering item
  void decrementCateringQuantity(String title) {
    _cart = _cart.decrementCateringQuantity(title);
    _debounceSaveCart();
  }

  /// Increment quantity of a regular dish
  void incrementQuantity(String title) {
    _cart = _cart.incrementQuantity(title);
    _debounceSaveCart();
  }

  /// Decrement quantity of a regular dish
  void decrementQuantity(String title) {
    _cart = _cart.decrementQuantity(title);
    _debounceSaveCart();
  }

  /// Add a meal plan dish to cart
  void addMealPlanDishToCart(Map<String, dynamic> item, int quantity) {
    _cart = _cart.addMealPlanDishToCart(item, quantity);
    _debounceSaveCart();
  }

  /// Consume a meal from a meal plan
  void consumeMeal(String title) {
    _cart = _cart.consumeMeal(title);
    _debounceSaveCart();
  }

  /// Record meal consumption to Firebase
  Future<void> recordMealToFirebase(
      CartItem mealPlan, CartItem dish, String regularAddress) async {
    final userId = _cart.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final firestore = FirebaseFirestore.instance;
    final consumptionRecord = {
      'title': dish.title,
      'description': dish.description,
      'pricing': dish.pricing,
      'address': {
        'dishLocation': regularAddress,
      },
      'remainingMeals': mealPlan.remainingMeals,
      'consumedAt': FieldValue.serverTimestamp(),
      'ingredients': dish.ingredients,
      'isSpicy': dish.isSpicy,
      'quantity': dish.quantity,
      'peopleCount': dish.peopleCount,
      'sideRequest': dish.sideRequest,
      'options': dish.options,
      'notes': dish.notes,
      'businessId': _cart.businessId,
    };

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('mealPlans')
          .doc(mealPlan.id)
          .collection('consumptions')
          .add(consumptionRecord);
    } catch (e) {
      debugPrint('Failed to record meal consumption to Firebase: $e');
    }
  }

  /// Update meal plan when a meal is consumed
  Future<void> updateMealPlan(
      String mealPlanTitle, CartItem dish, String regularAddress) async {
    _cart = _cart.updateMealPlan(mealPlanTitle, dish, regularAddress);
    _debounceSaveCart();

    // Get the updated meal plan for Firebase recording
    final mealPlan = _cart.items.firstWhere(
      (item) => item.title == mealPlanTitle && item.isMealSubscription,
      orElse: () => throw Exception('Meal plan not found'),
    );

    // Record the meal consumption to Firebase
    await recordMealToFirebase(mealPlan, dish, regularAddress);
  }

  /// Confirm meal plan consumption with multiple dishes
  Future<void> confirmMealPlanConsumption(
      String mealPlanId, List<String> dishIds, String address) async {
    final mealPlan = _cart.items.firstWhere(
      (item) => item.id == mealPlanId && item.isMealSubscription,
      orElse: () => throw Exception('Meal plan not found'),
    );

    final dishes = dishIds
        .map((id) => _cart.items.firstWhere(
              (item) => item.id == id && item.isMealPlanDish,
              orElse: () => throw Exception('Dish not found: $id'),
            ))
        .toList();

    // Update the cart
    _cart = _cart.confirmMealPlanConsumption(mealPlanId, dishIds, address);
    _debounceSaveCart();

    // Record each consumption to Firebase
    for (final dish in dishes) {
      await recordMealToFirebase(mealPlan, dish, address);
    }
  }

  /// Remove expired meal plans
  void removeExpiredPlans() {
    _cart = _cart.removeExpiredPlans();
    _debounceSaveCart();
  }

  /// Clear the cart
  void clearCart() {
    _cart = _cart.clear();
    _debounceSaveCart();
  }

  /// Update special instructions
  void updateSpecialInstructions(String? instructions) {
    _cart = _cart.updateSpecialInstructions(instructions);
    _debounceSaveCart();
  }

  /// Update resource ID
  void updateResourceId(String? resourceId) {
    _cart = _cart.updateResourceId(resourceId);
    _debounceSaveCart();
  }

  /// Update delivery option
  void updateDeliveryOption(bool isDelivery) {
    _cart = _cart.updateDeliveryOption(isDelivery);
    _debounceSaveCart();
  }

  /// Update people count
  void updatePeopleCount(int count) {
    _cart = _cart.updatePeopleCount(count);
    _debounceSaveCart();
  }
}

// ===== RIVERPOD PROVIDERS =====

/// Provider for cart service
@riverpod
CartService cartService(Ref ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  final userId = ref.watch(currentUserIdProvider);

  final cartService = CartService(
    businessId: businessId,
    userId: userId,
  );

  // Load the cart from local storage
  cartService.loadCart();

  return cartService;
}

/// Notifier for cart state
@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  late CartService _cartService;

  @override
  Cart build() {
    _cartService = ref.watch(cartServiceProvider);
    return _cartService.cart;
  }

  void _updateStateFromService() {
    state = _cartService.cart;
  }

  // Delegate all operations to the cart service

  void addItem(CartItem item) {
    _cartService.addItem(item);
    _updateStateFromService();
  }

  void addToCart(
    Map<String, dynamic> item,
    int quantity, {
    bool isMealSubscription = false,
    int totalMeals = 0,
    bool isCatering = false,
    int peopleCount = 0,
    String? sideRequest,
    Map<String, dynamic> options = const {},
    String? notes,
  }) {
    _cartService.addToCart(
      item,
      quantity,
      isMealSubscription: isMealSubscription,
      totalMeals: totalMeals,
      isCatering: isCatering,
      peopleCount: peopleCount,
      sideRequest: sideRequest,
      options: options,
      notes: notes,
    );
    _updateStateFromService();
  }

  void removeItem(int index) {
    _cartService.removeItem(index);
    _updateStateFromService();
  }

  void removeItemById(String id) {
    _cartService.removeItemById(id);
    _updateStateFromService();
  }

  void updateItemQuantity(int index, int quantity) {
    _cartService.updateItemQuantity(index, quantity);
    _updateStateFromService();
  }

  void incrementCateringQuantity(String title) {
    _cartService.incrementCateringQuantity(title);
    _updateStateFromService();
  }

  void decrementCateringQuantity(String title) {
    _cartService.decrementCateringQuantity(title);
    _updateStateFromService();
  }

  void incrementQuantity(String title) {
    _cartService.incrementQuantity(title);
    _updateStateFromService();
  }

  void decrementQuantity(String title) {
    _cartService.decrementQuantity(title);
    _updateStateFromService();
  }

  void addMealPlanDishToCart(Map<String, dynamic> item, int quantity) {
    _cartService.addMealPlanDishToCart(item, quantity);
    _updateStateFromService();
  }

  void consumeMeal(String title) {
    _cartService.consumeMeal(title);
    _updateStateFromService();
  }

  Future<void> updateMealPlan(
      String mealPlanTitle, CartItem dish, String regularAddress) async {
    await _cartService.updateMealPlan(mealPlanTitle, dish, regularAddress);
    _updateStateFromService();
  }

  Future<void> confirmMealPlanConsumption(
      String mealPlanId, List<String> dishIds, String address) async {
    await _cartService.confirmMealPlanConsumption(mealPlanId, dishIds, address);
    _updateStateFromService();
  }

  void removeExpiredPlans() {
    _cartService.removeExpiredPlans();
    _updateStateFromService();
  }

  void clearCart() {
    _cartService.clearCart();
    _updateStateFromService();
  }

  void updateSpecialInstructions(String? instructions) {
    _cartService.updateSpecialInstructions(instructions);
    _updateStateFromService();
  }

  void updateResourceId(String? resourceId) {
    _cartService.updateResourceId(resourceId);
    _updateStateFromService();
  }

  void updateDeliveryOption(bool isDelivery) {
    _cartService.updateDeliveryOption(isDelivery);
    _updateStateFromService();
  }

  void updatePeopleCount(int count) {
    _cartService.updatePeopleCount(count);
    _updateStateFromService();
  }
}

/// Helper providers for accessing cart properties

/// Provider for cart item count
@riverpod
int cartItemCount(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.itemCount;
}

/// Provider for cart subtotal
@riverpod
double cartSubtotal(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.subtotal;
}

/// Provider for cart total
@riverpod
double cartTotal(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.total;
}

/// Provider for meal plans in cart
@riverpod
List<CartItem> cartMealPlans(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.mealPlans;
}

/// Provider for catering items in cart
@riverpod
List<CartItem> cartCateringItems(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.cateringItems;
}

/// Provider for regular items in cart
@riverpod
List<CartItem> cartRegularItems(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.regularItems;
}

/// Provider for meal plan dishes in cart
@riverpod
List<CartItem> cartMealPlanDishes(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.mealPlanDishes;
}

final cartProvider = cartNotifierProvider;
