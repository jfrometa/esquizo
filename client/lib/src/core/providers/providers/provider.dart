export 'table_providers.dart';
export 'category_provider.dart';
export '../catalog/dish/dish_providers.dart';

// // ------ PROVIDERS ------
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';

// import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/dishes/dish_card.dart';

// // Tables provider
// final tablesProvider = FutureProvider<List<RestaurantTable>>((ref) async {
//   // In a real app, fetch from an API
//   await Future.delayed(const Duration(milliseconds: 800));
  
//   return [
//     RestaurantTable(id: 1, name: 'Table 1', capacity: 2),
//     RestaurantTable(id: 2, name: 'Table 2', capacity: 4),
//     RestaurantTable(id: 3, name: 'Table 3', capacity: 6),
//     RestaurantTable(id: 4, name: 'Table 4', capacity: 2),
//     RestaurantTable(id: 5, name: 'Table 5', capacity: 8),
//   ];
// });

// // Selected table provider
// final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);

// // Categories provider
// final categoriesProvider = FutureProvider<List<Category>>((ref) async {
//   // In a real app, fetch from an API
//   await Future.delayed(const Duration(milliseconds: 800));
  
//   return [
//     Category(id: 1, name: 'Starters', imageUrl: 'assets/images/starters.jpg'),
//     Category(id: 2, name: 'Main Courses', imageUrl: 'assets/images/main.jpg'),
//     Category(id: 3, name: 'Desserts', imageUrl: 'assets/images/desserts.jpg'),
//     Category(id: 4, name: 'Drinks', imageUrl: 'assets/images/drinks.jpg'),
//   ];
// });

// // Dishes provider
// final dishesProvider = FutureProvider<List<Dish>>((ref) async {
//   // In a real app, fetch from an API
//   await Future.delayed(const Duration(milliseconds: 1000));
  
//   return [
//     Dish(
//       id: 1, 
//       title: 'Caesar Salad', 
//       description: 'Fresh romaine lettuce, parmesan cheese, and our homemade dressing',
//       price: 12.99,
//       rating: 4.7,
//       imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1',
//       categoryId: 1,
//       ingredients: ['Romaine lettuce', 'Parmesan', 'Croutons', 'Caesar dressing'],
//     ),
//     Dish(
//       id: 2, 
//       title: 'Grilled Salmon', 
//       description: 'Atlantic salmon served with seasonal vegetables',
//       price: 24.99,
//       rating: 4.9,
//       imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288',
//       categoryId: 2,
//       ingredients: ['Salmon fillet', 'Lemon', 'Herbs', 'Seasonal vegetables'],
//     ),
//     Dish(
//       id: 3, 
//       title: 'Chocolate Lava Cake', 
//       description: 'Warm chocolate cake with a molten center, served with vanilla ice cream',
//       price: 9.99,
//       rating: 4.8,
//       imageUrl: 'https://images.unsplash.com/photo-1602351447937-745cb720612f',
//       categoryId: 3,
//       ingredients: ['Dark chocolate', 'Flour', 'Eggs', 'Vanilla ice cream'],
//     ),
//     // Add more dishes as needed
//   ];
// });

// // Filtered dishes by category provider
// final filteredDishesProvider = FutureProvider.family<List<Dish>, int?>((ref, categoryId) async {
//   final dishesAsync = ref.watch(dishesProvider);
  
//   return dishesAsync.when(
//     data: (dishes) {
//       if (categoryId == null) return dishes;
//       return dishes.where((dish) => dish.categoryId == categoryId).toList();
//     },
//     loading: () => [],
//     error: (_, __) => [],
//   );
// });

// // ------ SCREENS ------
