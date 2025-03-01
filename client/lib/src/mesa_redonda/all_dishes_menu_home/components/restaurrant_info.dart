import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/constants.dart';

class RestaurantInfo extends StatelessWidget {
  final String name;

  const RestaurantInfo({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 1,
          ),
          const SizedBox(height: defaultPadding / 2),
          // แสดงรายละเอียดอื่นๆ
        ],
      ),
    );
  }
}
