import 'package:flutter_riverpod/flutter_riverpod.dart';

class BooleanStateNotifier extends StateNotifier<bool> {
  // 1. initialize with current time
  BooleanStateNotifier(bool startsWith) : super(startsWith) {
    state = startsWith;
  }
  void update(bool boolean) {
    state = boolean;
  }
}
