import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/primary_button.dart';
import 'package:starter_architecture_flutter_firebase/src/features/onboarding/presentation/onboarding_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF2EBC1), Color(0xFFD7EEB4)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Unlock Culinary Creativity",
                        style: theme.textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: DefaultTextStyle(
                          style: theme.textTheme.bodyLarge!,
                          child: AnimatedTextKit(
                            isRepeatingAnimation: false,
                            animatedTexts: [
                              TyperAnimatedText(
                                  'Turn leftover ingredients into delicious meals with just a snap! Configure your dietary preferences, allergies, and favorite cuisines, and let our AI chef guide you to create unique and flavorful dishes. No more recipe hunting or food waste!'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.of(context)
                      //         .pushReplacementNamed(RoutesNames.mealCreation);
                      //   },
                      //   child: Text(
                      //     "Create Your Meal Now!",
                      //     style: theme.textTheme.bodyLarge?.copyWith(
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      PrimaryButton(
                        text: 'Get Started'.hardcoded,
                        isLoading: state.isLoading,
                        onPressed: state.isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(onboardingControllerProvider.notifier)
                                    .completeOnboarding();
                                if (context.mounted) {
                                  // go to sign in page after completing onboarding
                                  context.goNamed(AppRoute.signIn.name);
                                }
                              },
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "Powered by ",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 4),
                          // Image.asset(
                          //   "assets/gemini-logo.png",
                          //   scale: 10,
                          // ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),

      // ResponsiveCenter(
      //   maxContentWidth: 450,
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.stretch,
      //     children: [
      //       Text(
      //         'Track your time.\nBecause time counts.',
      //         style: Theme.of(context).textTheme.headlineSmall,
      //         textAlign: TextAlign.center,
      //       ),
      //       gapH16,
      //       SvgPicture.asset(
      //         'assets/time-tracking.svg',
      //         width: 200,
      //         height: 200,
      //         semanticsLabel: 'Time tracking logo',
      //       ),
      //       gapH16,
      //       PrimaryButton(
      //         text: 'Get Started'.hardcoded,
      //         isLoading: state.isLoading,
      //         onPressed: state.isLoading
      //             ? null
      //             : () async {
      //                 await ref
      //                     .read(onboardingControllerProvider.notifier)
      //                     .completeOnboarding();
      //                 if (context.mounted) {
      //                   // go to sign in page after completing onboarding
      //                   context.goNamed(AppRoute.signIn.name);
      //                 }
      //               },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
