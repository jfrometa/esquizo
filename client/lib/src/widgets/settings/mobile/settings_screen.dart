import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/providers/general.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/utils/biometric_manager.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/nav_component/nav_component.dart';
import 'package:starter_architecture_flutter_firebase/widgets/toast_message.dart';
import 'package:starter_architecture_flutter_firebase/widgets/toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/entities/client_info/client_info.dart';
import 'package:natasha/entities/kyc/kyc_status/kyc_status.dart';
import 'package:natasha/notifiers/account_manager_provider_notifier.dart';
import 'package:natasha/notifiers/client_provider_notifier.dart';

// @RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(accountManagerPhotoNotifierProvider.notifier).getPhoto(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    ClientInfo? clientInfo = ref.watch(clientInfoProviderNotifier);

    BiometricsManager().isBiometricAvailable;
    final isBiometricsEnabled = ref.watch(isBiometricAvailableProvider);
    return ColoredBox(
      color: customAppTheme.colorsPalette.white,
      child: ListView(
        controller: ScrollController(),
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'settings_personal.section.personal'.t(),
              style: customAppTheme.textStyles.labelMedium,
            ),
          ),
          const SizedBox(height: 16),
          NavComponent(
            backgroundColor: customAppTheme.colorsPalette.white,
            leadingBackgroundColor: customAppTheme.colorsPalette.neutral2,
            leading: const Icon(ThanosIcons.settingsMyDetails),
            title:
                'settings_personal.section.personal.cta.my_personal_details.title'
                    .t(),
            subtitle:
                'settings_personal.section.personal.cta.my_personal_details.description'
                    .t(),
            trailing: Icon(
              color: customAppTheme.colorsPalette.primary,
              ThanosIcons.buttonsArrow,
            ),
            onTap: () async {
              await context.router.push(const PersonalDetailsMobileRoute());
            },
          ),
          clientInfo?.accountManagerLinkInfo != null
              ? NavComponent(
                  backgroundColor: customAppTheme.colorsPalette.white,
                  leading:
                      ref.watch(accountManagerPhotoNotifierProvider).maybeWhen(
                            orElse: () => Container(),
                            data: (data) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                data,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                  title:
                      'settings_personal.section.personal.cta.financial_advisor.title'
                          .t(),
                  subtitle:
                      '${clientInfo?.accountManagerLinkInfo?.firstName} ${clientInfo?.accountManagerLinkInfo?.lastName}',
                  trailing: Icon(
                    color: customAppTheme.colorsPalette.primary,
                    ThanosIcons.buttonsArrow,
                  ),
                  onTap: () async {
                    await context.router
                        .push(const AccountManagerInfoMobileRoute());
                  },
                )
              : Container(),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'settings_personal.section.settings'.t(),
              style: customAppTheme.textStyles.labelMedium,
            ),
          ),
          //todo: add stuff for password

          const SizedBox(height: 16),
          NavComponent(
            backgroundColor: customAppTheme.colorsPalette.white,
            leadingBackgroundColor: customAppTheme.colorsPalette.neutral2,
            leading: const Icon(ThanosIcons.settingsWalletsBase),
            title: 'settings_personal.section.settings.cta.manage_wallets.title'
                .t(),
            subtitle:
                'settings_personal.section.settings.cta.manage_wallets.description'
                    .t(),
            trailing: Icon(
              color: customAppTheme.colorsPalette.primary,
              ThanosIcons.buttonsArrow,
            ),
            onTap: () async {
              if (ref.watch(clientInfoProviderNotifier)?.kycStatus ==
                  KYCStatusType.APPROVED) {
                await context.router.push(const ManageWalletsMobileRoute());
              } else {
                ToastMessage.showToast(
                  context,
                  'KYC is still pending',
                  ref.read(appThemeProvider),
                  type: ToastMessageType.negative,
                );
              }
            },
          ),
          NavComponent(
            backgroundColor: customAppTheme.colorsPalette.white,
            leadingBackgroundColor: customAppTheme.colorsPalette.neutral2,
            leading: const Icon(ThanosIcons.settingsPasscode),
            title:
                'settings_personal.section.settings.cta.change_passcode.title'
                    .t(),
            subtitle:
                'settings_personal.section.settings.cta.change_passcode.description'
                    .t(),
            trailing: Icon(
              color: customAppTheme.colorsPalette.primary,
              ThanosIcons.buttonsArrow,
            ),
            onTap: () async {
              await context.router.push(const ChangePasscodeMobileRoute());
            },
          ),
          NavComponent(
            backgroundColor: customAppTheme.colorsPalette.white,
            leadingBackgroundColor: customAppTheme.colorsPalette.neutral2,
            leading: const Icon(ThanosIcons.settingsBiometricsFaceid),
            title:
                'settings_personal.section.settings.toggle.login_with_biometrics.title'
                    .t(),
            subtitle: BiometricsManager().isBiometricAvailable
                ? 'settings_personal.section.settings.cta.login_with_biometrics.description'
                    .t()
                : 'settings_personal.section.settings.cta.login_with_biometrics.off.description'
                    .t(),
            trailing: Toggle(
              value: isBiometricsEnabled,
              onChanged: (_) async {
                await _toggleBiometrics(isBiometricsEnabled);
              },
            ),
            onTap: () async {
              await _toggleBiometrics(isBiometricsEnabled);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _toggleBiometrics(bool isBiometricsEnabled) async {
    final value =
        await BiometricsManager().toggleBiometrics(!isBiometricsEnabled);
    ref.read(isBiometricAvailableProvider.notifier).update(value);
  }
}
