import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/catalog_service.dart';

/// Provider for the current business ID
final currentBusinessIdProvider = StateProvider<String>((ref) => 'default');

/// Provider for the current catalog type
final currentCatalogTypeProvider = StateProvider<String>((ref) => 'menu');

/// Provider for catalog service
final catalogServiceProvider = Provider.family<CatalogService, String>((ref, catalogType) {
  final businessId = ref.watch(currentBusinessIdProvider);
  return CatalogService(
    businessId: businessId,
    catalogType: catalogType,
  );
});

/// Provider for categories stream
final catalogCategoriesProvider = StreamProvider.family<List<CatalogCategory>, String>((ref, catalogType) {
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  return catalogService.getCategories();
});

/// Provider for all items stream
final catalogItemsProvider = StreamProvider.family<List<CatalogItem>, String>((ref, catalogType) {
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  return catalogService.getItems();
});

/// Provider for items by category
final catalogItemsByCategoryProvider = StreamProvider.family<List<CatalogItem>, ({String catalogType, String categoryId})>((ref, params) {
  final catalogService = ref.watch(catalogServiceProvider(params.catalogType));
  return catalogService.getItemsByCategory(params.categoryId);
});

/// Provider for active categories only
final activeCatalogCategoriesProvider = StreamProvider.family<List<CatalogCategory>, String>((ref, catalogType) {
  // Get the stream directly
  return ref.watch(catalogCategoriesProvider(catalogType).stream)
    .map((categories) => 
      categories.where((category) => category.isActive).toList()
    );
});