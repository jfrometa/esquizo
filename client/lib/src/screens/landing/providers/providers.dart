// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/landing/models/model-meal-plan.dart';

// // Provider for dish data used in _selectRandomDishes() method
// final dishProvider = Provider<List<Map<String, dynamic>>>((ref) {
//   // Implementation that provides the list of dishes
//   return [
//     // Sample dish data structure
//     {
//       'title': 'Sample Dish',
//       'description': 'Description of the dish',
//       'pricing': 'S/ 25.00',
//       'img': 'image_url',
//       'ingredients': <String>['Ingredient 1', 'Ingredient 2'],
//       'isSpicy': false,
//       'foodType': 'Main',
//     },
//     // Additional dishes would be added here
//   ];
// });

// // Provider for meal plans data used in MealPlansSection
// final mealPlansProvider = Provider<List<MealPlan>>((ref) {
//   return [
//     MealPlan(
//       id: 'plan1',
//       title: 'Plan Básico',
//       description: 'Ideal para individuos o parejas, incluye 5 comidas a la semana',
//       price: 'S/ 149.99/semana',
//     ),
//     MealPlan(
//       id: 'plan2',
//       title: 'Plan Familiar',
//       description: 'Perfecto para familias, incluye 10 comidas a la semana',
//       price: 'S/ 259.99/semana',
//     ),
//     MealPlan(
//       id: 'plan3',
//       title: 'Plan Ejecutivo',
//       description: 'Comidas gourmet para profesionales ocupados, 7 almuerzos a la semana',
//       price: 'S/ 199.99/semana',
//     ),
//   ];
// });
