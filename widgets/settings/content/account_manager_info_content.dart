import 'dart:io';

import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/nav_component/nav_component.dart';
import 'package:starter_architecture_flutter_firebase/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/entities/account_manager/account_manager.dart';
import 'package:natasha/notifiers/account_manager_provider_notifier.dart';
import 'package:natasha/notifiers/client_provider_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountManagerInfoContent extends ConsumerStatefulWidget {
  const AccountManagerInfoContent({super.key});

  @override
  ConsumerState<AccountManagerInfoContent> createState() =>
      _AccountManagerInfoContentState();
}

class _AccountManagerInfoContentState
    extends ConsumerState<AccountManagerInfoContent> {
  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    AccountManager? accountManager =
        ref.watch(clientInfoProviderNotifier)?.accountManagerLinkInfo;

    return Column(
      crossAxisAlignment: ResponsiveWidget.isDesktopScreen(context)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        ResponsiveWidget.isDesktopScreen(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'settings.account_manager.header.title'.t(),
                  style: customAppTheme.textStyles.displayMedium,
                ),
              )
            : Container(),
        const SizedBox(width: double.infinity),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipOval(
            child: ref.watch(accountManagerPhotoNotifierProvider).maybeWhen(
                  orElse: () => Container(
                    height: 100,
                    width: 100,
                    color: customAppTheme.colorsPalette.primary,
                  ),
                  data: (data) => Image.memory(
                    data,
                    height: 100,
                    width: 100,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${accountManager?.firstName} ${accountManager?.lastName}',
            style: customAppTheme.textStyles.displaySmall,
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${accountManager?.jobTitle}',
            style: customAppTheme.textStyles.bodyLarge,
          ),
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: double.infinity),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'settings.account_manager.contact.title'.t(),
                style: customAppTheme.textStyles.labelMedium,
              ),
            ),
            const SizedBox(height: 14),
            NavComponent(
              backgroundColor: customAppTheme.colorsPalette.white,
              leadingBackgroundColor:
                  customAppTheme.colorsPalette.positiveActionSoft,
              leading: Icon(
                ThanosIcons.settingsAdvisorCall,
                color: customAppTheme.colorsPalette.positiveAction,
              ),
              title: 'settings.account_manager.contact.phone_call'.t(),
              subtitle:
                  '${accountManager?.phoneNumber.callingCode} ${accountManager?.phoneNumber.phoneNumber}',
              trailing: const Icon(ThanosIcons.buttonsArrow),
              onTap: () async {
                final Uri launchUri = Uri(
                  scheme: 'tel',
                  path:
                      "${accountManager?.phoneNumber.callingCode}${accountManager?.phoneNumber.phoneNumber}",
                );
                bool canLaunch = await canLaunchUrl(launchUri);
                if (canLaunch) {
                  await launchUrl(launchUri);
                } else {
                  // ignore: use_build_context_synchronously
                  ToastMessage.showToast(
                    context,
                    "can't call from this device",
                    customAppTheme,
                    type: ToastMessageType.negative,
                  );
                }
              },
            ),
            NavComponent(
              backgroundColor: customAppTheme.colorsPalette.white,
              leadingBackgroundColor:
                  customAppTheme.colorsPalette.negativeActionSoft,
              leading: Icon(
                ThanosIcons.settingsAdvisorEmail,
                color: customAppTheme.colorsPalette.negativeAction,
              ),
              title: 'settings.account_manager.contact.send_email'.t(),
              subtitle: '${accountManager?.email}',
              trailing: const Icon(ThanosIcons.buttonsArrow),
              onTap: () async {
                final Uri launchUri = Uri(
                  scheme: 'mailto',
                  path: '${accountManager?.email}',
                );
                bool canLaunch = await canLaunchUrl(launchUri);
                if (canLaunch) {
                  await launchUrl(launchUri);
                } else {
                  // ignore: use_build_context_synchronously
                  ToastMessage.showToast(
                    context,
                    "can't email from this device",
                    customAppTheme,
                    type: ToastMessageType.negative,
                  );
                }
              },
            ),
            NavComponent(
              backgroundColor: customAppTheme.colorsPalette.white,
              leadingBackgroundColor:
                  customAppTheme.colorsPalette.positiveActionSoft,
              leading: Icon(
                ThanosIcons.settingsAdvisorWhatsapp,
                color: customAppTheme.colorsPalette.positiveAction,
              ),
              title: 'settings.account_manager.contact.whatsapp'.t(),
              subtitle:
                  '${accountManager?.phoneNumber.callingCode} ${accountManager?.phoneNumber.phoneNumber}',
              trailing: const Icon(ThanosIcons.buttonsArrow),
              onTap: () async {
                Uri launchUri;

                if (Platform.isAndroid) {
                  launchUri = Uri.parse(
                    "whatsapp://send?phone=${accountManager?.phoneNumber.callingCode}${accountManager?.phoneNumber.phoneNumber}",
                  );
                } else {
                  launchUri = Uri(
                    scheme: 'https',
                    path:
                        "wa.me/${accountManager?.phoneNumber.callingCode}${accountManager?.phoneNumber.phoneNumber}",
                  );
                }
                bool canLaunch = await canLaunchUrl(launchUri);
                if (canLaunch) {
                  await launchUrl(launchUri);
                } else {
                  // ignore: use_build_context_synchronously
                  ToastMessage.showToast(
                    context,
                    "can't whatsapp from this device",
                    customAppTheme,
                    type: ToastMessageType.negative,
                  );
                }
              },
            ),
          ],
        )
      ],
    );
  }
}
