import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/catalog_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart';

part 'catering_packages_provider.g.dart';

class CateringPackage {
  final String id;
  final String title;
  final String description;
  final String price;
  final IconData icon;

  CateringPackage({
    required this.id, 
    required this.title, 
    required this.description, 
    required this.price, 
    required this.icon
  });
}

// Convert CatalogItem to CateringPackage
CateringPackage _convertToCateringPackage(CatalogItem item) {
  // Determine icon based on metadata or provide a default
  IconData getIconFromMetadata(Map<String, dynamic> metadata) {
    final iconName = metadata['icon'] as String? ?? 'celebration';
    
    switch (iconName) {
      case 'wine_bar': return Icons.wine_bar;
      case 'business_center': return Icons.business_center;
      case 'settings': return Icons.settings;
      case 'celebration':
      default: return Icons.celebration;
    }
  }

  return CateringPackage(
    id: item.id,
    title: item.name,
    description: item.description,
    price: 'S/ ${item.price.toStringAsFixed(2)}',
    icon: getIconFromMetadata(item.metadata),
  );
}

@riverpod
Future<List<CateringPackage>> cateringPackages(CateringPackagesRef ref) async {
  final catalogType = 'catering';
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  final itemsStream = catalogService.getItems();
  
  // Get catering items
  final items = await itemsStream.first;
  
  // Convert to CateringPackage objects
  return items.map(_convertToCateringPackage).toList();
}