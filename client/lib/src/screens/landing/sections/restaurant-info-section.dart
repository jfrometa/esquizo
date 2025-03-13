import 'package:flutter/material.dart';

/// Restaurant information section
class RestaurantInfoSection extends StatelessWidget {
  final ScrollController scrollController;
  
  const RestaurantInfoSection({
    super.key,
    required this.scrollController,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    
    return ListView(
      controller: scrollController,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Acerca de Nosotros',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Restaurant image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 240,
              width: double.infinity,
              color: colorScheme.primaryContainer,
              child: const Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.white54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Restaurant story
        Text(
          'Nuestra Historia',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kako nació en 2010 con la visión de ofrecer una experiencia gastronómica excepcional en Lima. Fundada por el reconocido chef Carlos Mendoza, nuestro restaurante combina técnicas culinarias tradicionales peruanas con influencias internacionales para crear platos únicos y deliciosos.\n\nDesde nuestros humildes comienzos como un pequeño bistró, hemos crecido hasta convertirnos en uno de los destinos gastronómicos más respetados de la ciudad, manteniendo siempre nuestro compromiso con la calidad, la creatividad y el servicio excepcional.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        
        // Business hours and location
        if (isMobile)
          _buildMobileInfoSection(context)
        else
          _buildDesktopInfoSection(context),
        
        const SizedBox(height: 24),
        
        // Meet the team
        Text(
          'Nuestro Equipo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Team members
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildTeamMemberCard(
              context,
              name: 'Carlos Mendoza',
              position: 'Chef Ejecutivo',
              image: 'https://images.unsplash.com/photo-1583394838336-acd977736f90',
            ),
            _buildTeamMemberCard(
              context,
              name: 'María López',
              position: 'Chef de Pastelería',
              image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
            ),
            _buildTeamMemberCard(
              context,
              name: 'Juan Pérez',
              position: 'Jefe de Sala',
              image: 'https://images.unsplash.com/photo-1560250097-0b93528c311a',
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Awards and recognitions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Premios y Reconocimientos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildAwardItem(context, '2023', 'Mejor Restaurante de Fusión - Lima Food Awards'),
              _buildAwardItem(context, '2022', 'Chef del Año - Revista Gastronomía & Sabor'),
              _buildAwardItem(context, '2021', 'Excelencia en Servicio - TripAdvisor'),
              _buildAwardItem(context, '2020', 'Innovación Culinaria - Premios Mesa Perú'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMobileInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business hours
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Horario de Atención',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHourRow(context, 'Lunes - Viernes', '11:00 AM - 10:00 PM'),
              const SizedBox(height: 8),
              _buildHourRow(context, 'Sábado', '10:00 AM - 11:00 PM'),
              const SizedBox(height: 8),
              _buildHourRow(context, 'Domingo', '10:00 AM - 9:00 PM'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Location
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ubicación',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Av. La Marina 2000, San Miguel, Lima',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  child: const Center(
                    child: Text('Mapa de ubicación'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions),
                label: const Text('Cómo llegar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Contact information
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.contact_phone,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contacto',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildContactItem(context, Icons.phone, 'Teléfono', '+51 123 456 789'),
              const SizedBox(height: 8),
              _buildContactItem(context, Icons.email, 'Email', 'info@upgrade.do'),
              const SizedBox(height: 8),
              _buildContactItem(context, Icons.language, 'Web', 'www.upgrade.do'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDesktopInfoSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Hours and Contact
        Expanded(
          child: Column(
            children: [
              // Business hours
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildBusinessHoursSection(context),
              ),
              const SizedBox(height: 16),
              // Contact info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildContactSection(context),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Right column - Location map
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildLocationSection(context),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBusinessHoursSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Horario de Atención',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildHourRow(context, 'Lunes - Viernes', '11:00 AM - 10:00 PM'),
        const SizedBox(height: 8),
        _buildHourRow(context, 'Sábado', '10:00 AM - 11:00 PM'),
        const SizedBox(height: 8),
        _buildHourRow(context, 'Domingo', '10:00 AM - 9:00 PM'),
      ],
    );
  }
  
  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.contact_phone,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Contacto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildContactItem(context, Icons.phone, 'Teléfono', '+51 123 456 789'),
        const SizedBox(height: 8),
        _buildContactItem(context, Icons.email, 'Email', 'info@upgrade.do'),
        const SizedBox(height: 8),
        _buildContactItem(context, Icons.language, 'Web', 'www.upgrade.do'),
      ],
    );
  }
  
  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Ubicación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Av. La Marina 2000, San Miguel, Lima',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: const Center(
              child: Text('Mapa de ubicación'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.directions),
          label: const Text('Cómo llegar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildHourRow(BuildContext context, String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          hours,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Widget _buildContactItem(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTeamMemberCard(
    BuildContext context, {
    required String name,
    required String position,
    required String image,
  }) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    final cardWidth = isMobile ? double.infinity : 200.0;
    
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(image),
            onBackgroundImageError: (exception, stackTrace) {},
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            position,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAwardItem(BuildContext context, String year, String award) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              year,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              award,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
