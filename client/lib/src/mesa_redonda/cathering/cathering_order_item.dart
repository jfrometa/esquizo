 
/// Model representing an individual dish within the catering order
class CateringDish {
  final String title;
  final int peopleCount;
  final double pricePerPerson;
  final double? pricePerUnit;
  final List<String> ingredients;
  final double pricing;
  final int quantity; // Default quantity field (default = 1)
  final String img; // Image for the dish
  bool hasUnitSelection;

  CateringDish({
    required this.title,
    required this.peopleCount,
    required this.pricePerPerson,
    required this.ingredients,
    required this.pricing,
    this.hasUnitSelection = false,
    this.pricePerUnit,
    this.img = 'assets/food5.jpeg', // Default image value
    this.quantity = 1, // Default quantity to 1
  });

  // copyWith method for immutability updates.
  CateringDish copyWith({
    String? title,
    int? peopleCount,
    double? pricePerPerson,
    double? pricePerUnit,
    List<String>? ingredients,
    bool? hasUnitSelection,
    int? quantity,
    String? img,
  }) {
    return CateringDish(
      title: title ?? this.title,
      peopleCount: peopleCount ?? this.peopleCount,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      ingredients: ingredients ?? this.ingredients,
      pricing: pricing,
      img: img ?? this.img,
      quantity: quantity ?? this.quantity,
      hasUnitSelection: hasUnitSelection ?? this.hasUnitSelection,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'peopleCount': peopleCount,
        'pricePerPerson': pricePerPerson,
        'ingredients': ingredients,
        'pricing': pricing,
        'pricePerUnit': pricePerUnit,
        'quantity': quantity,
        'img': img,
        'hasUnitSelection': hasUnitSelection,
      };

  factory CateringDish.fromJson(Map<String, dynamic> json) {
    return CateringDish(
      title: json['title'],
      peopleCount: json['peopleCount'],
      pricePerPerson: json['pricePerPerson'],
      ingredients: List<String>.from(json['ingredients']),
      pricing: json['pricing'],
      pricePerUnit: json['pricePerUnit'],
      hasUnitSelection: json['hasUnitSelection'],
      quantity: json['quantity'],
      img: json['img'] ?? 'assets/food5.jpeg',
    );
  }
}

/// Model representing the complete catering order
class CateringOrderItem {
  final String title;
  final String img;
  final String description;
  final List<CateringDish> dishes;
  final String alergias;
  final String eventType;
  final String preferencia;
  final String adicionales;
  final int? peopleCount; // cantidadPersonas
  bool? hasChef;
  final bool isQuote; // New flag to mark manual quotes

  CateringOrderItem({
    required this.title,
    required this.img,
    required this.description,
    required this.dishes,
    required this.alergias,
    required this.eventType,
    required this.preferencia,
    required this.adicionales,
    this.hasChef,
    required this.peopleCount,
    this.isQuote = false, // Default to false for normal orders
  });

  /// Calculates the total price for all dishes.
  /// If this is a quote, return 0.0 to bypass pricing.
  double get totalPrice {
    if (isQuote) return 0.0;
    return dishes.fold(0.0, (total, dish) {
      // Simple calculation: multiply dish price per unit (or 1) by the people count.
      return total + ((dish.pricePerUnit ?? 1) * (peopleCount ?? 1));
    });
  }

  /// Combines all ingredients from all dishes into a single list.
  List<String> get combinedIngredients =>
      dishes.expand((dish) => dish.ingredients).toList();

  Map<String, dynamic> toJson() => {
        'title': title,
        'img': img,
        'description': description,
        'dishes': dishes.map((dish) => dish.toJson()).toList(),
        'hasChef': hasChef,
        'alergias': alergias,
        'eventType': eventType,
        'preferencia': preferencia,
        'adicionales': adicionales,
        'cantidadPersonas': peopleCount,
        'isQuote': isQuote, // Save the quote flag
      };

  factory CateringOrderItem.fromJson(Map<String, dynamic> json) {
    return CateringOrderItem(
      title: json['title'],
      img: json['img'],
      description: json['description'],
      dishes: (json['dishes'] as List)
          .map((dish) => CateringDish.fromJson(dish))
          .toList(),
      hasChef: json['hasChef'],
      alergias: json['alergias'],
      eventType: json['eventType'],
      preferencia: json['preferencia'],
      adicionales: json['adicionales'],
      peopleCount: json['cantidadPersonas'],
      isQuote: json['isQuote'] ?? false,
    );
  }

  /// copyWith method updated to include isQuote.
  CateringOrderItem copyWith({
    String? title,
    String? img,
    String? description,
    List<CateringDish>? dishes,
    bool? hasChef,
    String? alergias,
    String? eventType,
    String? preferencia,
    String? adicionales,
    int? peopleCount,
    bool? isQuote,
  }) {
    return CateringOrderItem(
      title: title ?? this.title,
      img: img ?? this.img,
      description: description ?? this.description,
      dishes: dishes ?? this.dishes,
      hasChef: hasChef ?? this.hasChef,
      alergias: alergias ?? this.alergias,
      eventType: eventType ?? this.eventType,
      preferencia: preferencia ?? this.preferencia,
      adicionales: adicionales ?? this.adicionales,
      peopleCount: peopleCount ?? this.peopleCount,
      isQuote: isQuote ?? this.isQuote,
    );
  }
}

