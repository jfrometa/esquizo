import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/data/chat_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/data/recepies_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/domain/recipe_model.dart';

import '../../../util/filter_chip_enums.dart';
import '../domain/prompt_model.dart';

class PromptState {
  PromptState({
    required this.userPrompt,
    required this.loadingNewRecipe,
    this.recipe,
    this.geminiFailureResponse,
  });

  final PromptData userPrompt;
  final bool loadingNewRecipe;
  final Recipe? recipe;
  final String? geminiFailureResponse;

  PromptState copyWith({
    PromptData? userPrompt,
    bool? loadingNewRecipe,
    Recipe? recipe,
    String? geminiFailureResponse,
  }) {
    return PromptState(
      userPrompt: userPrompt ?? this.userPrompt,
      loadingNewRecipe: loadingNewRecipe ?? this.loadingNewRecipe,
      recipe: recipe ?? this.recipe,
      geminiFailureResponse:
          geminiFailureResponse ?? this.geminiFailureResponse,
    );
  }
}

class PromptNotifier extends StateNotifier<PromptState> {
  PromptNotifier({
    required this.multiModalModel,
    required this.textModel,
  }) : super(PromptState(
            userPrompt: PromptData.empty(), loadingNewRecipe: false));

  final GenerativeModel multiModalModel;
  final GenerativeModel textModel;
  final TextEditingController promptTextController = TextEditingController();

  String badImageFailure =
      "The recipe request either does not contain images, or does not contain images of food items. I cannot recommend a recipe.";

  void addImage(XFile image) {
    state = state.copyWith(
      userPrompt: state.userPrompt.copyWith(
        images: [...state.userPrompt.images, image],
      ),
    );
  }

  void addAdditionalPromptContext(String text) {
    final existingInputs = state.userPrompt.additionalTextInputs;
    state = state.copyWith(
      userPrompt: state.userPrompt.copyWith(
        additionalTextInputs: [...existingInputs, text],
      ),
    );
  }

  void removeImage(XFile image) {
    state = state.copyWith(
      userPrompt: state.userPrompt.copyWith(
        images: state.userPrompt.images
            .where((el) => el.path != image.path)
            .toList(),
      ),
    );
  }

  void resetPrompt() {
    state = state.copyWith(userPrompt: PromptData.empty());
  }

  PromptData buildPrompt() {
    return state.userPrompt.copyWith(
      textInput: mainPrompt,
      additionalTextInputs: [format],
    );
  }

  Future<void> submitPrompt() async {
    state = state.copyWith(loadingNewRecipe: true);
    var model = state.userPrompt.images.isEmpty ? textModel : multiModalModel;
    final prompt = buildPrompt();

    try {
      final content = await GeminiService.generateContent(model, prompt);
      // Parsing the generated content as JSON
      // final jsonContent = jsonDecode(content.text!);

      // Ensure the JSON structure adheres to the expected format
      // final recipe = Recipe.fromGeneratedContent(jsonContent);
      if (content.text != null && content.text!.contains(badImageFailure)) {
        state = state.copyWith(
          geminiFailureResponse: badImageFailure,
        );
      } else {
        final state1 = state.copyWith(
          recipe: Recipe.fromGeneratedContent(content),
        );
        state = state1;
      }
    } catch (error) {
      state = state.copyWith(
        geminiFailureResponse: 'Failed to reach Gemini. ${error.toString()}',
      );
      if (kDebugMode) {
        debugPrint(error.toString());
      }
    }

    state = state.copyWith(loadingNewRecipe: false);
    // resetPrompt();
  }

  void saveRecipe() {
    if (state.recipe != null) {
      FirestoreService.saveRecipe(state.recipe!);
    }
  }

  void addBasicIngredients(Set<BasicIngredientsFilter> ingredients) {
    state = state.copyWith(
      userPrompt: state.userPrompt.copyWith(
        selectedBasicIngredients: {
          ...state.userPrompt.selectedBasicIngredients,
          ...ingredients
        },
      ),
    );
  }

  void addCategoryFilters(Set<CuisineFilter> categories) {
    state = state.copyWith(
      userPrompt: state.userPrompt.copyWith(
        selectedCuisines: {...state.userPrompt.selectedCuisines, ...categories},
      ),
    );
  }

  void addDietaryRestrictionFilter(
      Set<DietaryRestrictionsFilter> restrictions) {
    state = state.copyWith(
      userPrompt: state.userPrompt.copyWith(
        selectedDietaryRestrictions: {
          ...state.userPrompt.selectedDietaryRestrictions,
          ...restrictions
        },
      ),
    );
  }

  String get mainPrompt {
    return '''
You are a Cat who's a chef that travels around the world a lot, and your travels inspire recipes.

Recommend a recipe for me based on the provided image.
The recipe should only contain real, edible ingredients.
If there are no images attached, or if the image does not contain food items, respond exactly with: $badImageFailure

Adhere to food safety and handling best practices like ensuring that poultry is fully cooked.
I'm in the mood for the following types of cuisine: ${state.userPrompt.cuisines},
I have the following dietary restrictions: ${state.userPrompt.dietaryRestrictions}
Optionally also include the following ingredients: ${state.userPrompt.ingredients}
Do not repeat any ingredients.

After providing the recipe, add an descriptions that creatively explains why the recipe is good based on only the ingredients used in the recipe.  Tell a short story of a travel experience that inspired the recipe.
List out any ingredients that are potential allergens.
Provide a summary of how many people the recipe will serve and the the nutritional information per serving.

${promptTextController.text.isNotEmpty ? promptTextController.text : ''}
''';
  }

  final String format = '''
Return the recipe as valid JSON using the following structure:
{
  "id": \$uniqueId,
  "title": \$recipeTitle,
  "ingredients": \$ingredients,
  "description": \$description,
  "instructions": \$instructions,
  "cuisine": \$cuisineType,
  "allergens": \$allergens,
  "servings": \$servings,
  "nutritionInformation": {
    "calories": "\$calories",
    "fat": "\$fat",
    "carbohydrates": "\$carbohydrates",
    "protein": "\$protein",
  },
}
  
uniqueId should be unique and of type String. 
title, description, cuisine, allergens, and servings should be of String type. 
ingredients and instructions should be of type List<String>.
nutritionInformation should be of type Map<String, String>.
''';
}
