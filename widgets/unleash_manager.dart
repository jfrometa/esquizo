import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:natasha/entities/client_info/client_info.dart';
import 'package:natasha/notifiers/index.dart';
import 'package:unleash_proxy_client_flutter/unleash_context.dart';
import 'package:unleash_proxy_client_flutter/unleash_proxy_client_flutter.dart';

class UnleashManager {
  factory UnleashManager() {
    return _instance;
  }

  UnleashManager._build();

  static final UnleashManager _instance = UnleashManager._build();

  bool isInitialized = false;
  late UnleashClient _unleashClient;

  bool isBypassKYCEnabled = false;
  bool isOTPFactorToCreateSubscriptionsEnabled = false;

  Future<void> init(WidgetRef ref) async {
    if (isInitialized) {
      return;
    }

    ClientInfo? clientInfo = ref.watch(clientInfoProviderNotifier);

    _unleashClient = UnleashClient(
      url: Uri.parse('https://feature.dev.secureuserarea.com/proxy'),
      clientKey: 'unleash-proxy-dev',
      refreshInterval: 15,
      appName: 'black-widow',
    );

    await _unleashClient.updateContext(
      UnleashContext(
        userId: clientInfo?.email ?? '',
        sessionId: 'black-widow',
        // properties: {
        //   'environment': 'dev',
        //   'project': 'default',
        // },
      ),
    );

    _unleashClient.on('error', (result) {
      log('_unleashClient error $result');
    });

    _unleashClient.on('initialized', (result) {
      log('_unleashClient initialized $result');
    });

    _unleashClient.on('ready', (result) {
      log('_unleashClient ready $result');

      var guardians_1011 = _unleashClient.isEnabled('guardians_1011');
      // isBypassKYCEnabled = _unleashClient.isEnabled('avengers_1036_bypass_kyc');
      // isOTPFactorToCreateSubscriptionsEnabled = _unleashClient
      //     .isEnabled('avengers_884_otp_factor_create_subscriptions');
      //
      if (guardians_1011) {
        print('ready guardians_1011 is enabled');
      } else {
        print('ready guardians_1011 is disabled');
      }
      //
      // if (isBypassKYCEnabled) {
      //   print('ready isBypassKYCEnabled is enabled');
      // } else {
      //   print('ready isBypassKYCEnabled is disabled');
      // }
      //
      // if (isOTPFactorToCreateSubscriptionsEnabled) {
      //   print('ready isOTPFactorToCreateSubscriptionsEnabled is enabled');
      // } else {
      //   print('guardians_1011');
      // }
    });

    _unleashClient.on('update', (result) {
      isBypassKYCEnabled = _unleashClient.isEnabled('avengers_1036_bypass_kyc');
      isOTPFactorToCreateSubscriptionsEnabled = _unleashClient
          .isEnabled('avengers_884_otp_factor_create_subscriptions');
      // var guardians_1011 = _unleashClient.isEnabled('guardians_1011');

      // if (guardians_1011) {
      //   print('ready guardians_1011 is enabled');
      // } else {
      //   print('ready guardians_1011 is disabled');
      // }
      //
      // if (isBypassKYCEnabled) {
      //   print('update isBypassKYCEnabled is enabled');
      // } else {
      //   print('update isBypassKYCEnabled is disabled');
      // }
      //
      // if (isOTPFactorToCreateSubscriptionsEnabled) {
      //   print('update isOTPFactorToCreateSubscriptionsEnabled is enabled');
      // } else {
      //   print('update isOTPFactorToCreateSubscriptionsEnabled is disabled');
      // }
    });

    if (!isInitialized) {
      isInitialized = true;
    }

    await _unleashClient.start();
  }
}
