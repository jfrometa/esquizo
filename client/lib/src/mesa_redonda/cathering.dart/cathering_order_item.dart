import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model representing an individual dish within the catering order
class CateringDish {
  final String title;
  final int peopleCount;
  final double pricePerPerson;
  final List<String> ingredients;

  CateringDish({
    required this.title,
    required this.peopleCount,
    required this.pricePerPerson,
    required this.ingredients,
  });
}

// Model for the overall catering order, including form data and total price calculation
class CateringOrderItem {
  final String title; 
  final String img;
  final String description;
  final List<CateringDish> dishes;
  final String apetito;
  final String alergias;
  final String eventType;
  final String preferencia;
  final String adicionales;

  CateringOrderItem({
    required this.title,
    required this.img,
    required this.description,
    required this.dishes,
    required this.apetito,
    required this.alergias,
    required this.eventType,
    required this.preferencia,
    required this.adicionales,
  });

  // Calculates the total price for all dishes in the order
  double get totalPrice => dishes.fold(
      0, (total, dish) => total + (dish.pricePerPerson * dish.peopleCount));

  // Combines all ingredients from all dishes into a single list for display
  List<String> get combinedIngredients =>
      dishes.expand((dish) => dish.ingredients).toList();
}

// State notifier for managing temporary catering orders
class CateringOrderNotifier extends StateNotifier<List<CateringOrderItem>> {
  CateringOrderNotifier() : super([]);

  // Temporary storage for dishes before completing the order with form details
  List<CateringDish> _pendingDishes = [];

  // Adds a dish to the pending list
  void addCateringItem(CateringDish dish) {
    _pendingDishes.add(dish);
  }

  // Completes the catering order with form data and finalizes it
  void finalizeCateringOrder({
    required String title,
    required String img,
    required String description,
    required String apetito,
    required String alergias,
    required String eventType,
    required String preferencia,
    required String adicionales,
  }) {
    if (_pendingDishes.isNotEmpty) {
      final newOrder = CateringOrderItem(
        img: img,
        description: description,
        dishes: List.from(_pendingDishes),
        apetito: apetito,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
         title: title,
      );

      state = [...state, newOrder];
      _pendingDishes.clear(); // Clear pending dishes after finalizing the order
    }
  }

  // Clears all orders in the temporary list
  void clearCateringOrder() {
    state = [];
    _pendingDishes.clear(); // Also clear pending dishes to reset fully
  }
}

// Provider for accessing the CateringOrderNotifier
final cateringOrderProvider =
    StateNotifierProvider<CateringOrderNotifier, List<CateringOrderItem>>((ref) {
  return CateringOrderNotifier();
});