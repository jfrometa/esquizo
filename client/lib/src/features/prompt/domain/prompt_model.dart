import 'package:image_picker/image_picker.dart';

import '../../../util/filter_chip_enums.dart';

class PromptData {
  PromptData({
    required this.images,
    required this.textInput,
    Set<BasicIngredientsFilter>? selectedBasicIngredients,
    Set<CuisineFilter>? selectedCuisines,
    Set<DietaryRestrictionsFilter>? selectedDietaryRestrictions,
    List<String>? additionalTextInputs,
  })  : additionalTextInputs = additionalTextInputs ?? [],
        selectedBasicIngredients = selectedBasicIngredients ?? {},
        selectedCuisines = selectedCuisines ?? {},
        selectedDietaryRestrictions = selectedDietaryRestrictions ?? {};

  PromptData.empty()
      : images = [],
        additionalTextInputs = [],
        selectedBasicIngredients = {},
        selectedCuisines = {},
        selectedDietaryRestrictions = {},
        textInput = '';

  String get cuisines {
    return selectedCuisines.map((catFilter) => catFilter.name).join(",");
  }

  String get ingredients {
    return selectedBasicIngredients
        .map((ingredient) => ingredient.name)
        .join(", ");
  }

  String get dietaryRestrictions {
    return selectedDietaryRestrictions
        .map((restriction) => restriction.name)
        .join(", ");
  }

  List<XFile> images;
  String textInput;
  List<String> additionalTextInputs;
  Set<BasicIngredientsFilter> selectedBasicIngredients;
  Set<CuisineFilter> selectedCuisines;
  Set<DietaryRestrictionsFilter> selectedDietaryRestrictions;

  PromptData copyWith({
    List<XFile>? images,
    String? textInput,
    List<String>? additionalTextInputs,
    Set<BasicIngredientsFilter>? selectedBasicIngredients,
    Set<CuisineFilter>? selectedCuisines,
    Set<DietaryRestrictionsFilter>? selectedDietaryRestrictions,
  }) {
    return PromptData(
      images: images ?? this.images,
      textInput: textInput ?? this.textInput,
      additionalTextInputs: additionalTextInputs ?? this.additionalTextInputs,
      selectedBasicIngredients:
          selectedBasicIngredients ?? this.selectedBasicIngredients,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      selectedDietaryRestrictions:
          selectedDietaryRestrictions ?? this.selectedDietaryRestrictions,
    );
  }
}
