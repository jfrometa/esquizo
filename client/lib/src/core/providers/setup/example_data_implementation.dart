import 'package:cloud_firestore/cloud_firestore.dart' as CloudFireStore;
import 'package:firebase_auth/firebase_auth.dart';
 import 'package:starter_architecture_flutter_firebase/src/core/services/business_config_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/resource_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart';
 import 'package:starter_architecture_flutter_firebase/src/core/services/reservation_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/admin_user.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
 

/// Service for initializing example data for different business types
class ExampleDataService {
  final CloudFireStore.FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  ExampleDataService({
    CloudFireStore.FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? CloudFireStore.FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Check if example data is already initialized for a business
  Future<bool> isExampleDataInitialized(String businessId) async {
    try {
      final businessDoc = await _firestore.collection('businesses').doc(businessId).get();
      return businessDoc.exists;
    } catch (e) {
      print('Error checking if example data is initialized: $e');
      return false;
    }
  }

  /// Initialize example data
  Future<void> initializeExampleData({
    required String businessId,
    required String businessType,
    required String adminEmail,
  }) async {
    try {
      // Check if example data already exists
      final businessDoc = await _firestore.collection('businesses').doc(businessId).get();
      if (businessDoc.exists) {
        print('Business already exists, skipping example data creation');
        return;
      }

      // Create admin user in admins collection
      final adminUser = await _ensureAdminUser(adminEmail);
      
      // Create business configuration
      await _createBusinessConfig(businessId, businessType, adminUser);
      
      // Create example data based on business type
      switch (businessType) {
        case 'restaurant':
          await _createRestaurantExample(businessId);
          break;
        case 'hotel':
          await _createHotelExample(businessId);
          break;
        default:
          await _createGenericExample(businessId);
      }
      
      print('Example data initialized for $businessType business');
    } catch (e) {
      print('Error initializing example data: $e');
      throw Exception('Failed to initialize example data: $e');
    }
  }

  /// Create business configuration
  Future<void> _createBusinessConfig(String businessId, String businessType, AdminUser adminUser) async {
    final businessConfig = BusinessConfig(
      id: businessId,
      name: businessType == 'restaurant' 
          ? 'Sample Restaurant' 
          : businessType == 'hotel' 
              ? 'Sample Hotel' 
              : 'Sample Business',
      type: businessType,
      logoUrl: '',
      coverImageUrl: '',
      description: 'This is a sample $businessType created for demonstration purposes.',
      contactInfo: {
        'email': 'contact@example.com',
        'phone': '+1234567890',
        'website': 'https://example.com'
      },
      address: {
        'street': '123 Main St',
        'city': 'Anytown',
        'state': 'CA',
        'postalCode': '12345',
        'country': 'USA'
      },
      hours: {
        'monday': {'open': '09:00', 'close': '22:00'},
        'tuesday': {'open': '09:00', 'close': '22:00'},
        'wednesday': {'open': '09:00', 'close': '22:00'},
        'thursday': {'open': '09:00', 'close': '22:00'},
        'friday': {'open': '09:00', 'close': '23:00'},
        'saturday': {'open': '10:00', 'close': '23:00'},
        'sunday': {'open': '10:00', 'close': '21:00'}
      },
      settings: {
        'currency': 'USD',
        'taxRate': 0.08,
        'serviceCharge': 0.1,
        'minOrderValue': 0,
        'allowReservations': true,
        'allowOnlineOrders': true,
        'theme': {
          'primaryColor': '#FF5722',
          'secondaryColor': '#FFC107',
          'darkMode': false
        }
      },
      features: _getBusinessFeatures(businessType),
      isActive: true,
    );
    
    await _firestore.collection('businesses').doc(businessId).set(businessConfig.toFirestore());
    
    // Add owner relationship
    await _firestore.collection('business_relationships').add({
      'businessId': businessId,
      'userId': adminUser.uid,
      'role': 'owner',
      'email': adminUser.email,
      'createdAt': CloudFireStore.FieldValue.serverTimestamp()
    });
  }

  /// Create restaurant example data
  Future<void> _createRestaurantExample(String businessId) async {
    // Create categories
    final categoryIds = await _createRestaurantCategories(businessId);
    
    // Create menu items
    await _createRestaurantMenuItems(businessId, categoryIds);
    
    // Create tables
    final tableIds = await _createRestaurantTables(businessId);
    
    // Create sample orders
    await _createRestaurantOrders(businessId, tableIds);
    
    // Create sample reservations
    await _createRestaurantReservations(businessId, tableIds);
  }

  /// Create hotel example data
  Future<void> _createHotelExample(String businessId) async {
    // Create room categories
    final categoryIds = await _createHotelCategories(businessId);
    
    // Create rooms
    final roomIds = await _createHotelRooms(businessId, categoryIds);
    
    // Create sample bookings
    await _createHotelBookings(businessId, roomIds);
  }

  /// Create generic example data
  Future<void> _createGenericExample(String businessId) async {
    // Create basic categories
    final categoryIds = await _createGenericCategories(businessId);
    
    // Create basic products
    await _createGenericProducts(businessId, categoryIds);
    
    // Create resources
    await _createGenericResources(businessId);
  }

  /// Create restaurant categories
  Future<Map<String, String>> _createRestaurantCategories(String businessId) async {
    final categories = {
      'appetizers': 'Appetizers',
      'mains': 'Main Courses',
      'desserts': 'Desserts',
      'drinks': 'Drinks'
    };
    
    final categoryIds = <String, String>{};
    
    for (final entry in categories.entries) {
      final category = CatalogCategory(
        id: entry.key,
        name: entry.value,
        imageUrl: '',
        sortOrder: categories.keys.toList().indexOf(entry.key),
        isActive: true,
      );
      
      final docRef = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('menu_categories')
          .doc(entry.key)
          .set(category.toFirestore());
      
      categoryIds[entry.key] = entry.key;
    }
    
    return categoryIds;
  }

  /// Create restaurant menu items
  Future<void> _createRestaurantMenuItems(String businessId, Map<String, String> categoryIds) async {
    final items = [
      // Appetizers
      {
        'id': 'bruschetta',
        'name': 'Bruschetta',
        'description': 'Toasted bread topped with tomatoes, garlic, and basil',
        'price': 8.99,
        'categoryId': categoryIds['appetizers']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'spicy': false, 'vegetarian': true, 'featured': true}
      },
      {
        'id': 'calamari',
        'name': 'Calamari',
        'description': 'Crispy fried squid with marinara sauce',
        'price': 12.99,
        'categoryId': categoryIds['appetizers']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'spicy': false, 'vegetarian': false, 'featured': false}
      },
      
      // Main Courses
      {
        'id': 'margherita',
        'name': 'Pizza Margherita',
        'description': 'Classic pizza with tomato sauce, mozzarella, and basil',
        'price': 14.99,
        'categoryId': categoryIds['mains']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'spicy': false, 'vegetarian': true, 'featured': true}
      },
      {
        'id': 'spaghetti',
        'name': 'Spaghetti Bolognese',
        'description': 'Spaghetti with hearty meat sauce',
        'price': 15.99,
        'categoryId': categoryIds['mains']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'spicy': false, 'vegetarian': false, 'featured': false}
      },
      {
        'id': 'lasagna',
        'name': 'Lasagna',
        'description': 'Layered pasta with meat sauce and cheese',
        'price': 16.99,
        'categoryId': categoryIds['mains']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'spicy': false, 'vegetarian': false, 'featured': true}
      },
      
      // Desserts
      {
        'id': 'tiramisu',
        'name': 'Tiramisu',
        'description': 'Coffee-flavored Italian dessert',
        'price': 7.99,
        'categoryId': categoryIds['desserts']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'vegetarian': true, 'featured': true}
      },
      {
        'id': 'cheesecake',
        'name': 'New York Cheesecake',
        'description': 'Creamy cheesecake with graham cracker crust',
        'price': 8.99,
        'categoryId': categoryIds['desserts']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'vegetarian': true, 'featured': false}
      },
      
      // Drinks
      {
        'id': 'soda',
        'name': 'Soda',
        'description': 'Assorted soft drinks',
        'price': 2.99,
        'categoryId': categoryIds['drinks']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'alcoholic': false, 'featured': false}
      },
      {
        'id': 'wine',
        'name': 'House Wine',
        'description': 'Red or white house wine',
        'price': 6.99,
        'categoryId': categoryIds['drinks']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'alcoholic': true, 'featured': true}
      }
    ];
    
    for (final item in items) {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('menu_items')
          .doc(item['id'] as String)
          .set({
            'name': item['name'],
            'description': item['description'],
            'price': item['price'],
            'categoryId': item['categoryId'],
            'imageUrl': item['imageUrl'],
            'isAvailable': item['isAvailable'],
            'metadata': item['metadata'],
            'createdAt': CloudFireStore.FieldValue.serverTimestamp(),
            'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
          });
    }
  }

  /// Create restaurant tables
  Future<List<String>> _createRestaurantTables(String businessId) async {
    final tableIds = <String>[];
    
    for (int i = 1; i <= 10; i++) {
      final tableId = 'table_$i';
      final capacity = i <= 6 ? 4 : (i <= 8 ? 6 : 8);
      final location = i <= 4 ? 'window' : (i <= 8 ? 'center' : 'patio');
      
      final resource = Resource(
        id: tableId,
        businessId: businessId,
        type: 'table',
        name: 'Table $i',
        description: 'Seating capacity: $capacity',
        status: 'available',
        attributes: {
          'capacity': capacity,
          'location': location,
          'smoking': location == 'patio',
          'accessible': i == 1 || i == 5,
        },
        isActive: true,
      );
      
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('resources')
          .doc(tableId)
          .set(resource.toFirestore());
      
      tableIds.add(tableId);
    }
    
    return tableIds;
  }

 
  /// Create sample restaurant reservations
  Future<void> _createRestaurantReservations(String businessId, List<String> tableIds) async {
    final now = DateTime.now();
    final statuses = ['confirmed', 'pending'];
    
    for (int i = 0; i < 5; i++) {
      final reservationId = 'sample_reservation_$i';
      final tableId = tableIds[i % tableIds.length];
      final status = statuses[i % statuses.length];
      
      // Create reservations for the next few days
      final reservationDate = DateTime(
        now.year, 
        now.month, 
        now.day + i + 1, 
        18 + (i % 4), // Hour (6pm - 9pm)
        i % 2 == 0 ? 0 : 30, // Minute (0 or 30)
      );
      
      final timeSlot = '${reservationDate.hour}:${reservationDate.minute == 0 ? '00' : '30'}';
      
      final reservation = Reservation(
        id: reservationId,
        businessId: businessId,
        resourceId: tableId,
        userId: 'sample_user',
        userName: 'John Doe',
        userEmail: 'john.doe@example.com',
        userPhone: '+1234567890',
        date: reservationDate,
        timeSlot: timeSlot,
        partySize: 2 + (i % 4),
        status: status,
        specialRequests: i == 0 ? 'Window seat preferred' : '',
      );
      
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('reservations')
          .doc(reservationId)
          .set(reservation.toFirestore());
    }
  }

  /// Create hotel categories
  Future<Map<String, String>> _createHotelCategories(String businessId) async {
    final categories = {
      'standard': 'Standard Rooms',
      'deluxe': 'Deluxe Rooms',
      'suite': 'Suites'
    };
    
    final categoryIds = <String, String>{};
    
    for (final entry in categories.entries) {
      final category = CatalogCategory(
        id: entry.key,
        name: entry.value,
        imageUrl: '',
        sortOrder: categories.keys.toList().indexOf(entry.key),
        isActive: true,
      );
      
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('room_categories')
          .doc(entry.key)
          .set(category.toFirestore());
      
      categoryIds[entry.key] = entry.key;
    }
    
    return categoryIds;
  }

  /// Create hotel rooms
  Future<List<String>> _createHotelRooms(String businessId, Map<String, String> categoryIds) async {
    final roomIds = <String>[];
    
    // Create room types in catalog
    final roomTypes = [
      {
        'id': 'standard_single',
        'name': 'Standard Single',
        'description': 'Comfortable room with a single bed',
        'price': 89.99,
        'categoryId': categoryIds['standard']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'beds': 1, 'capacity': 1, 'size': '250 sq ft', 'featured': false}
      },
      {
        'id': 'standard_double',
        'name': 'Standard Double',
        'description': 'Comfortable room with a double bed',
        'price': 99.99,
        'categoryId': categoryIds['standard']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'beds': 1, 'capacity': 2, 'size': '300 sq ft', 'featured': true}
      },
      {
        'id': 'deluxe_king',
        'name': 'Deluxe King',
        'description': 'Spacious room with a king-sized bed',
        'price': 149.99,
        'categoryId': categoryIds['deluxe']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'beds': 1, 'capacity': 2, 'size': '400 sq ft', 'featured': true}
      },
      {
        'id': 'executive_suite',
        'name': 'Executive Suite',
        'description': 'Luxury suite with separate living area',
        'price': 249.99,
        'categoryId': categoryIds['suite']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'beds': 1, 'capacity': 2, 'size': '600 sq ft', 'featured': true}
      }
    ];
    
    // Add room types to catalog
    for (final item in roomTypes) {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('room_items')
          .doc(item['id'] as String)
          .set({
            'name': item['name'],
            'description': item['description'],
            'price': item['price'],
            'categoryId': item['categoryId'],
            'imageUrl': item['imageUrl'],
            'isAvailable': item['isAvailable'],
            'metadata': item['metadata'],
            'createdAt': CloudFireStore.FieldValue.serverTimestamp(),
            'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
          });
    }
    
    // Create actual room resources
    final roomTypes2 = {
      'standard_single': {'total': 5, 'floor': 1},
      'standard_double': {'total': 8, 'floor': 2},
      'deluxe_king': {'total': 5, 'floor': 3},
      'executive_suite': {'total': 2, 'floor': 4},
    };
    
    for (final entry in roomTypes2.entries) {
      final type = entry.key;
      final total = entry.value['total'];
      final floor = entry.value['floor'];
      
      if(total == null || floor == null) continue;

      for (int i = 1; i <= total; i++) {
        final roomNumber = floor * 100 + i;
        final roomId = 'room_$roomNumber';
        
        final room = Resource(
          id: roomId,
          businessId: businessId,
          type: 'room',
          name: 'Room $roomNumber',
          description: 'Type: ${type.replaceAll('_', ' ').toUpperCase()}',
          status: 'available',
          attributes: {
            'roomType': type,
            'floor': floor,
            'roomNumber': roomNumber,
            'accessible': i == 1,
          },
          isActive: true,
        );
        
        await _firestore
            .collection('businesses')
            .doc(businessId)
            .collection('resources')
            .doc(roomId)
            .set(room.toFirestore());
        
        roomIds.add(roomId);
      }
    }
    
    return roomIds;
  }

 
  /// Create generic categories
  Future<Map<String, String>> _createGenericCategories(String businessId) async {
    final categories = {
      'category1': 'Category 1',
      'category2': 'Category 2',
      'category3': 'Category 3'
    };
    
    final categoryIds = <String, String>{};
    
    for (final entry in categories.entries) {
      final category = CatalogCategory(
        id: entry.key,
        name: entry.value,
        imageUrl: '',
        sortOrder: categories.keys.toList().indexOf(entry.key),
        isActive: true,
      );
      
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('product_categories')
          .doc(entry.key)
          .set(category.toFirestore());
      
      categoryIds[entry.key] = entry.key;
    }
    
    return categoryIds;
  }

  /// Create generic products
  Future<void> _createGenericProducts(String businessId, Map<String, String> categoryIds) async {
    final items = [
      {
        'id': 'product1',
        'name': 'Product 1',
        'description': 'Description for Product 1',
        'price': 9.99,
        'categoryId': categoryIds['category1']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'featured': true}
      },
      {
        'id': 'product2',
        'name': 'Product 2',
        'description': 'Description for Product 2',
        'price': 19.99,
        'categoryId': categoryIds['category1']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'featured': false}
      },
      {
        'id': 'product3',
        'name': 'Product 3',
        'description': 'Description for Product 3',
        'price': 29.99,
        'categoryId': categoryIds['category2']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'featured': true}
      },
      {
        'id': 'product4',
        'name': 'Product 4',
        'description': 'Description for Product 4',
        'price': 39.99,
        'categoryId': categoryIds['category3']!,
        'imageUrl': '',
        'isAvailable': true,
        'metadata': {'featured': false}
      },
    ];
    
    for (final item in items) {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('product_items')
          .doc(item['id'] as String)
          .set({
            'name': item['name'],
            'description': item['description'],
            'price': item['price'],
            'categoryId': item['categoryId'],
            'imageUrl': item['imageUrl'],
            'isAvailable': item['isAvailable'],
            'metadata': item['metadata'],
            'createdAt': CloudFireStore.FieldValue.serverTimestamp(),
            'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
          });
    }
  }

  /// Create generic resources
  Future<List<String>> _createGenericResources(String businessId) async {
    final resourceIds = <String>[];
    
    for (int i = 1; i <= 5; i++) {
      final resourceId = 'resource_$i';
      
      final resource = Resource(
        id: resourceId,
        businessId: businessId,
        type: 'generic',
        name: 'Resource $i',
        description: 'Generic resource $i',
        status: 'available',
        attributes: {
          'attribute1': 'value1',
          'attribute2': 'value2',
        },
        isActive: true,
      );
      
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('resources')
          .doc(resourceId)
          .set(resource.toFirestore());
      
      resourceIds.add(resourceId);
    }
    
    return resourceIds;
  }

  /// Ensure admin user exists in admins collection
  Future<AdminUser> _ensureAdminUser(String email) async {
    // Get user by email
    User? user;
    String uid = '';
    
    try {
      user = _auth.currentUser;
      if (user != null) {
        uid = user.uid;
      } else {
        // Try to find user in Firestore
        final usersSnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        
        if (usersSnapshot.docs.isNotEmpty) {
          uid = usersSnapshot.docs.first.id;
        } else {
          throw Exception('User not found. Please ensure the user exists in the system.');
        }
      }
    } catch (e) {
      print('Error finding user: $e');
      throw Exception('Failed to find user: $e');
    }
    
    // Check if admin already exists
    final adminDoc = await _firestore.collection('admins').doc(uid).get();
    
    if (adminDoc.exists) {
      return AdminUser.fromMap(uid, adminDoc.data()!);
    }
    
    // Create admin if it doesn't exist
    final adminUser = AdminUser(
      uid: uid,
      email: email,
      role: 'admin',
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('admins').doc(uid).set(adminUser.toMap());
    
    return adminUser;
  }

  /// Get business features based on business type
  List<String> _getBusinessFeatures(String businessType) {
    switch (businessType) {
      case 'restaurant':
        return [
          'menu',
          'tables',
          'reservations',
          'takeout',
          'delivery',
          'staff_management',
          'inventory',
        ];
      case 'hotel':
        return [
          'rooms',
          'bookings',
          'amenities',
          'housekeeping',
          'concierge',
          'staff_management',
          'inventory',
        ];
      default:
        return [
          'catalog',
          'orders',
          'inventory',
          'staff_management',
        ];
    }
  }

  /// Create sample restaurant orders
Future<void> _createRestaurantOrders(String businessId, List<String> tableIds) async {
  // Create some sample orders
  final now = DateTime.now();
  final statuses = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.readyForDelivery,
    OrderStatus.completed
  ];
  
  for (int i = 0; i < 5; i++) {
    final orderId = 'sample_order_$i';
    final tableId = tableIds[i % tableIds.length];
    final status = statuses[i % statuses.length];
    final createdAt = now.subtract(Duration(hours: i * 2));
    
    final orderItems = <OrderItem>[
      OrderItem(
        id: 'bruschetta',
        productId: 'bruschetta',
        name: 'Bruschetta',
        price: 8.99,
        quantity: 1,
      ),
      OrderItem(
        id: 'margherita',
        productId: 'margherita',
        name: 'Pizza Margherita',
        price: 14.99,
        quantity: 1,
      ),
      OrderItem(
        id: 'soda',
        productId: 'soda',
        name: 'Soda',
        price: 2.99,
        quantity: 2,
      ),
    ];
    
    final subtotal = orderItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final tax = subtotal * 0.08;
    final total = subtotal + tax;
    
    final order = Order(
      orderNumber: 'ORD-${now.millisecondsSinceEpoch}-$i',
      id: orderId,
      email: 'customer@example.com',
      userId: 'sample_user',
      orderType: 'dine-in',
      address: '123 Main St',
      latitude: '37.7749',
      longitude: '-122.4194',
      items: orderItems,
      paymentMethod: 'cash',
      paymentStatus: 'pending',
      totalAmount: total,
      // timestamp: CloudFireStore.Timestamp.now(),
      tableNumber: i + 1,
      tableId: tableId,
      createdAt: createdAt,
      status: status, // Using the OrderStatus enum directly
      orderDate: createdAt,
      location: {
        'address': '123 Main St',
        'latitude': '37.7749',
        'longitude': '-122.4194',
      },
      customerName: 'John Doe',
      customerCount: 2,
      waiterNotes: i == 0 ? 'No onions please' : null,
      subtotal: subtotal,
      taxAmount: tax,
      businessId: businessId,
    );
  
    await _firestore
      .collection('businesses')
      .doc(businessId)
      .collection('orders')
      .doc(orderId)
      .set(order.toFirestore());
  }
}

/// Create hotel bookings
Future<void> _createHotelBookings(String businessId, List<String> roomIds) async {
  final now = DateTime.now();
  
  for (int i = 0; i < 5; i++) {
    final bookingId = 'sample_booking_$i';
    final roomId = roomIds[i % roomIds.length];
    
    // Create bookings for the next few days
    final checkInDate = now.add(Duration(days: i + 1));
    final checkOutDate = checkInDate.add(Duration(days: 2 + (i % 3)));
    
    // Create an order for the booking
    final orderId = 'booking_order_$i';
    
    final orderItems = <OrderItem>[
      OrderItem(
        id: roomId,
        name: 'Room Booking',
        price: 149.99,
        quantity: checkOutDate.difference(checkInDate).inDays, 
        productId: '',
      ),
    ];
    
    final subtotal = orderItems.fold(0.0, (sum, item) => sum + item.price);
    final tax = subtotal * 0.08;
    final total = subtotal + tax;
    
    final order = Order(
      id: orderId,
      businessId: businessId,
      userId: 'sample_user',
      resourceId: roomId,
      items: orderItems,
      status: OrderStatus.confirmed, // Using OrderStatus enum instead of string
      subtotal: subtotal,
      tax: tax,
      total: total,
      specialInstructions: i == 0 ? 'Late check-in (after 8pm)' : null,
      isDelivery: false,
      peopleCount: 2,
      createdAt: now.subtract(Duration(days: 5 - i)), paymentMethod: '',
    );
    
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('orders')
        .doc(orderId)
        .set(order.toFirestore());
    
    // Create a reservation/booking
    final reservation = Reservation(
      id: bookingId,
      businessId: businessId,
      resourceId: roomId,
      userId: 'sample_user',
      userName: 'Jane Smith',
      userEmail: 'jane.smith@example.com',
      userPhone: '+1234567890',
      date: checkInDate,
      timeSlot: 'booking',
      partySize: 2,
      status: 'confirmed',
      specialRequests: i == 0 ? 'High floor requested' : '',
    );
    
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('reservations')
        .doc(bookingId)
        .set({
          ...reservation.toFirestore(),
          'checkOutDate': CloudFireStore.Timestamp.fromDate(checkOutDate),
          'orderId': orderId,
          'numberOfNights': checkOutDate.difference(checkInDate).inDays,
        });
  }
}
}
