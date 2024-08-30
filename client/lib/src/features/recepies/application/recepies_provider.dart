import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/domain/recipe_model.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/presentation/recipes_view_model.dart';

final savedRecipesProvider =
    StateNotifierProvider<SavedRecipesNotifier, List<Recipe>>(
  (ref) => SavedRecipesNotifier(),
);
