import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';

 

// Table status enum 
enum TableStatus {
  available,    // Table is free and can be occupied
  occupied,     // Table is currently in use
  reserved,     // Table has been reserved for future use
  maintenance,
  cleaning   // Table is under maintenance/cleaning
}

// Table shapes for visual representation
enum TableShape {
  rectangle,
  round,
  oval
}

// Restaurant table model
class RestaurantTable {
  final String id;
  final int number;
  final int capacity;
  final TableStatus status;
  final String? currentOrderId;
  final String? area;         // Section of restaurant (e.g., "Terrace", "Indoor")
  final String? description;  // Additional description
  final bool isActive;        // Whether this table is in active use
  final TableShape? shape;    // Visual shape representation
  final DateTime? updatedAt;  // Last update timestamp
  final String name; 
  final bool isAvailable;

  RestaurantTable({
    required this.id,
    required this.number,
    required this.capacity,
    this.status = TableStatus.available,
    this.currentOrderId,
    this.area,
    this.description,
    this.isActive = true,
    this.shape = TableShape.rectangle,
    this.updatedAt,
    this.name = '',
    this.isAvailable = true,
  });

    // Helper method to parse table status from string
  static TableStatus _parseTableStatus(dynamic status) {
    if (status == null) return TableStatus.available;
    
    if (status is TableStatus) return status;
    
    final statusStr = status.toString();
    
    switch (statusStr) {
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      case 'maintenance':
        return TableStatus.maintenance;
      case 'available':
      default:
        return TableStatus.available;
    }
  }
  
  // Helper method to parse table shape from string
  static TableShape? _parseTableShape(dynamic shape) {
    if (shape == null) return TableShape.rectangle;
    
    if (shape is TableShape) return shape;
    
    final shapeStr = shape.toString();
    
    switch (shapeStr) {
      case 'round':
        return TableShape.round;
      case 'oval':
        return TableShape.oval;
      case 'rectangle':
      default:
        return TableShape.rectangle;
    }
  }

  // Create from Firestore document
  factory RestaurantTable.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantTable(
      id: doc.id,
      number: data['number'] ?? 0,
      capacity: data['capacity'] ?? 4,
      status: _parseTableStatus(data['status']),
      currentOrderId: data['currentOrderId'],
      area: data['area'],
      description: data['description'],
      isActive: data['isActive'] ?? true,
      shape: _parseTableShape(data['shape']),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      name: data['name'] ?? 'Table ${data['number'] ?? 0}',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'number': number,
      'capacity': capacity,
      'status': status.toString().split('.').last,
      'currentOrderId': currentOrderId,
      'area': area,
      'description': description,
      'isActive': isActive,
      'shape': shape?.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
      'name': name,
      'isAvailable': isAvailable,
    };
  }

  // Create a copy with updated fields
  RestaurantTable copyWith({
    String? id,
    int? number,
    int? capacity,
    TableStatus? status,
    String? currentOrderId,
    String? area,
    String? description,
    bool? isActive,
    TableShape? shape,
    DateTime? updatedAt,
    String? name,
    bool? isAvailable,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      area: area ?? this.area,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      shape: shape ?? this.shape,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  // Helper methods remain unchanged
}


// // Enhanced Order model
// class Order {
//   final String id;
//   final int tableNumber;
//   final String tableId;
//   final DateTime createdAt;
//   final DateTime? lastUpdated;
//   final List<OrderItem> items;
//   final OrderStatus status;
//   final double subtotal;     // Before tax & tips
//   final double taxAmount;    // Tax amount
//   final double tipAmount;    // Tip amount
//   final double totalAmount;  // Final total
//   final String? customerName;
//   final int? customerCount;
//   final String? waiterNotes;
//   final String? waiterId;
//   final String? waiterName;
//   final String? cashierId;   // ID of cashier who processed payment
//   final String? cashierName; // Name of cashier
//   final String paymentMethod;
//   final bool isPaid;
//   final DateTime? paidAt;
//   final String? receiptNumber;
//   final bool isDelivery;     // Is this a delivery order (vs. dine-in)

//   Order({
//     required this.id,
//     required this.tableNumber,
//     required this.tableId,
//     required this.createdAt,
//     this.lastUpdated,
//     required this.items,
//     required this.status,
//     required this.subtotal,
//     required this.taxAmount,
//     required this.tipAmount,
//     required this.totalAmount,
//     this.customerName,
//     this.customerCount,
//     this.waiterNotes,
//     this.waiterId,
//     this.waiterName,
//     this.cashierId,
//     this.cashierName,
//     this.paymentMethod = 'efectivo',
//     this.isPaid = false,
//     this.paidAt,
//     this.receiptNumber,
//     this.isDelivery = false,
//   });

//   // Create from Firestore document
//   factory Order.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
    
//     // Parse items
//     List<OrderItem> orderItems = [];
//     if (data['items'] != null) {
//       orderItems = (data['items'] as List)
//           .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
//           .toList();
//     }

//     return Order(
//       id: doc.id,
//       tableNumber: data['tableNumber'] ?? 0,
//       tableId: data['tableId'] ?? '',
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
//       items: orderItems,
//       status: _parseOrderStatus(data['status']),
//       subtotal: (data['subtotal'] ?? 0).toDouble(),
//       taxAmount: (data['taxAmount'] ?? 0).toDouble(),
//       tipAmount: (data['tipAmount'] ?? 0).toDouble(),
//       totalAmount: (data['totalAmount'] ?? 0).toDouble(),
//       customerName: data['customerName'],
//       customerCount: data['customerCount'],
//       waiterNotes: data['waiterNotes'],
//       waiterId: data['waiterId'],
//       waiterName: data['waiterName'],
//       cashierId: data['cashierId'],
//       cashierName: data['cashierName'],
//       paymentMethod: data['paymentMethod'] ?? 'efectivo',
//       isPaid: data['isPaid'] ?? false,
//       paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
//       receiptNumber: data['receiptNumber'],
//       isDelivery: data['isDelivery'] ?? false,
//     );
//   }

//   // Convert to map for Firestore
//   Map<String, dynamic> toFirestore() {
//     return {
//       'tableNumber': tableNumber,
//       'tableId': tableId,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'lastUpdated': FieldValue.serverTimestamp(),
//       'items': items.map((item) => item.toMap()).toList(),
//       'status': status.toString().split('.').last,
//       'subtotal': subtotal,
//       'taxAmount': taxAmount,
//       'tipAmount': tipAmount,
//       'totalAmount': totalAmount,
//       'customerName': customerName,
//       'customerCount': customerCount,
//       'waiterNotes': waiterNotes,
//       'waiterId': waiterId,
//       'waiterName': waiterName,
//       'cashierId': cashierId,
//       'cashierName': cashierName,
//       'paymentMethod': paymentMethod,
//       'isPaid': isPaid,
//       'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
//       'receiptNumber': receiptNumber,
//       'isDelivery': isDelivery,
//     };
//   }

//   // Create a copy with updated fields
//   Order copyWith({
//     String? id,
//     int? tableNumber,
//     String? tableId,
//     DateTime? createdAt,
//     DateTime? lastUpdated,
//     List<OrderItem>? items,
//     OrderStatus? status,
//     double? subtotal,
//     double? taxAmount,
//     double? tipAmount,
//     double? totalAmount,
//     String? customerName,
//     int? customerCount,
//     String? waiterNotes,
//     String? waiterId,
//     String? waiterName,
//     String? cashierId,
//     String? cashierName,
//     String? paymentMethod,
//     bool? isPaid,
//     DateTime? paidAt,
//     String? receiptNumber,
//     bool? isDelivery,
//   }) {
//     return Order(
//       id: id ?? this.id,
//       tableNumber: tableNumber ?? this.tableNumber,
//       tableId: tableId ?? this.tableId,
//       createdAt: createdAt ?? this.createdAt,
//       lastUpdated: lastUpdated ?? this.lastUpdated,
//       items: items ?? this.items,
//       status: status ?? this.status,
//       subtotal: subtotal ?? this.subtotal,
//       taxAmount: taxAmount ?? this.taxAmount,
//       tipAmount: tipAmount ?? this.tipAmount,
//       totalAmount: totalAmount ?? this.totalAmount,
//       customerName: customerName ?? this.customerName,
//       customerCount: customerCount ?? this.customerCount,
//       waiterNotes: waiterNotes ?? this.waiterNotes,
//       waiterId: waiterId ?? this.waiterId,
//       waiterName: waiterName ?? this.waiterName,
//       cashierId: cashierId ?? this.cashierId,
//       cashierName: cashierName ?? this.cashierName,
//       paymentMethod: paymentMethod ?? this.paymentMethod,
//       isPaid: isPaid ?? this.isPaid,
//       paidAt: paidAt ?? this.paidAt,
//       receiptNumber: receiptNumber ?? this.receiptNumber,
//       isDelivery: isDelivery ?? this.isDelivery,
//     );
//   }

//   // Helper method to parse order status from string
//   static OrderStatus _parseOrderStatus(String? status) {
//     if (status == null) return OrderStatus.pending;
    
//     switch (status) {
//       case 'paymentConfirmed':
//         return OrderStatus.paymentConfirmed;
//       case 'preparing':
//         return OrderStatus.preparing;
//       case 'readyForDelivery':
//         return OrderStatus.readyForDelivery;
//       case 'delivering':
//         return OrderStatus.delivering;
//       case 'completed':
//         return OrderStatus.completed;
//       case 'cancelled':
//         return OrderStatus.cancelled;
//       case 'pending':
//       default:
//         return OrderStatus.pending;
//     }
//   }
  
//   // Calculate subtotal from items
//   static double calculateSubtotal(List<OrderItem> items) {
//     return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
//   }
  
//   // Calculate tax amount (16% by default)
//   static double calculateTax(double subtotal, {double taxRate = 0.16}) {
//     return subtotal * taxRate;
//   }
  
//   // Calculate total amount
//   static double calculateTotal(double subtotal, double taxAmount, double tipAmount) {
//     return subtotal + taxAmount + tipAmount;
//   }
// }

// // Admin-specific order model
// class AdminOrder {
//   final String id;
//   final String email;
//   final String userId;
//   final String orderType;
//   final OrderStatus status;
//   final DateTime orderDate;
//   final Map<String, dynamic> location;
//   final String? deliveryDate;
//   final String? deliveryTime;
//   final List<dynamic> items;
//   final String paymentMethod;
//   final double totalAmount;
//   final bool isReviewed;
//   final String? assignedToId;
//   final String? assignedToName;

//   AdminOrder({
//     required this.id,
//     required this.email,
//     required this.userId,
//     required this.orderType,
//     required this.status,
//     required this.orderDate,
//     required this.location,
//     this.deliveryDate,
//     this.deliveryTime,
//     required this.items,
//     required this.paymentMethod,
//     required this.totalAmount,
//     this.isReviewed = false,
//     this.assignedToId,
//     this.assignedToName,
//   });

//   factory AdminOrder.fromMap(String id, Map<String, dynamic> map) {
//     return AdminOrder(
//       id: id,
//       email: map['email'] ?? '',
//       userId: map['userId'] ?? '',
//       orderType: map['orderType'] ?? '',
//       status: _parseOrderStatus(map['status']),
//       orderDate: (map['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       location: map['location'] ?? {},
//       deliveryDate: map['deliveryDate'],
//       deliveryTime: map['deliveryTime'],
//       items: map['items'] ?? [],
//       paymentMethod: map['paymentMethod'] ?? '',
//       totalAmount: (map['totalAmount'] ?? 0).toDouble(),
//       isReviewed: map['isReviewed'] ?? false,
//       assignedToId: map['assignedToId'],
//       assignedToName: map['assignedToName'],
//     );
//   }
  
//   // Convert to map for Firestore
//   Map<String, dynamic> toFirestore() {
//     return {
//       'email': email,
//       'userId': userId,
//       'orderType': orderType,
//       'status': status.toString().split('.').last,
//       'orderDate': Timestamp.fromDate(orderDate),
//       'location': location,
//       'deliveryDate': deliveryDate,
//       'deliveryTime': deliveryTime,
//       'items': items,
//       'paymentMethod': paymentMethod,
//       'totalAmount': totalAmount,
//       'isReviewed': isReviewed,
//       'assignedToId': assignedToId,
//       'assignedToName': assignedToName,
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }
  
//   // Create a copy with updated fields
//   AdminOrder copyWith({
//     String? id,
//     String? email,
//     String? userId,
//     String? orderType,
//     OrderStatus? status,
//     DateTime? orderDate,
//     Map<String, dynamic>? location,
//     String? deliveryDate,
//     String? deliveryTime,
//     List<dynamic>? items,
//     String? paymentMethod,
//     double? totalAmount,
//     bool? isReviewed,
//     String? assignedToId,
//     String? assignedToName,
//   }) {
//     return AdminOrder(
//       id: id ?? this.id,
//       email: email ?? this.email,
//       userId: userId ?? this.userId,
//       orderType: orderType ?? this.orderType,
//       status: status ?? this.status,
//       orderDate: orderDate ?? this.orderDate,
//       location: location ?? this.location,
//       deliveryDate: deliveryDate ?? this.deliveryDate,
//       deliveryTime: deliveryTime ?? this.deliveryTime,
//       items: items ?? this.items,
//       paymentMethod: paymentMethod ?? this.paymentMethod,
//       totalAmount: totalAmount ?? this.totalAmount,
//       isReviewed: isReviewed ?? this.isReviewed,
//       assignedToId: assignedToId ?? this.assignedToId,
//       assignedToName: assignedToName ?? this.assignedToName,
//     );
//   }
  
//   // Helper method to parse order status from string
//   static OrderStatus _parseOrderStatus(String? status) {
//     if (status == null) return OrderStatus.pending;
    
//     switch (status) {
//       case 'paymentConfirmed':
//         return OrderStatus.paymentConfirmed;
//       case 'preparing':
//         return OrderStatus.preparing;
//       case 'readyForDelivery':
//         return OrderStatus.readyForDelivery;
//       case 'delivering':
//         return OrderStatus.delivering;
//       case 'completed':
//         return OrderStatus.completed;
//       case 'cancelled':
//         return OrderStatus.cancelled;
//       case 'pending':
//       default:
//         return OrderStatus.pending;
//     }
//   }
// }


// Staff role enum
enum StaffRole {
  admin,     // Full access to all areas
  manager,   // Management access
  waiter,    // Waitstaff
  cashier,   // Cashier
  kitchen,   // Kitchen staff
  delivery,  // Delivery personnel
  host       // Host/hostess
}

// Staff member model
class StaffMember {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final StaffRole role;
  final bool isActive;
  final DateTime? lastLogin;
  final String? profileImageUrl;
  
  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.isActive = true,
    this.lastLogin,
    this.profileImageUrl,
  });
  
  // Create from Firestore document
  factory StaffMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return StaffMember(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      role: _parseStaffRole(data['role']),
      isActive: data['isActive'] ?? true,
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      profileImageUrl: data['profileImageUrl'],
    );
  }
  
  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'isActive': isActive,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  // Helper method to parse staff role from string
  static StaffRole _parseStaffRole(String? role) {
    if (role == null) return StaffRole.waiter;
    
    switch (role) {
      case 'admin':
        return StaffRole.admin;
      case 'manager':
        return StaffRole.manager;
      case 'cashier':
        return StaffRole.cashier;
      case 'kitchen':
        return StaffRole.kitchen;
      case 'delivery':
        return StaffRole.delivery;
      case 'host':
        return StaffRole.host;
      case 'waiter':
      default:
        return StaffRole.waiter;
    }
  }
}