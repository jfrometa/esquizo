import 'dart:async';
import 'dart:developer';

import 'package:starter_architecture_flutter_firebase/providers/in_app_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/utils/notifiers/dynamic_state_notifier.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_amount_widget.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/promo_code_input_field.dart';
import 'package:starter_architecture_flutter_firebase/widgets/wallet_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/entities/product/product.dart';
import 'package:natasha/entities/wallet_controller/client_wallet/client_wallet.dart';
import 'package:natasha/notifiers/index.dart';
import 'package:natasha/subscriptions/application/subscription_notifier_providers.dart';
import 'package:natasha/subscriptions/domain/entity/subscription_simulation.dart';
import 'package:natasha/subscriptions/infrastructure/dto/subscription_simulation_request_dto.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/promo_code_input_field.dart';

class ProductSimulator extends ConsumerStatefulWidget {
  const ProductSimulator({
    super.key,
    required this.product,
    this.onSimulate,
    this.onReset,
  });
  final Product product;
  final Function()? onSimulate;
  final Function()? onReset;

  @override
  ConsumerState createState() => _ProductSimulatorState();
}

class _ProductSimulatorState extends ConsumerState<ProductSimulator>
    with TickerProviderStateMixin {
  late final List _infoList;
  bool _open = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _enableButtonAnimation;

  final TextEditingController _promoCodeController = TextEditingController();

  final ValueNotifier<String> _amountNotifier = ValueNotifier<String>('');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<PromoCodeInputFieldState> _simulatorPromoCodeKey =
      GlobalKey<PromoCodeInputFieldState>();

  final walletStateNotifierProvider =
      StateNotifierProvider<ValueStateNotifier<ClientWallets?>, ClientWallets?>(
          (_) {
    return ValueStateNotifier(null);
  });

  late ClientWalletResponse _clientWalletResponse;
  SubscriptionSimulation lastSimulation = SubscriptionSimulation();
  double _sourceWalletBalance = 0.0;
  double _smartWalletBalance = 0.0;
  double _baseWalletBalance = 0.0;
  Color _inputTextColor = Colors.black;

  String _selectedWalletType = 'none';

  String _sourceWalletID = '';
  String _smartWalletID = '';
  String _baseWalletID = '';

  String? _errorMessage;
  Color? _errorMessageColor;

  bool _enablePromoCode = true;
  String? _promocodeMessage;

  bool _baseBalanceIsSufficient = false;
  bool _smartBalanceIsSufficient = false;
  bool _isMoreThanMinimum = false;

  bool _promoHasError = false;
  bool _amountFocus = false;
  bool _hasDetails = false;
  bool _enableSimulation = true;

  List? _simulation;
  Timer? _debounce;

  bool _isSmartWalletAvailable = false;

  String get productName => widget.product.name;

  String get cancelationFeeForProduct {
    switch (productName) {
      case 'SMART':
        return 'marketplace_investments_product_details.section.details.smart_cancelation'
            .t();
      case 'STAR':
        return 'marketplace_investments_product_details.section.details.star_cancelation'
            .t();
      default:
        return 'marketplace_investments_product_details.section.details.all_interest_earned'
            .t();
    }
  }

  String get termForProduct {
    switch (productName) {
      case 'SMART':
        return '1 YEAR';
      default:
        return '${widget.product.termAmount} ${widget.product.termUnit}'.t();
    }
  }

  Widget get _openButton {
    CustomAppTheme customAppTheme = ref.read(appThemeProvider);

    switch (productName) {
      case 'SMART':
        return const SizedBox();
      default:
        return InkWell(
          onTap: _resetSimulation,
          child: Text(
            _open
                ? 'features.close'.t()
                : (_hasDetails
                    ? 'movements.filters.reset_button'.t()
                    : 'marketplace_investments_product_details.section.simulator.open'
                        .t()),
            style: customAppTheme.textStyles.button,
          ),
        );
    }
  }

  @override
  void initState() {
    super.initState();

    ref.read(clientWalletStateNotifierProvider).maybeWhen(
          orElse: () {},
          error: (error) {
            log('deposit_screen clientWalletStateNotifierProvider $error');
          },
          data: (wallets) {
            _setInitialWalletsParameters(wallets);
          },
        );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(.05, 0),
      end: Offset.zero,
    ).animate(_animationController);

    _enableButtonAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _infoList = [
      {
        'name':
            'marketplace_investments_product_details.section.details.provider'
                .t(),
        'value': widget.product.provider,
      },
      {
        'name': 'marketplace_investments_term.product_card.term'.t(),
        'value': termForProduct,
      },
      {
        'name': 'marketplace_investments_term.product_card.interest_rate'.t(),
        'value': '${widget.product.interestRate}% AER',
      },
      {
        'name': 'marketplace_investments_term.product_card.min_investment'.t(),
        'value': '€ ${widget.product.minimumAmount}',
      },
      {
        'name':
            'marketplace_investments_product_details.section.details.cancelation_fee'
                .t(),
        'value': cancelationFeeForProduct
      },
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _enableButtonAnimation.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _divider(customAppTheme),
          _body(customAppTheme),
          _divider(customAppTheme),
          _details(customAppTheme),
        ],
      ),
    );
  }

  Container _divider(CustomAppTheme customAppTheme) => Container(
        height: 8,
        width: double.infinity,
        color: customAppTheme.colorsPalette.secondary7,
      );

  Padding _body(CustomAppTheme customAppTheme) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _open
              ? _isSmartWalletAvailable
                  ? 512
                  : 416
              : 58,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'marketplace_investments_product_details.section.simulator'
                          .t(),
                      style: customAppTheme.textStyles.headlineLarge,
                    ),
                    _openButton,
                  ],
                ),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'marketplace_investments_product_details_simulator.simulator.choose_amount'
                              .t(),
                          style: _amountFocus
                              ? customAppTheme.textStyles.headlineMedium
                              : customAppTheme.textStyles.headlineMedium
                                  .copyWith(
                                  color:
                                      customAppTheme.colorsPalette.secondary40,
                                ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  setState(() {
                                    _amountFocus = hasFocus;
                                  });
                                },
                                child: AnimatedContainer(
                                  width: double.infinity,
                                  height: _errorMessage != null ? 90 : 72,
                                  duration: Duration.zero,
                                  curve: Curves.easeOut,
                                  child: Form(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    key: _formKey,
                                    child: InputAmountTextField(
                                      amountNotifier: _amountNotifier,
                                      validate: _onAmountChanged,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      style: customAppTheme
                                          .textStyles.displayLarge
                                          .copyWith(color: _inputTextColor),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        alignLabelWithHint: true,
                                        errorText: _errorMessage,
                                        errorBorder: InputBorder.none,
                                        errorStyle: customAppTheme
                                            .textStyles.bodyMedium
                                            .copyWith(
                                          color: _errorMessageColor,
                                        ),
                                        hintText: widget.product.minimumAmount
                                            .convertToCurrency(
                                          _clientWalletResponse
                                                  .base?.currency ??
                                              'PT',
                                        ),
                                        hintStyle: customAppTheme
                                            .textStyles.displayLarge
                                            .copyWith(
                                          color: customAppTheme
                                              .colorsPalette.primary40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.product.termAmount} '
                            '${widget.product.termUnit}',
                            style: customAppTheme.textStyles.bodyMedium,
                          ),
                          ref.watch(simulateSubscriptionNotiferProvier).when(
                                initial: () => Text(
                                  '€ 0,00',
                                  style:
                                      customAppTheme.textStyles.headlineMedium,
                                ),
                                loading: () {
                                  setState(() {
                                    _simulation = null;
                                  });

                                  return const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                data: (data) {
                                  _onSimulationDataReceived(data);

                                  return Text(
                                    data.expectedBalance != null
                                        ? '€ ${data.expectedBalance}'
                                        : '€ 0,00',
                                    style: customAppTheme
                                        .textStyles.headlineMedium,
                                  );
                                },
                                error: (error) {
                                  setState(() {
                                    _simulation = null;
                                  });
                                  // _toggleButton();
                                  log(
                                    error?.invalidParams?.toString() ??
                                        'error simulation subscription',
                                  );

                                  return Text(
                                    '€ 0,00',
                                    style: customAppTheme
                                        .textStyles.headlineMedium,
                                  );
                                },
                              )
                        ],
                      ),
                      const SizedBox(height: 16),
                      SelectWallet(
                        onWalletSelected: (wallet) {
                          final (simulation, _) =
                              ref.read(simulateRequestStateNotifierProvider);

                          final walletNotifier = ref.read(
                            walletStateNotifierProvider.notifier,
                          );

                          walletNotifier.update(wallet);

                          final amount = simulation?.amount ?? 0.00;
                          _validateInputAndHandleErrorsFor(amount.toString());

                          setState(() {
                            _sourceWalletBalance = wallet.balance ?? 0.00;
                            _sourceWalletID = wallet.id ?? 'error_loading_id';
                            _selectedWalletType = wallet.type.name;
                          });
                        },
                        wallets: _clientWalletResponse,
                        selected: _selectedWalletType,
                        amount: ref
                                .read(simulateRequestStateNotifierProvider)
                                .$1
                                ?.amount ??
                            0.00,
                      ),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: customAppTheme.colorsPalette.primary7,
                      ),
                      const SizedBox(height: 16),
                      PromoCodeInputField(
                        key: _simulatorPromoCodeKey,
                        style: PromoCodeInputStyle.noToggle,
                        controller: _promoCodeController,
                        onEditingComplete: (String? message, bool hasError) {
                          setState(() {
                            _promoHasError = hasError;
                            _promocodeMessage = message;
                          });
                        },
                        enabled: _enablePromoCode,
                        onToggle: () {},
                        onTextChange: () {
                          setState(() {
                            _promocodeMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );

  AnimatedContainer _details(CustomAppTheme customAppTheme) =>
      AnimatedContainer(
        color: _hasDetails
            ? customAppTheme.colorsPalette.primary7
            : customAppTheme.colorsPalette.white,
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _hasDetails
                    ? 'marketplace_investments_product_details_simuator_details.simulator_details'
                        .t()
                    : 'main_navigation.settings.secondary_navigation.settings.details'
                        .t(),
                textAlign: TextAlign.start,
                style: customAppTheme.textStyles.headlineLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, i) => SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _hasDetails
                            ? _simulation![i]['name']
                            : _infoList[i]['name'],
                        style: customAppTheme.textStyles.bodyMedium,
                      ),
                      Text(
                        _hasDetails
                            ? _simulation![i]['value']
                            : _infoList[i]['value'],
                        style: customAppTheme.textStyles.headlineMedium,
                      ),
                    ],
                  ),
                ),
                itemCount:
                    _hasDetails ? _simulation?.length ?? 0 : _infoList.length,
                separatorBuilder: (BuildContext context, int index) =>
                    Container(
                  height: .3,
                  color: customAppTheme.colorsPalette.secondary40,
                ),
              ),
            ),
          ],
        ),
      );

  void _validateInputAndHandleErrorsFor(String inputText) {
    try {
      double? amount = double.tryParse(inputText);
      CustomAppTheme customAppTheme = ref.read(appThemeProvider);

      if (amount == null) {
        _errorMessage = null;

        if (widget.onReset != null) {
          widget.onReset!();
        }
        return;
      } else {
        setState(() {
          final (balanceIsNotSufficient, _) = _getWalletInformation(amount);

          _errorMessage = _isMoreThanMinimum
              ? !balanceIsNotSufficient
                  ? 'marketplace_investments.investments.section.sub_categories.simulator.insufficient_funds'
                      .t()
                  : null
              : 'marketplace_investments_product_details_simulator.simulator.min_amount'
                  .t({'min_amount': widget.product.minimumAmount.toString()});

          _errorMessageColor = !_isMoreThanMinimum
              ? balanceIsNotSufficient
                  ? customAppTheme.colorsPalette.alert
                  : customAppTheme.colorsPalette.black
              : customAppTheme.colorsPalette.negativeAction;

          _inputTextColor = _isMoreThanMinimum
              ? !balanceIsNotSufficient
                  ? customAppTheme.colorsPalette.negativeAction
                  : customAppTheme.colorsPalette.black
              : customAppTheme.colorsPalette.alert;
        });
      }
    } catch (error) {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(
          exception: error,
          stack: StackTrace.current,
          library: 'product_simulator',
          context: ErrorDescription('while _validating the input amount'),
        ),
      );
      return;
    }
  }

  void _setInitialWalletsParameters(ClientWalletResponse wallets) {
    _clientWalletResponse = wallets;

    try {
      final bool isBaseWalletAvailable = wallets.base != null;

      if (isBaseWalletAvailable) {
        setState(() {
          _baseWalletBalance = wallets.base?.balance ?? 0.0;
          _baseWalletID = wallets.base?.id ?? '';
        });
      }

      _isSmartWalletAvailable = wallets.smart != null;

      if (_isSmartWalletAvailable) {
        _smartWalletBalance = wallets.smart?.balance ?? 0.0;
        _smartWalletID = wallets.smart?.id ?? '';
      }
    } catch (e) {
      log('product_simulator.dart _setInitialWalletsParameters $e');
    }
  }

  void _simulateSubscription() {
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (mounted && ref.read(simulateRequestStateNotifierProvider) != null) {
        final request = ref.read(simulateRequestStateNotifierProvider);

        await ref
            .read(simulateSubscriptionNotiferProvier.notifier)
            .simulateSubscription(widget.product.productId, request.$1!);
      }
    });
  }

  void _resetSimulation() {
    FocusScope.of(context).unfocus();
    _open ? _animationController.reverse() : _animationController.forward();
    setState(() {
      _open = !_open;
      _hasDetails = false;
      _amountNotifier.value = '';
      _promoCodeController.text = '';
      _promocodeMessage = null;
      _enablePromoCode = true;
      _simulation = null;
    });

    _simulatorPromoCodeKey.currentState?.resetState();
    ref.read(productSimulationNotifierProvider.notifier).reset();
    ref
        .read(simulateRequestStateNotifierProvider.notifier)
        .update((null, null));

    // _toggleButton();
    if (widget.onReset != null) {
      widget.onReset!();
    }
  }

  void _onSimulationDataReceived(SubscriptionSimulation simulation) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(simulateRequestStateNotifierProvider).$1?.amount == null ||
          lastSimulation.expectedBalance == simulation.expectedBalance) {
        return;
      }

      final request = ref.read(simulateRequestStateNotifierProvider)!;

      setState(() {
        lastSimulation = simulation;
        _simulation = [
          {
            'name':
                'marketplace_investments_product_details.section.details.provider'
                    .t(),
            'value': widget.product.provider,
          },
          {
            'name': 'marketplace_investments_term.product_card.term'.t(),
            'value': '${widget.product.termAmount} ${widget.product.termUnit}',
          },
          {
            'name':
                'marketplace_investments_term.product_card.interest_rate'.t(),
            'value': '${widget.product.interestRate}% AER',
          },
          {
            'name':
                'marketplace_investments_product_details_simuator_details.details.investment'
                    .t(),
            'value': '€ ${request.$1?.amount}',
          },
          {
            'name':
                'marketplace_investments_term.product_card.min_investment_forecast'
                    .t(),
            'value': '€ ${simulation.expectedBalance}',
          },
          {
            'name':
                'marketplace_investments_product_details.section.details.cancelation_fee'
                    .t(),
            'value': cancelationFeeForProduct,
          },
        ];
      });
    });
  }

  void _setWalletTypeForAmount(String amount) {
    try {
      double amount0 = double.parse(amount);

      final (_, walletType) = _getWalletInformation(amount0);

      setState(() {
        _selectedWalletType = walletType;
      });
    } catch (error) {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(
          exception: error,
          stack: StackTrace.current,
          library: 'product_simulator',
          context: ErrorDescription(
            'while _setWalletTypeForAmount the input amount',
          ),
        ),
      );
    }
  }

  (bool, String) _getWalletInformation(double amount) {
    _isMoreThanMinimum = amount >= widget.product.minimumAmount;
    _baseBalanceIsSufficient = amount <= _baseWalletBalance;
    _smartBalanceIsSufficient = amount <= _smartWalletBalance;

    final smartWalletBalanceOrNone =
        !_smartBalanceIsSufficient ? 0.0 : _smartWalletBalance;

    final smartWalletOrBaseWalletBalance = !_baseBalanceIsSufficient
        ? smartWalletBalanceOrNone
        : _baseWalletBalance;

    _sourceWalletBalance = smartWalletOrBaseWalletBalance;

    final smartWalletTypeOrNone =
        !_smartBalanceIsSufficient ? 'none' : WalletType.smart.name;

    final typeSmartOrTypeBase =
        (_baseBalanceIsSufficient && _smartBalanceIsSufficient)
            ? 'none'
            : !_baseBalanceIsSufficient
                ? smartWalletTypeOrNone
                : WalletType.base.name;

    final selectedWallet = ref.read(
      walletStateNotifierProvider,
    );

    final resultingWallet =
        typeSmartOrTypeBase == 'none' ? selectedWallet : null;

    ClientWallets? wallet;

    try {
      final assignedWallet = !_baseBalanceIsSufficient
          ? _clientWalletResponse.smart
          : _clientWalletResponse.base;

      wallet = (_baseBalanceIsSufficient && _smartBalanceIsSufficient)
          ? resultingWallet
          : assignedWallet;
    } catch (error) {
      final assignedWallet =
          !_baseBalanceIsSufficient ? null : _clientWalletResponse.base;

      wallet = (_baseBalanceIsSufficient && _smartBalanceIsSufficient)
          ? resultingWallet
          : assignedWallet;
    }

    final balanceIsSufficient = amount <= _sourceWalletBalance;

    ref
        .read(simulateRequestStateNotifierProvider.notifier)
        .update((SubscriptionSimulationRequestDTO(amount: amount), wallet));

    if (_isMoreThanMinimum && balanceIsSufficient && wallet != null) {
      _enableSimulation = true;

      if (widget.onSimulate != null) {
        widget.onSimulate!();
      }

      log('wallet != null in _getWalletInformation wallet: $wallet');
      return (balanceIsSufficient, typeSmartOrTypeBase);
    }

    if (!_isMoreThanMinimum || !balanceIsSufficient || wallet == null) {
      _enableSimulation = false;

      if (widget.onReset != null) {
        widget.onReset!();
      }
      log('wallet == null in _getWalletInformation balanceIsNotSufficient: $balanceIsSufficient  wallet: $wallet');
    }

    return (balanceIsSufficient, typeSmartOrTypeBase);
  }

  Future<void> _onAmountChanged(String amount) async {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    ref
        .read(
          walletStateNotifierProvider.notifier,
        )
        .update(null);

    if (amount.isEmpty) {
      _errorMessage = null;
      return;
    }

    _validateInputAndHandleErrorsFor(amount);

    _setWalletTypeForAmount(amount);

    _simulateSubscription();
  }
}
