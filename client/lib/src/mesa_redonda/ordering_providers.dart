import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dish List (immutable)
final dishProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
  {
    "img": 'assets/food1.jpeg',
    "title": 'La Bonita',
    "description": 'Sandwich de queso de hoja, tocino, y spicy honey.',
    "pricing": '400.00',
    "ingredients": ['Queso de hoja', 'Tocino', 'Spicy honey'],
    "isSpicy": true,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food2.jpeg',
    "title": 'Bosque Encantado',
    "description":
        'Sandwich de filete de res, crema de hongos, cebolla caramelizada, y queso provolone.',
    "pricing": '555.00',
    "ingredients": [
      'Filete de res',
      'Crema de hongos',
      'Cebolla caramelizada',
      'Queso provolone'
    ],
    "isSpicy": false,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food3.jpeg',
    "title": 'El Granjero',
    "description": 'Sandwich de pulled pork y coleslaw.',
    "pricing": '475.00',
    "ingredients": ['Pulled pork', 'Coleslaw'],
    "isSpicy": false,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food4.jpeg',
    "title": 'El Americano',
    "description":
        'Sandwich de pechuga empanizada, spicy honey, y queso americano.',
    "pricing": '500.00',
    "ingredients": ['Pechuga empanizada', 'Spicy honey', 'Queso americano'],
    "isSpicy": true,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food5.jpeg',
    "title": 'Kapow',
    "description": 'Sandwich de pechuga desmenuzada, crema de hongos y tocino.',
    "pricing": '555.00',
    "ingredients": ['Pechuga desmenuzada', 'Crema de hongos', 'Tocino'],
    "isSpicy": false,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food6.jpeg',
    "title": 'Verde',
    "description": 'Arroz al pesto con pechuga a la plancha.',
    "pricing": '575.00',
    "ingredients": ['Arroz al pesto', 'Pechuga a la plancha'],
    "isSpicy": false,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food7.jpeg',
    "title": 'Asiatica',
    "description": 'Arroz asiatico y flap meat.',
    "pricing": '600.00',
    "ingredients": ['Arroz asiatico', 'Flap meat'],
    "isSpicy": false,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food1.jpeg',
    "title": 'Clasica',
    "description": 'Pechuga desmenuzada, arroz blanco, ensalada y aguacate.',
    "pricing": '500.00',
    "ingredients": [
      'Pechuga desmenuzada',
      'Arroz blanco',
      'Ensalada',
      'Aguacate'
    ],
    "isSpicy": false,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food2.jpeg',
    "title": 'Mar y Tierra',
    "description": 'Ensalada, pechuga, y camarones.',
    "pricing": '600.00',
    "ingredients": ['Ensalada', 'Pechuga', 'Camarones'],
    "isSpicy": false,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food3.jpeg',
    "title": 'Quisqueya',
    "description":
        'Res mechada al estilo dominicano, plátano maduro, arroz blanco y ensalada.',
    "pricing": '575.00',
    "ingredients": [
      'Res mechada',
      'Plátano maduro',
      'Arroz blanco',
      'Ensalada'
    ],
    "isSpicy": false,
    "foodType": 'Meat',
  },
  {
    "img": 'assets/food4.jpeg',
    "title": 'Ensalada Camille',
    "description":
        'Mix de lechugas, flap meat, sweet potato, y queso parmesano.',
    "pricing": '600.00',
    "ingredients": ['Lechugas', 'Flap meat', 'Sweet potato', 'Queso parmesano'],
    "isSpicy": false,
    "foodType": 'Meat',
  },
];
});

// Meal Plan Options
enum MealPlan { twelveLunch, tenLunch, eightLunch }

// Meal Plan StateNotifier
class MealPlanNotifier extends StateNotifier<MealPlan> {
  MealPlanNotifier() : super(MealPlan.twelveLunch);

  void selectPlan(MealPlan plan) {
    state = plan;
  }
}

// Meal Plan Provider
final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlan>((ref) {
  return MealPlanNotifier();
});

// Date and Time Picker for each lunch in the subscription
class LunchTimeNotifier extends StateNotifier<Map<int, DateTime>> {
  LunchTimeNotifier() : super({});

  // Select a date and time for a particular lunch (at least 1 hour before delivery)
  void selectLunchTime(int lunchNumber, DateTime time) {
    if (time.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
      state = {...state, lunchNumber: time};
    } else {
      throw Exception("Lunch time must be at least 1 hour before delivery.");
    }
  }
}

// Lunch Time Provider
final lunchTimeProvider = StateNotifierProvider<LunchTimeNotifier, Map<int, DateTime>>((ref) {
  return LunchTimeNotifier();
});