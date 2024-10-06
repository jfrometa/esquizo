import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Cart Item Model
// Cart Item Model
class CartItem {
  final String id; // Added id field
  final String img;
  final String title;
  final String description;
  final String pricing;
  final String? offertPricing;
  final List<String> ingredients;
  final bool isSpicy;
  final String foodType;
  final int quantity;
  final bool isOffer;

  // Additional fields for meal subscription
  final bool isMealSubscription;
  final int totalMeals;
  final int remainingMeals;
  final DateTime expirationDate;

  // Additional fields for catering
  final int peopleCount;
  final String sideRequest;

  CartItem({
    required this.id, // Include id in constructor
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    this.offertPricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
    required this.quantity,
    required this.isOffer,
    this.isMealSubscription = false,
    this.totalMeals = 0,
    this.remainingMeals = 0,
    DateTime? expirationDate,
    this.peopleCount = 0,
    this.sideRequest = '',
  }) : expirationDate =
            expirationDate ?? DateTime.now().add(const Duration(days: 40));

  CartItem copyWith({
    String? id,
    int? quantity,
    int? remainingMeals,
    int? peopleCount,
    String? sideRequest,
  }) {
    return CartItem(
      id: id ?? this.id,
      img: img,
      title: title,
      description: description,
      pricing: pricing,
      offertPricing: offertPricing,
      ingredients: ingredients,
      isSpicy: isSpicy,
      foodType: foodType,
      quantity: quantity ?? this.quantity,
      isOffer: isOffer,
      isMealSubscription: isMealSubscription,
      totalMeals: totalMeals,
      remainingMeals: remainingMeals ?? this.remainingMeals,
      expirationDate: expirationDate,
      peopleCount: peopleCount ?? this.peopleCount,
      sideRequest: sideRequest ?? this.sideRequest,
    );
  }

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'img': img,
      'title': title,
      'description': description,
      'pricing': pricing,
      'offertPricing': offertPricing,
      'ingredients': ingredients,
      'isSpicy': isSpicy,
      'foodType': foodType,
      'quantity': quantity,
      'isOffer': isOffer,
      'isMealSubscription': isMealSubscription,
      'totalMeals': totalMeals,
      'remainingMeals': remainingMeals,
      'expirationDate': expirationDate.toIso8601String(),
      'peopleCount': peopleCount,
      'sideRequest': sideRequest,
    };
  }

  // fromJson factory constructor for deserialization
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      img: json['img'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pricing: json['pricing'] as String,
      offertPricing: json['offertPricing'] as String?,
      ingredients: List<String>.from(json['ingredients'] as List<dynamic>),
      isSpicy: json['isSpicy'] as bool,
      foodType: json['foodType'] as String,
      quantity: json['quantity'] as int,
      isOffer: json['isOffer'] as bool,
      isMealSubscription: json['isMealSubscription'] as bool,
      totalMeals: json['totalMeals'] as int,
      remainingMeals: json['remainingMeals'] as int,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      peopleCount: json['peopleCount'] as int,
      sideRequest: json['sideRequest'] as String,
    );
  }
}

// Serialization and Deserialization functions
String serializeCart(List<CartItem> cartItems) {
  return jsonEncode(cartItems.map((item) => item.toJson()).toList());
}

List<CartItem> deserializeCart(String jsonString) {
  List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.map((item) => CartItem.fromJson(item)).toList();
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  Timer? _saveDebounce;

  CartNotifier() : super([]) {
    _loadCart();
  }

  // Load cart from SharedPreferences
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedCart = prefs.getString('cart');
    if (serializedCart != null) {
      state = deserializeCart(serializedCart);
    } else {
      state = [];
    }
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    String serializedCart = serializeCart(state);
    await prefs.setString('cart', serializedCart);
  }

  // Override state setter to save cart whenever state changes
  @override
  set state(List<CartItem> value) {
    super.state = value;
    // Debounce the save operation to prevent excessive writes
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveCart();
    });
  }

  // Add a dish, meal subscription, or catering to the cart
  void addToCart(
    Map<String, dynamic> item,
    int quantity, {
    bool isMealSubscription = false,
    int totalMeals = 0,
    bool isCatering = false,
    int peopleCount = 0, // Catering-specific
    String? sideRequest, // Catering-specific
  }) {
    if (isCatering) {
      // Handle Catering Orders
      final existingCatering = state.firstWhere(
        (cartItem) =>
            cartItem.title == item['title'] && cartItem.foodType == 'Catering',
        orElse: () => CartItem(
          img: item['img'],
          title: item['title'],
          description: item['description'],
          pricing: item['pricing'],
          offertPricing: item['offertPricing'],
          ingredients: List<String>.from(item['ingredients']),
          isSpicy: false,
          foodType: 'Catering',
          quantity: 0,
          isOffer: false,
          peopleCount: peopleCount,
          sideRequest: sideRequest ?? '',
          id: item['id'] ?? 'no id',
        ),
      );

      if (existingCatering.quantity > 0) {
        // Update existing catering order
        state = [
          for (final cartItem in state)
            if (cartItem.title == item['title'] &&
                cartItem.foodType == 'Catering')
              cartItem.copyWith(
                  quantity: cartItem.quantity + quantity,
                  peopleCount: peopleCount,
                  sideRequest: sideRequest)
            else
              cartItem,
        ];
      } else {
        // Add new catering item to cart
        state = [...state, existingCatering.copyWith(quantity: quantity)];
      }
    } else if (isMealSubscription) {
      // Handle Meal Subscriptions
      // Handle Meal Subscriptions
      final existingPlanIndex = state.indexWhere(
        (cartItem) =>
            cartItem.title == item['title'] && cartItem.isMealSubscription,
      );

      if (existingPlanIndex != -1) {
        // Existing plan found, don't allow duplicates
        return;
      } else {
        // No existing plan, add new meal subscription to cart
        final newPlan = CartItem(
          img: item['img'] ?? '',
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          pricing: item['pricing'] ?? '',
          offertPricing: item['offertPricing'] ?? '',
          ingredients: List<String>.from(item['ingredients']) ?? [],
          isSpicy: item['isSpicy'] ?? false,
          foodType: item['foodType'] ?? 'Subscripcion',
          quantity: 1,
          isOffer: item.containsKey('offertPricing') &&
              item['offertPricing'] != null,
          isMealSubscription: true,
          totalMeals: totalMeals,
          remainingMeals: totalMeals,
          peopleCount: item['peopleCount'] ?? 1,
          id: item['id'] ?? 'no id',
        );
        state = [...state, newPlan];
      }
    } else {
      // Handle Regular Dish
      final existingDish = state.firstWhere(
        (cartItem) =>
            cartItem.title == item['title'] && !cartItem.isMealSubscription,
        orElse: () => CartItem(
          img: item['img'],
          title: item['title'],
          description: item['description'],
          pricing: item['pricing'],
          offertPricing: item['offertPricing'],
          ingredients: List<String>.from(item['ingredients']),
          isSpicy: item['isSpicy'],
          foodType: item['foodType'],
          quantity: 0,
          isOffer: item.containsKey('offertPricing') &&
              item['offertPricing'] != null,
          id: item['id'] ?? 'no id',
        ),
      );

      if (existingDish.quantity > 0) {
        state = [
          for (final cartItem in state)
            if (cartItem.title == item['title'] && !cartItem.isMealSubscription)
              cartItem.copyWith(quantity: cartItem.quantity + quantity)
            else
              cartItem,
        ];
      } else {
        state = [...state, existingDish.copyWith(quantity: quantity)];
      }
    }
  }

  // Increment quantity of a catering item
  void incrementCateringQuantity(String title) {
    state = [
      for (final item in state)
        if (item.title == title && item.foodType == 'Catering')
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void removeFromCart(String id) {
    state = state.where((item) => item.id != id).toList(); // Remove by id
  }

  // Decrement quantity of a catering item and remove if 0
  void decrementCateringQuantity(String title) {
    state = [
      for (final item in state)
        if (item.title == title && item.foodType == 'Catering')
          if (item.quantity > 1)
            item.copyWith(quantity: item.quantity - 1)
          else
            null // Remove item if quantity is 0
        else
          item,
    ].whereType<CartItem>().toList(); // Ensure to filter out null values
  }

  // Increment quantity of a regular dish
  void incrementQuantity(String title) {
    state = [
      for (final item in state)
        if (item.title == title &&
            !item.isMealSubscription &&
            item.foodType != 'Catering')
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  // Decrement quantity of a regular dish and remove if 0
  void decrementQuantity(String title) {
    state = [
      for (final item in state)
        if (item.title == title && !item.isMealSubscription)
          if (item.quantity > 1)
            item.copyWith(quantity: item.quantity - 1)
          else
            null // Remove item if quantity is 0
        else
          item,
    ].whereType<CartItem>().toList(); // Ensure to filter out null values
  }

  // Method to consume a meal from a meal subscription
  void consumeMeal(String title) {
    final currentDateTime = DateTime.now();
    state = [
      for (final item in state)
        if (item.title == title &&
            item.isMealSubscription &&
            currentDateTime.isBefore(item.expirationDate))
          item.copyWith(remainingMeals: item.remainingMeals - 1)
        else
          item,
    ];
  }

  // Method to remove expired meal subscriptions
  void removeExpiredPlans() {
    final currentDateTime = DateTime.now();
    state = state
        .where((item) =>
            !item.isMealSubscription ||
            currentDateTime.isBefore(item.expirationDate))
        .toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
