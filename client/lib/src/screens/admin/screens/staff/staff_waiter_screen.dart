import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';

class StaffWaiterTableSelectScreen extends StatelessWidget {
  const StaffWaiterTableSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with actual table data fetching and display (Grid or List)
    final tables = List.generate(12, (index) => 'Table ${index + 1}');

    return Scaffold(
      // No AppBar needed if inside ShellRoute
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150, // Adjust size as needed
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final tableId =
                tables[index].replaceAll(' ', '-').toLowerCase(); // Example ID
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor:
                    Theme.of(context).colorScheme.primary, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Navigate to order entry screen for this table
                context.goNamed(
                  AdminRoutes.nameStaffWaiterOrderEntry,
                  pathParameters: {'tableId': tableId},
                );
              },
              child: Text(tables[index]),
            );
          },
        ),
      ),
    );
  }
}
