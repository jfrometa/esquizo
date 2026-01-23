import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';

/// Debug widget to test admin status and navigation
class AdminDebugWidget extends ConsumerWidget {
  const AdminDebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final adminStatusAsync = ref.watch(isAdminProvider);
    final destinations = ref.watch(navigationDestinationsProvider);
    final allDestinations = ref.watch(allNavigationDestinationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Authentication Status',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                        'User: ${authState.value?.uid ?? 'Not authenticated'}'),
                    Text('Email: ${authState.value?.email ?? 'None'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Status',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    adminStatusAsync.when(
                      data: (isAdmin) => Text(
                        'Is Admin: $isAdmin',
                        style: TextStyle(
                          color: isAdmin ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const Text('Checking admin status...'),
                      error: (error, stackTrace) => Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          ref.read(refreshAdminStatusProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Admin status refreshed'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Refresh Admin Status'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All Navigation Destinations',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...allDestinations.map((dest) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '${dest.label} (${dest.path}) - Visible: ${dest.isVisible}',
                            style: TextStyle(
                              color:
                                  dest.isVisible ? Colors.green : Colors.grey,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visible Navigation Destinations',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...destinations.map((dest) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '${dest.label} (${dest.path})',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
