import 'package:flutter_riverpod/flutter_riverpod.dart';

// Cart Item Model
class CartItem {
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
  final int peopleCount;  // Number of people for catering
  final String sideRequest; // Side requests for catering

  CartItem({
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
    this.peopleCount = 0,  // Default for non-catering items
    this.sideRequest = '',  // Default empty for non-catering items
  }) : expirationDate = expirationDate ?? DateTime.now().add(const Duration(days: 40));

  CartItem copyWith({
    int? quantity,
    int? remainingMeals,
    int? peopleCount,
    String? sideRequest,
  }) {
    return CartItem(
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
}
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Add a dish, meal subscription, or catering to the cart
  void addToCart(Map<String, dynamic> item, int quantity, {
    bool isMealSubscription = false,
    int totalMeals = 0,
    bool isCatering = false,
    int peopleCount = 0,  // Catering-specific
    String? sideRequest,  // Catering-specific
  }) {
    if (isCatering) {
      // Handle Catering Orders
      final existingCatering = state.firstWhere(
        (cartItem) => cartItem.title == item['title'] && cartItem.foodType == 'Catering',
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
          peopleCount: peopleCount,  // Number of people for catering
          sideRequest: sideRequest ?? '',  // Optional side request
        ),
      );

      if (existingCatering.quantity > 0) {
        // Update quantity and peopleCount for existing catering order
        state = [
          for (final cartItem in state)
            if (cartItem.title == item['title'] && cartItem.foodType == 'Catering')
              cartItem.copyWith(quantity: cartItem.quantity + quantity, peopleCount: peopleCount, sideRequest: sideRequest)
            else
              cartItem,
        ];
      } else {
        // Add new catering item to cart
        state = [...state, existingCatering.copyWith(quantity: quantity)];
      }
    } else if (isMealSubscription) {
      // Handle Meal Subscriptions
      final existingPlan = state.firstWhere(
        (cartItem) => cartItem.title == item['title'] && cartItem.isMealSubscription,
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
          isOffer: item.containsKey('offertPricing') && item['offertPricing'] != null,
          isMealSubscription: true,
          totalMeals: totalMeals,
          remainingMeals: totalMeals,
        ),
      );

      if (existingPlan.remainingMeals > 0) {
        return;  // Don't allow duplicates for meal subscriptions
      } else {
        state = [...state, existingPlan.copyWith(remainingMeals: totalMeals)];
      }
    } else {
      // Handle Regular Dish
      final existingDish = state.firstWhere(
        (cartItem) => cartItem.title == item['title'] && !cartItem.isMealSubscription,
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

  // Decrement quantity of a catering item
  void decrementCateringQuantity(String title) {
    state = [
      for (final item in state)
        if (item.title == title && item.foodType == 'Catering' && item.quantity > 1)
          item.copyWith(quantity: item.quantity - 1)
        else if (item.title == title && item.foodType == 'Catering' && item.quantity == 1)
          ...state.where((item) => item.title != title) // Remove the item when quantity is 0
        else
          item,
    ];
  }

  // Update people count of catering item
  void updatePeopleCount(String title, int peopleCount) {
    state = [
      for (final item in state)
        if (item.title == title && item.foodType == 'Catering')
          item.copyWith(peopleCount: peopleCount)
        else
          item,
    ];
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

  // Decrement quantity of a regular dish
  void decrementQuantity(String title) {
    state = [
      for (final item in state)
        if (item.title == title && !item.isMealSubscription && item.quantity > 1 && item.foodType != 'Catering')
          item.copyWith(quantity: item.quantity - 1)
        else if (item.title == title && !item.isMealSubscription && item.quantity == 1 && item.foodType != 'Catering')
          ...state.where((item) => item.title != title) // Remove the item when quantity is 0
        else
          item,
    ];
  }

  // Method to consume a meal from a meal subscription
  void consumeMeal(String title) {
    final currentDateTime = DateTime.now();
    state = [
      for (final item in state)
        if (item.title == title && item.isMealSubscription && currentDateTime.isBefore(item.expirationDate))
          item.copyWith(remainingMeals: item.remainingMeals - 1)
        else
          item,
    ];
  }

  // Method to remove expired meal subscriptions
  void removeExpiredPlans() {
    final currentDateTime = DateTime.now();
    state = state.where((item) => !item.isMealSubscription || currentDateTime.isBefore(item.expirationDate)).toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
