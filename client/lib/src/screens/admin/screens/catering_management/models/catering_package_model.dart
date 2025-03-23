import 'package:flutter/foundation.dart';

class CateringPackage {
  final String id;
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
    name: '',
    description: '',
    basePrice: 0,
  );

  // From JSON constructor
  factory CateringPackage.fromJson(Map<String, dynamic> json) {
    return CateringPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      categoryIds: (json['categoryIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PackageItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
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
      iconCodePoint: clearIconCodePoint ? null : (iconCodePoint ?? this.iconCodePoint),
      iconFontFamily: clearIconFontFamily ? null : (iconFontFamily ?? this.iconFontFamily),
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CateringPackage &&
      other.id == id &&
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
    return 'CateringPackage(id: $id, name: $name, basePrice: $basePrice, items: ${items.length})';
  }
}

class PackageItem {
  final String itemId;
  final String name;
  final int quantity;
  final double pricePerUnit;
  final String description;
  final bool isRequired;
  final int minQuantity;
  final int maxQuantity;

  const PackageItem({
    required this.itemId,
    required this.name,
    this.quantity = 1,
    this.pricePerUnit = 0,
    this.description = '',
    this.isRequired = false,
    this.minQuantity = 0,
    this.maxQuantity = 0,
  });

  // From JSON constructor
  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 1,
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      isRequired: json['isRequired'] as bool? ?? false,
      minQuantity: json['minQuantity'] as int? ?? 0,
      maxQuantity: json['maxQuantity'] as int? ?? 0,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'description': description,
      'isRequired': isRequired,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
    };
  }

  // Copy with method
  PackageItem copyWith({
    String? itemId,
    String? name,
    int? quantity,
    double? pricePerUnit,
    String? description,
    bool? isRequired,
    int? minQuantity,
    int? maxQuantity,
  }) {
    return PackageItem(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PackageItem &&
      other.itemId == itemId &&
      other.name == name &&
      other.quantity == quantity &&
      other.pricePerUnit == pricePerUnit &&
      other.description == description &&
      other.isRequired == isRequired &&
      other.minQuantity == minQuantity &&
      other.maxQuantity == maxQuantity;
  }

  // Hash code
  @override
  int get hashCode {
    return itemId.hashCode ^
      name.hashCode ^
      quantity.hashCode ^
      pricePerUnit.hashCode ^
      description.hashCode ^
      isRequired.hashCode ^
      minQuantity.hashCode ^
      maxQuantity.hashCode;
  }

  // String representation
  @override
  String toString() {
    return 'PackageItem(itemId: $itemId, name: $name, quantity: $quantity, isRequired: $isRequired)';
  }
}