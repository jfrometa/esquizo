import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/providers/general.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/utils/notifiers/dynamic_state_notifier.dart';
import 'package:starter_architecture_flutter_firebase/utils/secure_storange_manager.dart';
import 'package:starter_architecture_flutter_firebase/utils/shared_preference_manager.dart';
import 'package:starter_architecture_flutter_firebase/widgets/button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:natasha/entities/settings/request_update_email.dart';
import 'package:natasha/notifiers/index.dart';
import 'package:natasha/notifiers/update_user_details_provider_notifier.dart';

final _isCountingProvider =
    StateNotifierProvider<ValueStateNotifier<bool>, bool>(
  (ref) => ValueStateNotifier(false),
);

class PersonalDetailsCheckEmailScreenContent extends ConsumerStatefulWidget {
  PersonalDetailsCheckEmailScreenContent({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.email,
  });

  //   @queryParam this.token,
  // });
  // final Str

  final String icon;
  final String title;
  final String message;
  final String email;
  final ValueNotifier<bool> isWaitingTimeOutToRequestNewEmailNotifier =
      ValueNotifier<bool>(false);

  static const String path = 'check-email-update';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PersonalDetailsCheckEmailState();
}

class _PersonalDetailsCheckEmailState
    extends ConsumerState<PersonalDetailsCheckEmailScreenContent> {
  @override
  void initState() {
    super.initState();

    ref.listenManual(changeEmailTokenProvider, (previous, newToken) async {
      if (newToken.isNotEmpty) {
        CustomAppTheme theme = ref.watch(appThemeProvider);
        final String response = await _updateEmail(
          UpdateEmail(newEmail: widget.email, token: newToken),
          theme,
        );

        if (response.contains('200')) {
          await context.router.push(
            PersonalDetailsSuccessRoute(
              icon: 'assets/BigCheckMark.svg',
              message: 'settings.change_email.text',
              title: 'settings.change_email.title',
              onButtonPress: () async {
                final storage = SecureStoreManager.instance;
                final prefs = SharedPreferenceManager.instance;

                await ref
                    .read(authenticationNotifierProvider.notifier)
                    .unauthenticate()
                    .then((_) async {
                  ref.read(clientInfoRequestProviderNotifier.notifier).reset();

                  await prefs.writeBiometrics(false);
                  await storage.deleteAll();

                  context.router.popUntilRoot();
                  await context.router.replaceAll([const OutOfAppRoute()]);
                });
              },
            ),
          );
        }
      }
    });
  }

  Future<String> _updateEmail(
    UpdateEmail newEmail,
    CustomAppTheme customAppTheme,
  ) async {
    try {
      final result = await ref
          .read(updateEmailNotifierProvider.notifier)
          .updateEmail(newEmail);

      return result;
    } catch (error) {
      ToastMessage.showToast(
        context,
        '$error',
        customAppTheme,
        type: ToastMessageType.negative,
      );
      return error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    bool isCounting = ref.watch(_isCountingProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: Header(
        context: context,
        leading: IconButton(
          icon: const Icon(ThanosIcons.buttonsBack),
          onPressed: () async => context.router.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 100, 0, 40),
            child: SvgPicture.asset(widget.icon),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.title.t(),
              style: customAppTheme.textStyles.displaySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
              left: 16.0,
              bottom: 34.0,
            ),
            child: Text(
              widget.message.t(),
              style: customAppTheme.textStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          !isCounting
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                  child: Text(
                    'settings.change_email.check_email.didnt_receive.title'.t(),
                    style: customAppTheme.textStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox(),
          !isCounting
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                  child: Text(
                    'settings.change_email.check_email.didnt_receive.text'.t(),
                    style: customAppTheme.textStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox(),
          isCounting
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                  child: Text(
                    'settings.change_email.check_email.didnt_receive.resend.title'
                        .t({'name': widget.email}),
                    style: customAppTheme.textStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox(),
          EmailRequestCountDownButton(
            isCountingNotifier: _isCountingProvider,
            email: widget.email,
          ),
        ],
      ),
    );
  }
}

class EmailRequestCountDownButton extends ConsumerStatefulWidget {
  const EmailRequestCountDownButton(
      {required this.isCountingNotifier, required this.email, super.key});
  final StateNotifierProvider<ValueStateNotifier<bool>, bool>
      isCountingNotifier;
  final String email;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextCountDownState();
}

class _TextCountDownState extends ConsumerState<EmailRequestCountDownButton> {
  // Step 2
  Timer? _countdownTimer;
  Duration myDuration = const Duration(minutes: 2);
  bool isPerformingNetworkRequest = false;

  @override
  void initState() {
    super.initState();
  }

  void startTimer() {
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() {
      ref.read(widget.isCountingNotifier.notifier).update(false);
      _countdownTimer?.cancel();
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(minutes: 2));
  }

  void setCountDown() {
    const reduceSecondsBy = 1;

    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        _countdownTimer?.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
        ref.read(widget.isCountingNotifier.notifier).update(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme theme = ref.watch(appThemeProvider);

    String strDigits(int n) => n.toString().padLeft(2, '0');
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    final minutes = strDigits(myDuration.inMinutes.remainder(2));

    if (minutes == '00' &&
        seconds == '01' &&
        ref.watch(widget.isCountingNotifier)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        stopTimer();
      });
    }

    return Center(
      child: isPerformingNetworkRequest
          ? const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: CircularProgressIndicator(),
            )
          : ref.watch(widget.isCountingNotifier)
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'settings.change_email.check_email.didnt_receive.resend.text'
                        .t({
                      'time': '$minutes $seconds',
                    }),
                    style: theme.textStyles.bodyMedium,
                  ),
                )
              : Button.secondary(
                  onPressed: () async {
                    setState(() => isPerformingNetworkRequest = true);

                    await ref
                        .read(requestUpdateEmailNotifierProvider.notifier)
                        .requestUpdateEmail(
                          RequestUpdateEmail(newEmail: widget.email),
                        );

                    setState(() => isPerformingNetworkRequest = false);

                    startTimer();
                  },
                  text: Text(
                    'settings.change_email.check_email.didnt_receive.button'
                        .t(),
                    style: theme.textStyles.headlineLarge.copyWith(
                      color: theme.colorsPalette.primary,
                    ),
                  ),
                ),
    );
  }
}
