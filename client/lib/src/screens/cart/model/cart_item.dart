import 'dart:convert';
 
// CartItem Model
// CartItem Model
class CartItem {
  final String id;
  final String img;
  final String title;
  final String description;
  final String pricing;
  final String? offertPricing;
  final List<String> ingredients;
  final bool isSpicy;
  final String foodType;
  final int quantity;
  final bool isOffer;

  final Map<String, dynamic> options;
  final String? notes;

  // Additional fields for meal subscription
  final bool isMealSubscription;
  final int totalMeals;
  final int remainingMeals;
  final DateTime expirationDate;
  final bool isMealPlanDish;
  // Additional fields for catering
  final int peopleCount;
  final String sideRequest;

  //Catering
  final bool? hasChef;
  final String alergias;
  final String eventType;
  final String preferencia;
  
  // Getter to return the pricing as a num
  num get numericPrice {
    try {
      // Use offertPricing if available, otherwise use regular pricing
      final priceStr = offertPricing ?? pricing;
      // Remove any currency symbols or non-numeric characters except decimal points
      final cleanedPrice = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      return num.parse(cleanedPrice);
    } catch (e) {
      // Return 0 if parsing fails
      return 0;
    }
  }

  CartItem({
    this.isMealPlanDish = false,
    required this.id,
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    this.offertPricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
    required this.quantity,
    required this.isOffer,
    this.hasChef = false,
    this.alergias = '',
    this.eventType = '',
    this.preferencia = '',
    this.isMealSubscription = false,
    this.totalMeals = 0,
    this.remainingMeals = 0,
    DateTime? expirationDate,
    this.peopleCount = 0,
    this.sideRequest = '',
    this.options = const {},
    this.notes,
  }) : expirationDate = expirationDate ?? DateTime.now().add(const Duration(days: 40));

  CartItem copyWith({
    bool? hasChef,
    String? alergias,
    String? eventType,
    String? preferencia,
    String? id,
    String? img,
    String? title,
    String? description,
    String? pricing,
    String? offertPricing,
    List<String>? ingredients,
    bool? isSpicy,
    String? foodType,
    int? quantity,
    bool? isOffer,
    bool? isMealSubscription,
    int? totalMeals,
    int? remainingMeals,
    DateTime? expirationDate,
    int? peopleCount,
    String? sideRequest,
    Map<String, dynamic>? options,
    String? notes,
    bool? isMealPlanDish,
  }) {
    return CartItem(
      id: id ?? this.id,
      img: img ?? this.img,
      title: title ?? this.title,
      description: description ?? this.description,
      pricing: pricing ?? this.pricing,
      offertPricing: offertPricing ?? this.offertPricing,
      ingredients: ingredients ?? this.ingredients,
      isSpicy: isSpicy ?? this.isSpicy,
      foodType: foodType ?? this.foodType,
      quantity: quantity ?? this.quantity,
      isOffer: isOffer ?? this.isOffer,
      isMealSubscription: isMealSubscription ?? this.isMealSubscription,
      totalMeals: totalMeals ?? this.totalMeals,
      remainingMeals: remainingMeals ?? this.remainingMeals,
      expirationDate: expirationDate ?? this.expirationDate,
      peopleCount: peopleCount ?? this.peopleCount,
      sideRequest: sideRequest ?? this.sideRequest,
      isMealPlanDish: isMealPlanDish ?? this.isMealPlanDish,
      hasChef: hasChef ?? this.hasChef,
      alergias: alergias ?? this.alergias,
      eventType: eventType ?? this.eventType,
      preferencia: preferencia ?? this.preferencia,
      options: options ?? this.options,
      notes: notes ?? this.notes,
    );
  }

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'img': img,
      'title': title,
      'description': description,
      'pricing': pricing,
      'offertPricing': offertPricing,
      'ingredients': ingredients,
      'isSpicy': isSpicy,
      'foodType': foodType,
      'quantity': quantity,
      'isOffer': isOffer,
      'isMealSubscription': isMealSubscription,
      'totalMeals': totalMeals,
      'remainingMeals': remainingMeals,
      'expirationDate': expirationDate.toIso8601String(),
      'peopleCount': peopleCount,
      'sideRequest': sideRequest,
      'hasChef': hasChef,
      'alergias': alergias,
      'eventType': eventType,
      'preferencia': preferencia,
      'options': options,
      'notes': notes,
      'isMealPlanDish': isMealPlanDish,
    };
  }

  // fromJson factory constructor for deserialization
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      img: json['img'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pricing: json['pricing'] as String,
      offertPricing: json['offertPricing'] as String?,
      ingredients: List<String>.from(json['ingredients'] as List<dynamic>),
      isSpicy: json['isSpicy'] as bool,
      foodType: json['foodType'] as String,
      quantity: json['quantity'] as int,
      isOffer: json['isOffer'] as bool,
      hasChef: json['hasChef'] as bool?,
      alergias: json['alergias'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      preferencia: json['preferencia'] as String? ?? '',
      isMealSubscription: json['isMealSubscription'] as bool,
      totalMeals: json['totalMeals'] as int,
      remainingMeals: json['remainingMeals'] as int,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      peopleCount: json['peopleCount'] as int,
      sideRequest: json['sideRequest'] as String,
      options: json['options'] as Map<String, dynamic>? ?? {},
      notes: json['notes'] as String?,
      isMealPlanDish: json['isMealPlanDish'] as bool? ?? false,
    );
  }
}

// Serialization and Deserialization functions
String serializeCart(List<CartItem> cartItems) {
  return jsonEncode(cartItems.map((item) => item.toJson()).toList());
}

List<CartItem> deserializeCart(String jsonString) {
  List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.map((item) => CartItem.fromJson(item)).toList();
}