import 'package:cloud_firestore/cloud_firestore.dart' as CloudFireStore; 
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';

class OrderService {
  final CloudFireStore.FirebaseFirestore _firestore;
  final String _businessId;
  
  OrderService({
    CloudFireStore.FirebaseFirestore? firestore,
    required String businessId,
  }) : 
    _firestore = firestore ?? CloudFireStore.FirebaseFirestore.instance,
    _businessId = businessId;
  
  // Collection reference
  CloudFireStore.CollectionReference get _ordersCollection => 
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
      'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
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
        .where('createdAt', isGreaterThan: CloudFireStore.Timestamp.fromDate(yesterday))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
  }
}

// Extension methods for Order class to handle Firestore conversion
extension OrderFirestoreExtension on Order {
  // Convert Order to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'businessId': businessId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'items': items.map((item) => item is Map ? item : item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status.name,
      'createdAt': CloudFireStore.Timestamp.fromDate(createdAt),
      'resourceId': resourceId,
      'specialInstructions': specialInstructions,
      'isDelivery': isDelivery,
      'deliveryAddress': deliveryAddress,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'peopleCount': peopleCount,
      'paymentMethod': paymentMethod,
      'lastUpdated': lastUpdated != null 
          ? CloudFireStore.Timestamp.fromDate(lastUpdated!) 
          : null,
    };
  }

  // Create Order from Firestore document
  static Order fromFirestore(CloudFireStore.DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Order(
      id: data['id'] ?? doc.id,
      businessId: data['businessId'],
      userId: data['userId'] ?? '',
      userName: data['userName'],
      userEmail: data['userEmail'],
      userPhone: data['userPhone'],
      items: (data['items'] as List?)?.map((item) => item as Map<String, dynamic>).toList() ?? [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: _parseOrderStatus(data['status']),
      createdAt: (data['createdAt'] as CloudFireStore.Timestamp?)?.toDate() ?? DateTime.now(),
      resourceId: data['resourceId'],
      specialInstructions: data['specialInstructions'],
      isDelivery: data['isDelivery'] ?? false,
      deliveryAddress: data['deliveryAddress'],
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      peopleCount: data['peopleCount'],
      paymentMethod: data['paymentMethod'] ?? 'cash',
      lastUpdated: (data['lastUpdated'] as CloudFireStore.Timestamp?)?.toDate(),
    );
  }
  
  // Helper method to parse order status
  static OrderStatus _parseOrderStatus(String? status) {
    if (status == null) return OrderStatus.pending;
    
    switch (status.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'preparing': return OrderStatus.preparing;
      case 'ready': return OrderStatus.ready;
      case 'completed': return OrderStatus.completed;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }
}