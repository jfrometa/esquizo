import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../screens/models/scheduled_meal.dart';

part 'meal_schedule_provider.g.dart';

@riverpod
class MealSchedule extends _$MealSchedule {
  @override
  List<ScheduledMeal> build() => [];

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
        if (meal.id == id) meal.copyWith(isActive: !meal.isActive) else meal
    ];
  }
}
