import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/primary_button.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/constants.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tus Ordenes"),
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              const SizedBox(height: defaultPadding),
              // Placeholder for future order summary
              Text(
                "Your order details will be displayed here.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: defaultPadding * 2),
              PrimaryButton(
                text: "Continue Shopping",
                onPressed: () {
                  // Navigate to the home screen and replace the current screen
                  context.goNamed(AppRoute.home.name);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
