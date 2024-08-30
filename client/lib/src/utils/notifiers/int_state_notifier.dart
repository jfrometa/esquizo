import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntStateNotifier extends StateNotifier<int> {
  // 1. initialize with current time
  IntStateNotifier(int startsWith) : super(startsWith) {
    state = startsWith;
  }
  void update(int boolean) {
    state = boolean;
  }
}
