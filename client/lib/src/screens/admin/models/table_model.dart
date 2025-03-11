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