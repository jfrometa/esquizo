import 'package:cloud_firestore/cloud_firestore.dart';

// Menu item model
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String? imageUrl;
  final bool isAvailable;
  final bool isSpecial;
  final bool isPopular;
  final Map<String, dynamic>? options;  // For item customization options
  final List<String>? allergens;        // List of allergens in the item
  final int preparationTime;            // Estimated preparation time in minutes
  final Map<String, dynamic>? nutritionalInfo;  // Nutritional information
  
  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.isAvailable = true,
    this.isSpecial = false,
    this.isPopular = false,
    this.options,
    this.allergens,
    this.preparationTime = 15,
    this.nutritionalInfo,
  });
  
  // Create from Firestore document
  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MenuItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'] ?? true,
      isSpecial: data['isSpecial'] ?? false,
      isPopular: data['isPopular'] ?? false,
      options: data['options'],
      allergens: data['allergens'] != null 
          ? List<String>.from(data['allergens']) 
          : null,
      preparationTime: data['preparationTime'] ?? 15,
      nutritionalInfo: data['nutritionalInfo'],
    );
  }
  
  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isSpecial': isSpecial,
      'isPopular': isPopular,
      'options': options,
      'allergens': allergens,
      'preparationTime': preparationTime,
      'nutritionalInfo': nutritionalInfo,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  // Create a copy with updated fields
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? imageUrl,
    bool? isAvailable,
    bool? isSpecial,
    bool? isPopular,
    Map<String, dynamic>? options,
    List<String>? allergens,
    int? preparationTime,
    Map<String, dynamic>? nutritionalInfo,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isSpecial: isSpecial ?? this.isSpecial,
      isPopular: isPopular ?? this.isPopular,
      options: options ?? this.options,
      allergens: allergens ?? this.allergens,
      preparationTime: preparationTime ?? this.preparationTime,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
    );
  }
}

// Menu category model
class MenuCategory {
  final String id;
  final String name;
  final int sortOrder;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  
  MenuCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });
  
  // Create from Firestore document
  factory MenuCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MenuCategory(
      id: doc.id,
      name: data['name'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
      description: data['description'],
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
    );
  }
  
  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'sortOrder': sortOrder,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  // Create a copy with updated fields
  MenuCategory copyWith({
    String? id,
    String? name,
    int? sortOrder,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}