import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cart/cart_item.dart';


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
    int peopleCount = 0,
    String? sideRequest,
  
  }) {
    if (isCatering) {
      // Handle Catering Orders
      final existingCatering = state.firstWhere(
        (cartItem) => cartItem.title == item['title'] && cartItem.foodType == 'Catering',
        orElse: () => CartItem(
          id: item['id'] ?? 'no id',
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
          hasChef: false,
        ),
      );

 
    if (isCatering) {
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
        peopleCount: item['peopleCount'],
        sideRequest: item['sideRequest'] ?? '',
        hasChef: item['hasChef'] ?? false,
        alergias: item['alergias'] ?? '',
        eventType: item['eventType'] ?? '',
        preferencia: item['preferencia'] ?? 'salado', isOffer: false,
      );
      state = [...state, newItem];
    

      if (existingCatering.quantity > 0) {
        // Update existing catering order
        state = [
          for (final cartItem in state)
            if (cartItem.title == item['title'] && cartItem.foodType == 'Catering')
              cartItem.copyWith(
                quantity: cartItem.quantity + quantity,
                peopleCount: peopleCount,
                sideRequest: sideRequest,
              )
            else
              cartItem,
        ];
      } else {
        // Add new catering item to cart
        state = [...state, existingCatering.copyWith(quantity: quantity)];
      }
  }
    } else if (isMealSubscription) {
      // Handle Meal Subscriptions
      final existingPlanIndex = state.indexWhere(
        (cartItem) => cartItem.title == item['title'] && cartItem.isMealSubscription,
      );

      if (existingPlanIndex != -1) {
        // Existing plan found, don't allow duplicates
        return;
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
          isOffer: item.containsKey('offertPricing') && item['offertPricing'] != null,
          isMealSubscription: true,
          totalMeals: totalMeals,
          remainingMeals: totalMeals,
          peopleCount: item['peopleCount'] ?? 1,
        );
        state = [...state, newPlan];
      }
    } else {
      // Handle Regular Dish
      final existingDish = state.firstWhere(
        (cartItem) => cartItem.title == item['title'] && !cartItem.isMealSubscription,
        orElse: () => CartItem(
          id: item['id'] ?? 'no id',
          img: item['img'],
          title: item['title'],
          description: item['description'],
          pricing: item['pricing'],
          offertPricing: item['offertPricing'],
          ingredients: List<String>.from(item['ingredients']),
          isSpicy: item['isSpicy'],
          foodType: item['foodType'],
          hasChef: item['hasChef'],
          quantity: 0,
          isOffer: item.containsKey('offertPricing') && item['offertPricing'] != null,
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

  void clearCart() {
    state = [];
  }

  void addMealPlanDishToCart(Map<String, dynamic> item, int quantity) {
  final existingDish = state.firstWhere(
    (cartItem) =>
        cartItem.title == item['title'] && cartItem.isMealPlanDish,
    orElse: () => CartItem(
      // Initialize with item details
      id: item['id'] ?? 'no id',
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
      isMealPlanDish: true,
    ),
  );

  if (existingDish.quantity > 0) {
    state = [
      for (final cartItem in state)
        if (cartItem.title == item['title'] && cartItem.isMealPlanDish)
          cartItem.copyWith(quantity: cartItem.quantity + quantity)
        else
          cartItem,
    ];
  } else {
    state = [...state, existingDish.copyWith(quantity: quantity)];
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

  void confirmMealPlanConsumption(
    CartItem mealPlan, List<CartItem> mealPlanDishes, String address) {
  final currentDateTime = DateTime.now();

  // Update the meal plan's remaining meals
  int totalDishes = mealPlanDishes.fold(0, (sum, item) => sum + item.quantity);
  if (mealPlan.remainingMeals >= totalDishes) {
    state = [
      for (final item in state)
        if (item.id == mealPlan.id &&
            item.isMealSubscription &&
            currentDateTime.isBefore(item.expirationDate))
          item.copyWith(remainingMeals: item.remainingMeals - totalDishes)
        else
          item,
    ];

    // Record consumption for each dish
    for (final dish in mealPlanDishes) {
      _recordMealToFirebase(mealPlan, dish, address);
    }

    // Remove consumed dishes from cart
    state = state.where((item) => !mealPlanDishes.contains(item)).toList();
  } else {
    // Handle insufficient meals
    throw Exception('Not enough meals remaining in the meal plan.');
  }
}

  // Decrement quantity of a catering item and remove if 0
  void decrementCateringQuantity(String title) {
    state = [
      for (final item in state)
        if (item.title == title && item.foodType == 'Catering')
          if (item.quantity > 1)
            item.copyWith(quantity: item.quantity - 1)
          else
            null
        else
          item,
    ].whereType<CartItem>().toList();
  }

  // Increment quantity of a regular dish
  void incrementQuantity(String title) {
    state = [
      for (final item in state)
        if (item.title == title && !item.isMealSubscription && item.foodType != 'Catering')
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
            null
        else
          item,
    ].whereType<CartItem>().toList();
  }

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

  // Update meal plan when a meal is consumed
  void updateMealPlan(String mealPlanTitle, CartItem dish, String regularAddress) {
    final currentDateTime = DateTime.now();

    // Update the meal plan's remaining meals
    state = [
      for (final item in state)
        if (item.title == mealPlanTitle && item.isMealSubscription && item.remainingMeals > 0 && currentDateTime.isBefore(item.expirationDate))
          item.copyWith(remainingMeals: item.remainingMeals - 1)
        else
          item,
    ];

    // Get the updated meal plan
    final mealPlan = state.firstWhere((item) => item.title == mealPlanTitle && item.isMealSubscription);

    // Record the meal consumption details in Firebase
    _recordMealToFirebase(mealPlan, dish, regularAddress);
  }

  Future<void> _recordMealToFirebase(CartItem mealPlan, CartItem dish, String regularAddress) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
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
      print('Failed to record to Firebase: $e');
      // Implement retry logic or user notification if necessary
    }
  }

  // Remove expired meal plans
  void removeExpiredPlans() {
    final currentDateTime = DateTime.now();
    state = state
        .where((item) => !item.isMealSubscription || currentDateTime.isBefore(item.expirationDate))
        .toList();
  }

  // Remove item from cart by id
  void removeFromCart(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});