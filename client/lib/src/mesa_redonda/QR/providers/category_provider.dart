import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/models/food_category.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  return [
    Category(id: 1, name: 'Starters', imageUrl: 'assets/images/starters.jpg'),
    Category(id: 2, name: 'Main Courses', imageUrl: 'assets/images/main.jpg'),
    Category(id: 3, name: 'Desserts', imageUrl: 'assets/images/desserts.jpg'),
    Category(id: 4, name: 'Drinks', imageUrl: 'assets/images/drinks.jpg'),
  ];
});