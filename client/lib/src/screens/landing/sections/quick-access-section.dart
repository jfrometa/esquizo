import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

/// Quick access section with cards for main features
class QuickAccessSection extends StatelessWidget {
  final VoidCallback onReserveTap;
  final VoidCallback onInfoTap;
  
  const QuickAccessSection({
    super.key,
    required this.onReserveTap,
    required this.onInfoTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    
    return Container(
      width: double.infinity,
      color: colorScheme.surface,
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: isMobile ? 16 : 32,
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              
              _buildQuickAccessCard(
                  context,
                  title: 'Reservar Mesa',
                  icon: Icons.calendar_today,
                  description: 'Reserve su mesa para una experiencia gastronómica inolvidable',
                  onTap: onReserveTap,
                  color: colorScheme.primaryContainer,
                ),
               
               
                  _buildQuickAccessCard(
                  context,
                  title: 'Nuestro Menú',
                  icon: Icons.restaurant_menu,
                  description: 'Descubra nuestra variedad de platos exquisitos',
                  onTap: () => context.goNamed(AppRoute.home.name),
                  color: colorScheme.secondaryContainer,
                ),
               
              _buildQuickAccessCard(
                  context,
                  title: 'Catering',
                  icon: Icons.celebration,
                  description: 'Servicios de catering para eventos especiales',
                  onTap: () => context.goNamed(AppRoute.cateringMenuE.name),
                  color: colorScheme.tertiaryContainer,
             
              ),
              
                 _buildQuickAccessCard(
                  context,
                  title: 'Información',
                  icon: Icons.info_outline,
                  description: 'Conozca más sobre nosotros, ubicación y horarios',
                  onTap: onInfoTap,
                  color: colorScheme.surfaceContainerHighest,
                ),
              
            
            
            ],
          ),
        ],
      ),
    );
  }
  
Widget _buildQuickAccessCard(
  BuildContext context, {
  required String title,
  required IconData icon,
  required String description,
  required VoidCallback onTap,
  required Color color,
}) {
  final theme = Theme.of(context);
  final size = MediaQuery.sizeOf(context);
  final isMobile = size.width < 600;
  
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
       width: isMobile ? double.infinity : 220,
      // ADD THIS HEIGHT CONSTRAINT:
       
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // This is important!
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 36,
            color: color,
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
