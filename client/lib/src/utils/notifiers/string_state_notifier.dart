import 'package:flutter_riverpod/flutter_riverpod.dart';

class StringStateNotifier extends StateNotifier<String> {
  // 1. initialize with current time
  StringStateNotifier(String startsWith) : super(startsWith) {
    state = startsWith;
  }
  void update(String string) {
    state = string;
  }
}
