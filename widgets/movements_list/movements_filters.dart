import 'package:starter_architecture_flutter_firebase/helpers/text_capitalization.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/animated_button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/check_box.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_field.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/select_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovementsFilters {
  MovementsFilters({
    this.minAmount,
    this.maxAmount,
    this.from,
    this.to,
    this.status = 'all',
    this.types,
  });
  double? minAmount;
  double? maxAmount;
  DateTime? from;
  DateTime? to;
  String? status;
  List<String>? types;
}

enum MovementType {
  DEPOSIT,
  WITHDRAWAL,
  TRANSFER,
  INTEREST,
  PRODUCT_SUBSCRIBED,
  FEE,
  UNKNOWN
}

extension StringToMovementType on String {
  MovementType toMovementType() {
    return MovementType.values.firstWhere(
      (element) => element.toString().split('.').last == toUpperCase(),
      orElse: () => throw ArgumentError('Invalid MovementType string: $this'),
    );
  }
}

extension MovementTypeExtension on MovementType {
  String get value {
    switch (this) {
      case MovementType.DEPOSIT:
        return 'DEPOSIT';
      case MovementType.WITHDRAWAL:
        return 'WITHDRAWAL';
      case MovementType.TRANSFER:
        return 'TRANSFER';
      case MovementType.INTEREST:
        return 'INTEREST';
      case MovementType.PRODUCT_SUBSCRIBED:
        return 'PRODUCT_SUBSCRIBED';
      case MovementType.FEE:
        return 'FEE';
      case MovementType.UNKNOWN:
        return 'UNKNOWN';
    }
  }

  bool isEqual(MovementType compare) {
    return value == compare.value;
  }
}

enum MovementStatus { PENDING, COMPLETED, CANCELLED, UNKNOWN, NEW }

extension StringToMovementStatus on String {
  MovementStatus toMovementStatus() {
    return MovementStatus.values.firstWhere(
      (element) => element.toString().split('.').last == toUpperCase(),
      orElse: () => throw ArgumentError('Invalid MovementStatus string: $this'),
    );
  }
}

extension MovementStatusExtension on MovementStatus {
  String get value {
    switch (this) {
      case MovementStatus.PENDING:
        return 'PENDING';
      case MovementStatus.CANCELLED:
        return 'CANCELLED';
      case MovementStatus.COMPLETED:
        return 'COMPLETED';

      case MovementStatus.UNKNOWN:
        return 'UNKNOWN';
      case MovementStatus.NEW:
        return 'NEW';
    }
  }

  bool isEqual(MovementStatus compare) {
    return value == compare.value;
  }
}

enum FilterType { BASEWALLETS, SMARTWALLETS, SUBSCRIPTIONS }

extension FilterTypeExtension on FilterType {
  String get value {
    switch (this) {
      case FilterType.BASEWALLETS:
        return 'BASEWALLETS';
      case FilterType.SMARTWALLETS:
        return 'SMARTWALLETS';
      case FilterType.SUBSCRIPTIONS:
        return 'SUBSCRIPTIONS';
    }
  }

  bool isEqual(FilterType compare) {
    return value == compare.value;
  }
}

class MovementsFiltersModal extends ConsumerStatefulWidget {
  const MovementsFiltersModal({
    super.key,
    this.filters,
    required this.filterType,
    required this.onApplyFilters,
  });

  final MovementsFilters? filters;
  final FilterType filterType;
  final Function(MovementsFilters) onApplyFilters;

  @override
  ConsumerState createState() => _MovementsFiltersModalState();
}

class _MovementsFiltersModalState extends ConsumerState<MovementsFiltersModal> {
  late TextEditingController _dateFromController;
  late TextEditingController _dateToController;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;

  double? _minAmount;
  double? _maxAmount;
  DateTime? _from;
  DateTime? _to;
  String? _status;

  List<String> _selectedTypeFilters = [];

  final List<String> _byStatus = [
    'movements.filters.by_status.all'.t(),
    'movements.filters.by_status.pending'.t(),
    'movements.filters.by_status.completed'.t()
  ];

  final bool _enableButton = true;

//TODO: - agree with BE upcomming filters.

  final Map<String, dynamic> _typeSubscriptionsFilters = {
    'Subscriptions': {
      'type': 'subscriptions',
      'value': false,
      'children': {
        'movements.interest_earned.label'.t(): {
          'type': MovementType.INTEREST.value,
          'value': false
        },
        'movements.product_subscribed'.t(): {
          'type': MovementType.PRODUCT_SUBSCRIBED.value,
          'value': false
        },
        // 'movements.monthly_installment'.t(): {
        //   'type': 'monthly_installment',
        //   'value': false
        // },
        // 'movements.service_retainer': {
        //   'type': 'service_retainer',
        //   'value': false
        // },
        // 'movements.penalty_fee'.t(): {'type': 'penalty_fee', 'value': false},
        // 'home.notification_center.notifications.subscription_renewed_label'.t():
        //     {'type': 'subscription_renewed', 'value': false},
      }
    },
  };

  late final Map<String, dynamic> _typeSmartFilters = {
    // 'Interest': {
    //   'type': MovementType.INTEREST.value,
    //   'value': false,
    // },

    'Transfers': {
      'type': MovementType.TRANSFER.value,
      'value': false,
      //   'children': {
      //     'movements.transfer_sent'.t(): {'type': 'sent', 'value': false},
      //     'movements.transfer_received'.t(): {'type': 'received', 'value': false},
      //     'movements.transfer_cancelled'.t(): {
      //       'type': 'cancelled',
      //       'value': false
      //     },
      //     'movements.transfer_reversed'.t(): {'type': 'reversed', 'value': false},
      //   }
    },
    ..._typeSubscriptionsFilters,
  };

  final Map<String, dynamic> _typeCommonFilters = {
    'Deposits': {
      'type': MovementType.DEPOSIT.value,
      'value': false,
    },
    'Withdrawals': {
      'type': MovementType.WITHDRAWAL.value,
      'value': false,
    },
  };

  late final Map<String, dynamic> _typeFilters = {
    if (widget.filterType == FilterType.SMARTWALLETS ||
        widget.filterType == FilterType.BASEWALLETS)
      ..._typeCommonFilters,
    if (widget.filterType == FilterType.SMARTWALLETS) ..._typeSmartFilters,
    if (widget.filterType == FilterType.SUBSCRIPTIONS)
      ..._typeSubscriptionsFilters,
  };

  @override
  void initState() {
    super.initState();

    _minAmount = widget.filters?.minAmount;
    _maxAmount = widget.filters?.maxAmount;
    _from = widget.filters?.from;
    _to = widget.filters?.to;
    _status = widget.filters?.status?.capitalize() ?? 'all';
    _selectedTypeFilters = widget.filters?.types ?? [];

    _dateToController = TextEditingController(text: _to?.toString() ?? '');
    _dateFromController = TextEditingController(text: _from?.toString() ?? '');
    _minAmountController =
        TextEditingController(text: _minAmount?.toString() ?? '');
    _maxAmountController =
        TextEditingController(text: _maxAmount?.toString() ?? '');
  }

  Widget _renderTypeFilterList(CustomAppTheme customAppTheme) {
    return Column(
      children: _typeFilters.keys
          .map<Widget>(
            (type) => Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type,
                        style: customAppTheme.textStyles.headlineMedium,
                      ),
                      CheckBox(
                        value: _selectedTypeFilters
                            .contains(_typeFilters[type]['type']),
                        onChanged: (value) {
                          List<String> addList = _typeFilters[type]['children']
                                  ?.keys
                                  .map<String>(
                                    (subType) => _typeFilters[type]['children']
                                        [subType]['type'] as String,
                                  )
                                  .toList() ??
                              [];

                          if (value!) {
                            List<String> tmp = _selectedTypeFilters;
                            for (String element in addList) {
                              tmp.remove(element);
                              tmp.add(element);
                            }
                            tmp = [...tmp, _typeFilters[type]['type']];
                            setState(() {
                              _selectedTypeFilters = tmp;
                            });
                          } else {
                            List<String> tmp = _selectedTypeFilters;
                            tmp.remove(_typeFilters[type]['type']);

                            for (int i = 0; i < addList.length; i++) {
                              String element = addList[i];
                              tmp.remove(element);
                            }

                            setState(() {
                              _selectedTypeFilters = tmp;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                ..._typeFilters[type]['children']
                        ?.keys
                        .map(
                          (subType) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                subType,
                                style: customAppTheme.textStyles.bodyLarge,
                              ),
                              CheckBox(
                                small: true,
                                value: _selectedTypeFilters.contains(
                                  _typeFilters[type]['children'][subType]
                                      ['type'],
                                ),
                                onChanged: (value) {
                                  if (value!) {
                                    setState(() {
                                      _selectedTypeFilters = [
                                        ..._selectedTypeFilters,
                                        _typeFilters[type]['children'][subType]
                                            ['type']
                                      ];
                                    });
                                  } else {
                                    List<String> tmp = _selectedTypeFilters;
                                    tmp.remove(
                                      _typeFilters[type]['children'][subType]
                                          ['type'],
                                    );
                                    setState(() {
                                      _selectedTypeFilters = tmp;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                        .toList() ??
                    [],
              ],
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return MaterialApp(
      theme: Theme.of(context),
      home: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Scaffold(
            backgroundColor: customAppTheme.colorsPalette.white,
            appBar: Header(
              context: context,
              leading: IconButton(
                icon: const Icon(ThanosIcons.buttonsBack),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              trailing: TextButton(
                onPressed: () {
                  _maxAmountController.text = '';
                  _minAmountController.text = '';
                  _dateFromController.text = '';
                  _dateToController.text = '';

                  setState(() {
                    _minAmount = null;
                    _maxAmount = null;
                    _from = null;
                    _to = null;
                    _status = 'all';
                    _selectedTypeFilters = [];

                    widget.onApplyFilters(
                      MovementsFilters(
                        from: _from,
                        minAmount: _minAmount,
                        maxAmount: _maxAmount,
                        to: _to,
                        status: _status,
                      ),
                    );
                  });
                },
                child: Text(
                  'movements.filters.reset_button'.t(),
                  style: customAppTheme.textStyles.button,
                ),
              ),
              title: 'movements.filters.header'.t(),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'movements.filters.by_amount.label'.t(),
                      style: customAppTheme.textStyles.labelMedium.copyWith(
                        color: customAppTheme.colorsPalette.secondary40,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InputField(
                            controller: _minAmountController,
                            label: 'movements.filters.by_amount.min'.t(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _minAmount = double.tryParse(value ?? '0');
                            },
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: InputField(
                            controller: _maxAmountController,
                            label: 'movements.filters.by_amount.max'.t(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _maxAmount = double.tryParse(value ?? '0');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'movements.filters.by_date.label'.t(),
                      style: customAppTheme.textStyles.labelMedium.copyWith(
                        color: customAppTheme.colorsPalette.secondary40,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InputField.dateSelector(
                            label: 'movements.filters.by_date.from'.t(),
                            controller: _dateFromController,
                            context: context,
                            customAppTheme: customAppTheme,
                            onSelected: (date) {
                              setState(() {
                                _from = date;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: InputField.dateSelector(
                            label: 'To',
                            controller: _dateToController,
                            context: context,
                            customAppTheme: customAppTheme,
                            onSelected: (date) {
                              setState(() {
                                _to = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'movements.filters.by_status.label'.t(),
                      style: customAppTheme.textStyles.labelMedium.copyWith(
                        color: customAppTheme.colorsPalette.secondary40,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectInputField<String>(
                      label: 'Status'.t(),
                      initialValue: _status?.capitalize(),
                      value: _status?.capitalize(),
                      items: _byStatus
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              onTap: () => setState(() {
                                switch (status.toLowerCase()) {
                                  default:
                                    _status = status.toLowerCase();
                                }
                              }),
                              child: Text(status),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'movements.filters.type'.t(),
                      style: customAppTheme.textStyles.labelMedium.copyWith(
                        color: customAppTheme.colorsPalette.secondary40,
                      ),
                    ),
                    _renderTypeFilterList(customAppTheme),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _displayButton()
                ? AnimatedButton(
                    buttonEnabled: _enableButton,
                    text: Text('button.apply_filters'.t()),
                    onPressed: () {
                      widget.onApplyFilters(
                        MovementsFilters(
                          from: _from,
                          to: _to,
                          maxAmount: _maxAmountController.text != ''
                              ? double.parse(_maxAmountController.text)
                              : null,
                          minAmount: _minAmountController.text != ''
                              ? double.parse(_minAmountController.text)
                              : null,
                          status: _status,
                          types: _selectedTypeFilters,
                        ),
                      );
                      Navigator.pop(context);
                    },
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }

  bool _displayButton() {
    bool showButton = true;
    if (_minAmount != null ||
        _maxAmount != null ||
        _from != null ||
        _to != null ||
        _status != 'all' ||
        _selectedTypeFilters.isNotEmpty) {
      return showButton;
    }
    showButton = false;
    return showButton;
  }
}
