import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final Map<String, dynamic> options;
  final String? notes;
  
  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.options = const {},
    this.notes,
  });
  
  double get totalPrice => price * quantity;
  
  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      options: data['options'] ?? {},
      notes: data['notes'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'options': options,
      'notes': notes,
    };
  }
}

class Order {
  final String id;
  final String businessId;
  final String userId;
  final String? resourceId; // Table ID, delivery address, etc.
  final List<OrderItem> items;
  final String status;
  final double subtotal;
  final double tax;
  final double total;
  final String? specialInstructions;
  final bool isDelivery;
  final int peopleCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Order({
    required this.id,
    required this.businessId,
    required this.userId,
    this.resourceId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.specialInstructions,
    this.isDelivery = false,
    this.peopleCount = 1,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final itemsList = (data['items'] as List<dynamic>? ?? [])
        .map((item) => OrderItem.fromFirestore(item as Map<String, dynamic>))
        .toList();
    
    return Order(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      userId: data['userId'] ?? '',
      resourceId: data['resourceId'],
      items: itemsList,
      status: data['status'] ?? 'pending',
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      specialInstructions: data['specialInstructions'],
      isDelivery: data['isDelivery'] ?? false,
      peopleCount: data['peopleCount'] ?? 1,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'userId': userId,
      'resourceId': resourceId,
      'items': items.map((item) => item.toFirestore()).toList(),
      'status': status,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'specialInstructions': specialInstructions,
      'isDelivery': isDelivery,
      'peopleCount': peopleCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class OrderService {
  final FirebaseFirestore _firestore;
  final String _businessId;
  
  OrderService({
    FirebaseFirestore? firestore,
    required String businessId,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _businessId = businessId;
  
  // Collection reference
  CollectionReference get _ordersCollection => 
      _firestore.collection('businesses').doc(_businessId).collection('orders');
  
  // Create a new order
  Future<String> createOrder(Order order) async {
    try {
      final docRef = await _ordersCollection.add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      throw e;
    }
  }
  
  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }
  
  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _ordersCollection.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Get orders by status
  Stream<List<Order>> getOrdersByStatusStream(String status) {
    return _ordersCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
  }
  
  // Get orders for a specific resource
  Stream<List<Order>> getOrdersByResourceStream(String resourceId) {
    return _ordersCollection
        .where('resourceId', isEqualTo: resourceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
  }
  
  // Get user orders
  Stream<List<Order>> getUserOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
  }
  
  // Get recent orders (last 24 hours)
  Stream<List<Order>> getRecentOrdersStream() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    return _ordersCollection
        .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
  }
}