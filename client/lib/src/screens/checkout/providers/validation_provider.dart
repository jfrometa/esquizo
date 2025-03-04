import 'package:flutter_riverpod/flutter_riverpod.dart';

final validationProvider =
    StateNotifierProvider.family<ValidationNotifier, Map<String, bool>, String>(
        (ref, type) {
  return ValidationNotifier();
});

class ValidationNotifier extends StateNotifier<Map<String, bool>> {
  ValidationNotifier()
      : super({
          'location': false,
          'date': false,
          'time': false,
        });

  void setValid(String field, bool isValid) {
    state = {...state, field: isValid};
  }

  bool isFieldValid(String field) {
    return state[field] ?? false;
  }

  bool areAllFieldsValid() {
    return !state.values.contains(false);
  }
}