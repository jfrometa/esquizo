import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/form/meal_plan_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/meal_plan_card.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/meal_plan_detail_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';

// State provider for selected category
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// State provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// State provider for active meal plan ID
final activeMealPlanIdProvider = StateProvider<String?>((ref) => null);

// Combined provider for filtered meal plans
final filteredMealPlansProvider = Provider<AsyncValue<List<MealPlan>>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  AsyncValue<List<MealPlan>> plansAsync;

  if (selectedCategory != null) {
    plansAsync = ref.watch(mealPlansByCategoryProvider(selectedCategory));
  } else {
    plansAsync = ref.watch(mealPlansProvider);
  }

  return plansAsync.whenData((plans) {
    if (searchQuery.isEmpty) return plans;

    return plans.where((plan) {
      final lowercaseQuery = searchQuery.toLowerCase();
      return plan.title.toLowerCase().contains(lowercaseQuery) ||
          plan.description.toLowerCase().contains(lowercaseQuery) ||
          plan.categoryName.toLowerCase().contains(lowercaseQuery) ||
          plan.ownerName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  });
});

class MealPlanManagementScreen extends ConsumerStatefulWidget {
  const MealPlanManagementScreen({super.key});

  @override
  ConsumerState<MealPlanManagementScreen> createState() =>
      _MealPlanManagementScreenState();
}

class _MealPlanManagementScreenState
    extends ConsumerState<MealPlanManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final selectedMealPlanId = ref.watch(activeMealPlanIdProvider);

    return Scaffold(
      body: Column(
        children: [
          // Tab bar and search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Meal Plans'),
                      Tab(text: 'Categories'),
                    ],
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurface,
                    isScrollable: true,
                  ),
                ),
                const SizedBox(width: 16),
                // Search field
                if (isDesktop)
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search meal plans...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Mobile search field
          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search meal plans...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),

          // Filters section
          _buildFiltersSection(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                isDesktop && selectedMealPlanId != null
                    ? Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildMealPlansTab(),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(
                            flex: 3,
                            child: MealPlanDetailView(
                              mealPlanId: selectedMealPlanId,
                              onClose: () => ref
                                  .read(activeMealPlanIdProvider.notifier)
                                  .state = null,
                            ),
                          ),
                        ],
                      )
                    : _buildMealPlansTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddMealPlanDialog();
          } else {
            _showAddCategoryDialog();
          }
        },
        tooltip: _tabController.index == 0 ? 'Add Meal Plan' : 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltersSection() {
    final categories = ref.watch(mealPlanCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 120 : 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filters:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon:
                    Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                tooltip: _showFilters ? 'Hide filters' : 'Show filters',
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 8),
            categories.when(
              data: (categories) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: const Text('All Categories'),
                          selected: selectedCategory == null,
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = null;
                            }
                          },
                        ),
                      ),
                      ...categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category.name),
                            selected: selectedCategory == category.id,
                            onSelected: (selected) {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = selected ? category.id : null;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Failed to load categories'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealPlansTab() {
    final filteredPlans = ref.watch(filteredMealPlansProvider);

    return filteredPlans.when(
      data: (plans) {
        if (plans.isEmpty) {
          return const Center(
            child: Text('No meal plans found'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveGridView(
            children: plans
                .map((plan) => AdminMealPlanCard(
                      mealPlan: plan,
                      onTap: () => _onMealPlanSelected(plan),
                      onEdit: () => _showEditMealPlanDialog(plan),
                      onDelete: () => _confirmDeleteMealPlan(plan),
                    ))
                .toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        // Log error details to console for debugging
        debugPrint('Error loading meal plans: $error');
        debugPrint('Stack trace: $stackTrace');
        return Center(child: Text('Error: $error'));
      },
    );
  }

  Widget _buildCategoriesTab() {
    final categories = ref.watch(mealPlanCategoriesProvider);

    return categories.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text('No categories found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(category.name),
                subtitle: Text(category.description),
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.category,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: category.isActive,
                      onChanged: (value) =>
                          _toggleCategoryActive(category, value),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditCategoryDialog(category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteCategory(category),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  void _onMealPlanSelected(MealPlan plan) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      ref.read(activeMealPlanIdProvider.notifier).state = plan.id;
    } else {
      // For mobile, navigate to detail screen
      context.push('/admin/meal-plans/${plan.id}');
    }
  }

  void _showAddMealPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: MealPlanForm(
            onSave: (mealPlan) {
              Navigator.pop(context);
              _createMealPlan(mealPlan);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _showEditMealPlanDialog(MealPlan plan) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: MealPlanForm(
            mealPlan: plan,
            onSave: (updatedPlan) {
              Navigator.pop(context);
              _updateMealPlan(updatedPlan);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;

              final category = MealPlanCategory(
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                businessId: ref.read(currentBusinessIdProvider),
              );

              Navigator.pop(context);
              _createCategory(category);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(MealPlanCategory category) {
    final nameController = TextEditingController(text: category.name);
    final descriptionController =
        TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;

              final updatedCategory = category.copyWith(
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
              );

              Navigator.pop(context);
              _updateCategory(updatedCategory);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMealPlan(MealPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Plan'),
        content: Text(
            'Are you sure you want to delete "${plan.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMealPlan(plan.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(MealPlanCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // CRUD Operations
  Future<void> _createMealPlan(MealPlan mealPlan) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.createMealPlan(mealPlan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating meal plan: $e')),
        );
      }
    }
  }

  Future<void> _updateMealPlan(MealPlan mealPlan) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.updateMealPlan(mealPlan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating meal plan: $e')),
        );
      }
    }
  }

  Future<void> _deleteMealPlan(String id) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.deleteMealPlan(id);

      // Clear active meal plan if it was deleted
      if (ref.read(activeMealPlanIdProvider) == id) {
        ref.read(activeMealPlanIdProvider.notifier).state = null;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting meal plan: $e')),
        );
      }
    }
  }

  Future<void> _createCategory(MealPlanCategory category) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.createCategory(category);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating category: $e')),
        );
      }
    }
  }

  Future<void> _updateCategory(MealPlanCategory category) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.updateCategory(category);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating category: $e')),
        );
      }
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.deleteCategory(id);

      // Clear selected category if it was deleted
      if (ref.read(selectedCategoryProvider) == id) {
        ref.read(selectedCategoryProvider.notifier).state = null;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }

  Future<void> _toggleCategoryActive(
      MealPlanCategory category, bool isActive) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.toggleCategoryActive(category.id, isActive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  isActive ? 'Category activated' : 'Category deactivated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating category: $e')),
        );
      }
    }
  }
}
