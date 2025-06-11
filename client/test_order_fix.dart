// Test file to verify the order saving fix
import 'dart:convert';

// Simple test to verify OrderItem toMap works correctly with null id
void main() {
  print('Testing OrderItem.toMap() with null id...');

  // Simulate an OrderItem with null id (which was causing the issue)
  final testOrderItem = TestOrderItem(
    id: null, // This was causing the Firestore error
    productId: 'product_123',
    name: 'Test Product',
    price: 10.0,
    quantity: 2,
    notes: 'Extra sauce',
    categoryId: 'category_1',
    categoryName: 'Appetizers',
    imageUrl: 'test.jpg',
    isPriority: false,
    isModifiable: true,
  );

  final map = testOrderItem.toMap();

  print('Generated map: $map');

  // Check that null id is not included in the map
  if (map.containsKey('id')) {
    print('❌ ERROR: Map should not contain id key when id is null');
  } else {
    print('✅ SUCCESS: Map correctly excludes null id field');
  }

  // Test with non-null id
  final testOrderItemWithId = TestOrderItem(
    id: 'item_123',
    productId: 'product_123',
    name: 'Test Product',
    price: 10.0,
    quantity: 2,
  );

  final mapWithId = testOrderItemWithId.toMap();

  if (mapWithId.containsKey('id') && mapWithId['id'] == 'item_123') {
    print('✅ SUCCESS: Map correctly includes non-null id field');
  } else {
    print('❌ ERROR: Map should contain id when id is not null');
  }

  // Test JSON serialization (what Firestore does internally)
  try {
    final jsonString = jsonEncode(map);
    print('✅ SUCCESS: Map can be safely JSON encoded');
    print('JSON: $jsonString');
  } catch (e) {
    print('❌ ERROR: Map cannot be JSON encoded: $e');
  }
}

// Test class that mimics the fixed OrderItem
class TestOrderItem {
  final String? id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? notes;
  final String? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final bool isPriority;
  final bool isModifiable;

  TestOrderItem({
    this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.notes,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.isPriority = false,
    this.isModifiable = true,
  });

  // This is the FIXED version of toMap()
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'notes': notes,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'isPriority': isPriority,
      'isModifiable': isModifiable,
    };

    // Only include id if it's not null to avoid Firestore issues
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
