import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/restaurant/restaurant_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';

class DashboardStatsCard extends StatelessWidget {
  final String title;
  final String? primaryStat;
  final String? secondaryStat;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool hasError;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.primaryStat,
    this.secondaryStat,
    this.onTap,
    this.isLoading = false,
    this.hasError = false,
  });
  
  // Constructor for loading state
  const DashboardStatsCard.loading({
    Key? key,
    required String title,
    required IconData icon,
    required Color color,
  }) : this(
    key: key,
    title: title,
    icon: icon,
    color: color,
    isLoading: true,
  );
  
  // Constructor for error state
  const DashboardStatsCard.error({
    Key? key,
    required String title,
    required IconData icon,
    required Color color,
  }) : this(
    key: key,
    title: title,
    icon: icon,
    color: color,
    hasError: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Main stat
              if (isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ] else if (hasError) ...[
                Text(
                  'Error loading data',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Retry'),
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ] else ...[
                Text(
                  primaryStat ?? '0',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                if (secondaryStat != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    secondaryStat!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
              
              const Spacer(),
              
              // View details link
              if (onTap != null && !isLoading && !hasError)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Details',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: color,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model classes for dashboard stats
class DashboardStats {
  final OrderStats orderStats;
  final SalesStats salesStats;
  final TableStats tableStats;
  final ProductStats productStats;
  
  DashboardStats({
    required this.orderStats,
    required this.salesStats,
    required this.tableStats,
    required this.productStats,
  });
}

