import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/utils/notifiers/dynamic_state_notifier.dart';
import 'package:starter_architecture_flutter_firebase/utils/secure_storange_manager.dart';
import 'package:starter_architecture_flutter_firebase/utils/shared_preference_manager.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/nav_component/nav_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/entities/client_info/client_info.dart';
import 'package:natasha/entities/kyc/kyc_status/kyc_status.dart';
import 'package:natasha/entities/registration/update_passcode/request_update_passcode.dart';
import 'package:natasha/notifiers/account_manager_provider_notifier.dart';
import 'package:natasha/notifiers/authentication_provider_notifier.dart';
import 'package:natasha/notifiers/client_provider_notifier.dart';

final requestUpdatePasscodeProvider = StateNotifierProvider<
    ValueStateNotifier<RequestUpdatePasscode?>, RequestUpdatePasscode?>(
  (ref) => ValueStateNotifier(RequestUpdatePasscode()),
);

final updatePasscodeProvider = StateProvider<UpdatePasscode>(
  (_) => UpdatePasscode(),
);

// // @RoutePage()
class SettingsRouterScreen extends ConsumerStatefulWidget {
  const SettingsRouterScreen({super.key});

  @override
  ConsumerState<SettingsRouterScreen> createState() =>
      _SettingsRouterScreenState();
}

class _SettingsRouterScreenState extends ConsumerState<SettingsRouterScreen> {
  final SharedPreferenceManager _prefs = SharedPreferenceManager.instance;
  final SecureStoreManager _storage = SecureStoreManager.instance;

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    Color navComponentColor(TabsRouter tabsRouter, int tab) =>
        tabsRouter.activeIndex == tab
            ? customAppTheme.colorsPalette.primary70
            : customAppTheme.colorsPalette.white;

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: Header(
        context: context,
        title: 'settings_personal.title'.t(),
        trailing: TextButton(
          child: Text(
            'main_navigation.logout'.t(),
            style: customAppTheme.textStyles.button,
          ),
          onPressed: () async {
            await ref
                .read(authenticationNotifierProvider.notifier)
                .unauthenticate();

            ref.read(clientInfoRequestProviderNotifier.notifier).reset();

            await _prefs.clearAllPreferences();
            await _storage.deleteAll();

            // ignore: use_build_context_synchronously
            context.router.popUntilRoot();
            await context.router.replaceAll([const OutOfAppRoute()]);
          },
        ),
      ),
      body: ResponsiveWidget(
        mobileScreen: const AutoRouter(),
        desktopScreen: AutoTabsRouter(
          routes: const [
            PersonalDetailsRoute(),
            AccountManagerInfoRoute(),
            ManageCommunicationsRoute(),
            ManageDevicesRoute(),
            ManageWalletsRoute(),
            ChangePasscodeRoute(),
            ChangeLanguageRoute(),
            ReferralProgramRoute(),
            UpdatePasscodeSuccessRoute()
            // OTPOverlayRoute(),
          ],
          builder: (context, child) {
            final tabsRouter = AutoTabsRouter.of(context);
            ClientInfo? clientInfo = ref.watch(clientInfoProviderNotifier);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Row(
                children: [
                  SizedBox(
                    width: 400,
                    child: ListView(
                      controller: ScrollController(),
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64),
                          child: Text(
                            'settings_personal.section.personal'.t(),
                            style: customAppTheme.textStyles.labelMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        clientInfo?.accountManagerLinkInfo != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 48),
                                child: NavComponent(
                                  backgroundColor:
                                      navComponentColor(tabsRouter, 1),
                                  leadingBackgroundColor:
                                      navComponentColor(tabsRouter, 1),
                                  leading: ref
                                      .watch(
                                        accountManagerPhotoNotifierProvider,
                                      )
                                      .maybeWhen(
                                        orElse: () => Container(),
                                        data: (data) => ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.memory(
                                            data,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                  title:
                                      'settings_personal.section.personal.cta.financial_advisor.title'
                                          .t(),
                                  onTap: () {
                                    tabsRouter.setActiveIndex(1);
                                  },
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64),
                          child: Text(
                            'settings_personal.section.settings'.t(),
                            style: customAppTheme.textStyles.labelMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: NavComponent(
                            backgroundColor: navComponentColor(tabsRouter, 4),
                            leadingBackgroundColor:
                                navComponentColor(tabsRouter, 4),
                            leading:
                                const Icon(ThanosIcons.settingsWalletsBase),
                            title:
                                'settings_personal.section.settings.cta.manage_wallets.title'
                                    .t(),
                            onTap: () {
                              if (ref
                                      .watch(clientInfoProviderNotifier)
                                      ?.kycStatus ==
                                  KYCStatusType.APPROVED) {
                                tabsRouter.setActiveIndex(4);
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: NavComponent(
                            backgroundColor: navComponentColor(tabsRouter, 5),
                            leadingBackgroundColor:
                                navComponentColor(tabsRouter, 5),
                            leading: const Icon(ThanosIcons.settingsPasscode),
                            title:
                                'settings_personal.section.settings.cta.change_passcode.title'
                                    .t(),
                            onTap: () => tabsRouter.setActiveIndex(5),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
