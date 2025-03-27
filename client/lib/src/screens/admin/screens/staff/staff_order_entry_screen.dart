import 'package:flutter/material.dart';

class StaffOrderEntryScreen extends StatelessWidget {
  final String tableId;
  const StaffOrderEntryScreen({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar needed if inside ShellRoute
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Order Entry for Table ID: $tableId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            const Text('Menu Items List - Placeholder'),
            const SizedBox(height: 20),
            const Text('Current Order Summary - Placeholder'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to send order to kitchen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Order for $tableId sent to kitchen!')),
                );
              },
              child: const Text('Send Order to Kitchen'),
            )
          ],
        ),
      ),
    );
  }
}
