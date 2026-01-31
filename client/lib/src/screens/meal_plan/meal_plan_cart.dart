import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'dart:convert';

part 'meal_plan_cart.g.dart';

@Riverpod(keepAlive: true)
class MealOrder extends _$MealOrder {
  @override
  List<CartItem> build() {
    _loadMeals();
    return [];
  }

  // Load meals from SharedPreferences
  Future<void> _loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedMeals = prefs.getString('mealOrders');
    if (serializedMeals != null && serializedMeals.isNotEmpty) {
      try {
        state = deserializeCart(serializedMeals);
      } catch (e) {
        debugPrint('Error deserializing meals: $e');
        state = [];
      }
    } else {
      state = [];
    }
  }

  // Save meals to SharedPreferences
  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    String serializedMeals = serializeCart(state);
    await prefs.setString('mealOrders', serializedMeals);
  }

  // Set the state and trigger save
  void _updateState(List<CartItem> newState) {
    state = newState;
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

    _updateState([...state, newMeal]);
    debugPrint('Meal Subscription added successfully.');
  }

  // Deserialize method
  List<CartItem> deserializeCart(String jsonString) {
    if (jsonString.isEmpty ||
        jsonString == 'null' ||
        jsonString == 'undefined') {
      return [];
    }
    try {
      List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error decoding meal cart JSON: $e');
      return [];
    }
  }

  // Serialize method
  String serializeCart(List<CartItem> cartItems) {
    return jsonEncode(cartItems.map((item) => item.toJson()).toList());
  }

  // Remove meal subscription by ID
  void removeFromCart(String id) {
    _updateState(state.where((meal) => meal.id != id).toList());
  }

  // Consume a meal from a meal subscription
  void consumeMeal(String title) {
    _updateState([
      for (final meal in state)
        if (meal.title == title && meal.isMealSubscription)
          meal.copyWith(remainingMeals: meal.remainingMeals - 1)
        else
          meal,
    ]);
  }

  // Clear all meal subscriptions from the cart
  void clearCart() {
    _updateState([]);
    debugPrint('Meal subscriptions cleared from the cart.');
  }
}
