 

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
//   });

//   factory AdminOrder.fromMap(String id, Map<String, dynamic> map) {
//     return AdminOrder(
//       id: id,
//       email: map['email'] ?? '',
//       userId: map['userId'] ?? '',
//       orderType: map['orderType'] ?? '',
//       status: OrderStatus.values.firstWhere(
//         (e) => e.name == map['status'],
//         orElse: () => OrderStatus.pending,
//       ),
//       orderDate: DateTime.parse(map['orderDate'] ?? DateTime.now().toIso8601String()),
//       location: map['location'] ?? {},
//       deliveryDate: map['deliveryDate'],
//       deliveryTime: map['deliveryTime'],
//       items: map['items'] ?? [],
//       paymentMethod: map['paymentMethod'] ?? '',
//       totalAmount: (map['totalAmount'] ?? 0).toDouble(),
//     );
//   }
// }
