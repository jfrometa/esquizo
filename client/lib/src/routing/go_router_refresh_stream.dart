import 'dart:async';

import 'package:flutter/foundation.dart';

/// This class was imported from the migration guide for GoRouter 5.0
/// Enhanced to reduce excessive rebuilds
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();

    // Add a simple distinct filter to prevent duplicate notifications
    _subscription = stream
        .asBroadcastStream()
        .distinct() // Only emit when the auth state actually changes
        .listen((dynamic authState) {
      debugPrint('🔄 Auth state changed, notifying router: $authState');
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
