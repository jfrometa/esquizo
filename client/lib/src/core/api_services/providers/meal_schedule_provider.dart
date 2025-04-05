import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../screens/models/scheduled_meal.dart';

class MealScheduleNotifier extends StateNotifier<List<ScheduledMeal>> {
  MealScheduleNotifier() : super([]);

  void addScheduledMeal(ScheduledMeal meal) {
    state = [...state, meal];
  }

  void updateScheduledMeal(ScheduledMeal meal) {
    state = [
      for (final existingMeal in state)
        if (existingMeal.id == meal.id) meal else existingMeal
    ];
  }

  void removeScheduledMeal(String id) {
    state = state.where((meal) => meal.id != id).toList();
  }

  void toggleMealStatus(String id) {
    state = [
      for (final meal in state)
        if (meal.id == id)
          meal.copyWith(isActive: !meal.isActive)
        else
          meal
    ];
  }
}

final mealScheduleProvider =
    StateNotifierProvider<MealScheduleNotifier, List<ScheduledMeal>>((ref) {
  return MealScheduleNotifier();
});