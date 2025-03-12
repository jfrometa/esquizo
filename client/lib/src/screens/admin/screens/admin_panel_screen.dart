import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/providers/restaurant_table_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/providers/table_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/admin_user.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart'; 
 

import 'dart:async';

import 'package:starter_architecture_flutter_firebase/src/core/restaurant/services/restaurant_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_management/admin_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/table_and_order_management/table_and_order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/table_service.dart';
 
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Set up periodic refresh for real-time data
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Refresh providers that need real-time updates
      ref.invalidate(activeOrdersProvider);
      ref.refresh(tablesStatusProvider);
      ref.refresh(restaurantStatsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar datos: $e'), 
          behavior: SnackBarBehavior.floating)
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Gestión del Restaurante'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar datos',
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificaciones',
            onPressed: () => _showNotifications(context),
          ),
          const SizedBox(width: 8),
          _buildUserProfileButton(context),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Servicio de Mesas',
            ),
            Tab(
              icon: Icon(Icons.admin_panel_settings),
              text: 'Administración',
            ),
          ],
        ),
      ),
      drawer: isTablet ? null : _buildNavigationDrawer(context),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWaiterDashboard(context),
                  _buildAdminDashboard(context),
                ],
              ),
            ),
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomStatusBar(context),
    );
  }
  
  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // Waiter dashboard
        return FloatingActionButton.extended(
          onPressed: () => _navigateToSection(context, 'create-order'),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Pedido'),
        );
      case 1: // Admin dashboard, no FAB needed
        return null;
      default:
        return null;
    }
  }

  Widget _buildUserProfileButton(BuildContext context) {
    final currentStaff = ref.watch(currentStaffProvider);
    
    return currentStaff.when(
      data: (staff) => InkWell(
        onTap: () => _showUserOptions(context),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundImage: staff?.profileImageUrl != null 
                    ? NetworkImage(staff!.profileImageUrl!) 
                    : null,
                child: staff?.name != null && staff!.name.isNotEmpty
                    ? Text(
                        staff.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 16,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                staff?.name ?? 'Usuario',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => IconButton(
        icon: const Icon(Icons.account_circle),
        onPressed: () => _showUserOptions(context),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final currentStaff = ref.watch(currentStaffProvider);
    
    return Drawer(
      child: Column(
        children: [
          currentStaff.when(
            data: (staff) => UserAccountsDrawerHeader(
              accountName: Text(staff?.name ?? 'Usuario'),
              accountEmail: Text(staff?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                foregroundImage: staff?.profileImageUrl != null 
                    ? NetworkImage(staff!.profileImageUrl!) 
                    : null,
                child: staff?.name != null && staff!.name.isNotEmpty
                    ? Text(
                        staff.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24),
                      )
                    : const Icon(Icons.person),
              ),
            ),
            loading: () => const DrawerHeader(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const DrawerHeader(
              child: Text('Error al cargar usuario'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Gestión de Productos'),
            onTap: () => _navigateToSection(context, 'products'),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () => _navigateToSection(context, 'categories'),
          ),
          ListTile(
            leading: const Icon(Icons.table_restaurant),
            title: const Text('Mesas'),
            onTap: () => _navigateToSection(context, 'tables'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Pedidos'),
            onTap: () => _navigateToSection(context, 'orders'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Administradores'),
            onTap: () => _navigateToSection(context, 'users'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Estadísticas'),
            onTap: () => _navigateToSection(context, 'stats'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ayuda'),
            onTap: () => _showHelpDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiterDashboard(BuildContext context) {
    final tables = ref.watch(activeTablesProvider);
        final orders = ref.watch(activeOrdersProvider('all')); // or another appropriate parameter
    
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Quick actions section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acciones Rápidas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.add_shopping_cart,
                          label: 'Nuevo Pedido',
                          onTap: () => _navigateToSection(context, 'create-order'),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.table_restaurant,
                          label: 'Ver Mesas',
                          onTap: () => _navigateToSection(context, 'tables'),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.receipt_long,
                          label: 'Pedidos',
                          onTap: () => _navigateToSection(context, 'orders'),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.payment,
                          label: 'Cobrar',
                          onTap: () => _navigateToSection(context, 'payment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Active tables section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mesas Activas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver Todas'),
                  onPressed: () => _navigateToSection(context, 'tables'),
                ),
              ],
            ),
          ),
          
   
          SizedBox(
            height: 180,
            child: tables.when(
              data: (tableList) {
                if (tableList.isEmpty) {
                  return const Center(
                    child: Text('No hay mesas configuradas'),
                  );
                }
                
                // Show only occupied tables or first 6 tables if none occupied
                final occupiedTables = tableList
                    .where((table) => table.status == TableStatus.occupied)
                    .toList();
                    
                final displayTables = occupiedTables.isNotEmpty 
                    ? occupiedTables 
                    : tableList.take(6).toList();
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: displayTables.length,
                  itemBuilder: (context, index) {
                    final table = displayTables[index];
                    return _buildTableCard(table);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
          
          // Active orders section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedidos Activos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Ver Todos'),
                  onPressed: () => _navigateToSection(context, 'orders'),
                ),
              ],
            ),
          ),
          
          orders.when(
            data: (orderList) {
              if (orderList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No hay pedidos activos'),
                  ),
                );
              }
              
              // Show only latest 3 orders
              final latestOrders = orderList.take(3).toList();
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: latestOrders.length,
                itemBuilder: (context, index) {
                  final order = latestOrders[index];
                  return _buildOrderCard(order);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(RestaurantTable table) {
    final statusColor = _getStatusColor(table.status);
    
    return Card(
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      child: InkWell(
        onTap: () => _navigateToTableDetails(context, table),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mesa ${table.number}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${table.capacity}',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getStatusText(table.status),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (table.status == TableStatus.occupied && table.currentOrderId != null)
                TextButton(
                  onPressed: () => _navigateToOrderDetails(context, table.currentOrderId!),
                  child: const Text('Ver Pedido'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final theme = Theme.of(context);
    final statusColor = _getOrderStatusColor(order.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToOrderDetails(context, order.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${order.id.substring(0, 8)}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getOrderStatusText(order.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.table_restaurant, size: 16),
                  const SizedBox(width: 4),
                  Text('Mesa ${order.tableNumber}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.shopping_basket, size: 16),
                  const SizedBox(width: 4),
                  Text('${order.items.length} productos'),
                  const SizedBox(width: 16),
                  const Icon(Icons.attach_money, size: 16),
                  const SizedBox(width: 4),
                  Text('\$${order.totalAmount.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    onPressed: () => _navigateToEditOrder(context, order),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Ver'),
                    onPressed: () => _navigateToOrderDetails(context, order.id),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Administración',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona todos los aspectos de tu restaurante desde aquí',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // Admin Dashboard Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildAdminCard(
                context,
                title: 'Gestión de Productos',
                icon: Icons.restaurant_menu,
                description: 'Añadir, editar y eliminar productos del menú',
                onTap: () => _navigateToSection(context, 'products'),
                color: Colors.orange.shade100,
                iconColor: Colors.deepOrange,
              ),
              _buildAdminCard(
                context,
                title: 'Categorías',
                icon: Icons.category,
                description: 'Organiza tus productos en categorías',
                onTap: () => _navigateToSection(context, 'categories'),
                color: Colors.green.shade100,
                iconColor: Colors.green,
              ),
              _buildAdminCard(
                context,
                title: 'Usuarios y Permisos',
                icon: Icons.people,
                description: 'Gestiona administradores y permisos',
                onTap: () => _navigateToSection(context, 'users'),
                color: Colors.blue.shade100,
                iconColor: Colors.blue,
              ),
              _buildAdminCard(
                context,
                title: 'Configuración de Mesas',
                icon: Icons.table_restaurant,
                description: 'Configura las mesas de tu restaurante',
                onTap: () => _navigateToSection(context, 'tables'),
                color: Colors.purple.shade100,
                iconColor: Colors.purple,
              ),
              _buildAdminCard(
                context,
                title: 'Pedidos',
                icon: Icons.receipt_long,
                description: 'Visualiza y gestiona los pedidos',
                onTap: () => _navigateToSection(context, 'orders'),
                color: Colors.amber.shade100,
                iconColor: Colors.amber.shade800,
              ),
              _buildAdminCard(
                context,
                title: 'Estadísticas',
                icon: Icons.bar_chart,
                description: 'Analiza el rendimiento de tu negocio',
                onTap: () => _navigateToSection(context, 'stats'),
                color: Colors.teal.shade100,
                iconColor: Colors.teal,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions Section
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick action buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionChip(
                context,
                label: 'Añadir Producto',
                icon: Icons.add_circle_outline,
                onTap: () => _navigateToSection(context, 'add-product'),
              ),
              _buildActionChip(
                context,
                label: 'Añadir Administrador',
                icon: Icons.admin_panel_settings,
                onTap: () => _navigateToSection(context, 'users'),
              ),
              _buildActionChip(
                context,
                label: 'Ver Pedidos Pendientes',
                icon: Icons.pending_actions,
                onTap: () => _navigateToSection(context, 'pending-orders'),
              ),
              _buildActionChip(
                context,
                label: 'Configurar QR',
                icon: Icons.qr_code,
                onTap: () => _navigateToSection(context, 'qr-config'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStatusBar(BuildContext context) {
    final stats = ref.watch(restaurantStatsProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: stats.when(
        data: (data) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatusItem(
              context, 
              icon: Icons.table_restaurant,
              label: 'Mesas Ocupadas',
              value: '${data.occupiedTables}/${data.totalTables}',
            ),
            _buildStatusItem(
              context,
              icon: Icons.pending_actions,
              label: 'Pedidos Pendientes',
              value: '${data.pendingOrders}',
            ),
            _buildStatusItem(
              context,
              icon: Icons.timer,
              label: 'Tiempo Promedio',
              value: '${data.averageServiceTime} min',
            ),
            _buildStatusItem(
              context,
              icon: Icons.attach_money,
              label: 'Ventas del Día',
              value: '\$${data.dailySales.toStringAsFixed(2)}',
            ),
          ],
        ),
        loading: () => const Center(child: LinearProgressIndicator()),
        error: (_, __) => const Text('Error al cargar estadísticas'),
      ),
    );
  }
  
  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: iconColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
      ),
      label: Text(label),
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  // Navigation methods
  void _navigateToSection(BuildContext context, String section) {
    switch (section) {
      case 'users':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AdminManagementScreen(),
          ),
        );
        break;
      case 'tables':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TableManagementScreen(),
          ),
        );
        break;
      case 'products':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MenuManagementScreen(initialTab: 1,),
          ),
        );
        break;
      case 'orders':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OrderManagementScreen(),
          ),
        );
        break;
      case 'categories':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MenuManagementScreen(initialTab: 1),
          ),
        );
        break;
      case 'create-order':
        _createNewOrder();
        break;
      // Add other navigation cases as needed
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sección "$section" en desarrollo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
  
  void _navigateToTableDetails(BuildContext context, RestaurantTable table) {
    // Check if there's an active order for this table
    if (table.currentOrderId != null) {
      _navigateToOrderDetails(context, table.currentOrderId!);
    } else {
      // Show table options bottom sheet
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Mesa ${table.number}'),
              subtitle: Text(_getStatusText(table.status)),
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Crear Pedido'),
              enabled: table.status == TableStatus.available || table.status == TableStatus.reserved,
              onTap: () {
                Navigator.pop(context);
                _createNewOrderForTable(table);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Mesa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TableManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  }
  
  void _navigateToOrderDetails(BuildContext context, String orderId) {
    final orderProvider = ref.read(orderServiceProvider);
    
    setState(() {
      _isLoading = true;
    });
    
    orderProvider.getOrderById(orderId).then((order) {
      setState(() {
        _isLoading = false;
      });
      
      if (order != null) {
        Navigator.of(context).pushNamed(
          '/order-details',
          arguments: order,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo encontrar el pedido'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
  
  void _navigateToEditOrder(BuildContext context, Order order) {
    Navigator.of(context).pushNamed(
      '/edit-order',
      arguments: order,
    );
  }
  
  void _createNewOrder() {
    final availableTables = ref.read(availableTablesProvider);
    
    availableTables.when(
      data: (tables) {
        if (tables.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay mesas disponibles para crear un nuevo pedido'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Seleccionar Mesa'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: ListView.builder(
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final table = tables[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${table.number}'),
                    ),
                    title: Text('Mesa ${table.number}'),
                    subtitle: Text('Capacidad: ${table.capacity} personas'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(table.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(table.status),
                        style: TextStyle(
                          color: _getStatusColor(table.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _createNewOrderForTable(table);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
      loading: () => setState(() => _isLoading = true),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
  }
  
  void _createNewOrderForTable(RestaurantTable table) {
    Navigator.of(context).pushNamed(
      '/create-order',
      arguments: table,
    );
  }
  
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => NotificationsPanel(
          scrollController: scrollController,
        ),
      ),
    );
  }
  
  void _showUserOptions(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 80, 0, 0),
      items: [
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Mi Perfil'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => _navigateToSection(context, 'profile'),
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Configuración'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => _navigateToSection(context, 'settings'),
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Panel del Mesero',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Estado de Mesas: Muestra todas las mesas y su estado actual. Puedes crear pedidos o realizar acciones tocando una mesa.',
              ),
              const SizedBox(height: 4),
              const Text(
                '• Pedidos Activos: Lista de todos los pedidos en curso. Puedes actualizar estados, editar o ver detalles.',
              ),
              const SizedBox(height: 16),
              Text(
                'Panel de Administración',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Desde aquí puedes gestionar todos los aspectos del restaurante: productos, categorías, usuarios, mesas, etc.',
              ),
              const SizedBox(height: 16),
              Text(
                'Atajos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('• Botón "+" flotante: Crear nuevo pedido'),
              const Text('• Deslizar hacia abajo: Actualizar datos'),
              const Text('• Tocar una mesa: Ver opciones de la mesa'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
  
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout logic here
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.maintenance:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Disponible';
      case TableStatus.occupied:
        return 'Ocupada';
      case TableStatus.reserved:
        return 'Reservada';
      case TableStatus.maintenance:
        return 'Mantenimiento';
      default:
        return 'Desconocido';
    }
  }
  
  Color _getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paymentConfirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.readyForDelivery:
        return Colors.green;
      case OrderStatus.delivering:
        return Colors.cyan;
      case OrderStatus.completed:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.paymentConfirmed:
        return 'Pago Confirmado';
      case OrderStatus.preparing:
        return 'En Preparación';
      case OrderStatus.readyForDelivery:
        return 'Listo para Entregar';
      case OrderStatus.delivering:
        return 'Entregando';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }
}

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
                'Notificaciones',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    tooltip: 'Marcar todas como leídas',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Configuración de notificaciones',
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
                title: 'Pedido listo para entregar',
                message: 'El pedido #12345 está listo para entregar en la Mesa 3',
                time: '2 min',
                icon: Icons.restaurant,
                color: Colors.green,
                isUnread: true,
              ),
              NotificationItem(
                title: 'Nuevo pedido recibido',
                message: 'Se ha recibido un nuevo pedido para la Mesa 5',
                time: '15 min',
                icon: Icons.receipt,
                color: Colors.blue,
                isUnread: true,
              ),
              NotificationItem(
                title: 'Reserva confirmada',
                message: 'Mesa 8 reservada para las 20:00',
                time: '30 min',
                icon: Icons.event_available,
                color: Colors.orange,
                isUnread: false,
              ),
              NotificationItem(
                title: 'Producto agotado',
                message: 'El producto "Ensalada César" se ha agotado',
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
// Admin Management Screen with improved UI/UX

// // Placeholder Widget for the Notifications Panel
// class NotificationsPanel extends StatelessWidget {
//   final ScrollController scrollController;
  
//   const NotificationsPanel({
//     super.key,
//     required this.scrollController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 40,
//           height: 5,
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Notificaciones',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               IconButton(
//                 icon: const Icon(Icons.more_vert),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//         const Divider(),
//         Expanded(
//           child: ListView(
//             controller: scrollController,
//             padding: const EdgeInsets.all(16.0),
//             children: const [
//               NotificationItem(
//                 title: 'Mesa 5: Pedido Listo',
//                 body: 'El pedido #1234 está listo para ser servido',
//                 time: '5 min',
//                 icon: Icons.restaurant,
//                 color: Colors.green,
//               ),
//               NotificationItem(
//                 title: 'Nuevo Pedido',
//                 body: 'Se ha creado un nuevo pedido para la Mesa 3',
//                 time: '12 min',
//                 icon: Icons.receipt,
//                 color: Colors.blue,
//               ),
//               NotificationItem(
//                 title: 'Mesa 7: Solicitud de Asistencia',
//                 body: 'Los clientes solicitan la presencia de un mesero',
//                 time: '15 min',
//                 icon: Icons.people,
//                 color: Colors.orange,
//                 isUnread: false,
//               ),
//               NotificationItem(
//                 title: 'Stock Bajo',
//                 body: 'Alerta: El producto "Vino tinto" está por agotarse',
//                 time: '1h',
//                 icon: Icons.warning,
//                 color: Colors.red,
//                 isUnread: false,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Notification Item Widget
// class NotificationItem extends StatelessWidget {
//   final String title;
//   final String body;
//   final String time;
//   final IconData icon;
//   final Color color;
//   final bool isUnread;
  
//   const NotificationItem({
//     super.key,
//     required this.title,
//     required this.body,
//     required this.time,
//     required this.icon,
//     required this.color,
//     this.isUnread = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: isUnread ? color.withOpacity(0.1) : null,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: color.withOpacity(0.2),
//           child: Icon(
//             icon,
//             color: color,
//           ),
//         ),
//         title: Text(
//           title,
//           style: theme.textTheme.titleSmall?.copyWith(
//             fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         subtitle: Text(body),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               time,
//               style: theme.textTheme.bodySmall,
//             ),
//             const SizedBox(height: 4),
//             if (isUnread)
//               Container(
//                 width: 8,
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: color,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//           ],
//         ),
//         onTap: () {},
//       ),
//     );
//   }
// }

// Placeholder classes for navigation
class TableManagementScreen extends ConsumerWidget {
  const TableManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Mesas'),
      ),
      body: const Center(
        child: Text('Pantalla de Gestión de Mesas'),
      ),
    );
  }
}

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
      ),
      body: const Center(
        child: Text('Pantalla de Gestión de Productos'),
      ),
    );
  }
}

class OrderManagementScreen extends ConsumerWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
      ),
      body: const Center(
        child: Text('Pantalla de Gestión de Pedidos'),
      ),
    );
  }
}

class OrderDetailsScreen extends ConsumerWidget {
  final Order order;
  
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${order.id.substring(0, 8)}'),
      ),
      body: const Center(
        child: Text('Detalles del Pedido'),
      ),
    );
  }
}

class CreateOrderScreen extends ConsumerWidget {
  final RestaurantTable table;
  
  const CreateOrderScreen({super.key, required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Pedido - Mesa ${table.number}'),
      ),
      body: const Center(
        child: Text('Pantalla de Creación de Pedido'),
      ),
    );
  }
}

class EditOrderScreen extends ConsumerWidget {
  final Order order;
  
  const EditOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Pedido #${order.id.substring(0, 8)}'),
      ),
      body: const Center(
        child: Text('Pantalla de Edición de Pedido'),
      ),
    );
  }
}

// Models placeholder
// enum TableStatus { available, occupied, reserved, cleaning }

// enum OrderStatus { pending, inProgress, ready, delivered, completed, cancelled }

// class Order {
//   final String id;
//   final DateTime createdAt;
//   final int? tableNumber;
//   final List<OrderItem> items;
//   final double totalAmount;
//   final OrderStatus status;
  
//   Order({
//     required this.id,
//     required this.createdAt,
//     this.tableNumber,
//     required this.items,
//     required this.totalAmount,
//     required this.status,
//   });
// }

// class OrderItem {
//   final String productId;
//   final String name;
//   final double price;
//   final int quantity;
//   final String? notes;
  
//   OrderItem({
//     required this.productId,
//     required this.name,
//     required this.price,
//     required this.quantity,
//     this.notes,
//   });
// }

// class RestaurantTable {
//   final String id;
//   final int number;
//   final int capacity;
//   final TableStatus status;
//   final String? currentOrderId;
  
//   RestaurantTable({
//     required this.id,
//     required this.number,
//     required this.capacity,
//     required this.status,
//     this.currentOrderId,
//   });
// }


// Service providers
final authServiceProvider = Provider((ref) => AuthService());
// final adminManagementServiceProvider = Provider((ref) => AdminManagementService());
// final orderServiceProvider = Provider((ref) => OrderService());
// final tableServiceProvider = Provider((ref) => TableService());
// final productServiceProvider = Provider((ref) => ProductService());
// final printServiceProvider = Provider((ref) => PrintService());

// Stream providers
// final adminsStreamProvider = StreamProvider<List<AdminUser>>((ref) {
//   final adminService = ref.watch(adminManagementServiceProvider);
//   return adminService.getAdminsStream();
// });

final currentUserProvider = FutureProvider<UserProfile?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});

final isCurrentUserProvider = FutureProvider.family<bool, String>((ref, email) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  return currentUser?.email == email;
});

// final tablesStatusProvider = FutureProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getAllTables();
// });

// final availableTablesProvider = FutureProvider<List<RestaurantTable>>((ref) async {
//   final allTables = await ref.watch(tablesStatusProvider.future);
//   return allTables.where((table) => 
//     table.status == TableStatus.available || 
//     table.status == TableStatus.reserved
//   ).toList();
// });

// final activeOrdersProvider = FutureProvider<List<Order>>((ref) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getActiveOrders();
// });

// final restaurantStatsProvider = FutureProvider<RestaurantStats>((ref) {
//   final tableService = ref.watch(tableServiceProvider);
//   final orderService = ref.watch(orderServiceProvider);
  
//   return Future.wait([
//     tableService.getTableStats(),
//     orderService.getOrderStats(),
//   ]).then((results) {
//     final tableStats = results[0] as TableStats;
//     final orderStats = results[1] as OrderStats;
    
//     return RestaurantStats(
//       totalTables: tableStats.totalTables,
//       occupiedTables: tableStats.occupiedTables,
//       pendingOrders: orderStats.pendingOrders,
//       dailySales: orderStats.dailySales,
//       averageServiceTime: orderStats.averageServiceTime, readyOrders: 0, reservedTables: 0, cleaningTables: 0, preparingOrders: 0,
//     );
//   });
// });

// // Stats classes
// class TableStats {
//   final int totalTables;
//   final int occupiedTables;
  
//   TableStats({
//     required this.totalTables,
//     required this.occupiedTables,
//   });
// }

// Services - These would be implemented with actual functionality
class AuthService {
  Future<UserProfile?> getCurrentUser() async {
    // Mock implementation
    return UserProfile(
      uid: 'user123',
      email: 'mesero@restaurante.com',
      displayName: 'Juan Mesero',
    );
  }
  
  Future<void> signOut() async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  
  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
  });
}

// class AdminManagementService {
//   Future<String> addAdmin(String email) async {
//     // Mock implementation
//     await Future.delayed(const Duration(seconds: 1));
//     return 'Administrador agregado correctamente';
//   }
  
//   Future<String> removeAdmin(String email) async {
//     // Mock implementation
//     await Future.delayed(const Duration(seconds: 1));
//     return 'Administrador eliminado correctamente';
//   }
  
//   Stream<List<AdminUser>> getAdminsStream() {
//     // Mock implementation
//     return Stream.value([
//       AdminUser(
//         email: 'admin@restaurante.com',
//         createdAt: DateTime.now().subtract(const Duration(days: 30)),
//       ),
//       AdminUser(
//         email: 'gerente@restaurante.com',
//         createdAt: DateTime.now().subtract(const Duration(days: 15)),
//       ),
//       AdminUser(
//         email: 'mesero@restaurante.com',
//         createdAt: DateTime.now().subtract(const Duration(days: 5)),
//       ),
//     ]);
//   }
// }

// class OrderService {
//   Future<List<Order>> getActiveOrders() async {
//     // Mock implementation
//     await Future.delayed(const Duration(seconds: 1));
    
//     return [
//       Order(
//         id: 'order123456789',
//         createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
//         tableNumber: 5,
//         items: [
//           OrderItem(
//             productId: 'prod1',
//             name: 'Hamburguesa Clásica',
//             price: 9.99,
//             quantity: 2,
//           ),
//           OrderItem(
//             productId: 'prod2',
//             name: 'Refresco Cola',
//             price: 2.50,
//             quantity: 2,
//           ),
//         ],
//         totalAmount: 24.98,
//         status: OrderStatus.inProgress,
//       ),
//       Order(
//         id: 'order987654321',
//         createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
//         tableNumber: 3,
//         items: [
//           OrderItem(
//             productId: 'prod3',
//             name: 'Ensalada César',
//             price: 7.99,
//             quantity: 1,
//           ),
//           OrderItem(
//             productId: 'prod4',
//             name: 'Agua Mineral',
//             price: 1.50,
//             quantity: 1,
//           ),
//         ],
//         totalAmount: 9.49,
//         status: OrderStatus.pending,
//       ),
//     ];
//   }
  
//   Future<Order?> getOrderById(String orderId) async {
//     // Mock implementation
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     return Order(
//       id: orderId,
//       createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
//       tableNumber: 5,
//       items: [
//         OrderItem(
//           productId: 'prod1',
//           name: 'Hamburguesa Clásica',
//           price: 9.99,
//           quantity: 2,
//         ),
//         OrderItem(
//           productId: 'prod2',
//           name: 'Refresco Cola',
//           price: 2.50,
//           quantity: 2,
//         ),
//       ],
//       totalAmount: 24.98,
//       status: OrderStatus.inProgress,
//     );
//   }
  
//   Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
//     // Mock implementation
//     await Future.delayed(const Duration(milliseconds: 500));
//   }
  
//   Future<OrderStats> getOrderStats() async {
//     // Mock implementation
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     return OrderStats(
//       pendingOrders: 3,
//       dailySales: 456.75,
//       averageServiceTime: 12, preparingOrders: 0, readyOrders: 0,
//     );
//   }
// }

// class TableService {
//   Future<List<RestaurantTable>> getAllTables() async {
//     // Mock implementation
//     await Future.delayed(const Duration(seconds: 1));
    
//     return [
//       RestaurantTable(
//         id: 'table1',
//         number: 1,
//         capacity: 4,
//         status: TableStatus.available,
//       ),
//       RestaurantTable(
//         id: 'table2',
//         number: 2,
//         capacity: 2,
//         status: TableStatus.available,
//       ),
//       RestaurantTable(
//         id: 'table3',
//         number: 3,
//         capacity: 6,
//         status: TableStatus.occupied,
//         currentOrderId: 'order987654321',
//       ),
//       RestaurantTable(
//         id: 'table4',
//         number: 4,
//         capacity: 4,
//         status: TableStatus.reserved,
//       ),
//       RestaurantTable(
//         id: 'table5',
//         number: 5,
//         capacity: 6,
//         status: TableStatus.occupied,
//         currentOrderId: 'order123456789',
//       ),
//       RestaurantTable(
//         id: 'table6',
//         number: 6,
//         capacity: 2,
//         status: TableStatus.cleaning,
//       ),
//       RestaurantTable(
//         id: 'table7',
//         number: 7,
//         capacity: 8,
//         status: TableStatus.available,
//       ),
//       RestaurantTable(
//         id: 'table8',
//         number: 8,
//         capacity: 4,
//         status: TableStatus.available,
//       ),
//     ];
//   }
  
//   Future<void> updateTableStatus(String tableId, TableStatus newStatus) async {
//     // Mock implementation
//     await Future.delayed(const Duration(milliseconds: 500));
//   }
  
//   Future<TableStats> getTableStats() async {
//     // Mock implementation
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     return TableStats(
//       totalTables: 8,
//       occupiedTables: 2,
//     );
//   }
// }


// class PrintService {
//   Future<void> printOrder(Order order) async {
//     // Mock implementation
//     await Future.delayed(const Duration(seconds: 1));
//   }
// }

// class AdminUser {
//   final String email;
//   final DateTime? createdAt;
  
//   AdminUser({
//     required this.email,
//     this.createdAt,
//   });
// }