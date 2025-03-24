import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart'; 



// Cart notifier using Riverpod
class CartNotifier extends StateNotifier<Cart> {
  final CartService _cartService;
  Timer? _saveDebounce;

  CartNotifier(this._cartService) : super(_cartService.cart) {
    _loadCart();
  }

  // Load cart from shared preferences
  Future<void> _loadCart() async {
    await _cartService.loadCart();
    state = _cartService.cart;
  }

  // Save cart with debounce
  void _saveCart() {
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _cartService.saveCart();
    });
  }

  // Add an item to the cart
  void addItem(CartItem item) {
    state = state.addItem(item);
    _saveCart();
  }
  
  // Add to cart with flexible options
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
    state = state.addToCart(
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
    _saveCart();
  }
  
  // Remove an item at specific index
  void removeItem(int index) {
    state = state.removeItem(index);
    _saveCart();
  }
  
  // Remove item by ID
  void removeItemById(String id) {
    state = state.removeItemById(id);
    _saveCart();
  }
  
  // Update quantity of an item at specific index
  void updateItemQuantity(int index, int quantity) {
    state = state.updateItemQuantity(index, quantity);
    _saveCart();
  }
  
  // Increment quantity of a catering item
  void incrementCateringQuantity(String title) {
    state = state.incrementCateringQuantity(title);
    _saveCart();
  }
  
  // Decrement quantity of a catering item
  void decrementCateringQuantity(String title) {
    state = state.decrementCateringQuantity(title);
    _saveCart();
  }
  
  // Increment quantity of a regular dish
  void incrementQuantity(String title) {
    state = state.incrementQuantity(title);
    _saveCart();
  }
  
  // Decrement quantity of a regular dish
  void decrementQuantity(String title) {
    state = state.decrementQuantity(title);
    _saveCart();
  }
  
  // Add a meal plan dish to cart
  void addMealPlanDishToCart(Map<String, dynamic> item, int quantity) {
    state = state.addMealPlanDishToCart(item, quantity);
    _saveCart();
  }
  
  // Consume a meal from a meal plan
  void consumeMeal(String title) {
    state = state.consumeMeal(title);
    _saveCart();
  }
  
  // Update meal plan when a meal is consumed
  Future<void> updateMealPlan(String mealPlanTitle, CartItem dish, String regularAddress) async {
    state = state.updateMealPlan(mealPlanTitle, dish, regularAddress);
    _saveCart();
    
    // Get the updated meal plan for Firebase recording
    final mealPlan = state.items.firstWhere(
      (item) => item.title == mealPlanTitle && item.isMealSubscription,
      orElse: () => throw Exception('Meal plan not found'),
    );
    
    // Record the meal consumption to Firebase
    await _cartService.recordMealToFirebase(mealPlan, dish, regularAddress);
  }
  
  // Confirm meal plan consumption with multiple dishes
  Future<void> confirmMealPlanConsumption(CartItem mealPlan, List<CartItem> mealPlanDishes, String address) async {
    final dishIds = mealPlanDishes.map((dish) => dish.id).toList();
    
    state = state.confirmMealPlanConsumption(mealPlan.id, dishIds, address);
    _saveCart();
    
    // Record each consumption to Firebase
    for (final dish in mealPlanDishes) {
      await _cartService.recordMealToFirebase(mealPlan, dish, address);
    }
  }
  
  // Remove expired meal plans
  void removeExpiredPlans() {
    state = state.removeExpiredPlans();
    _saveCart();
  }
  
  // Clear the cart
  void clearCart() {
    state = state.clear();
    _saveCart();
  }
  
  // Update special instructions
  void updateSpecialInstructions(String? instructions) {
    state = state.updateSpecialInstructions(instructions);
    _saveCart();
  }
  
  // Update resource ID
  void updateResourceId(String? resourceId) {
    state = state.updateResourceId(resourceId);
    _saveCart();
  }
  
  // Update delivery option
  void updateDeliveryOption(bool isDelivery) {
    state = state.updateDeliveryOption(isDelivery);
    _saveCart();
  }
  
  // Update people count
  void updatePeopleCount(int count) {
    state = state.updatePeopleCount(count);
    _saveCart();
  }
}

// Riverpod Providers
final cartServiceProvider = Provider<CartService>((ref) { 
  final auth = ref.watch(firebaseUserProvider).value?.uid ;
  final businessConfig = ref.watch(currentBusinessIdProvider);
 
  return CartService( 
    userId: auth ?? '',
    businessId: businessConfig, // Added .value to access the BusinessConfig object
  );
});

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  final cartService = ref.watch(cartServiceProvider);
  return CartNotifier(cartService);
});

// Helper providers for commonly accessed cart properties
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.itemCount;
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.subtotal;
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.total;
});

final cartMealPlansProvider = Provider<List<CartItem>>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.mealPlans;
});

final cartCateringItemsProvider = Provider<List<CartItem>>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.cateringItems;
});