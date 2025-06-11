import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../admin/models/order_status_enum.dart';

class Subscription {
  final String id;
  final String planName;
  final int mealsRemaining;
  final String status;
  final String orderDate;
  final double totalCost;
  final DateTime expirationDate;
  final String paymentStatus;
  final double totalAmount;
  final String orderNumber; // New field for order number

  Subscription({
    required this.id,
    required this.planName,
    required this.mealsRemaining,
    required this.status,
    required this.orderDate,
    required this.totalCost,
    required this.expirationDate,
    required this.paymentStatus,
    required this.totalAmount,
    required this.orderNumber, // Initialize order number
  });

  bool get isActive =>
      paymentStatus == 'pagado' && DateTime.now().isBefore(expirationDate);

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      planName: data['planName'] ?? 'Unknown Plan',
      mealsRemaining: data['remainingMeals'] ?? 0,
      status: data['status'] ?? 'Pendiente',
      orderDate: (data['orderDate']),
      totalCost: (data['totalCost'] ?? 0).toDouble(),
      expirationDate: DateTime.parse(data['expirationDate']),
      paymentStatus: data['paymentStatus'] ?? 'Pending',
      totalAmount: data['totalAmount'] ?? 0.0,
      orderNumber: data['orderNumber'] ?? '', // Fetch order number
    );
  }

  Map<String, dynamic> toFirestore() => {
        'planName': planName,
        'mealsRemaining': mealsRemaining,
        'status': status,
        'orderDate': orderDate,
        'totalCost': totalCost,
        'expirationDate': expirationDate.toIso8601String(),
        'paymentStatus': paymentStatus,
        'totalAmount': totalAmount,
        'orderNumber': orderNumber, // Save order number
      };
}

class Order {
  final String orderNumber;
  final String id;
  final String email;
  final String userId;
  final String orderType;
  final String address;
  final String latitude;
  final String longitude;
  final String paymentStatus;
  final double totalAmount;
  final Timestamp timestamp;
  final int? tableNumber;
  final String? tableId;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final List<OrderItem> items;
  final OrderStatus status;
  final String? customerName;
  final String? userName; // Added to match create_order.dart
  final String? userEmail; // Added to match create_order.dart
  final String? userPhone; // Added to match create_order.dart
  final int? customerCount;
  final int? peopleCount; // Added to match create_order.dart
  final String? waiterNotes;
  final String? specialInstructions; // Added to match create_order.dart
  final String? waiterId;
  final String? waiterName;
  final String paymentMethod;
  final double? subtotal;
  final double? taxAmount;
  final double? tax; // Added to match create_order.dart
  final double? tipAmount;
  final double? total; // Added to match create_order.dart
  final double? deliveryFee; // Added to match create_order.dart
  final double? discount; // Added to match create_order.dart
  final String? cashierId;
  final String? cashierName;
  final bool isPaid;
  final DateTime? paidAt;
  final String? receiptNumber;
  final bool isDelivery;
  final String? deliveryAddress; // Added to match create_order.dart
  final DateTime orderDate;
  final Map<String, dynamic> location;
  final String? deliveryDate;
  final String? deliveryTime;
  final bool isReviewed;
  final String? assignedToId;
  final String? assignedToName;
  final String? businessId;
  final String? resourceId; // Added to match create_order.dart
  final String? adminNotes;
  final DateTime? adminReviewedAt;
  final String? adminId;
  final String? adminName;
  final bool isArchived;
  final Map<String, dynamic>? adminMetadata;

  Order({
    this.orderNumber = '',
    required this.id,
    this.email = '',
    required this.userId,
    this.orderType = 'standard',
    this.address = '',
    this.latitude = '',
    this.longitude = '',
    required this.items,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.totalAmount = 0.0,
    // Initialize timestamp properly
    this.tableNumber,
    this.tableId,
    required this.createdAt,
    this.lastUpdated,
    this.status = OrderStatus.pending,
    this.customerName,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.customerCount,
    this.peopleCount,
    this.waiterNotes,
    this.specialInstructions,
    this.waiterId,
    this.waiterName,
    this.subtotal,
    this.taxAmount,
    this.tax,
    this.tipAmount,
    this.total,
    this.deliveryFee,
    this.discount,
    this.cashierId,
    this.cashierName,
    this.isPaid = false,
    this.paidAt,
    this.receiptNumber,
    this.isDelivery = false,
    this.deliveryAddress,
    DateTime? orderDate, // Keep as parameter
    Map<String, dynamic>? location,
    this.deliveryDate,
    this.deliveryTime,
    this.isReviewed = false,
    this.assignedToId,
    this.assignedToName,
    this.businessId,
    this.resourceId,
    this.adminNotes,
    this.adminReviewedAt,
    this.adminId,
    this.adminName,
    this.isArchived = false,
    this.adminMetadata,
  })  :
        // Initialize orderDate and location with default values if not provided
        timestamp = Timestamp.now(),
        orderDate = orderDate ?? DateTime.now(),
        location = location ??
            {
              'address': address,
              'latitude': latitude,
              'longitude': longitude,
            };

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse items
    List<OrderItem> orderItems = [];
    if (data['items'] != null) {
      if (data['items'] is List) {
        final itemsList = data['items'] as List;
        orderItems = itemsList.map((item) {
          if (item is Map<String, dynamic>) {
            return OrderItem.fromMap(item);
          } else {
            // Handle legacy format or unexpected data
            return OrderItem(
              productId: 'unknown',
              name: 'Unknown Item',
              price: 0.0,
              quantity: 1,
            );
          }
        }).toList();
      }
    }

    // Parse location data
    Map<String, dynamic> locationData = {};
    if (data['location'] != null && data['location'] is Map) {
      locationData = Map<String, dynamic>.from(data['location']);
    } else {
      locationData = {
        'address': data['address'] ?? 'Unknown Address',
        'latitude': data['latitude'] ?? '0.0',
        'longitude': data['longitude'] ?? '0.0',
      };
    }

    return Order(
      orderNumber: data['orderNumber'] ?? '',
      id: doc.id,
      email: data['email'] ?? 'No email provided',
      userId: data['userId'] ?? '',
      orderType: data['orderType'] ?? 'Unknown Type',
      address: locationData['address'] ?? 'Unknown Address',
      latitude: locationData['latitude']?.toString() ?? '0.0',
      longitude: locationData['longitude']?.toString() ?? '0.0',
      location: locationData,
      items: orderItems,
      paymentMethod: data['paymentMethod'] ?? 'Unknown Method',
      paymentStatus: data['paymentStatus'] ?? 'Unknown Status',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      // timestamp: data['timestamp'] ?? Timestamp.now(),
      tableNumber: data['tableNumber'] ?? 0,
      tableId: data['tableId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
      status: _parseOrderStatus(data['status']),
      customerName: data['customerName'],
      customerCount: data['customerCount'],
      waiterNotes: data['waiterNotes'],
      waiterId: data['waiterId'],
      waiterName: data['waiterName'],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      taxAmount: (data['taxAmount'] ?? 0.0).toDouble(),
      tipAmount: (data['tipAmount'] ?? 0.0).toDouble(),
      cashierId: data['cashierId'],
      cashierName: data['cashierName'],
      isPaid: data['isPaid'] ?? false,
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      receiptNumber: data['receiptNumber'],
      isDelivery: data['isDelivery'] ?? false,
      deliveryDate: data['deliveryDate'],
      deliveryTime: data['deliveryTime'],
      isReviewed: data['isReviewed'] ?? false,
      assignedToId: data['assignedToId'],
      assignedToName: data['assignedToName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'orderNumber': orderNumber,
      'email': email,
      'userId': userId,
      'orderType': orderType,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'orderDate': Timestamp.fromDate(orderDate),
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : FieldValue.serverTimestamp(),
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'isPaid': isPaid,
      'isDelivery': isDelivery,
      'isReviewed': isReviewed,
      'timestamp': timestamp,
    };

    // Only include optional fields if they are not null
    if (tableNumber != null) map['tableNumber'] = tableNumber;
    if (tableId != null) map['tableId'] = tableId;
    if (subtotal != null) map['subtotal'] = subtotal;
    if (taxAmount != null) map['taxAmount'] = taxAmount;
    if (tipAmount != null) map['tipAmount'] = tipAmount;
    if (customerName != null) map['customerName'] = customerName;
    if (customerCount != null) map['customerCount'] = customerCount;
    if (waiterNotes != null) map['waiterNotes'] = waiterNotes;
    if (waiterId != null) map['waiterId'] = waiterId;
    if (waiterName != null) map['waiterName'] = waiterName;
    if (cashierId != null) map['cashierId'] = cashierId;
    if (cashierName != null) map['cashierName'] = cashierName;
    if (paidAt != null) map['paidAt'] = Timestamp.fromDate(paidAt!);
    if (receiptNumber != null) map['receiptNumber'] = receiptNumber;
    if (deliveryDate != null) map['deliveryDate'] = deliveryDate;
    if (deliveryTime != null) map['deliveryTime'] = deliveryTime;
    if (assignedToId != null) map['assignedToId'] = assignedToId;
    if (assignedToName != null) map['assignedToName'] = assignedToName;

    return map;
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'email': email,
      'userId': userId,
      'orderType': orderType,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'items': items.map((item) => item.toMap()).toList(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'timestamp': timestamp,
      'tableNumber': tableNumber,
      'tableId': tableId,
      'createdAt': Timestamp.fromDate(createdAt),
      'orderDate': Timestamp.fromDate(orderDate),
      'lastUpdated':
          lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'status': status.toString().split('.').last,
      'customerName': customerName,
      'customerCount': customerCount,
      'waiterNotes': waiterNotes,
      'waiterId': waiterId,
      'waiterName': waiterName,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'tipAmount': tipAmount,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'isPaid': isPaid,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'receiptNumber': receiptNumber,
      'isDelivery': isDelivery,
      'deliveryDate': deliveryDate,
      'deliveryTime': deliveryTime,
      'isReviewed': isReviewed,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
    };
  }

  // Helper method to parse order status from string
  static OrderStatus _parseOrderStatus(dynamic status) {
    if (status == null) return OrderStatus.pending;
    if (status is OrderStatus) return status;

    final statusStr = status.toString();

    switch (statusStr) {
      case 'inProgress':
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
      case 'readyForDelivery':
        return OrderStatus.readyForDelivery;
      case 'delivered':
      case 'delivering':
        return OrderStatus.delivering;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'paymentConfirmed':
        return OrderStatus.paymentConfirmed;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  // Create an empty order with default values
  factory Order.empty() {
    return Order(
      orderNumber: OrderNumberGenerator.generateOrderNumber(),
      id: '',
      email: '',
      userId: '',
      orderType: 'dine-in',
      address: '',
      latitude: '0.0',
      longitude: '0.0',
      items: [],
      paymentMethod: 'efectivo',
      paymentStatus: 'pending',
      totalAmount: 0.0,
      // timestamp: Timestamp.now(),
      tableNumber: 0,
      tableId: '',
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      orderDate: DateTime.now(),
      location: {
        'address': '',
        'latitude': '0.0',
        'longitude': '0.0',
      },
    );
  }

  // Create a copy with updated fields
  Order copyWith({
    String? orderNumber,
    String? id,
    String? email,
    String? userId,
    String? orderType,
    String? address,
    String? latitude,
    String? longitude,
    String? paymentStatus,
    double? totalAmount,
    Timestamp? timestamp,
    int? tableNumber,
    String? tableId,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<OrderItem>? items,
    OrderStatus? status,
    String? customerName,
    int? customerCount,
    String? waiterNotes,
    String? waiterId,
    String? waiterName,
    String? paymentMethod,
    double? subtotal,
    double? taxAmount,
    double? tipAmount,
    String? cashierId,
    String? cashierName,
    bool? isPaid,
    DateTime? paidAt,
    String? receiptNumber,
    bool? isDelivery,
    DateTime? orderDate,
    Map<String, dynamic>? location,
    String? deliveryDate,
    String? deliveryTime,
    bool? isReviewed,
    String? assignedToId,
    String? assignedToName,
  }) {
    return Order(
      orderNumber: orderNumber ?? this.orderNumber,
      id: id ?? this.id,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      orderType: orderType ?? this.orderType,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      // timestamp: timestamp ?? this.timestamp,
      tableNumber: tableNumber ?? this.tableNumber,
      tableId: tableId ?? this.tableId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      items: items ?? this.items,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerCount: customerCount ?? this.customerCount,
      waiterNotes: waiterNotes ?? this.waiterNotes,
      waiterId: waiterId ?? this.waiterId,
      waiterName: waiterName ?? this.waiterName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      isDelivery: isDelivery ?? this.isDelivery,
      orderDate: orderDate ?? this.orderDate,
      location: location ?? this.location,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      isReviewed: isReviewed ?? this.isReviewed,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
    );
  }
}

// Order item model
class OrderItem {
  final String? id; // Added optional id field
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? notes;
  final String? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final bool isPriority; // Items that should be prepared first
  final bool
      isModifiable; // Whether the item can be modified after order is placed

  OrderItem({
    this.id, // Optional id parameter
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

  // Create from map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'], // Get id from map
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      notes: map['notes'],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      imageUrl: map['imageUrl'],
      isPriority: map['isPriority'] ?? false,
      isModifiable: map['isModifiable'] ?? true,
    );
  }

  // Convert to map
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

  // Create a copy with updated fields
  OrderItem copyWith({
    String? id, // Add id to copyWith
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? notes,
    String? categoryId,
    String? categoryName,
    String? imageUrl,
    bool? isPriority,
    bool? isModifiable,
  }) {
    return OrderItem(
      id: id ?? this.id, // Use provided id or current id
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      isPriority: isPriority ?? this.isPriority,
      isModifiable: isModifiable ?? this.isModifiable,
    );
  }
}

class OrderNumberGenerator {
  static const Uuid _uuid = Uuid();

  static String generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomComponent = _uuid.v4().substring(0, 8); // Shorten the UUID
    return '$timestamp-$randomComponent';
  }
}

class Sizes {
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
}
