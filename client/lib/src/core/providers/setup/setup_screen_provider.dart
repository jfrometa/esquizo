import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_screen_provider.g.dart';

/// Provider that controls whether to show the setup screen
/// This is used during app initialization to determine if the admin
/// needs to set up their business configuration
@Riverpod(keepAlive: true)
class ShowSetupScreen extends _$ShowSetupScreen {
  @override
  bool build() {
    // Default is false - don't show setup screen unless specifically triggered
    return false;
  }

  /// Show the setup screen
  void show() {
    state = true;
  }

  /// Hide the setup screen
  void hide() {
    state = false;
  }
}