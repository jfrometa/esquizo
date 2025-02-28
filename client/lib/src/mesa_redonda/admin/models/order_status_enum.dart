import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  inProgress,
  ready,
  delivered,
  completed,
  cancelled,
  paymentConfirmed,
  preparing,
  readyForDelivery,
  delivering,  
}

// class OrderItem {
//   final String productId;
//   final String name;
//   final double price;
//   final int quantity;
//   final String? notes;

//   OrderItem({
//     required this.productId,
//     required this.name,
//     required this.price,
//     required this.quantity,
//     this.notes,
//   });

//   // Create from map
//   factory OrderItem.fromMap(Map<String, dynamic> map) {
//     return OrderItem(
//       productId: map['productId'] ?? '',
//       name: map['name'] ?? '',
//       price: (map['price'] ?? 0).toDouble(),
//       quantity: map['quantity'] ?? 0,
//       notes: map['notes'],
//     );
//   }

//   // Convert to map
//   Map<String, dynamic> toMap() {
//     return {
//       'productId': productId,
//       'name': name,
//       'price': price,
//       'quantity': quantity,
//       'notes': notes,
//     };
//   }

//   // Create a copy with updated fields
//   OrderItem copyWith({
//     String? productId,
//     String? name,
//     double? price,
//     int? quantity,
//     String? notes,
//   }) {
//     return OrderItem(
//       productId: productId ?? this.productId,
//       name: name ?? this.name,
//       price: price ?? this.price,
//       quantity: quantity ?? this.quantity,
//       notes: notes ?? this.notes,
//     );
//   }
// }

// class Order {
//   final String id;
//   final int tableNumber;
//   final String tableId;
//   final DateTime createdAt;
//   final DateTime? lastUpdated;
//   final List<OrderItem> items;
//   final OrderStatus status;
//   final double totalAmount;
//   final String? customerName;
//   final int? customerCount;
//   final String? waiterNotes;
//   final String? waiterId;
//   final String? waiterName;

//   Order({
//     required this.id,
//     required this.tableNumber,
//     required this.tableId,
//     required this.createdAt,
//     this.lastUpdated,
//     required this.items,
//     required this.status,
//     required this.totalAmount,
//     this.customerName,
//     this.customerCount,
//     this.waiterNotes,
//     this.waiterId,
//     this.waiterName,
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
//       totalAmount: (data['totalAmount'] ?? 0).toDouble(),
//       customerName: data['customerName'],
//       customerCount: data['customerCount'],
//       waiterNotes: data['waiterNotes'],
//       waiterId: data['waiterId'],
//       waiterName: data['waiterName'],
//     );
//   }

//   // Convert to map for Firestore
//   Map<String, dynamic> toFirestore() {
//     return {
//       'tableNumber': tableNumber,
//       'tableId': tableId,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
//       'items': items.map((item) => item.toMap()).toList(),
//       'status': status.toString().split('.').last,
//       'totalAmount': totalAmount,
//       'customerName': customerName,
//       'customerCount': customerCount,
//       'waiterNotes': waiterNotes,
//       'waiterId': waiterId,
//       'waiterName': waiterName,
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
//     double? totalAmount,
//     String? customerName,
//     int? customerCount,
//     String? waiterNotes,
//     String? waiterId,
//     String? waiterName,
//   }) {
//     return Order(
//       id: id ?? this.id,
//       tableNumber: tableNumber ?? this.tableNumber,
//       tableId: tableId ?? this.tableId,
//       createdAt: createdAt ?? this.createdAt,
//       lastUpdated: lastUpdated ?? this.lastUpdated,
//       items: items ?? this.items,
//       status: status ?? this.status,
//       totalAmount: totalAmount ?? this.totalAmount,
//       customerName: customerName ?? this.customerName,
//       customerCount: customerCount ?? this.customerCount,
//       waiterNotes: waiterNotes ?? this.waiterNotes,
//       waiterId: waiterId ?? this.waiterId,
//       waiterName: waiterName ?? this.waiterName,
//     );
//   }

//   // Helper method to parse order status from string
//   static OrderStatus _parseOrderStatus(String? status) {
//     if (status == null) return OrderStatus.pending;
    
//     switch (status) {
//       case 'inProgress':
//         return OrderStatus.inProgress;
//       case 'ready':
//         return OrderStatus.ready;
//       case 'delivered':
//         return OrderStatus.delivered;
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