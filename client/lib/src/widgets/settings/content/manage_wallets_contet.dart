import 'dart:async';
import 'dart:developer';

import 'package:starter_architecture_flutter_firebase/helpers/currency_converter.dart';
import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/nav_component/nav_component.dart';
import 'package:starter_architecture_flutter_firebase/widgets/radio_button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/core/screen_representable/screen_states.dart';
import 'package:natasha/entities/wallet_controller/client_wallet/client_wallet.dart';
import 'package:natasha/notifiers/wallet_controller_provider_notififer.dart';

class ManageWalletsContent extends ConsumerStatefulWidget {
  const ManageWalletsContent({super.key});

  @override
  ConsumerState<ManageWalletsContent> createState() =>
      _ManageWalletsContentState();
}

class _ManageWalletsContentState extends ConsumerState<ManageWalletsContent> {
  String _defaultWallet = '';
  bool _loading = false;

  Future<void> _getWallets() async {
    await ref.read(clientWalletStateNotifierProvider.notifier).clientWallet();
  }

  String _walletName(WalletType? walletType) {
    if (walletType == null) {
      return '';
    }
    if (walletType == WalletType.base) {
      return 'settings_personal.section.manage_wallets.section.my_wallets.section.base_wallet.title'
          .t();
    }
    return 'settings_personal.section.manage_wallets.section.my_wallets.section.smart_wallet.title'
        .t();
  }

  Future _setDefaultWallet(ClientWallets wallet) async {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    setState(() {
      _loading = true;
    });

    if (_defaultWallet != wallet.id) {
      var response = await ref
          .read(defaultWalletStateNotifierProvider.notifier)
          .setDefaultWallet(wallet.id!, true);

      response.fold(
        (failure) {
          ToastMessage.showToast(
            context,
            'Unable to change',
            customAppTheme,
            type: ToastMessageType.negative,
          );
        },
        (response) {
          setState(() {
            _defaultWallet = response.id!;
          });
          ToastMessage.showToast(context, 'Updated', customAppTheme);
        },
      );

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_getWallets());
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    ref.listen<ScreenState<ClientWalletResponse>>(
        clientWalletStateNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () {},
        error: (error) {
          log(error.toString());
        },
        data: (wallets) {
          wallets.clientWallets!.every((element) {
            if (element.favourite != null && element.favourite!) {
              setState(() {
                _defaultWallet = element.id!;
              });
              return false;
            }
            return true;
          });
        },
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidget.isDesktopScreen(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'settings_personal.section.manage_wallets.section.78'.t(),
                  style: customAppTheme.textStyles.displayMedium,
                ),
              )
            : Container(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'settings_personal.section.manage_wallets.section.information.text.69'
                .t(),
            style: customAppTheme.textStyles.bodyLarge,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'settings_personal.section.manage_wallets.section.my_wallets.section'
                .t(),
            style: customAppTheme.textStyles.labelMedium,
          ),
        ),
        const SizedBox(height: 14),
        ref.watch(clientWalletStateNotifierProvider).maybeWhen(
              orElse: () => Center(
                child: CircularProgressIndicator(
                  color: customAppTheme.colorsPalette.tertiary,
                ),
              ),
              data: (data) {
                List<ClientWallets>? accountList = data.clientWallets;
                if (accountList == null) {
                  return Container();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: accountList.length,
                  itemBuilder: (ctx, i) {
                    return NavComponent(
                      onTap: () async {
                        if (!_loading) {
                          await _setDefaultWallet(accountList[i]);
                        }
                      },
                      leading: Icon(
                        accountList[i].type == WalletType.base
                            ? ThanosIcons.settingsWalletsBase
                            : ThanosIcons.settingsWalletsSmart,
                      ),
                      title:
                          "${_walletName(accountList[i].type)} ${(_defaultWallet == accountList[i].id) ? "settings_personal.section.manage_wallets.section.my_wallets.section.base_wallet.default".t() : ""}",
                      subtitle: accountList[i]
                          .balance
                          ?.convertToCurrency(accountList[i].currency!),
                      backgroundColor: customAppTheme.colorsPalette.white,
                      leadingBackgroundColor:
                          customAppTheme.colorsPalette.neutral2,
                      trailing:
                          (_loading && _defaultWallet != accountList[i].id)
                              ? const Padding(
                                  padding: EdgeInsets.all(7.0),
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : RadioButton(
                                  groupValue: _defaultWallet,
                                  value: accountList[i].id!,
                                  onChanged: (value) {
                                    if (!_loading) {
                                      _setDefaultWallet(accountList[i]);
                                    }
                                  },
                                ),
                    );
                  },
                );
              },
              error: (err) => const Center(
                child: Text('Error'),
              ),
            ),
      ],
    );
  }
}
