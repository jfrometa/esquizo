import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/constants.dart';

 

class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.text,
    required this.price,
  });

  final String text;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(color: titleColor),
        ),
        Text(
          "\$$price",
          style: const TextStyle(color: titleColor),
        )
      ],
    );
  }
}
