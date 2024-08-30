import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountryStateNotifier extends StateNotifier<Country?> {
  // 1. initialize with current time
  CountryStateNotifier(Country? startsWith) : super(startsWith) {
    state = startsWith;
  }
  void update(Country country) {
    state = country;
  }
}

class Country {}
