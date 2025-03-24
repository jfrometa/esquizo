import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/catalog_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart';

part 'featured_dishes_provider.g.dart';

@riverpod
Future<List<CatalogItem>> featuredDishes(FeaturedDishesRef ref) async {
  final catalogType = 'menu';
  final catalogService = ref.watch(catalogServiceProvider(catalogType));
  final itemsStream = catalogService.getItems();

  // Get all menu items
  final items = await itemsStream.first;

  // Filter for featured items or return all if no featured flag exists
  return items.where((item) {
    // if (item.metadata.containsKey('featured')) {
    //   return item.metadata['featured'] == true;
    // }
    return true;
  }).toList();
}
