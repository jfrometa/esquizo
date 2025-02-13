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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: DropdownButtonFormField<int>(
              dropdownColor: ColorsPaletteRedonda.white,
              value: selectedMethod,
              items: List.generate(paymentMethods.length, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    paymentMethods[index],
                    style: const TextStyle(
                      color: ColorsPaletteRedonda.primary,
                      fontSize: 14,
                    ),
                  ),
                );
              }),
              onChanged: (int? value) {
                if (value != null) {
                  onMethodSelected(value);
                }
              },
              decoration: InputDecoration(
                labelText: 'Método de pago',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: Text(
              getDescription(selectedMethod),
              style: const TextStyle(
                color: ColorsPaletteRedonda.primary,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}