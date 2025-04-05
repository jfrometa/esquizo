// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/admin_services/firebase_providers.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/catalog_service.dart';

// /// Provider for the current catalog type
// final currentCatalogTypeProvider = StateProvider<String>((ref) => 'menu');

// // Provider for catalog service
// final catalogServiceProvider =
//     Provider.family<CatalogService, String>((ref, catalogType) {
//   final firestore = ref.watch(firebaseFirestoreProvider);
//   final businessId = ref.watch(currentBusinessIdProvider);

//   return CatalogService(
//     firestore: firestore,
//     businessId: businessId,
//     catalogType: catalogType,
//   );
// });

// /// Provider for categories stream
// final catalogCategoriesProvider =
//     StreamProvider.family<List<CatalogCategory>, String>((ref, catalogType) {
//   final catalogService = ref.watch(catalogServiceProvider(catalogType));
//   return catalogService.getCategories(catalogType);
// });

// /// Provider for all items stream
// final catalogItemsProvider =
//     StreamProvider.family<List<CatalogItem>, String>((ref, catalogType) {
//   final catalogService = ref.watch(catalogServiceProvider(catalogType));
//   return catalogService.getItems(catalogType);
// });

// /// Provider for items by category
// // final catalogItemsByCategoryProvider = StreamProvider.family<List<CatalogItem>, ({String catalogType, String categoryId})>((ref, params) {
// //   final catalogService = ref.watch(catalogServiceProvider(params.catalogType));
// //   return catalogService.getItemsByCategory(params.categoryId);
// // });

// // Provider for catalog items by category
// final catalogItemsByCategoryProvider = FutureProvider.family<List<CatalogItem>,
//     ({String catalogType, String categoryId})>((ref, params) async {
//   final catalogService = ref.watch(catalogServiceProvider(params.catalogType));
//   final itemsStream =
//       catalogService.getItemsByCategory(params.categoryId, params.catalogType);
//   return await itemsStream.first;
// });

// /// Provider for active categories only
// final activeCatalogCategoriesProvider =
//     StreamProvider.family<List<CatalogCategory>, String>((ref, catalogType) {
//   // Get the stream directly
//   return ref.watch(catalogCategoriesProvider(catalogType).stream).map(
//       (categories) =>
//           categories.where((category) => category.isActive).toList());
// });
