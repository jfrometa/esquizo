import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

/// Enhanced Footer Section with links and information
class EnhancedFooterSection extends StatelessWidget {
  const EnhancedFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isMobile ? 16 : 32,
      ),
      child: Column(
        children: [
          if (isMobile)
            _buildMobileFooterContent(context)
          else
            _buildDesktopFooterContent(context),
          const SizedBox(height: 40),
          Divider(
            color: colorScheme.outline.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10,
            children: [
              Text(
                '© 2025 Kako. Todos los derechos reservados.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              if (!isMobile)
                Wrap(
                  spacing: 16,
                  children: [
                    InkWell(
                      onTap: () {
                        // TODO: Implement Terms and Conditions page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Términos y Condiciones próximamente')),
                        );
                      },
                      child: Text(
                        'Términos y Condiciones',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // TODO: Implement Privacy Policy page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Política de Privacidad próximamente')),
                        );
                      },
                      child: Text(
                        'Política de Privacidad',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    // TODO: Implement Terms and Conditions page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Términos y Condiciones próximamente')),
                    );
                  },
                  child: Text(
                    'Términos y Condiciones',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    // TODO: Implement Privacy Policy page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Política de Privacidad próximamente')),
                    );
                  },
                  child: Text(
                    'Política de Privacidad',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileFooterContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and description
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/appIcon.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading image: $error');
                    return const Icon(Icons.image_not_supported, size: 80);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kako',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Disfruta de comidas exquisitas, saludables y con presentación impecable, entregadas directamente a tu puerta o servidas en nuestro elegante restaurante.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Quick links
        Text(
          'Enlaces Rápidos',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink(context, 'Inicio', Icons.home),
        _buildFooterLink(context, 'Menú', Icons.restaurant_menu),
        _buildFooterLink(context, 'Reservaciones', Icons.event_seat),
        _buildFooterLink(context, 'Planes de Comida', Icons.food_bank),
        _buildFooterLink(context, 'Catering', Icons.celebration),
        _buildFooterLink(context, 'Contacto', Icons.mail),

        const SizedBox(height: 32),

        // Newsletter
        Text(
          'Suscríbete a nuestro boletín',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recibe nuestras últimas noticias, eventos y ofertas especiales directamente en tu bandeja de entrada.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ingresa tu email',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Newsletter subscription
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gracias por suscribirte')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Suscribir'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFooterContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and description
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/appIcon.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: $error');
                          return const Icon(Icons.image_not_supported,
                              size: 80);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Kako',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Disfruta de comidas exquisitas, saludables y con presentación impecable, entregadas directamente a tu puerta o servidas en nuestro elegante restaurante.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Av. La Marina 2000, San Miguel, Lima\nTeléfono: +51 123 456 789\nEmail: info@upgrade.do',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 64),

        // Quick links
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enlaces Rápidos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildFooterLink(context, 'Inicio', Icons.home),
              _buildFooterLink(context, 'Menú', Icons.restaurant_menu),
              _buildFooterLink(context, 'Reservaciones', Icons.event_seat),
              _buildFooterLink(context, 'Planes de Comida', Icons.food_bank),
              _buildFooterLink(context, 'Catering', Icons.celebration),
              _buildFooterLink(context, 'Contacto', Icons.mail),
            ],
          ),
        ),

        const SizedBox(width: 64),

        // Newsletter
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suscríbete a nuestro boletín',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recibe nuestras últimas noticias, eventos y ofertas especiales directamente en tu bandeja de entrada.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ingresa tu email',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Newsletter subscription
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gracias por suscribirte')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Suscribir'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Síguenos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSocialIconButton(context, Icons.facebook),
                  const SizedBox(width: 12),
                  _buildSocialIconButton(context, Icons.camera_alt),
                  const SizedBox(width: 12),
                  _buildSocialIconButton(context, Icons.alternate_email),
                  const SizedBox(width: 12),
                  _buildSocialIconButton(context, Icons.video_collection),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (title == 'Inicio') {
            // Already here, scroll to top
          } else if (title == 'Menú') {
            context.goToBusinessHome();
          } else if (title == 'Reservaciones') {
            // TODO: Trigger reservation sheet
          } else if (title == 'Planes de Comida') {
            context.goNamedSafe(AppRoute.mealPlans.name);
          } else if (title == 'Catering') {
            context.goNamedSafe(AppRoute.catering.name);
          } else if (title == 'Contacto') {
            // TODO: Scroll to contact
          }
        },
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIconButton(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        // TODO: Open Social Media link
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Redes sociales próximamente')),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
