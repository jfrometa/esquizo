import 'package:flutter/foundation.dart';

class CateringItem {
  final String id;
  final String businessId;
  final String name;
  final double price;
  final String description;
  final List<String> categoryIds;
  final String imageUrl;
  final List<String> tags;
  final bool isActive;
  final bool isHighlighted;
  final int preparationTimeMinutes;
  final String? allergenInfo;
  final List<IngredientItem> ingredients;
  final ItemUnitType unitType;
  final int? iconCodePoint;
  final String? iconFontFamily;

  // Added properties
  final int quantity;
  final bool hasUnitSelection;
  final int peopleCount;
  final double? pricePerUnit;

  const CateringItem({
    required this.id,
    required this.businessId,
    required this.name,
    required this.price,
    this.description = '',
    this.categoryIds = const [],
    this.imageUrl = '',
    this.tags = const [],
    this.isActive = false,
    this.isHighlighted = false,
    this.preparationTimeMinutes = 0,
    this.allergenInfo,
    this.ingredients = const [],
    this.unitType = ItemUnitType.perPerson,
    this.iconCodePoint,
    this.iconFontFamily,
    // Added properties with default values
    this.quantity = 1,
    this.hasUnitSelection = false,
    this.peopleCount = 1,
    this.pricePerUnit,
  });

  // Empty constructor
  factory CateringItem.empty() => const CateringItem(
        id: '',
        businessId: '',
        name: '',
        price: 0,
      );

  // From JSON constructor
  factory CateringItem.fromJson(Map<String, dynamic> json) {
    return CateringItem(
      id: json['id'] as String,
      businessId: json['businessId'] as String? ?? '',
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      categoryIds: (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      isActive: json['isActive'] as bool? ?? false,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 0,
      allergenInfo: json['allergenInfo'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => IngredientItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unitType: _parseUnitType(json['unitType']),
      iconCodePoint: json['iconCodePoint'] as int?,
      iconFontFamily: json['iconFontFamily'] as String?,
      // Added properties
      quantity: json['quantity'] as int? ?? 1,
      hasUnitSelection: json['hasUnitSelection'] as bool? ?? false,
      peopleCount: json['peopleCount'] as int? ?? 1,
      pricePerUnit: json['pricePerUnit'] != null
          ? (json['pricePerUnit'] as num).toDouble()
          : null,
    );
  }

  // Helper method to parse unit type from string or int
  static ItemUnitType _parseUnitType(dynamic unitType) {
    if (unitType == null) return ItemUnitType.perPerson;

    if (unitType is String) {
      return ItemUnitType.values.firstWhere(
        (e) => e.toString().split('.').last == unitType,
        orElse: () => ItemUnitType.perPerson,
      );
    } else if (unitType is int) {
      return ItemUnitType.values[unitType];
    }

    return ItemUnitType.perPerson;
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'price': price,
      'description': description,
      'categoryIds': categoryIds,
      'imageUrl': imageUrl,
      'tags': tags,
      'isActive': isActive,
      'isHighlighted': isHighlighted,
      'preparationTimeMinutes': preparationTimeMinutes,
      if (allergenInfo != null) 'allergenInfo': allergenInfo,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'unitType': unitType.toString().split('.').last,
      if (iconCodePoint != null) 'iconCodePoint': iconCodePoint,
      if (iconFontFamily != null) 'iconFontFamily': iconFontFamily,
      // Added properties
      'quantity': quantity,
      'hasUnitSelection': hasUnitSelection,
      'peopleCount': peopleCount,
      if (pricePerUnit != null) 'pricePerUnit': pricePerUnit,
    };
  }

  // Copy with method
  CateringItem copyWith({
    String? id,
    String? businessId,
    String? name,
    double? price,
    String? description,
    List<String>? categoryIds,
    String? imageUrl,
    List<String>? tags,
    bool? isActive,
    bool? isHighlighted,
    int? preparationTimeMinutes,
    String? allergenInfo,
    bool clearAllergenInfo = false,
    List<IngredientItem>? ingredients,
    ItemUnitType? unitType,
    int? iconCodePoint,
    bool clearIconCodePoint = false,
    String? iconFontFamily,
    bool clearIconFontFamily = false,
    // Added properties
    int? quantity,
    bool? hasUnitSelection,
    int? peopleCount,
    double? pricePerUnit,
    bool clearPricePerUnit = false,
  }) {
    return CateringItem(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      categoryIds: categoryIds ?? this.categoryIds,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      allergenInfo:
          clearAllergenInfo ? null : (allergenInfo ?? this.allergenInfo),
      ingredients: ingredients ?? this.ingredients,
      unitType: unitType ?? this.unitType,
      iconCodePoint:
          clearIconCodePoint ? null : (iconCodePoint ?? this.iconCodePoint),
      iconFontFamily:
          clearIconFontFamily ? null : (iconFontFamily ?? this.iconFontFamily),
      // Added properties
      quantity: quantity ?? this.quantity,
      hasUnitSelection: hasUnitSelection ?? this.hasUnitSelection,
      peopleCount: peopleCount ?? this.peopleCount,
      pricePerUnit:
          clearPricePerUnit ? null : (pricePerUnit ?? this.pricePerUnit),
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CateringItem &&
        other.id == id &&
        other.businessId == businessId &&
        other.name == name &&
        other.price == price &&
        other.description == description &&
        listEquals(other.categoryIds, categoryIds) &&
        other.imageUrl == imageUrl &&
        listEquals(other.tags, tags) &&
        other.isActive == isActive &&
        other.isHighlighted == isHighlighted &&
        other.preparationTimeMinutes == preparationTimeMinutes &&
        other.allergenInfo == allergenInfo &&
        listEquals(other.ingredients, ingredients) &&
        other.unitType == unitType &&
        other.iconCodePoint == iconCodePoint &&
        other.iconFontFamily == iconFontFamily &&
        // Added properties
        other.quantity == quantity &&
        other.hasUnitSelection == hasUnitSelection &&
        other.peopleCount == peopleCount &&
        other.pricePerUnit == pricePerUnit;
  }

  // Hash code
  @override
  int get hashCode {
    return id.hashCode ^
        businessId.hashCode ^
        name.hashCode ^
        price.hashCode ^
        description.hashCode ^
        categoryIds.hashCode ^
        imageUrl.hashCode ^
        tags.hashCode ^
        isActive.hashCode ^
        isHighlighted.hashCode ^
        preparationTimeMinutes.hashCode ^
        allergenInfo.hashCode ^
        ingredients.hashCode ^
        unitType.hashCode ^
        iconCodePoint.hashCode ^
        iconFontFamily.hashCode ^
        // Added properties
        quantity.hashCode ^
        hasUnitSelection.hashCode ^
        peopleCount.hashCode ^
        pricePerUnit.hashCode;
  }

  // String representation
  @override
  String toString() {
    return 'CateringItem(id: $id, businessId: $businessId, name: $name, price: $price, isActive: $isActive, quantity: $quantity)';
  }
}

class IngredientItem {
  final String name;
  final String amount;
  final String unit;
  final bool isOptional;

  const IngredientItem({
    required this.name,
    this.amount = '',
    this.unit = '',
    this.isOptional = false,
  });

  // From JSON constructor
  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    return IngredientItem(
      name: json['name'] as String,
      amount: json['amount'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      isOptional: json['isOptional'] as bool? ?? false,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'isOptional': isOptional,
    };
  }

  // Copy with method
  IngredientItem copyWith({
    String? name,
    String? amount,
    String? unit,
    bool? isOptional,
  }) {
    return IngredientItem(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IngredientItem &&
        other.name == name &&
        other.amount == amount &&
        other.unit == unit &&
        other.isOptional == isOptional;
  }

  // Hash code
  @override
  int get hashCode {
    return name.hashCode ^
        amount.hashCode ^
        unit.hashCode ^
        isOptional.hashCode;
  }

  // String representation
  @override
  String toString() {
    return 'IngredientItem(name: $name, amount: $amount, unit: $unit, isOptional: $isOptional)';
  }
}

enum ItemUnitType {
  perPerson,
  perUnit,
  perWeight,
  perVolume,

  wholeItem
}
