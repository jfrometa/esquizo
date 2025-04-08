// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_screen_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$showSetupScreenHash() => r'e2d6ca1a1142975e715c7ab0486962230080d351';

/// Provider that controls whether to show the setup screen
/// This is used during app initialization to determine if the admin
/// needs to set up their business configuration
///
/// Copied from [ShowSetupScreen].
@ProviderFor(ShowSetupScreen)
final showSetupScreenProvider =
    NotifierProvider<ShowSetupScreen, bool>.internal(
  ShowSetupScreen.new,
  name: r'showSetupScreenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showSetupScreenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowSetupScreen = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
