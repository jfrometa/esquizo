import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenStateNotifier extends StateNotifier<Token?> {
  // 1. initialize with current time
  TokenStateNotifier(Token? startsWith) : super(startsWith) {
    state = startsWith;
  }
  void update(Token? token) {
    state = token;
  }
}

class Token {
}
