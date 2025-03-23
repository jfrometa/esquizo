import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Represents the status of a catering order
enum CateringOrderStatus {
  pending,
  confirmed,
  preparing,
  readyForDelivery,
  inTransit,
  delivered,
  completed,
  cancelled,
  refunded;
  
  /// Helper property to check if status is in a terminal state
  bool get isTerminal => this == CateringOrderStatus.completed || 
                        this == CateringOrderStatus.cancelled || 
                        this == CateringOrderStatus.refunded;
                        
  String get displayName {
    switch (this) {
      case CateringOrderStatus.pending:
        return 'Pending';
      case CateringOrderStatus.confirmed:
        return 'Confirmed';
      case CateringOrderStatus.preparing:
        return 'Preparing';
      case CateringOrderStatus.readyForDelivery:
        return 'Ready for Delivery';
      case CateringOrderStatus.inTransit:
        return 'In Transit';
      case CateringOrderStatus.delivered:
        return 'Delivered';
      case CateringOrderStatus.completed:
        return 'Completed';
      case CateringOrderStatus.cancelled:
        return 'Cancelled';
      case CateringOrderStatus.refunded:
        return 'Refunded';
    }
  }
  
  String get description {
    switch (this) {
      case CateringOrderStatus.pending:
        return 'Order received, awaiting confirmation';
      case CateringOrderStatus.confirmed:
        return 'Order confirmed, scheduled for preparation';
      case CateringOrderStatus.preparing:
        return 'Food is being prepared for the event';
      case CateringOrderStatus.readyForDelivery:
        return 'Order is ready for pickup or delivery';
      case CateringOrderStatus.inTransit:
        return 'Order is on the way to the destination';
      case CateringOrderStatus.delivered:
        return 'Order has been delivered, awaiting completion';
      case CateringOrderStatus.completed:
        return 'Order has been successfully completed';
      case CateringOrderStatus.cancelled:
        return 'Order has been cancelled';
      case CateringOrderStatus.refunded:
        return 'Order has been refunded';
    }
  }
  
  Color get color {
    switch (this) {
      case CateringOrderStatus.pending:
        return Colors.grey;
      case CateringOrderStatus.confirmed:
        return Colors.blue;
      case CateringOrderStatus.preparing:
        return Colors.orange;
      case CateringOrderStatus.readyForDelivery:
        return Colors.amber;
      case CateringOrderStatus.inTransit:
        return Colors.indigo;
      case CateringOrderStatus.delivered:
        return Colors.lightGreen;
      case CateringOrderStatus.completed:
        return Colors.green;
      case CateringOrderStatus.cancelled:
        return Colors.red;
      case CateringOrderStatus.refunded:
        return Colors.redAccent;
    }
  }
  
  IconData get icon {
    switch (this) {
      case CateringOrderStatus.pending:
        return Icons.hourglass_empty;
      case CateringOrderStatus.confirmed:
        return Icons.check_circle_outline;
      case CateringOrderStatus.preparing:
        return Icons.restaurant;
      case CateringOrderStatus.readyForDelivery:
        return Icons.shopping_bag;
      case CateringOrderStatus.inTransit:
        return Icons.local_shipping;
      case CateringOrderStatus.delivered:
        return Icons.delivery_dining;
      case CateringOrderStatus.completed:
        return Icons.done_all;
      case CateringOrderStatus.cancelled:
        return Icons.cancel;
      case CateringOrderStatus.refunded:
        return Icons.money_off;
    }
  }
  
  List<CateringOrderStatus> get allowedTransitions {
    switch (this) {
      case CateringOrderStatus.pending:
        return [
          CateringOrderStatus.confirmed,
          CateringOrderStatus.cancelled,
        ];
      case CateringOrderStatus.confirmed:
        return [
          CateringOrderStatus.preparing,
          CateringOrderStatus.cancelled,
        ];
      case CateringOrderStatus.preparing:
        return [
          CateringOrderStatus.readyForDelivery,
          CateringOrderStatus.cancelled,
        ];
      case CateringOrderStatus.readyForDelivery:
        return [
          CateringOrderStatus.inTransit,
          CateringOrderStatus.delivered, // For pickup
          CateringOrderStatus.cancelled,
        ];
      case CateringOrderStatus.inTransit:
        return [
          CateringOrderStatus.delivered,
          CateringOrderStatus.cancelled,
        ];
      case CateringOrderStatus.delivered:
        return [
          CateringOrderStatus.completed,
          CateringOrderStatus.refunded,
        ];
      case CateringOrderStatus.completed:
        return [
          CateringOrderStatus.refunded,
        ];
      case CateringOrderStatus.cancelled:
        return [
          CateringOrderStatus.refunded,
        ];
      case CateringOrderStatus.refunded:
        return [];
    }
  }
}

/// Represents an individual dish in the catering menu
class CateringDish {
  final String title;
  final int peopleCount;
  final double pricePerPerson;
  final double? pricePerUnit;
  final List<String> ingredients;
  final double pricing; 
  final int quantity;
  final String img;
  final bool hasUnitSelection;

  CateringDish({
    required this.title,
    required this.peopleCount,
    required this.pricePerPerson,
    required this.ingredients,
    required this.pricing,
    this.hasUnitSelection = false,
    this.pricePerUnit,
    this.img = 'assets/food5.jpeg',
    this.quantity = 1,
  });

  /// Creates a copy with optional updated fields
  CateringDish copyWith({
    String? title,
    int? peopleCount,
    double? pricePerPerson,
    double? pricePerUnit,
    List<String>? ingredients,
    double? pricing,
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
      pricing: pricing ?? this.pricing,
      img: img ?? this.img,
      quantity: quantity ?? this.quantity,
      hasUnitSelection: hasUnitSelection ?? this.hasUnitSelection,
    );
  }

  /// Calculates the total price for this dish based on quantity and unit price
  double get totalPrice {
    if (hasUnitSelection && pricePerUnit != null) {
      return pricePerUnit! * quantity;
    } else {
      return pricePerPerson * peopleCount * quantity;
    }
  }

  /// Converts dish to JSON format
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

  /// Creates a dish from JSON format
  factory CateringDish.fromJson(Map<String, dynamic> json) {
    return CateringDish(
      title: json['title'],
      peopleCount: json['peopleCount'] ?? 0,
      pricePerPerson: (json['pricePerPerson'] ?? 0.0).toDouble(),
      ingredients: json['ingredients'] != null 
          ? List<String>.from(json['ingredients']) 
          : [],
      pricing: (json['pricing'] ?? 0.0).toDouble(),
      pricePerUnit: json['pricePerUnit']?.toDouble(),
      hasUnitSelection: json['hasUnitSelection'] ?? false,
      quantity: json['quantity'] ?? 1,
      img: json['img'] ?? 'assets/food5.jpeg',
    );
  }
  
  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CateringDish &&
        other.title == title &&
        other.peopleCount == peopleCount &&
        other.pricePerPerson == pricePerPerson &&
        other.pricePerUnit == pricePerUnit &&
        listEquals(other.ingredients, ingredients) &&
        other.pricing == pricing &&
        other.quantity == quantity &&
        other.img == img &&
        other.hasUnitSelection == hasUnitSelection;
  }

  /// Hash code
  @override
  int get hashCode {
    return title.hashCode ^
        peopleCount.hashCode ^
        pricePerPerson.hashCode ^
        pricePerUnit.hashCode ^
        ingredients.hashCode ^
        pricing.hashCode ^
        quantity.hashCode ^
        img.hashCode ^
        hasUnitSelection.hashCode;
  }
  
  /// String representation
  @override
  String toString() {
    return 'CateringDish(title: $title, quantity: $quantity, price: $pricing)';
  }
}

/// Represents an individual item in a catering order
class CateringOrderItem {
  // Core identification fields
  final String id; // Added new id field
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  
  // Additional fields
  final String notes;
  final List<String> modifications;
  
  // Optional reference to the original dish
  final CateringDish? dish;

  // Legacy fields from the original CateringOrderItem class
  final String title;
  final String img;
  final String description;
  final List<CateringDish> dishes;
  final String alergias;
  final String eventType;
  final String preferencia;
  final String adicionales;
  final int? peopleCount;
  final bool? hasChef;
  final bool isQuote;

  const CateringOrderItem({
    // Required fields from both models
    this.id = '', // Added with default empty string
    required this.itemId,
    required this.name,
    required this.price,
    
    // Optional fields with defaults
    this.quantity = 1,
    this.notes = '',
    this.modifications = const [],
    this.dish,
    
    // Legacy fields with defaults
    this.title = '',
    this.img = '',
    this.description = '',
    this.dishes = const [],
    this.alergias = '',
    this.eventType = '',
    this.preferencia = '',
    this.adicionales = '',
    this.peopleCount,
    this.hasChef,
    this.isQuote = false,
  });

  /// Create an item from a dish
  factory CateringOrderItem.fromDish(CateringDish dish, {String? id, String? itemId, String? notes}) {
    return CateringOrderItem(
      id: id ?? '', // Added id parameter
      itemId: itemId ?? UniqueKey().toString(),
      name: dish.title,
      price: dish.hasUnitSelection && dish.pricePerUnit != null 
          ? dish.pricePerUnit! 
          : dish.pricePerPerson,
      quantity: dish.quantity,
      notes: notes ?? '',
      dish: dish,
    );
  }
  
  /// Create a legacy order item
  factory CateringOrderItem.legacy({
    String? id, // Added id parameter
    required String title,
    required String img,
    required String description,
    required List<CateringDish> dishes,
    required String alergias,
    required String eventType,
    required String preferencia,
    required String adicionales,
    int? peopleCount,
    bool? hasChef,
    bool isQuote = false,
  }) {
    return CateringOrderItem(
      id: id ?? '', // Added id parameter
      itemId: UniqueKey().toString(),
      name: title,
      price: 0.0, // Will be calculated from dishes
      title: title,
      img: img,
      description: description,
      dishes: dishes,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
      adicionales: adicionales,
      peopleCount: peopleCount,
      hasChef: hasChef,
      isQuote: isQuote,
    );
  }

  /// Total price for this item
  double get totalPrice => price * quantity;
  
  /// Calculates the total price for all dishes (legacy mode)
  double get legacyTotalPrice {
    if (isQuote) return 0.0;
    return dishes.fold(0.0, (total, dish) {
      return total + ((dish.pricePerUnit ?? 1) * (peopleCount ?? 1));
    });
  }

  /// Combines all ingredients from all dishes into a single list (legacy mode)
  List<String> get combinedIngredients =>
      dishes.expand((dish) => dish.ingredients).toList();

  /// Creates a copy with optional updated fields
  CateringOrderItem copyWith({
    // Modern fields
    String? id, // Added id parameter
    String? itemId,
    String? name,
    double? price,
    int? quantity,
    String? notes,
    List<String>? modifications,
    CateringDish? dish,
    
    // Legacy fields
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
      // Modern fields
      id: id ?? this.id, // Added id field
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      modifications: modifications ?? this.modifications,
      dish: dish ?? this.dish,
      
      // Legacy fields
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

  /// Converts item to JSON format
  Map<String, dynamic> toJson() {
    final json = {
      // Modern fields
      'id': id, // Added id field
      'itemId': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'notes': notes,
      'modifications': modifications,
      
      // Legacy fields
      'title': title,
      'img': img,
      'description': description,
      'dishes': dishes.map((dish) => dish.toJson()).toList(),
      'alergias': alergias,
      'eventType': eventType,
      'preferencia': preferencia,
      'adicionales': adicionales,
      'isQuote': isQuote,
    };
    
    // Add optional fields
    if (dish != null) {
      json['dish'] = dish!.toJson();
    }
    if (peopleCount != null) {
      json['peopleCount'] = peopleCount ?? 1;
    }
    if (hasChef != null) {
      json['hasChef'] = hasChef ?? false;
    }
    
    return json;
  }

  /// Creates an item from JSON format
  factory CateringOrderItem.fromJson(Map<String, dynamic> json) {
    // Handle legacy format if 'dishes' exists in the JSON
    if (json.containsKey('dishes') && json['dishes'] is List) {
      return CateringOrderItem(
        // Modern fields (with fallbacks)
        id: json['id'] as String? ?? '', // Added id field
        itemId: json['itemId'] ?? UniqueKey().toString(),
        name: json['name'] ?? json['title'] ?? '',
        price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
        quantity: json['quantity'] as int? ?? 1,
        notes: json['notes'] as String? ?? '',
        modifications: (json['modifications'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ?? [],
        dish: json['dish'] != null ? CateringDish.fromJson(json['dish']) : null,
        
        // Legacy fields
        title: json['title'] as String? ?? '',
        img: json['img'] as String? ?? '',
        description: json['description'] as String? ?? '',
        dishes: json['dishes'] != null 
            ? (json['dishes'] as List)
                .map((dish) => CateringDish.fromJson(dish))
                .toList()
            : const [],
        alergias: json['alergias'] as String? ?? '',
        eventType: json['eventType'] as String? ?? '',
        preferencia: json['preferencia'] as String? ?? '',
        adicionales: json['adicionales'] as String? ?? '',
        peopleCount: json['peopleCount'] ?? json['cantidadPersonas'],
        hasChef: json['hasChef'] as bool?,
        isQuote: json['isQuote'] as bool? ?? false,
      );
    }
    
    // Standard format (modern)
    return CateringOrderItem(
      id: json['id'] as String? ?? '', // Added id field
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes'] as String? ?? '',
      modifications: (json['modifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      dish: json['dish'] != null ? CateringDish.fromJson(json['dish']) : null,
    );
  }

  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CateringOrderItem &&
        other.id == id && // Added id comparison
        other.itemId == itemId &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.notes == notes &&
        listEquals(other.modifications, modifications) &&
        other.dish == dish &&
        // Legacy checks
        other.title == title &&
        other.img == img &&
        other.description == description &&
        listEquals(other.dishes, dishes) &&
        other.alergias == alergias &&
        other.eventType == eventType &&
        other.preferencia == preferencia &&
        other.adicionales == adicionales &&
        other.peopleCount == peopleCount &&
        other.hasChef == hasChef &&
        other.isQuote == isQuote;
  }

  /// Hash code
  @override
  int get hashCode {
    return id.hashCode ^ // Added id to hashCode
        itemId.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        notes.hashCode ^
        modifications.hashCode ^
        dish.hashCode ^
        // Legacy hashes
        title.hashCode ^
        img.hashCode ^
        description.hashCode ^
        dishes.hashCode ^
        alergias.hashCode ^
        eventType.hashCode ^
        preferencia.hashCode ^
        adicionales.hashCode ^
        peopleCount.hashCode ^
        hasChef.hashCode ^
        isQuote.hashCode;
  }

  /// String representation
  @override
  String toString() {
    if (dishes.isNotEmpty) {
      return 'CateringOrderItem(legacy, title: $title, dishes: ${dishes.length})';
    }
    return 'CateringOrderItem(itemId: $itemId, name: $name, price: $price, quantity: $quantity)';
  }
  
  /// Check if this is primarily a legacy item
  bool get isLegacyItem => dishes.isNotEmpty;
}

/// Represents a complete catering order
class CateringOrder {
  // Core identification
  final String id;
  final String customerId;
  final DateTime orderDate;
  final DateTime eventDate;
  final CateringOrderStatus status;
  
  // Content related fields
  final List<CateringOrderItem> items;
  final double total;
  
  // Customer details
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  
  // Event details
  final String eventAddress;
  final String eventType;
  final int guestCount;
  final String? packageId;
  final String? packageName;
  
  // Service details
  final bool hasChef;
  final String specialInstructions;
  final List<String> dietaryRestrictions;
  final String alergias; // Legacy field for allergies
  final String preferencia; // Legacy field for preferences
  final String adicionales; // Legacy field for additional notes
  
  // Scheduling details
  final DateTime? deliveryTime;
  final DateTime? setupTime;
  
  // Metadata
  final DateTime? lastStatusUpdate;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final String? paymentId;
  final String paymentStatus;
  final String? cancellationReason;
  
  // Legacy flags
  final bool isQuote;
  final String img;
  final String description;

  const CateringOrder({
    required this.id,
    required this.customerId,
    required this.orderDate,
    required this.eventDate,
    required this.status,
    required this.items,
    required this.total,
    this.customerName = '',
    this.customerEmail = '',
    this.customerPhone = '',
    this.eventAddress = '',
    this.eventType = '',
    this.guestCount = 0,
    this.packageId,
    this.packageName,
    this.hasChef = false,
    this.specialInstructions = '',
    this.dietaryRestrictions = const [],
    this.alergias = '',
    this.preferencia = 'salado',
    this.adicionales = '',
    this.deliveryTime,
    this.setupTime,
    this.lastStatusUpdate,
    this.assignedStaffId,
    this.assignedStaffName,
    this.paymentId,
    this.paymentStatus = 'pending',
    this.cancellationReason,
    this.isQuote = false,
    this.img = '',
    this.description = '',
  });

  // Add this to your CateringOrder class
factory CateringOrder.fromStatistics(Map<String, dynamic> stats) {
  final String statsId = 'stats-${DateTime.now().millisecondsSinceEpoch}';
  
  // Create a statistics item that will be included in the order
  final statisticsItem = CateringOrderItem(
    itemId: statsId,
    name: 'Statistics Summary',
    price: stats['totalRevenue'] ?? 0.0,
    quantity: 1,
    notes: 'Generated statistics report',
    adicionales: json.encode(stats), // Store the full stats as JSON
  );
  
  return CateringOrder(
    id: statsId,
    customerId: 'admin',
    orderDate: DateTime.now(),
    eventDate: DateTime.now(),
    status: CateringOrderStatus.completed,
    items: [statisticsItem], // Include the statistics item
    total: stats['totalRevenue'] ?? 0.0,
    customerName: 'Statistics',
    eventType: 'Statistics Report',
    guestCount: stats['totalOrders'] ?? 0,
    paymentStatus: 'completed',
    specialInstructions: 'This is an automatically generated statistics report',
  );
}

  // Empty constructor
  factory CateringOrder.empty() => CateringOrder(
    id: '',
    customerId: '',
    orderDate: DateTime.now(),
    eventDate: DateTime.now().add(const Duration(days: 7)),
    status: CateringOrderStatus.pending,
    items: const [],
    total: 0,
  );
  
  /// Create an order from a legacy CateringOrderItem
  factory CateringOrder.fromLegacyItem(CateringOrderItem legacyItem, {
    String? id,
    required String customerId,
    String? customerName,
    required DateTime eventDate,
    CateringOrderStatus status = CateringOrderStatus.pending,
    String paymentStatus = 'pending',
  }) {
    return CateringOrder(
      id: id ?? '',
      customerId: customerId,
      customerName: customerName ?? '',
      orderDate: DateTime.now(),
      eventDate: eventDate,
      status: status,
      items: legacyItem.dishes.map((dish) => 
        CateringOrderItem.fromDish(dish)
      ).toList(),
      total: legacyItem.isQuote ? 0.0 : legacyItem.legacyTotalPrice,
      hasChef: legacyItem.hasChef ?? false,
      alergias: legacyItem.alergias,
      eventType: legacyItem.eventType,
      preferencia: legacyItem.preferencia,
      adicionales: legacyItem.adicionales,
      guestCount: legacyItem.peopleCount ?? 0,
      isQuote: legacyItem.isQuote,
      img: legacyItem.img,
      description: legacyItem.description,
      paymentStatus: paymentStatus,
    );
  }

  /// Calculate the total price for all items
  double calculateTotal() {
    if (isQuote) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Get all unique ingredients from all items
  List<String> get combinedIngredients {
    final allIngredients = <String>{};
    for (final item in items) {
      if (item.dish != null) {
        allIngredients.addAll(item.dish!.ingredients);
      }
    }
    return allIngredients.toList();
  }

  /// Creates a copy with optional updated fields
  CateringOrder copyWith({
    String? id,
    String? customerId,
    DateTime? orderDate,
    DateTime? eventDate,
    CateringOrderStatus? status,
    List<CateringOrderItem>? items,
    double? total,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? eventAddress,
    String? eventType,
    int? guestCount,
    String? packageId,
    bool clearPackageId = false,
    String? packageName,
    bool clearPackageName = false,
    bool? hasChef,
    String? specialInstructions,
    List<String>? dietaryRestrictions,
    String? alergias,
    String? preferencia,
    String? adicionales,
    DateTime? deliveryTime,
    bool clearDeliveryTime = false,
    DateTime? setupTime,
    bool clearSetupTime = false,
    DateTime? lastStatusUpdate,
    bool clearLastStatusUpdate = false,
    String? assignedStaffId,
    bool clearAssignedStaffId = false,
    String? assignedStaffName,
    bool clearAssignedStaffName = false,
    String? paymentId,
    bool clearPaymentId = false,
    String? paymentStatus,
    String? cancellationReason,
    bool? isQuote,
    String? img,
    String? description,
  }) {
    return CateringOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      orderDate: orderDate ?? this.orderDate,
      eventDate: eventDate ?? this.eventDate,
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      eventAddress: eventAddress ?? this.eventAddress,
      eventType: eventType ?? this.eventType,
      guestCount: guestCount ?? this.guestCount,
      packageId: clearPackageId ? null : (packageId ?? this.packageId),
      packageName: clearPackageName ? null : (packageName ?? this.packageName),
      hasChef: hasChef ?? this.hasChef,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      alergias: alergias ?? this.alergias,
      preferencia: preferencia ?? this.preferencia,
      adicionales: adicionales ?? this.adicionales,
      deliveryTime: clearDeliveryTime ? null : (deliveryTime ?? this.deliveryTime),
      setupTime: clearSetupTime ? null : (setupTime ?? this.setupTime),
      lastStatusUpdate: clearLastStatusUpdate ? null : (lastStatusUpdate ?? this.lastStatusUpdate),
      assignedStaffId: clearAssignedStaffId ? null : (assignedStaffId ?? this.assignedStaffId),
      assignedStaffName: clearAssignedStaffName ? null : (assignedStaffName ?? this.assignedStaffName),
      paymentId: clearPaymentId ? null : (paymentId ?? this.paymentId),
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isQuote: isQuote ?? this.isQuote,
      img: img ?? this.img,
      description: description ?? this.description,
    );
  }

  /// Helper method to parse order status from string or int
  static CateringOrderStatus _parseOrderStatus(dynamic status) {
    if (status == null) return CateringOrderStatus.pending;
    
    if (status is String) {
      return CateringOrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
        orElse: () => CateringOrderStatus.pending,
      );
    } else if (status is int) {
      return CateringOrderStatus.values[status];
    }
    
    return CateringOrderStatus.pending;
  }

  /// Converts order to JSON format
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'orderDate': orderDate.toIso8601String(),
      'eventDate': eventDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'eventAddress': eventAddress,
      'eventType': eventType,
      'guestCount': guestCount,
      'hasChef': hasChef,
      'specialInstructions': specialInstructions,
      'dietaryRestrictions': dietaryRestrictions,
      'alergias': alergias,
      'preferencia': preferencia,
      'adicionales': adicionales,
      'paymentStatus': paymentStatus,
      'isQuote': isQuote,
      'img': img,
      'description': description,
    };

    // Add optional fields if they exist
    if (packageId != null) json['packageId'] = packageId;
    if (packageName != null) json['packageName'] = packageName;
    if (deliveryTime != null) json['deliveryTime'] = deliveryTime!.toIso8601String();
    if (setupTime != null) json['setupTime'] = setupTime!.toIso8601String();
    if (lastStatusUpdate != null) json['lastStatusUpdate'] = lastStatusUpdate!.toIso8601String();
    if (assignedStaffId != null) json['assignedStaffId'] = assignedStaffId;
    if (assignedStaffName != null) json['assignedStaffName'] = assignedStaffName;
    if (paymentId != null) json['paymentId'] = paymentId;
    if (cancellationReason != null) json['cancellationReason'] = cancellationReason;

    return json;
  }

  /// Creates an order from JSON format
  factory CateringOrder.fromJson(Map<String, dynamic> json) {
    return CateringOrder(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? json['userId'] as String? ?? '',
      orderDate: json['orderDate'] != null 
          ? DateTime.parse(json['orderDate'] as String) 
          : DateTime.now(),
      eventDate: json['eventDate'] != null 
          ? DateTime.parse(json['eventDate'] as String) 
          : DateTime.now().add(const Duration(days: 7)),
      status: _parseOrderStatus(json['status']),
      items: json['items'] != null 
          ? (json['items'] as List)
              .map((e) => CateringOrderItem.fromJson(e))
              .toList() 
          : [],
      total: json['total'] != null ? (json['total'] as num).toDouble() : 0.0,
      customerName: json['customerName'] as String? ?? json['userName'] as String? ?? '',
      customerEmail: json['customerEmail'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      eventAddress: json['eventAddress'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      guestCount: json['guestCount'] as int? ?? json['peopleCount'] as int? ?? 0,
      packageId: json['packageId'] as String?,
      packageName: json['packageName'] as String?,
      hasChef: json['hasChef'] as bool? ?? false,
      specialInstructions: json['specialInstructions'] as String? ?? '',
      dietaryRestrictions: json['dietaryRestrictions'] != null 
          ? (json['dietaryRestrictions'] as List).map((e) => e as String).toList() 
          : const [],
      alergias: json['alergias'] as String? ?? '',
      preferencia: json['preferencia'] as String? ?? 'salado',
      adicionales: json['adicionales'] as String? ?? '',
      deliveryTime: json['deliveryTime'] != null
          ? DateTime.parse(json['deliveryTime'] as String)
          : null,
      setupTime: json['setupTime'] != null
          ? DateTime.parse(json['setupTime'] as String)
          : null,
      lastStatusUpdate: json['lastStatusUpdate'] != null
          ? DateTime.parse(json['lastStatusUpdate'] as String)
          : null,
      assignedStaffId: json['assignedStaffId'] as String?,
      assignedStaffName: json['assignedStaffName'] as String?,
      paymentId: json['paymentId'] as String?,
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      cancellationReason: json['cancellationReason'] as String?,
      isQuote: json['isQuote'] as bool? ?? false,
      img: json['img'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  /// String representation
  @override
  String toString() {
    return 'CateringOrder(id: $id, status: $status, eventDate: $eventDate, total: $total)';
  }
  
  /// Convert to legacy CateringOrderItem
  CateringOrderItem toLegacyItem() {
    // Convert items to dishes if possible
    final dishes = items.map((item) => 
      item.dish ?? CateringDish(
        title: item.name,
        peopleCount: guestCount,
        pricePerPerson: item.price,
        ingredients: [],
        pricing: item.price,
        quantity: item.quantity,
      )
    ).toList();
    
    return CateringOrderItem.legacy(
      title: description.isNotEmpty ? description : customerName,
      img: img,
      description: description.isNotEmpty ? description : 'Order #$id',
      dishes: dishes,
      hasChef: hasChef,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
      adicionales: adicionales,
      peopleCount: guestCount,
      isQuote: isQuote,
    );
  }
}
