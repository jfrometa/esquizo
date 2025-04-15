import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'dart:convert';

class MealOrderNotifier extends StateNotifier<List<CartItem>> {
  MealOrderNotifier() : super([]) {
    _loadMeals();
  }

  // Load meals from SharedPreferences
  Future<void> _loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedMeals = prefs.getString('mealOrders') ?? 'no order';
    state = deserializeCart(serializedMeals);
    }

  // Save meals to SharedPreferences
  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    String serializedMeals = serializeCart(state);
    await prefs.setString('mealOrders', serializedMeals);
  }

  // Override state setter to save meals when modified
  @override
  set state(List<CartItem> value) {
    super.state = value;
    _saveMeals();
  }

  // Add meal subscription to meal orders
  void addMealSubscription(Map<String, dynamic> item, int totalMeals) {
    debugPrint('Adding Meal Subscription: ${item['title']}');
    // Prevent duplicates in meal subscriptions
    if (state.any((meal) => meal.id == item['id'] && meal.isMealSubscription)) {
      return;
    }

    final newMeal = CartItem(
      id: item['id'],
      img: item['img'] ?? '',
      title: item['title'],
      description: item['description'],
      pricing: item['pricing'],
      foodType: item['foodType'],
      isMealSubscription: true,
      totalMeals: totalMeals,
      remainingMeals: totalMeals,
      isOffer: false,
      ingredients: item['ingredients'],
      isSpicy: item['isSpicy'],
      quantity: item['quantity'],
    );

    state = [...state, newMeal];
    debugPrint('Meal Subscription added successfully.');
  }

  // Deserialize method
  List<CartItem> deserializeCart(String jsonString) {
    List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => CartItem.fromJson(item)).toList();
  }

  // Serialize method
  String serializeCart(List<CartItem> cartItems) {
    return jsonEncode(cartItems.map((item) => item.toJson()).toList());
  }

  // Remove meal subscription by ID
  void removeFromCart(String id) {
    state = state.where((meal) => meal.id != id).toList();
  }

  // Consume a meal from a meal subscription
  void consumeMeal(String title) {
    state = [
      for (final meal in state)
        if (meal.title == title && meal.isMealSubscription)
          meal.copyWith(remainingMeals: meal.remainingMeals - 1)
        else
          meal,
    ];
  }

  // Clear all meal subscriptions from the cart
  void clearCart() {
    state = [];
    debugPrint('Meal subscriptions cleared from the cart.');
  }
}

final mealOrderProvider =
    StateNotifierProvider<MealOrderNotifier, List<CartItem>>((ref) {
  return MealOrderNotifier();
});
