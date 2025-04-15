// File: lib/src/screens/setup/business_setup_complete_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
 
class BusinessSetupCompleteScreen extends ConsumerWidget {
  final String businessId;
  
  const BusinessSetupCompleteScreen({
    super.key,
    required this.businessId,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessConfig = ref.watch(businessConfigProvider).valueOrNull;
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Success message
                Text(
                  'Setup Complete!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Text(
                  businessConfig != null
                      ? '${businessConfig.name} has been set up successfully.'
                      : 'Your restaurant has been set up successfully.',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSummaryItem(
                          theme,
                          icon: Icons.business,
                          title: 'Business ID',
                          value: businessId,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildSummaryItem(
                          theme,
                          icon: Icons.restaurant,
                          title: 'Restaurant Name',
                          value: businessConfig?.name ?? 'Your Restaurant',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildSummaryItem(
                          theme,
                          icon: Icons.category,
                          title: 'Restaurant Type',
                          value: businessConfig?.type ?? 'restaurant',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Next steps
                Text(
                  'Next Steps',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                _buildNextStepItem(
                  theme,
                  number: 1,
                  title: 'Explore the Dashboard',
                  description: 'Get familiar with your restaurant management dashboard',
                ),
                const SizedBox(height: 12),
                
                _buildNextStepItem(
                  theme,
                  number: 2,
                  title: 'Add Menu Items',
                  description: 'Create your restaurant menu with categories and items',
                ),
                const SizedBox(height: 12),
                
                _buildNextStepItem(
                  theme,
                  number: 3,
                  title: 'Configure Settings',
                  description: 'Customize your restaurant settings and preferences',
                ),
                const SizedBox(height: 32),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/admin');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Go to Dashboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildNextStepItem(
    ThemeData theme, {
    required int number,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}