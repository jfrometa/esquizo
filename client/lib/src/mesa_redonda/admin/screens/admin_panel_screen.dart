import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_management_service.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Panel de Administración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido al Panel de Administración',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona todos los aspectos de tu restaurante desde aquí',
              style: theme.textTheme.bodyLarge,
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
              style: theme.textTheme.titleLarge?.copyWith(
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
      ),
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

  void _navigateToSection(BuildContext context, String section) {
    switch (section) {
      case 'users':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AdminManagementScreen(),
          ),
        );
        break;
      // Add other navigation cases as you implement them
      default:
        // Temporary placeholder for sections not yet implemented
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sección "$section" en desarrollo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}

// Keep the existing AdminManagementScreen class
class AdminManagementScreen extends ConsumerStatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  ConsumerState<AdminManagementScreen> createState() =>
      _AdminManagementScreenState();
}

class _AdminManagementScreenState extends ConsumerState<AdminManagementScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final adminService = ref.watch(adminManagementServiceProvider);
    final admins = ref.watch(adminsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Gestión de Administradores'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email del nuevo administrador',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final result =
                          await adminService.addAdmin(_emailController.text);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                      }
                      _emailController.clear();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: admins.when(
              data: (adminList) => ListView.builder(
                itemCount: adminList.length,
                itemBuilder: (context, index) {
                  final admin = adminList[index];
                  return ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: Text(admin.email),
                    subtitle: Text('Desde: ${admin.createdAt?.toLocal() ?? 'Fecha no disponible'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever,size: 20, color: Colors.red),
                      onPressed: () async {
                        try {
                          final result =
                              await adminService.removeAdmin(admin.email);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
