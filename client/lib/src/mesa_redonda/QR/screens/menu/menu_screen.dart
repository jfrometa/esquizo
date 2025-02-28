// Menu Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/models/qr_code_data.dart';
 

import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/providers/provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/screens/category_dishes_screen.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Menu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Our Menu',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Delicious dishes crafted with love',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDishesScreen(
                                categoryId: category.id,
                                categoryName: category.name,
                                tableData: QRCodeData(
                                  tableId: DateTime.now().millisecondsSinceEpoch.toString(),
                                  tableName: 'Takeaway',
                                  restaurantId: 'la-redonda-123',
                                  generatedAt: DateTime.now(),
                                ),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getCategoryIcon(category.id),
                                  size: 32,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getCategoryDescription(category.id),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error loading categories: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.lunch_dining;
      case 2:
        return Icons.dinner_dining;
      case 3:
        return Icons.cake;
      case 4:
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }
  
  String _getCategoryDescription(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'Light bites to start your meal';
      case 2:
        return 'Hearty and satisfying main dishes';
      case 3:
        return 'Sweet treats to end your meal';
      case 4:
        return 'Refreshing beverages and cocktails';
      default:
        return 'Explore our delicious options';
    }
  }
}
