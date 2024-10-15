import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:natasha/notifiers/index.dart';

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class InputAmountTextField extends ConsumerStatefulWidget {
  const InputAmountTextField({
    super.key,
    required this.amountNotifier,
    required this.validate,
    this.keyboardType = TextInputType.number,
    this.style,
    this.decoration = const InputDecoration(),
  });

  final ValueNotifier<String> amountNotifier;
  final void Function(String) validate;
  final TextInputType keyboardType;
  final TextStyle? style;
  final InputDecoration decoration;

  @override
  _InputAmountTextFieldState createState() => _InputAmountTextFieldState();
}

class _InputAmountTextFieldState extends ConsumerState<InputAmountTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final americanFormating = r'^(\d{1,3})(\,\d{3})?(\.\d{1})?$';
  final europeanFromating = r'^(\d{1,3})(\.\d{3})?(\,\d{1})?$';

  (double, String) _formatNumber(String value) {
    final trimmedValue = value.replaceAll(RegExp(r'\s+'), '');
    final locale = ref.read(clientInfoProviderNotifier)?.countryOfResidence;

    double number = 0.00;

    try {
      number = double.parse(trimmedValue).toPrecision(2);
      final String result = NumberFormat.decimalPattern(locale).format(number);
      final trimedResult = result.replaceAll(RegExp(r'\s+'), '');
      
      return (number, trimedResult);
    } catch (exception) {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(
          exception: exception,
          stack: StackTrace.current,
          library: 'home_screen',
          context: ErrorDescription('while updating wallets'),
        ),
      );
      return (number, trimmedValue);
    }
  }

  String get regionRegularExpression {
    final locale = ref.read(clientInfoProviderNotifier)?.countryOfResidence;
    return europeanCodes.contains(locale)
        ? europeanFromating
        : americanFormating;
  }

  bool get shouldReplaceTheComas {
    final locale = ref.read(clientInfoProviderNotifier)?.countryOfResidence;
    return europeanCodes.contains(locale);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (newValue) {
        if (newValue.isEmpty) {
          return;
        }

        if (shouldReplaceTheComas && newValue.characters.last == (',')) {
          newValue = _checkDecimal(newValue, ',');
          return;
        }

        if (!shouldReplaceTheComas && newValue.characters.last == ('.')) {
          newValue = _checkDecimal(newValue, '.');
          return;
        }

        final numberToTransform = shouldReplaceTheComas
            ? newValue.replaceAll('.', '').replaceAll(',', '.')
            : newValue.replaceAll(',', '');

        final formattingDone = _formatNumber(numberToTransform);

        newValue = formattingDone.$2;

        widget.amountNotifier.value = formattingDone.$1.toString();
        widget.validate(widget.amountNotifier.value);

        updateTextEditingValueWith(newValue);
      },
      keyboardType: widget.keyboardType,
      style: widget.style,
      decoration: widget.decoration,
    );
  }

  String _checkDecimal(String newValue, String simbol) {
    final bool isAllowed = simbol.allMatches(newValue).length <= 1;

    final String newValueWithOutExtraSimbol =
        newValue.substring(0, newValue.length - 1);

    newValue = isAllowed ? newValue : newValueWithOutExtraSimbol;

    updateTextEditingValueWith(newValue);
    return newValue;
  }

  void updateTextEditingValueWith(String formattingDone) {
    _controller.value = TextEditingValue(
      text: formattingDone,
      selection: TextSelection.collapsed(offset: formattingDone.length),
    );
  }

  final europeanCodes = [
    'BR',
    'AD',
    'AL',
    'AM',
    'AT',
    'AZ',
    'BA',
    'BE',
    'BG',
    'BH',
    'BI',
    'BY',
    'CH',
    'CY',
    'CZ',
    'DE',
    'DK',
    'EE',
    'ES',
    'FI',
    'FR',
    'GB',
    'GE',
    'GI',
    'GR',
    'HR',
    'HU',
    'IE',
    'IS',
    'IT',
    'JE',
    'LT',
    'LU',
    'LV',
    'MC',
    'MD',
    'ME',
    'MK',
    'MT',
    'MU',
    'NL',
    'NO',
    'PL',
    'PT',
    'RO',
    'RS',
    'RU',
    'SE',
    'SI',
    'SK',
    'SM',
    'SO',
    'SR',
    'SV',
    'TR',
    'UA',
    'UK',
    'VA'
  ];
}
