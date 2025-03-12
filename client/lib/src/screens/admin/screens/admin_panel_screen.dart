import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/services/restaurant_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/business_config_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/service_factory.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/analytics_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_settings_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/product_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/user_management/user_management_screen.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/admin_side_menu.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/dashboard_status_card.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/theme_switcher.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/order_service.dart';

// Model classes for stats
class OrderStats {
  final int totalOrders;
  final int pendingOrders;
  final int preparingOrders;
  final int readyOrders;
  final int completedOrders;
  final double dailySales;
  final int averageServiceTime; // in minutes
  
  OrderStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.preparingOrders,
    required this.readyOrders,
    required this.completedOrders,
    required this.dailySales,
    required this.averageServiceTime,
  });
}

class SalesStats {
  final double totalSales;
  final double todaySales;
  final int orderCount;
  
  SalesStats({
    required this.totalSales,
    required this.todaySales,
    required this.orderCount,
  });
}

class TableStats {
  final int totalTables;
  final int occupiedTables;
  final int reservedTables;
  
  TableStats({
    required this.totalTables,
    required this.occupiedTables,
    required this.reservedTables,
  });
}

class ProductStats {
  final int totalProducts;
  final int categories;
  final int outOfStock;
  
  ProductStats({
    required this.totalProducts,
    required this.categories,
    required this.outOfStock,
  });
}

// Providers for dashboard stats - FIXED
final orderStatsProvider = FutureProvider<OrderStats>((ref) async {
  // Using compute to avoid blocking the main thread for intensive calculations
  // This implementation avoids multiple unnecessary Firestore reads
  final pendingOrders = await ref.watch(pendingOrdersProvider.future);
  final allOrders = await ref.watch(allActiveOrdersProvider.future);

  return OrderStats(
    totalOrders: allOrders.length,
    pendingOrders: pendingOrders.length,
    preparingOrders: allOrders.where((o) => o.status == OrderStatus.preparing).length,
    completedOrders: allOrders.where((o) => o.status == OrderStatus.completed).length,
    readyOrders: allOrders.where((o) => o.status == OrderStatus.readyForDelivery).length,
    dailySales: allOrders.fold(0.0, (sum, order) => sum + order.totalAmount),
    averageServiceTime: 30, // Default value, replace with actual calculation
  );
});

final salesStatsProvider = FutureProvider<SalesStats>((ref) async {
  // Get all orders first to avoid multiple Firestore reads
   final allOrders = await ref.watch(allActiveOrdersProvider.future);
  
  // Now process the data locally
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  
  final totalSales = allOrders.fold(
    0.0, 
    (sum, order) => sum + (order.status != OrderStatus.cancelled ? order.totalAmount : 0)
  );
  
  final todayOrders = allOrders.where(
    (order) => order.createdAt.isAfter(startOfDay) && order.status != OrderStatus.cancelled
  );
  
  final todaySales = todayOrders.fold(
    0.0, 
    (sum, order) => sum + order.totalAmount
  );
  
  return SalesStats(
    totalSales: totalSales,
    todaySales: todaySales,
    orderCount: allOrders.length,
  );
});

final tableStatsProvider = FutureProvider<TableStats>((ref) async {
  // Use the existing table service through the resource service
  final resourceService = ref.watch(
    serviceFactoryProvider.select((factory) => 
      factory.createResourceService('table')
    )
  );
  
  // Get resource stats to avoid multiple Firestore reads
  final stats = await resourceService.getResourceStats();
  
  return TableStats(
    totalTables: stats.totalResources,
    occupiedTables: stats.statusCounts['occupied'] ?? 0,
    reservedTables: stats.statusCounts['reserved'] ?? 0,
  );
});

final productStatsProvider = FutureProvider<ProductStats>((ref) async {
  // Get catalog service for menu items
  final catalogService = ref.watch(
    serviceFactoryProvider.select((factory) => 
      factory.createCatalogService('menu')
    )
  );
  
  // Get all items and categories to avoid multiple Firestore reads
  final itemsStream = catalogService.getItems();
  final categoriesStream = catalogService.getCategories();
  
  final items = await itemsStream.first;
  final categories = await categoriesStream.first;
  
  return ProductStats(
    totalProducts: items.length,
    categories: categories.length,
    outOfStock: items.where((item) => !item.isAvailable).length,
  );
});

// This provider is already correctly implemented
final recentOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  // Limit to last 5 orders for dashboard display
  return orderService.getRecentOrdersStream().map((orders) => orders.take(5).toList());
});

// Provider for orders by specific status
// final ordersByStatusProvider = StreamProvider.family<List<Order>, String>((ref, status) {
//   final orderService = ref.watch(orderServiceProvider);
  
//   if (status == 'all') {
//     return orderService.getAllOrdersStream();
//   }
  
//   // Convert string status to enum
//   final OrderStatus orderStatus = OrderStatus.values.firstWhere(
//     (e) => e.toString().split('.').last == status,
//     orElse: () => OrderStatus.pending, // Default to pending if not found
//   );
  
//   return orderService.getOrdersByStatusStream(orderStatus);
// });

// // Provider for orders filtered by date
// final ordersByDateProvider = StreamProvider.family<List<Order>, DateTime?>((ref, date) {
  
//   final orderService2 = ref.watch(ordersByDateProvider);

  
//   return orderService2.value;
// });

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _refreshTimer;
  bool _isLoading = false; 
  int _selectedIndex = 0; 
  
  final List<Widget> _screens = [
    const AdminDashboardHome(),
    const ProductManagementScreen(),
    const OrderManagementScreen(),
    // const TableManagementScreen(),
    const UserManagementScreen(),
    const BusinessSettingsScreen(),
    const AnalyticsDashboard(),
  ];
  
  final List<String> _screenTitles = [
    'Dashboard',
    'Products & Menu',
    'Orders',
    'Tables',
    'Users & Staff',
    'Business Settings',
    'Analytics',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _screens.length,
      vsync: this,
      initialIndex: _selectedIndex,
    );

    // Add listener to sync tab controller with selected index
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = ref.watch(hasRoleProvider('admin'));
    
    // Check if user is authenticated and has admin privileges
    // if (authState != AuthState.authenticated || !isAdmin) {
    if (authState != AuthState.authenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You do not have access to the admin panel'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }
    
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        actions: [
          const ThemeSwitch(),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _showUserMenu,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      drawer: SidebarMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 4 : _selectedIndex,
        onTap: _onItemSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'Tables'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
  
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        actions: [
          const ThemeSwitch(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _showUserMenu,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          SidebarMenu(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemSelected,
            isExpanded: false,
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemSelected,
            isExpanded: true,
          ),
          Expanded(
            child: Column(
              children: [
                _buildDesktopHeader(context),
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDesktopHeader(BuildContext context) {
    final businessConfig = ref.watch(businessConfigProvider).value;
    final currentUser = ref.watch(currentUserProvider).value;
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _screenTitles[_selectedIndex],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          const ThemeSwitch(),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: _showUserMenu,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundImage: currentUser?.photoURL != null 
                      ? NetworkImage(currentUser!.photoURL!) 
                      : null,
                  child: currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty
                      ? Text(currentUser.displayName![0].toUpperCase())
                      : const Icon(Icons.person, size: 16),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentUser?.displayName ?? 'Admin',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      businessConfig?.name ?? 'Business',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onItemSelected(int index) {
    // For mobile, the 'More' item opens a modal with additional options
    if (index == 4 && MediaQuery.of(context).size.width < 600) {
      _showMoreOptions();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users & Staff'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Business Settings'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 5);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 6);
            },
          ),
        ],
      ),
    );
  }
  
  void _showUserMenu() {
    final authService = ref.read(authServiceProvider);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 160,
        kToolbarHeight + 16,
        16,
        0,
      ),
      items: [
        PopupMenuItem(
          child: const Text('Profile'),
          onTap: () => context.push('/admin/profile'),
        ),
        PopupMenuItem(
          child: const Text('Help'),
          onTap: () => context.push('/admin/help'),
        ),
        PopupMenuItem(
          child: const Text('Logout'),
          onTap: () async {
            await authService.signOut();
            if (mounted) context.go('/login');
          },
        ),
      ],
    );
  }
}

// Home screen of the admin dashboard
class AdminDashboardHome extends ConsumerStatefulWidget {
  const AdminDashboardHome({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardHome> createState() => _AdminDashboardHomeState();
}

class _AdminDashboardHomeState extends ConsumerState<AdminDashboardHome> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1200;
    final isTablet = width > 600 && width <= 1200;
    
    // Watch necessary providers
    final businessConfig = ref.watch(businessConfigProvider);
    final orderStats = ref.watch(orderStatsProvider);
    final salesStats = ref.watch(salesStatsProvider);
    final tableStats = ref.watch(tableStatsProvider);
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Overview Card
            businessConfig.when(
              data: (config) => _buildBusinessOverview(config),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Error loading business information'),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Cards
            Text(
              'Business Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Stats Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
              childAspectRatio: isDesktop ? 1.5 : 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Orders Stats
                orderStats.when(
                  data: (data) => DashboardStatsCard(
                    title: 'Orders',
                    primaryStat: '${data.totalOrders}',
                    secondaryStat: '${data.pendingOrders} pending',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                    onTap: () => _navigateToSection(context, 2), // Orders screen
                  ),
                  loading: () => const DashboardStatsCard.loading(
                    title: 'Orders',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                  error: (_, __) => const DashboardStatsCard.error(
                    title: 'Orders',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                ),
                
                // Sales Stats
                salesStats.when(
                  data: (data) => DashboardStatsCard(
                    title: 'Sales',
                    primaryStat: '\$${data.totalSales.toStringAsFixed(2)}',
                    secondaryStat: 'Today: \$${data.todaySales.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    onTap: () => _navigateToSection(context, 6), // Analytics screen
                  ),
                  loading: () => const DashboardStatsCard.loading(
                    title: 'Sales',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  error: (_, __) => const DashboardStatsCard.error(
                    title: 'Sales',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ),
                
                // Tables Stats
                tableStats.when(
                  data: (data) => DashboardStatsCard(
                    title: 'Tables',
                    primaryStat: '${data.occupiedTables}/${data.totalTables}',
                    secondaryStat: '${data.occupiedTables} tables occupied',
                    icon: Icons.table_chart,
                    color: Colors.orange,
                    onTap: () => _navigateToSection(context, 3), // Tables screen
                  ),
                  loading: () => const DashboardStatsCard.loading(
                    title: 'Tables',
                    icon: Icons.table_chart,
                    color: Colors.orange,
                  ),
                  error: (_, __) => const DashboardStatsCard.error(
                    title: 'Tables',
                    icon: Icons.table_chart,
                    color: Colors.orange,
                  ),
                ),
                
                // Products Stats
                ref.watch(productStatsProvider).when(
                  data: (data) => DashboardStatsCard(
                    title: 'Products',
                    primaryStat: '${data.totalProducts}',
                    secondaryStat: '${data.categories} categories',
                    icon: Icons.restaurant_menu,
                    color: Colors.purple,
                    onTap: () => _navigateToSection(context, 1), // Products screen
                  ),
                  loading: () => const DashboardStatsCard.loading(
                    title: 'Products',
                    icon: Icons.restaurant_menu,
                    color: Colors.purple,
                  ),
                  error: (_, __) => const DashboardStatsCard.error(
                    title: 'Products',
                    icon: Icons.restaurant_menu,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('View All'),
                  onPressed: () => _navigateToSection(context, 2), // Orders screen
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recent Orders List
            ref.watch(recentOrdersProvider).when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('No recent orders'),
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: orders.map((order) => _buildOrderCard(context, order)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Error loading recent orders'),
                ),
              ),
            ),
            
            if (isDesktop) ...[
              const SizedBox(height: 24),
              
              // Analytics Preview Section
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildAnalyticsPreview(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildQuickActions(context),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 24),
              
              _buildAnalyticsPreview(context),
              
              const SizedBox(height: 24),
              
              _buildQuickActions(context),
            ],
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBusinessOverview(BusinessConfig? config) {
    if (config == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (config.logoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  config.logoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.business,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    config.type.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (config.features.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: config.features.map((feature) => Chip(
                        label: Text(feature),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                      )).toList(),
                    ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              onPressed: () => _navigateToSection(context, 5), // Business Settings
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getOrderStatusColor(order.status.name).withOpacity(0.2),
          child: Icon(
            Icons.receipt,
            color: _getOrderStatusColor(order.status.name),
          ),
        ),
        title: Row(
          children: [
            Text('Order #${order.id.substring(0, 6)}'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getOrderStatusColor(order.status.name).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getOrderStatusText(order.status.name),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getOrderStatusColor(order.status.name),
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${order.items.length} items • Table ${order.resourceId} • \$${order.totalAmount.toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () => _navigateToOrderDetails(context, order.id),
        ),
        onTap: () => _navigateToOrderDetails(context, order.id),
      ),
    );
  }
  
  Widget _buildAnalyticsPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => _navigateToSection(context, 6), // Analytics
                  child: const Text('View Full Analytics'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Sales Graph Preview'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Create New Order',
              onPressed: () => _navigateToSection(context, 2), // Orders
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              icon: Icons.add_business,
              label: 'Add Product to Menu',
              onPressed: () => _navigateToSection(context, 1), // Products
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              icon: Icons.person_add_alt,
              label: 'Add New User',
              onPressed: () => _navigateToSection(context, 4), // Users
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              icon: Icons.print,
              label: 'Print Reports',
              onPressed: () => _navigateToSection(context, 6), // Analytics
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
  
  Future<void> _refreshData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Refresh providers that need real-time updates
      ref.invalidate(businessConfigProvider);
      ref.invalidate(orderStatsProvider);
      ref.invalidate(salesStatsProvider);
      ref.invalidate(tableStatsProvider);
      ref.invalidate(recentOrdersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _navigateToSection(BuildContext context, int index) {
    final parentState = context.findAncestorStateOfType<_AdminPanelScreenState>();
    if (parentState != null) {
      parentState.setState(() {
        parentState._selectedIndex = index;
      });
    }
  }
  
  void _navigateToOrderDetails(BuildContext context, String orderId) {
    context.push('/admin/orders/$orderId');
  }
  
  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getOrderStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}

// Placeholder classes for navigation
// class TableManagementScreen extends ConsumerWidget {
//   const TableManagementScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Table Management'),
//       ),
//       body: const Center(
//         child: Text('Table Management Screen'),
//       ),
//     );
//   }
// }

// class ProductManagementScreen extends ConsumerWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Product Management'),
//       ),
//       body: const Center(
//         child: Text('Product Management Screen'),
//       ),
//     );
//   }
// }

// class OrderManagementScreen extends ConsumerWidget {
//   const OrderManagementScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Order Management'),
//       ),
//       body: const Center(
//         child: Text('Order Management Screen'),
//       ),
//     );
//   }
// }

// class UserManagementScreen extends ConsumerWidget {
//   const UserManagementScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Management'),
//       ),
//       body: const Center(
//         child: Text('User Management Screen'),
//       ),
//     );
//   }
// }

// class BusinessSettingsScreen extends ConsumerWidget {
//   const BusinessSettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Business Settings'),
//       ),
//       body: const Center(
//         child: Text('Business Settings Screen'),
//       ),
//     );
//   }
// }

// class AnalyticsDashboard extends ConsumerWidget {
//   const AnalyticsDashboard({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Analytics Dashboard'),
//       ),
//       body: const Center(
//         child: Text('Analytics Dashboard Screen'),
//       ),
//     );
//   }
// }

// Notifications Panel Widget
class NotificationsPanel extends StatelessWidget {
  final ScrollController scrollController;
  
  const NotificationsPanel({
    Key? key,
    required this.scrollController,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    tooltip: 'Mark all as read',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Notification settings',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Notification list
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              NotificationItem(
                title: 'Order ready for delivery',
                message: 'Order #12345 is ready for delivery at Table 3',
                time: '2 min',
                icon: Icons.restaurant,
                color: Colors.green,
                isUnread: true,
              ),
              NotificationItem(
                title: 'New order received',
                message: 'A new order has been received for Table 5',
                time: '15 min',
                icon: Icons.receipt,
                color: Colors.blue,
                isUnread: true,
              ),
              NotificationItem(
                title: 'Reservation confirmed',
                message: 'Table 8 reserved for 8:00 PM',
                time: '30 min',
                icon: Icons.event_available,
                color: Colors.orange,
                isUnread: false,
              ),
              NotificationItem(
                title: 'Product out of stock',
                message: 'The "Caesar Salad" product is out of stock',
                time: '1h',
                icon: Icons.warning,
                color: Colors.red,
                isUnread: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Notification Item Widget
class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isUnread;
  
  const NotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isUnread = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(message),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }
}