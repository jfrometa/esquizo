import 'package:flutter/material.dart';

// Restaurant Info Screen
class RestaurantInfoScreen extends StatelessWidget {


  const RestaurantInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with restaurant image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          
          // Restaurant info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    'Kako',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Restaurant description
                  Text(
                    'A cozy restaurant offering the finest dishes with a modern twist on traditional cuisine.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Hours section
                  _buildInfoSection(
                    context,
                    'Opening Hours',
                    Icons.access_time,
                    [
                      _buildInfoItem('Monday - Thursday', '11:00 AM - 10:00 PM'),
                      _buildInfoItem('Friday - Saturday', '11:00 AM - 11:00 PM'),
                      _buildInfoItem('Sunday', '12:00 PM - 9:00 PM'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Location section
                  _buildInfoSection(
                    context,
                    'Location',
                    Icons.location_on,
                    [
                      _buildInfoItem('Address', '123 Main Street, Miraflores, Lima'),
                      _buildInfoItem('Neighborhood', 'Miraflores'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Contact section
                  _buildInfoSection(
                    context,
                    'Contact',
                    Icons.phone,
                    [
                      _buildInfoItem('Phone', '+51 1 234 5678'),
                      _buildInfoItem('Email', 'info@laredonda.com'),
                      _buildInfoItem('Website', 'www.laredonda.com'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Amenities section
                  _buildInfoSection(
                    context,
                    'Amenities',
                    Icons.star,
                    [
                      _buildInfoItem('Parking', 'Available'),
                      _buildInfoItem('Outdoor Seating', 'Yes'),
                      _buildInfoItem('Takeout', 'Available'),
                      _buildInfoItem('Delivery', 'Available'),
                      _buildInfoItem('Accessibility', 'Wheelchair accessible'),
                      _buildInfoItem('WiFi', 'Free'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // CTA buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // In a real app, this would open maps
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening in Maps...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // In a real app, this would make a call
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Calling restaurant...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}