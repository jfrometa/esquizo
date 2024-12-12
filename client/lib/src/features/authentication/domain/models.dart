import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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
  final List<dynamic> items;
  final String paymentMethod;
  final String paymentStatus;
  final double totalAmount;
  final Timestamp timestamp;

  Order({
    required this.orderNumber,
    required this.id,
    required this.email,
    required this.userId,
    required this.orderType,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.items,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required this.timestamp,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      orderNumber: data['orderNumber'] ?? '', // Fetch order number
      id: doc.id,
      email: data['email'] ?? 'No email provided',
      userId: data['userId'] ?? '',
      orderType: data['orderType'] ?? 'Unknown Type',
      address: data['location']['address'] ?? 'Unknown Address',
      latitude: data['location']['latitude'] ?? 'Unknown Latitude',
      longitude: data['location']['longitude'] ?? 'Unknown Longitude',
      items: data['items'] ?? [],
      paymentMethod: data['paymentMethod'] ?? 'Unknown Method',
      paymentStatus: data['paymentStatus'] ?? 'Unknown Status',
      totalAmount: data['totalAmount'] ?? 0.0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber, // Save order number
      'email': email,
      'userId': userId,
      'orderType': orderType,
      'location': {
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      },
      'items': items,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'timestamp': timestamp,
    };
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
