import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_models.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_providers.dart';

class PaymentTipsTab extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String searchQuery;

  const PaymentTipsTab({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.searchQuery,
  });

  @override
  ConsumerState<PaymentTipsTab> createState() => _PaymentTipsTabState();
}

class _PaymentTipsTabState extends ConsumerState<PaymentTipsTab> {
  final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  String? _selectedStaffId;
  bool _showDistributionDialog = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final tipsAsync = ref.watch(staffTipDistributionsProvider((
      staffId: _selectedStaffId ?? '',
      startDate: widget.startDate,
      endDate: widget.endDate,
    )));

    return Column(
      children: [
        // Header with filters and actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedStaffId,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Staff',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Staff')),
                    // TODO: Load staff members from service
                  ],
                  onChanged: (value) => setState(() => _selectedStaffId = value),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showTipDistributionDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Distribute Tips'),
              ),
            ],
          ),
        ),
        
        // Tips summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTipsSummary(),
        ),
        
        const SizedBox(height: 16),
        
        // Tips distributions list
        Expanded(
          child: tipsAsync.when(
            data: (distributions) {
              if (distributions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volunteer_activism, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No tip distributions found'),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: distributions.length,
                itemBuilder: (context, index) => _buildDistributionCard(distributions[index], colorScheme),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSummary() {
    return ref.watch(dailyServiceSummaryProvider).when(
      data: (summary) {
        final totalTips = summary['totalTips'] ?? 0.0;
        final staffTipTotals = summary['staffTipTotals'] as Map<String, double>? ?? {};
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tips Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currencyFormatter.format(totalTips),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total tips for selected period',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (staffTipTotals.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Top Recipients',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ...staffTipTotals.entries.take(3).map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key), // Should be staff name
                        Text(currencyFormatter.format(entry.value)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
      error: (error, stack) => Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Error: $error'))),
    );
  }

  Widget _buildDistributionCard(TipDistribution distribution, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${distribution.orderId.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDateTime(distribution.distributedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(distribution.totalTipAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  _formatMethod(distribution.method),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribution Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...distribution.allocations.map((allocation) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _getRoleIcon(allocation.role),
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(allocation.staffName),
                            Text(
                              _formatRole(allocation.role),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(allocation.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${allocation.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
                if (distribution.notes != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Notes: ${distribution.notes}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTipDistributionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distribute Tips'),
        content: const Text('Tip distribution dialog would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement tip distribution
              Navigator.pop(context);
            },
            child: const Text('Distribute'),
          ),
        ],
      ),
    );
  }

  String _formatMethod(DistributionMethod method) {
    switch (method) {
      case DistributionMethod.equalSplit:
        return 'Equal Split';
      case DistributionMethod.percentageBased:
        return 'Percentage Based';
      case DistributionMethod.roleBased:
        return 'Role Based';
      case DistributionMethod.manual:
        return 'Manual';
      case DistributionMethod.pointsSystem:
        return 'Points System';
    }
  }

  IconData _getRoleIcon(StaffRole role) {
    switch (role) {
      case StaffRole.waiter:
        return Icons.room_service;
      case StaffRole.cook:
      case StaffRole.chef:
        return Icons.restaurant;
      case StaffRole.bartender:
        return Icons.local_bar;
      case StaffRole.busser:
        return Icons.cleaning_services;
      case StaffRole.host:
        return Icons.person;
      case StaffRole.manager:
        return Icons.manage_accounts;
      case StaffRole.cashier:
        return Icons.point_of_sale;
      default:
        return Icons.person;
    }
  }

  String _formatRole(StaffRole role) {
    switch (role) {
      case StaffRole.waiter:
        return 'Waiter';
      case StaffRole.cook:
        return 'Cook';
      case StaffRole.chef:
        return 'Chef';
      case StaffRole.bartender:
        return 'Bartender';
      case StaffRole.busser:
        return 'Busser';
      case StaffRole.host:
        return 'Host';
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.cashier:
        return 'Cashier';
      case StaffRole.other:
        return 'Other';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y h:mm a').format(dateTime);
  }
}
