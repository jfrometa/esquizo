import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/notifiers/index.dart';

class SumsubManager {
  static final SumsubManager instance = SumsubManager();

  Future<SumsubManager> get sumsub async => SumsubManager.instance;
  late SNSMobileSDK _sdk;
  late SNSMobileSDKResult _sdkResult;

  Future<void> launchSDK(String accessToken, WidgetRef ref) async {
    final CustomAppTheme theme = ref.watch(appThemeProvider);
    final locale0 =
        ref.read(clientInfoProviderNotifier)?.countryOfResidence ?? 'en';
    final locale = Locale(locale0);

    final email = ref.read(clientInfoProviderNotifier)?.email ?? 'id_not_found';
    final phone0 = ref.read(clientInfoProviderNotifier)?.phone;

    final phone = '${phone0?.callingCode ?? ''} ${phone0?.phoneNumber ?? ''}';

    onStatusChanged(
      SNSMobileSDKStatus newStatus,
      SNSMobileSDKStatus prevStatus,
    ) {
      log('The SDK status was changed: $prevStatus -> $newStatus');
    }

    onTokenExpiration() async {
      final newtoken = await ref
          .read(kycGetSumsubTokenNotifierProvider.notifier)
          .getSumsubToken();

      onTokenExpirationForExpiredToken() {
        return Future.value(newtoken);
      }

      await _launchSumsub(
        newtoken,
        phone,
        email,
        locale,
        theme,
        onTokenExpirationForExpiredToken,
        onStatusChanged,
      );
    }

    SNSMobileSDKResult result = await _launchSumsub(
      accessToken,
      phone,
      email,
      locale,
      theme,
      onTokenExpiration,
      onStatusChanged,
    );

    log('Completed with result: $result');
  }

  Future<SNSMobileSDKResult> _launchSumsub(
    String accessToken,
    String phone,
    String email,
    Locale locale,
    CustomAppTheme theme,
    Future<String?> Function() onTokenExpiration,
    void Function(SNSMobileSDKStatus newStatus, SNSMobileSDKStatus prevStatus)
        onStatusChanged,
  ) async {
    _sdk = SNSMobileSDK.init(accessToken, onTokenExpiration)
        .withHandlers(onStatusChanged: onStatusChanged)
        .withApplicantConf({
          'email': email,
          'phone': phone,
        })
        .withDebug(false)
        .withLocale(locale)
        // .withTheme(_buldTheme(theme))
        .build();

    _sdkResult = await _sdk.launch();
    return _sdkResult;
  }

  Map<String, dynamic> _buldTheme(CustomAppTheme theme) {
    return {
      'universal': {
        // 'fonts': {
        //   'assets': [
        //     // refers to the ttf/otf files (ios needs them to register fonts before they could be used)
        //     {'name': 'Scriptina', 'file': 'assets/fonts/SCRIPTIN.ttf'},
        //     {
        //       'name': 'Caslon Antique',
        //       'file': 'assets/fonts/Caslon Antique.ttf'
        //     },
        //     {'name': 'Requiem', 'file': 'assets/fonts/Requiem.ttf'},
        //     {'name': 'DAGGERSQUARE', 'file': 'assets/fonts/DAGGERSQUARE.otf'},
        //     {'name': 'Plasma Drip (BRK)', 'file': 'assets/fonts/plasdrip.ttf'}
        //   ],
        //   'headline1': {
        //     'name':
        //         'Scriptina', // use ttf's `Full Name` or the name of any system font installed, or omit the key to keep the default font-face
        //     'size': 40 // in points
        //   },
        //   'headline2': {'size': 22},
        //   'subtitle1': {'name': 'DAGGERSQUARE', 'size': 20},
        //   'subtitle2': {'name': 'Plasma Drip (BRK)', 'size': 18},
        //   'body': {'name': 'Caslon Antique', 'size': 16},
        //   'caption': {'name': 'Requiem', 'size': 12}
        // },
        // 'images': {
        //   'iconMail':
        //       'assets/img/mail-icon.png', // either an image name or a path to the image (the size in points equals the size in pixels)
        //   'iconClose': {
        //     'image': 'assets/img/cross-icon.png',
        //     'scale':
        //         3, // adjusts the "logical" size (in points), points=pixels/scale
        //     'rendering': 'template' // "template" or "original"
        //   },
        //   'verificationStepIcons': {
        //     'identity': {'image': 'assets/img/robot-icon.png', 'scale': 3},
        //   }
        // },

        'colors': {
          'navigationBarItem': {
            'light': '0xFF000080', // 0xFFRRGGBBAA - white with 50% alpha
            'dark': '0xFF000000' // 0xAARRGGBB - white with 50% alpha
          },
          'alertTint':
              '0xFFFF000080', // sets both light and dark to the same color
          'backgroundCommon': {'light': '0xFFFFFFFF', 'dark': '0xFF1E232E'},
          'backgroundNeutral': {
            'light': '0xFFA59A8630' // keeps default `dark`
          },
          'backgroundInfo': {'light': '0xFF9E95C0'},
          'backgroundSuccess': {'light': '0xFF749C6F30'},
          'backgroundWarning': {'light': '0xFFF1BE4F30'},
          'backgroundCritical': {'light': '0xFFBB362A30'},
          'contentLink': {'light': '0xFFDD8B35'},
          'contentStrong': {'light': '0xFF4F4945'},
          'contentNeutral': {'light': '0xFF7F877B'},
          'contentWeak': {'light': '0xFFA59A86'},
          'contentInfo': {'light': '0xFF1B1F4E'},
          'contentSuccess': {'light': '0xFF749C6F'},
          'contentWarning': {'light': '0xFFF1BE4F'},
          'contentCritical': {'light': '0xFFBB362A'},
          'primaryButtonBackground': {'light': '0xFF558387'},
          'primaryButtonBackgroundHighlighted': {'light': '0xFF44696B'},
          'primaryButtonBackgroundDisabled': {'light': '0xFF8AA499'},
          'primaryButtonContent': {'light': '0xFFfff'},
          'primaryButtonContentHighlighted': {'light': '0xFFfff'},
          'primaryButtonContentDisabled': {'light': '0xFFfff'},
          'secondaryButtonBackground': {},
          'secondaryButtonBackgroundHighlighted': {'light': '0xFF8AA499'},
          'secondaryButtonBackgroundDisabled': {},
          'secondaryButtonContent': {'light': '0xFF558387'},
          'secondaryButtonContentHighlighted': {'light': '0xFFfff'},
          'secondaryButtonContentDisabled': {'light': '0xFF8AA499'},
          'cameraBackground': {'light': '0xFF222'},
          'cameraContent': {'light': '0xFFD2C5A5'},
          'fieldBackground': {'light': '0xFFF9F1CB80'},
          'fieldBorder': {},
          'fieldPlaceholder': {'light': '0xFF8F8376'},
          'fieldContent': {'light': '0xFF32302F'},
          'fieldTint': {'light': '0xFF558387'},
          'listSeparator': {'light': '0xFF8F837680'},
          'listSelectedItemBackground': {'light': '0xFFD2C5A580'},
          'bottomSheetHandle': {'light': '0xFF8AA499'},
          'bottomSheetBackground': {'light': '0xFFFFFFFF', 'dark': '0xFF4F4945'}
        }
      },
      'ios': {
        'metrics': {
          'commonStatusBarStyle': 'default',
          'activityIndicatorStyle': 'medium',
          'screenHorizontalMargin': 16,
          'buttonHeight': 48,
          'buttonCornerRadius': 8,
          'buttonBorderWidth': 1,
          'cameraStatusBarStyle': 'default',
          'fieldHeight': 48,
          'fieldCornerRadius': 0,
          'viewportBorderWidth': 8,
          'bottomSheetCornerRadius': 16,
          'bottomSheetHandleSize': {'width': 36, 'height': 4},
          'verificationStepCardStyle': 'filled',
          'supportItemCardStyle': 'filled',
          'documentTypeCardStyle': 'filled',
          'selectedCountryCardStyle': 'bordered',
          'cardCornerRadius': 16,
          'cardBorderWidth': 2,
          'listSectionTitleAlignment': 'natural'
        }
      }
    };
  }
}
