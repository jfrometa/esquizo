import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../screens/admin/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore;

  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _categoriesCollection => _firestore
      .collection('restaurants')
      .doc('default')
      .collection('categories');

  CollectionReference get _productsCollection => _firestore
      .collection('restaurants')
      .doc('default')
      .collection('products');

  // Get all categories
  Stream<List<MenuCategory>> getCategories() {
    return _categoriesCollection
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuCategory.fromFirestore(doc))
          .toList();
    });
  }

  // Get all products
  Stream<List<MenuItem>> getProducts() {
    return _productsCollection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
    });
  }

  // Get products by category
  Stream<List<MenuItem>> getProductsByCategory(String categoryId) {
    return _productsCollection
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
    });
  }

  // Get a single category
  Future<MenuCategory?> getCategory(String categoryId) async {
    final doc = await _categoriesCollection.doc(categoryId).get();
    if (doc.exists) {
      return MenuCategory.fromFirestore(doc);
    }
    return null;
  }

  // Get a single product
  Future<MenuItem?> getProduct(String productId) async {
    final doc = await _productsCollection.doc(productId).get();
    if (doc.exists) {
      return MenuItem.fromFirestore(doc);
    }
    return null;
  }

  // Create a new category
  Future<String> createCategory(MenuCategory category) async {
    final docRef = await _categoriesCollection.add(category.toFirestore());
    return docRef.id;
  }

  // Create a new product
  Future<String> createProduct(MenuItem product) async {
    final docRef = await _productsCollection.add(product.toFirestore());
    return docRef.id;
  }

  // Update a category
  Future<void> updateCategory(MenuCategory category) async {
    await _categoriesCollection.doc(category.id).update(category.toFirestore());
  }

  // Update a product
  Future<void> updateProduct(MenuItem product) async {
    await _productsCollection.doc(product.id).update(product.toFirestore());
  }

  // Update product availability
  Future<void> updateProductAvailability(
      String productId, bool isAvailable) async {
    await _productsCollection.doc(productId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    // Check if there are products in this category
    final products = await _productsCollection
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();

    if (products.docs.isNotEmpty) {
      throw Exception(
          'No se puede eliminar la categoría porque tiene productos asociados');
    }

    await _categoriesCollection.doc(categoryId).delete();
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }

  // Update category sort order
  Future<void> updateCategorySortOrder(
      String categoryId, int newSortOrder) async {
    await _categoriesCollection.doc(categoryId).update({
      'sortOrder': newSortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

// Provider for product service
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Provider for categories stream
final menuCategoriesProvider = StreamProvider<List<MenuCategory>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getCategories();
});

// Provider for products stream
final menuProductsProvider = StreamProvider<List<MenuItem>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProducts();
});

// Provider for products by category
final categoryProductsProvider =
    StreamProvider.family<List<MenuItem>, String>((ref, categoryId) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsByCategory(categoryId);
});
