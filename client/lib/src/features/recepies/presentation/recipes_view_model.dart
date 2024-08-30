import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/data/recepies_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/domain/recipe_model.dart';

class SavedRecipesNotifier extends StateNotifier<List<Recipe>> {
  final recipePath = '/recipes';
  final firestore = FirebaseFirestore.instance;

  SavedRecipesNotifier() : super([]) {
    firestore.collection(recipePath).snapshots().listen((querySnapshot) {
      state = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Recipe.fromFirestore(data);
      }).toList();
    });
  }

  void deleteRecipe(Recipe recipe) {
    FirestoreService.deleteRecipe(recipe);
  }

  void updateRecipe(Recipe recipe) {
    FirestoreService.updateRecipe(recipe);
  }
}

