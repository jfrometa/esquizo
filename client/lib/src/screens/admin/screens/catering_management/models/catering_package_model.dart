import 'package:flutter/foundation.dart';

class CateringPackage {
  final String id;
  final String businessId;
  final String name;
  final String description;
  final double basePrice;
  final String imageUrl;
  final List<String> categoryIds;
  final List<PackageItem> items;
  final bool isActive;
  final bool isPromoted;
  final int minPeople;
  final int maxPeople;
  final int? iconCodePoint;
  final String? iconFontFamily;

  const CateringPackage({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.basePrice,
    this.imageUrl = '',
    this.categoryIds = const [],
    this.items = const [],
    this.isActive = false,
    this.isPromoted = false,
    this.minPeople = 0,
    this.maxPeople = 0,
    this.iconCodePoint,
    this.iconFontFamily,
  });

  // Empty constructor
  factory CateringPackage.empty() => const CateringPackage(
        id: '',
        businessId: '',
        name: '',
        description: '',
        basePrice: 0,
      );

  // From JSON constructor
  factory CateringPackage.fromJson(Map<String, dynamic> json) {
    return CateringPackage(
      id: json['id'] as String,
      businessId: json['businessId'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      categoryIds: (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PackageItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? false,
      isPromoted: json['isPromoted'] as bool? ?? false,
      minPeople: json['minPeople'] as int? ?? 0,
      maxPeople: json['maxPeople'] as int? ?? 0,
      iconCodePoint: json['iconCodePoint'] as int?,
      iconFontFamily: json['iconFontFamily'] as String?,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'categoryIds': categoryIds,
      'items': items.map((item) => item.toJson()).toList(),
      'isActive': isActive,
      'isPromoted': isPromoted,
      'minPeople': minPeople,
      'maxPeople': maxPeople,
      if (iconCodePoint != null) 'iconCodePoint': iconCodePoint,
      if (iconFontFamily != null) 'iconFontFamily': iconFontFamily,
    };
  }

  // Copy with method
  CateringPackage copyWith({
    String? id,
    String? businessId,
    String? name,
    String? description,
    double? basePrice,
    String? imageUrl,
    List<String>? categoryIds,
    List<PackageItem>? items,
    bool? isActive,
    bool? isPromoted,
    int? minPeople,
    int? maxPeople,
    int? iconCodePoint,
    bool clearIconCodePoint = false,
    String? iconFontFamily,
    bool clearIconFontFamily = false,
  }) {
    return CateringPackage(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryIds: categoryIds ?? this.categoryIds,
      items: items ?? this.items,
      isActive: isActive ?? this.isActive,
      isPromoted: isPromoted ?? this.isPromoted,
      minPeople: minPeople ?? this.minPeople,
      maxPeople: maxPeople ?? this.maxPeople,
      iconCodePoint:
          clearIconCodePoint ? null : (iconCodePoint ?? this.iconCodePoint),
      iconFontFamily:
          clearIconFontFamily ? null : (iconFontFamily ?? this.iconFontFamily),
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CateringPackage &&
        other.id == id &&
        other.businessId == businessId &&
        other.name == name &&
        other.description == description &&
        other.basePrice == basePrice &&
        other.imageUrl == imageUrl &&
        listEquals(other.categoryIds, categoryIds) &&
        listEquals(other.items, items) &&
        other.isActive == isActive &&
        other.isPromoted == isPromoted &&
        other.minPeople == minPeople &&
        other.maxPeople == maxPeople &&
        other.iconCodePoint == iconCodePoint &&
        other.iconFontFamily == iconFontFamily;
  }

  // Hash code
  @override
  int get hashCode {
    return id.hashCode ^
        businessId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        basePrice.hashCode ^
        imageUrl.hashCode ^
        categoryIds.hashCode ^
        items.hashCode ^
        isActive.hashCode ^
        isPromoted.hashCode ^
        minPeople.hashCode ^
        maxPeople.hashCode ^
        iconCodePoint.hashCode ^
        iconFontFamily.hashCode;
  }

  // String representation
  @override
  String toString() {
    return 'CateringPackage(id: $id, businessId: $businessId, name: $name, basePrice: $basePrice, items: ${items.length})';
  }
}

/// Represents an item included in a catering package
class PackageItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final int quantity;
  final bool? isRequired;

  const PackageItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    this.quantity = 1,
    this.isRequired,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Other',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      isRequired: json['isRequired'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      if (description != null) 'description': description,
      'quantity': quantity,
      if (isRequired != null) 'isRequired': isRequired,
    };
  }

  // Copy with method
  PackageItem copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    bool clearDescription = false,
    int? quantity,
    bool? isRequired,
    bool clearIsRequired = false,
  }) {
    return PackageItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: clearDescription ? null : (description ?? this.description),
      quantity: quantity ?? this.quantity,
      isRequired: clearIsRequired ? null : (isRequired ?? this.isRequired),
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PackageItem &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.price == price &&
        other.description == description &&
        other.quantity == quantity &&
        other.isRequired == isRequired;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        category.hashCode ^
        price.hashCode ^
        description.hashCode ^
        quantity.hashCode ^
        isRequired.hashCode;
  }

  @override
  String toString() {
    return 'PackageItem(id: $id, name: $name, category: $category, price: $price, quantity: $quantity, isRequired: $isRequired)';
  }
}
