import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/onboarding/onboarding_repository.dart';

part 'onboarding_controller.g.dart';

@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {
    // no op
  }

  Future<void> completeOnboarding() async {
    final onboardingRepository = ref.read(onboardingRepositoryProvider).value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => onboardingRepository?.setOnboardingComplete() ?? Future.value());
  }
}
