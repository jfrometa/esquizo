import 'package:starter_architecture_flutter_firebase/helpers/currency_converter.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/nav_component/nav_component.dart';
import 'package:starter_architecture_flutter_firebase/widgets/radio_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/entities/wallet_controller/client_wallet/client_wallet.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/radio_button.dart';

typedef WalletIdCallback = void Function(ClientWallets wallet);

class SelectWallet extends ConsumerStatefulWidget {
  const SelectWallet({
    super.key,
    required this.wallets,
    required this.onWalletSelected,
    required this.selected,
    required this.amount,
  });

  final ClientWalletResponse wallets;
  final String selected;
  final WalletIdCallback onWalletSelected;
  final double amount;

  @override
  ConsumerState<SelectWallet> createState() => SelectWalletState();
}

class SelectWalletState extends ConsumerState<SelectWallet> {
  @override
  Widget build(BuildContext context) {
    CustomAppTheme theme = ref.watch(appThemeProvider);
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: (widget.wallets.clientWallets?.length ?? 0) >= 2 ? 160 : 80,
      width: screenWidth,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text(
            'transfer_make_transfer.withdraw_options'.t(),
            style: theme.textStyles.labelMedium,
          ),
          ...widget.wallets.clientWallets!.map<NavComponent>(
            (wallet) {
              final isBalanceGreaterThanZero = wallet.balance != null &&
                  wallet.balance! > 0 &&
                  wallet.balance! >= widget.amount;

              return NavComponent(
                leading: Icon(
                  wallet.type == WalletType.smart
                      ? ThanosIcons.settingsWalletsSmart
                      : ThanosIcons.settingsWalletsBase,
                  color: isBalanceGreaterThanZero
                      ? null
                      : theme.colorsPalette.neutral6,
                ),
                backgroundColor: theme.colorsPalette.white,
                textColor: isBalanceGreaterThanZero
                    ? theme.colorsPalette.secondary
                    : theme.colorsPalette.neutral6,
                leadingBackgroundColor: isBalanceGreaterThanZero
                    ? theme.colorsPalette.primary7
                    : theme.colorsPalette.neutral2,
                title: wallet.type == WalletType.smart
                    ? 'settings_personal.section.manage_wallets.section.my_wallets.section.smart_wallet'
                        .t()
                    : 'home.wallet.base_wallet_option'.t(),
                subtitle: wallet.balance?.convertToCurrency(wallet.currency!),
                trailing: RadioButton(
                  groupValue: wallet.type.name,
                  onChanged: (_) {
                    if (isBalanceGreaterThanZero) {
                      _updateSelectedWallet(wallet);
                    }
                  },
                  value: widget.selected,
                  isEnabled: isBalanceGreaterThanZero,
                ),
                onTap: () {
                  if (isBalanceGreaterThanZero) {
                    _updateSelectedWallet(wallet);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _updateSelectedWallet(ClientWallets wallet) {
    widget.onWalletSelected(wallet);
    FocusScope.of(context).unfocus();
  }
}
