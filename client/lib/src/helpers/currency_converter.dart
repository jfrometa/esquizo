import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/currency_labels.dart';

extension CurrencyConverter on double {
  String convertToCurrency(String? currency) {
    final converter = NumberFormat('#,##0.00');

    return "${currency != null ? currencySymbols[currency] : ""} ${converter.format(this)}";
  }

  String convertToCompactCurrency(String? currency) {
    final converter = NumberFormat.compactCurrency(symbol: '€');
    return ' ${converter.format(this)}';
  }
}

extension CurrencyToSymbolConverter on String {
  String convertToCurrency() {
    return '${currencySymbols[this]}';
  }
}
