import 'package:uuid/uuid.dart';

enum MealPlanStatus {
  active,
  inactive,
  discontinued
}

// Model for items that can be consumed within a meal plan
class MealPlanItem {
  final String id;
  final String name;
  final String description;
  final double price;  // Individual price of the item
  final String categoryId;
  final String imageUrl;
  final bool isAvailable;
  
  MealPlanItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl = '',
    this.isAvailable = true,
  });
  
  MealPlanItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? imageUrl,
    bool? isAvailable,
  }) {
    return MealPlanItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
  
  factory MealPlanItem.fromMap(Map<String, dynamic> map) {
    return MealPlanItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      categoryId: map['categoryId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}

// Model for consumed items tracking
class ConsumedItem {
  final String id;
  final String mealPlanId;
  final String itemId;
  final String itemName;
  final DateTime consumedAt;
  final String consumedBy; // User ID who consumed or recorded
  final String notes;
  
  ConsumedItem({
    required this.id,
    required this.mealPlanId,
    required this.itemId,
    required this.itemName,
    required this.consumedAt,
    required this.consumedBy,
    this.notes = '',
  });
  
  ConsumedItem copyWith({
    String? id,
    String? mealPlanId,
    String? itemId,
    String? itemName,
    DateTime? consumedAt,
    String? consumedBy,
    String? notes,
  }) {
    return ConsumedItem(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      consumedAt: consumedAt ?? this.consumedAt,
      consumedBy: consumedBy ?? this.consumedBy,
      notes: notes ?? this.notes,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealPlanId': mealPlanId,
      'itemId': itemId,
      'itemName': itemName,
      'consumedAt': consumedAt.millisecondsSinceEpoch,
      'consumedBy': consumedBy,
      'notes': notes,
    };
  }
  
  factory ConsumedItem.fromMap(Map<String, dynamic> map) {
    return ConsumedItem(
      id: map['id'] ?? '',
      mealPlanId: map['mealPlanId'] ?? '',
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      consumedAt: DateTime.fromMillisecondsSinceEpoch(map['consumedAt']),
      consumedBy: map['consumedBy'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}

// Enhanced MealPlan class with additional fields
class MealPlan {
  final String id;
  final String title;
  final String price;
  final List<String> features;
  final bool isBestValue;
  final String description;
  final String img;
  final String longDescription;
  final String howItWorks;
  final int totalMeals;
  final int mealsRemaining;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // New fields
  final String categoryId;
  final String categoryName;
  final bool isAvailable;
  final MealPlanStatus status;
  final List<String> allowedItemIds; // Items that can be consumed in this plan
  final List<ConsumedItem> consumedItems; // History of consumed items
  final double originalPrice; // Original price before any discounts
  final DateTime? expiryDate; // When the plan expires
  final String ownerId; // Customer who owns this meal plan
  final String ownerName; // Customer name
  final String businessId; // Business ID for multi-tenant support
  
  MealPlan({
    String? id,
    required this.title,
    required this.price,
    required this.features,
    required this.description,
    required this.longDescription,
    required this.howItWorks,
    required this.totalMeals,
    required this.mealsRemaining,
    this.img = '',
    this.isBestValue = false,
    this.isAvailable = true,
    this.status = MealPlanStatus.active,
    this.categoryId = '',
    this.categoryName = '',
    this.allowedItemIds = const [],
    this.consumedItems = const [],
    this.originalPrice = 0.0,
    this.expiryDate,
    this.ownerId = '',
    this.ownerName = '',
    this.businessId = '',
    DateTime? createdAt,
    this.updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  MealPlan copyWith({
    String? id,
    String? title,
    String? price,
    List<String>? features,
    bool? isBestValue,
    String? description,
    String? img,
    String? longDescription,
    String? howItWorks,
    int? totalMeals,
    int? mealsRemaining,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryId,
    String? categoryName,
    bool? isAvailable,
    MealPlanStatus? status,
    List<String>? allowedItemIds,
    List<ConsumedItem>? consumedItems,
    double? originalPrice,
    DateTime? expiryDate,
    String? ownerId,
    String? ownerName,
    String? businessId,
  }) {
    return MealPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      features: features ?? this.features,
      isBestValue: isBestValue ?? this.isBestValue,
      description: description ?? this.description,
      img: img ?? this.img,
      longDescription: longDescription ?? this.longDescription,
      howItWorks: howItWorks ?? this.howItWorks,
      totalMeals: totalMeals ?? this.totalMeals,
      mealsRemaining: mealsRemaining ?? this.mealsRemaining,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      allowedItemIds: allowedItemIds ?? this.allowedItemIds,
      consumedItems: consumedItems ?? this.consumedItems,
      originalPrice: originalPrice ?? this.originalPrice,
      expiryDate: expiryDate ?? this.expiryDate,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      businessId: businessId ?? this.businessId,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'features': features,
      'isBestValue': isBestValue,
      'description': description,
      'img': img,
      'longDescription': longDescription,
      'howItWorks': howItWorks,
      'totalMeals': totalMeals,
      'mealsRemaining': mealsRemaining,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isAvailable': isAvailable,
      'status': status.name,
      'allowedItemIds': allowedItemIds,
      'consumedItems': consumedItems.map((item) => item.toMap()).toList(),
      'originalPrice': originalPrice,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'businessId': businessId,
    };
  }
  
  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'],
      title: map['title'] ?? '',
      price: map['price'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      isBestValue: map['isBestValue'] ?? false,
      description: map['description'] ?? '',
      img: map['img'] ?? '',
      longDescription: map['longDescription'] ?? '',
      howItWorks: map['howItWorks'] ?? '',
      totalMeals: map['totalMeals'] ?? 0,
      mealsRemaining: map['mealsRemaining'] ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) : null,
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      status: MealPlanStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MealPlanStatus.active,
      ),
      allowedItemIds: List<String>.from(map['allowedItemIds'] ?? []),
      consumedItems: map['consumedItems'] != null 
        ? List<ConsumedItem>.from(map['consumedItems']?.map((x) => ConsumedItem.fromMap(x)))
        : [],
      originalPrice: map['originalPrice']?.toDouble() ?? 0.0,
      expiryDate: map['expiryDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate']) : null,
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      businessId: map['businessId'] ?? '',
    );
  }
  
  // Helper methods
  int get remainingMealsCount => totalMeals - consumedItems.length;
  double get usagePercentage => totalMeals > 0 ? (consumedItems.length / totalMeals) * 100 : 0;
  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get isActive => isAvailable && status == MealPlanStatus.active && !isExpired;
}

// Meal Plan Category
class MealPlanCategory {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final String businessId;
  final int sortOrder;
  
  MealPlanCategory({
    String? id,
    required this.name,
    this.description = '',
    this.isActive = true,
    required this.businessId,
    this.sortOrder = 0,
  }) : id = id ?? const Uuid().v4();
  
  MealPlanCategory copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    String? businessId,
    int? sortOrder,
  }) {
    return MealPlanCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      businessId: businessId ?? this.businessId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'businessId': businessId,
      'sortOrder': sortOrder,
    };
  }
  
  factory MealPlanCategory.fromMap(Map<String, dynamic> map) {
    return MealPlanCategory(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      businessId: map['businessId'] ?? '',
      sortOrder: map['sortOrder'] ?? 0,
    );
  }
}