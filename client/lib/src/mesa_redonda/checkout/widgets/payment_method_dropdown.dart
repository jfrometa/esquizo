import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class PaymentMethodDropdown extends StatelessWidget {
  final int selectedMethod;
  final Function(int) onMethodSelected;
  final List<String> paymentMethods;
  final String Function(int) getDescription;

  const PaymentMethodDropdown({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.paymentMethods,
    required this.getDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de pago',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
              color: colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedMethod,
                  icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: colorScheme.surface,
                  elevation: 3,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  items: List.generate(paymentMethods.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Row(
                        children: [
                          Icon(
                            _getPaymentIcon(paymentMethods[index]),
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            paymentMethods[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: index == selectedMethod ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  onChanged: (int? value) {
                    if (value != null) {
                      onMethodSelected(value);
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    getDescription(selectedMethod),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    final methodLower = method.toLowerCase();
    if (methodLower.contains('tarjeta') || methodLower.contains('crédito') || methodLower.contains('débito')) {
      return Icons.credit_card;
    } else if (methodLower.contains('efectivo')) {
      return Icons.payments_outlined;
    } else if (methodLower.contains('transferencia')) {
      return Icons.account_balance;
    } else if (methodLower.contains('paypal')) {
      return Icons.paypal;
    } else {
      return Icons.payment;
    }
  }
}