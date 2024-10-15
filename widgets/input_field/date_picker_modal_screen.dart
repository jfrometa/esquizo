import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';

class DatePickerController {
  DatePickerController({
    int? initialDay,
    int? initialMonth,
    int? initialYear,
  }) {
    day = initialDay ?? 1;
    month = initialMonth ?? 1;
    year = initialYear ?? 1900;
  }
  late int day;
  late int month;
  late int year;

  String get date => '$day/$month/$year';
}

// @RoutePage()
class DatePickerModalScreen extends StatefulWidget {
  const DatePickerModalScreen({
    super.key,
    required this.customAppTheme,
    required this.label,
    this.description,
    this.controller,
    this.onSelect,
    this.validator,
  });
  final CustomAppTheme customAppTheme;
  final String label;
  final String? description;
  final DatePickerController? controller;
  final Function(DateTime)? onSelect;
  final bool Function(DateTime)? validator;

  @override
  State createState() => _DatePickerModalScreenState();
}

class _DatePickerModalScreenState extends State<DatePickerModalScreen> {
  late final List<int> years =
      List.generate(100, (index) => (widget.controller?.year ?? 0) - index);
  late final List<int> months = List.generate(12, (index) => index + 1);
  late final List<int> days = List.generate(31, (index) => index + 1);
  late final List<String> monthNames = [
    'home.graph.jan'.t(),
    'home.graph.feb'.t(),
    'home.graph.mar'.t(),
    'home.graph.apr'.t(),
    'home.graph.may'.t(),
    'home.graph.jun'.t(),
    'home.graph.jul'.t(),
    'home.graph.aug'.t(),
    'home.graph.sep'.t(),
    'home.graph.oct'.t(),
    'home.graph.nov'.t(),
    'home.graph.dec'.t(),
  ];

  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  late bool _buttonEnabled;

  _validate() {
    var selectedDay = DateTime(
      years[_selectedYear],
      months[_selectedMonth],
      days[_selectedDay],
    );
    if (widget.validator!(selectedDay)) {
      setState(() {
        _buttonEnabled = true;
      });
    } else {
      setState(() {
        _buttonEnabled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _buttonEnabled = widget.validator == null;
    _selectedYear = 0;
    _selectedMonth = 0;
    _selectedDay = 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: widget.customAppTheme.colorsPalette.white,
        appBar: Header(
          context: context,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(ThanosIcons.buttonsBack),
            color: widget.customAppTheme.colorsPalette.secondary,
          ),
          title: widget.label,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  widget.description != null
                      ? Text(
                          widget.description!,
                          style: widget.customAppTheme.textStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 70.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  horizontal: BorderSide(
                                    width: 0.5,
                                    color: widget
                                        .customAppTheme.colorsPalette.primary
                                        .withOpacity(0.2),
                                  ),
                                ),
                              ),
                              child: const SizedBox(
                                height: 56,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ListWheelScrollView(
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setState(() {
                                      _selectedYear = index;
                                    });
                                    if (widget.validator != null) {
                                      _validate();
                                    }
                                  },
                                  diameterRatio: 2.5,
                                  itemExtent: 56,
                                  children: years
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => Center(
                                          child: Text(
                                            '${entry.value}',
                                            style: entry.key == _selectedYear
                                                ? widget.customAppTheme
                                                    .textStyles.displaySmall
                                                : widget.customAppTheme
                                                    .textStyles.bodyLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: ListWheelScrollView(
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setState(() {
                                      _selectedMonth = index;
                                    });
                                    if (widget.validator != null) {
                                      _validate();
                                    }
                                  },
                                  diameterRatio: 2.5,
                                  itemExtent: 56,
                                  children: months
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => Center(
                                          child: Text(
                                            monthNames[entry.value - 1],
                                            style: entry.key == _selectedMonth
                                                ? widget.customAppTheme
                                                    .textStyles.displaySmall
                                                : widget.customAppTheme
                                                    .textStyles.bodyLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: ListWheelScrollView(
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setState(() {
                                      _selectedDay = index;
                                    });
                                    if (widget.validator != null) {
                                      _validate();
                                    }
                                  },
                                  diameterRatio: 2.5,
                                  itemExtent: 56,
                                  children: days
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => Center(
                                          child: Text(
                                            '${entry.value}',
                                            style: entry.key == _selectedDay
                                                ? widget.customAppTheme
                                                    .textStyles.displaySmall
                                                : widget.customAppTheme
                                                    .textStyles.bodyLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _buttonEnabled ? 56 : 0,
              curve: Curves.linearToEaseOut,
              child: Button(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onSelect != null) {
                    widget.onSelect!(
                      DateTime(
                        years[_selectedYear],
                        months[_selectedMonth],
                        days[_selectedDay],
                      ),
                    );
                  }
                },
                text: Text('button.confirm_date'.t()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
