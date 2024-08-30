import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeepLinkStateNotifier extends StateNotifier<Uri?> {
  // 1. initialize with current time
  DeepLinkStateNotifier(Uri? startsWith) : super(startsWith) {
    state = startsWith;
  }
  void update(Uri? link) {
    state = link;
  }

  void clear() {
    state = null;
  }
}
