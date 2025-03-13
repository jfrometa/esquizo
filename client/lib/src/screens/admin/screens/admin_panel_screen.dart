import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/restaurant/restaurant_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/business_config_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/service_factory.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_dashboard_home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/analytics_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_settings_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/product_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/user_management/user_management_screen.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/admin_side_menu.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/theme_switcher.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/order_service.dart';
 

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
    const UserManagementScreen(),
    const BusinessSettingsScreen(),
    const AnalyticsDashboard(),
  ];
  
  final List<String> _screenTitles = [
    'Dashboard',
    'Products & Menu',
    'Orders',
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
    if (authState != AuthState.authenticated || isAdmin) {
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
        currentIndex: _selectedIndex > 3 ? 4 : _selectedIndex, // Updated to match new indices
        onTap: _onItemSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'), // Changed from Tables to Users
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
              setState(() => _selectedIndex = 3); // Was 4, now 3
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Business Settings'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 4); // Was 5, now 4
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 5); // Was 6, now 5
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