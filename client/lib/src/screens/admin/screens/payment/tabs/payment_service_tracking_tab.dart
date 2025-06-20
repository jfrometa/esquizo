import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/tabs/payment_service_tracking_tab.dart';

class PaymentManagementScreen extends ConsumerWidget {
  const PaymentManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Service Tracking'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(ref, theme, colorScheme),
            Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text('Service Tracking Tab - Implementation pending'),
              ),
            ),
            _buildReportsTab(ref, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(WidgetRef ref, ThemeData theme, ColorScheme colorScheme) {
    // Overview tab content
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Overview', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Add widgets for overview metrics
        ],
      ),
    );
  }

  Widget _buildReportsTab(WidgetRef ref, ThemeData theme, ColorScheme colorScheme) {
    // Reports tab content
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Reports', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Add widgets for reports
        ],
      ),
    );
  }
}