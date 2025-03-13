import 'package:flutter/material.dart';

/// Catering details content
class CateringDetailsContent extends StatelessWidget {
  final String packageTitle;
  final ScrollController scrollController;
  
  const CateringDetailsContent({
    super.key,
    required this.packageTitle,
    required this.scrollController,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Sample menu items based on package type
    List<Map<String, dynamic>> menuItems = [];
    String packageDescription = '';
    
    if (packageTitle == 'Cocktail Party') {
      packageDescription = 'Nuestro paquete para cocktails es perfecto para reuniones informales, lanzamientos y eventos sociales. Incluye una selección de canapés gourmet, bebidas y servicio profesional.';
      menuItems = [
        {
          'title': 'Canapés Variados',
          'description': 'Selección de 8 variedades de canapés gourmet (3 por persona)',
          'included': true,
        },
        {
          'title': 'Estación de Quesos',
          'description': 'Selección de quesos locales e importados con acompañamientos',
          'included': true,
        },
        {
          'title': 'Barra de Bebidas',
          'description': 'Selección de vinos, cervezas y bebidas sin alcohol',
          'included': true,
        },
        {
          'title': 'Cócktails Preparados',
          'description': 'Selección de cócteles clásicos preparados por nuestros bartenders',
          'included': false,
        },
        {
          'title': 'Postres Miniatura',
          'description': 'Selección de postres en formato miniatura (2 por persona)',
          'included': true,
        },
      ];
    } else if (packageTitle == 'Corporate Lunch') {
      packageDescription = 'Diseñado para reuniones de negocios y eventos corporativos, nuestro paquete de almuerzo ofrece un menú equilibrado y profesional que impresionará a sus clientes y colaboradores.';
      menuItems = [
        {
          'title': 'Ensaladas Gourmet',
          'description': 'Selección de ensaladas frescas y saludables',
          'included': true,
        },
        {
          'title': 'Plato Principal',
          'description': 'Elección entre 3 opciones de plato principal (carne, pescado, vegetariano)',
          'included': true,
        },
        {
          'title': 'Guarniciones',
          'description': 'Acompañamientos variados para complementar el plato principal',
          'included': true,
        },
        {
          'title': 'Bebidas',
          'description': 'Agua, jugos naturales y refrescos',
          'included': true,
        },
        {
          'title': 'Postres',
          'description': 'Selección de postres elegantes para finalizar la comida',
          'included': true,
        },
        {
          'title': 'Café y Té',
          'description': 'Estación de café y té para después de la comida',
          'included': true,
        },
      ];
    } else if (packageTitle == 'Wedding Reception') {
      packageDescription = 'Haga de su día especial un evento inolvidable con nuestro paquete de catering para bodas. Incluye un menú personalizado, decoración de mesas y servicio de calidad superior.';
      menuItems = [
        {
          'title': 'Cocktail de Bienvenida',
          'description': 'Selección de canapés y bebidas para recibir a los invitados',
          'included': true,
        },
        {
          'title': 'Entrada',
          'description': 'Elegante primer plato para comenzar la celebración',
          'included': true,
        },
        {
          'title': 'Plato Principal',
          'description': 'Opciones de lujo para el plato principal, adaptado a sus preferencias',
          'included': true,
        },
        {
          'title': 'Torta de Bodas',
          'description': 'Torta personalizada diseñada según sus especificaciones',
          'included': true,
        },
        {
          'title': 'Mesa de Postres',
          'description': 'Variedad de postres elegantes para deleitar a sus invitados',
          'included': true,
        },
        {
          'title': 'Barra de Bebidas Premium',
          'description': 'Servicio completo de bar con opciones premium',
          'included': true,
        },
        {
          'title': 'Brindis con Champagne',
          'description': 'Champagne de calidad para el brindis especial',
          'included': true,
        },
      ];
    } else {
      packageDescription = 'Diseñamos un paquete totalmente personalizado basado en sus necesidades específicas, presupuesto y número de invitados. Contáctenos para una consulta detallada.';
      menuItems = [
        {
          'title': 'Menú Personalizado',
          'description': 'Diseñado específicamente para su evento y preferencias',
          'included': true,
        },
        {
          'title': 'Estaciones Temáticas',
          'description': 'Opciones de estaciones de comida según la temática de su evento',
          'included': true,
        },
        {
          'title': 'Opciones Dietéticas Especiales',
          'description': 'Adaptación a necesidades dietéticas y alergias',
          'included': true,
        },
        {
          'title': 'Personal de Servicio',
          'description': 'Personal profesional adaptado al tamaño de su evento',
          'included': true,
        },
        {
          'title': 'Equipo y Mobiliario',
          'description': 'Opciones de alquiler de equipo, vajilla y mobiliario',
          'included': true,
        },
        {
          'title': 'Decoración',
          'description': 'Opciones de decoración personalizada',
          'included': true,
        },
      ];
    }
    
    return ListView(
      controller: scrollController,
      children: [
        // Package description
        Text(
          'Detalles del Paquete',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          packageDescription,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        
        // Included items
        Text(
          'Menú Incluido',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuItems.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item['included']
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['included'] ? Icons.check : Icons.add,
                  color: item['included']
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              title: Text(
                item['title'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                item['description'],
                style: theme.textTheme.bodyMedium,
              ),
              trailing: item['included']
                  ? null
                  : TextButton(
                      onPressed: () {},
                      child: const Text('Agregar'),
                    ),
            );
          },
        ),
        
        const Divider(height: 32),
        
        // Additional services
        Text(
          'Servicios Adicionales',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAdditionalServiceChip(context, 'Servicio de DJ'),
            _buildAdditionalServiceChip(context, 'Decoración Floral'),
            _buildAdditionalServiceChip(context, 'Fotografía'),
            _buildAdditionalServiceChip(context, 'Transporte'),
            _buildAdditionalServiceChip(context, 'Barra de Postres'),
            _buildAdditionalServiceChip(context, 'Mobiliario Extra'),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Terms and conditions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.surfaceVariant,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Términos y Condiciones',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildTermItem('Se requiere un depósito del 50% para confirmar la reserva'),
              _buildTermItem('La cancelación con menos de 7 días de anticipación implica la pérdida del depósito'),
              _buildTermItem('El número final de invitados debe confirmarse 3 días antes del evento'),
              _buildTermItem('Los precios no incluyen IVA'),
              _buildTermItem('Servicios adicionales sujetos a disponibilidad'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAdditionalServiceChip(BuildContext context, String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (bool selected) {},
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
  
  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
