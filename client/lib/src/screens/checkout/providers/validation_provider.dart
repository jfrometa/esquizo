import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'validation_provider.g.dart';

@riverpod
class Validation extends _$Validation {
  @override
  Map<String, bool> build(String type) => {
        'location': false,
        'date': false,
        'time': false,
      };

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
