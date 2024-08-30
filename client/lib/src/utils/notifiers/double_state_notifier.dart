import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoubleStateNotifier extends StateNotifier<double> {
  // 1. initialize with current time
  DoubleStateNotifier(double startsWith) : super(startsWith) {
    state = startsWith;
  }
  void update(double boolean) {
    state = boolean;
  }
}
