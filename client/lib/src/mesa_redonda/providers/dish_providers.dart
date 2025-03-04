import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/models/food_dish.dart';
 
final dishesProvider = FutureProvider<List<Dish>>((ref) async {
  // In a real app, fetch from an API
  await Future.delayed(const Duration(milliseconds: 1000));
  
  return [
    Dish(
      id: 1, 
      title: 'Caesar Salad', 
      description: 'Fresh romaine lettuce, parmesan cheese, and our homemade dressing',
      price: 12.99,
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1',
      categoryId: 1,
      ingredients: ['Romaine lettuce', 'Parmesan', 'Croutons', 'Caesar dressing'],
    ),
    Dish(
      id: 2, 
      title: 'Grilled Salmon', 
      description: 'Atlantic salmon served with seasonal vegetables',
      price: 24.99,
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288',
      categoryId: 2,
      ingredients: ['Salmon fillet', 'Lemon', 'Herbs', 'Seasonal vegetables'],
    ),
    Dish(
      id: 3, 
      title: 'Chocolate Lava Cake', 
      description: 'Warm chocolate cake with a molten center, served with vanilla ice cream',
      price: 9.99,
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1602351447937-745cb720612f',
      categoryId: 3,
      ingredients: ['Dark chocolate', 'Flour', 'Eggs', 'Vanilla ice cream'],
    ),
    // Add more dishes as needed
  ];
});

final filteredDishesProvider = FutureProvider.family<List<Dish>, int?>((ref, categoryId) async {
  final dishesAsync = ref.watch(dishesProvider);
  
  return dishesAsync.when(
    data: (dishes) {
      if (categoryId == null) return dishes;
      return dishes.where((dish) => dish.categoryId == categoryId).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});