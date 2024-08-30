import 'package:flutter_riverpod/flutter_riverpod.dart';

class ValueStateNotifier<T> extends StateNotifier<T> {
  ValueStateNotifier(T startsWith) : super(startsWith) {
    state = startsWith;
  }
  void update(T value) {
    state = value;
  }

  T? get value => state;
}
