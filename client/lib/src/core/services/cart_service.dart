

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final Map<String, dynamic> options;
  final String? notes;
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.options = const {},
    this.notes,
  });
  
  double get totalPrice => price * quantity;
  
  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    Map<String, dynamic>? options,
    String? notes,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      options: options ?? this.options,
      notes: notes ?? this.notes,
    );
  }
}

class Cart {
  final List<CartItem> items;
  final String? specialInstructions;
  final String businessId;
  final String? resourceId; // Table ID, delivery address, etc.
  final bool isDelivery;
  final int peopleCount;
  
  Cart({
    this.items = const [],
    this.specialInstructions,
    required this.businessId,
    this.resourceId,
    this.isDelivery = false,
    this.peopleCount = 1,
  });
  
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get tax => subtotal * 0.16; // Example tax rate
  
  double get total => subtotal + tax;
  
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  Cart copyWith({
    List<CartItem>? items,
    String? specialInstructions,
    String? businessId,
    String? resourceId,
    bool? isDelivery,
    int? peopleCount,
  }) {
    return Cart(
      items: items ?? this.items,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      businessId: businessId ?? this.businessId,
      resourceId: resourceId ?? this.resourceId,
      isDelivery: isDelivery ?? this.isDelivery,
      peopleCount: peopleCount ?? this.peopleCount,
    );
  }
}

class CartService {
  // This would typically interact with local storage or a backend
  // For now, we'll keep it simple with in-memory operations
  
  Cart _cart = Cart(businessId: 'default');
  
  Cart get cart => _cart;
  
  void addItem(CartItem item) {
    final existingIndex = _cart.items.indexWhere((i) => 
      i.id == item.id && 
      i.options.toString() == item.options.toString()
    );
    
    if (existingIndex >= 0) {
      // Update existing item quantity
      final existingItem = _cart.items[existingIndex];
      final updatedItems = List<CartItem>.from(_cart.items);
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity
      );
      _cart = _cart.copyWith(items: updatedItems);
    } else {
      // Add new item
      _cart = _cart.copyWith(
        items: [..._cart.items, item]
      );
    }
  }
  
  void removeItem(int index) {
    final updatedItems = List<CartItem>.from(_cart.items);
    updatedItems.removeAt(index);
    _cart = _cart.copyWith(items: updatedItems);
  }
  
  void updateItemQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }
    
    final updatedItems = List<CartItem>.from(_cart.items);
    updatedItems[index] = updatedItems[index].copyWith(quantity: quantity);
    _cart = _cart.copyWith(items: updatedItems);
  }
  
  void clearCart() {
    _cart = _cart.copyWith(items: []);
  }
  
  void updateSpecialInstructions(String? instructions) {
    _cart = _cart.copyWith(specialInstructions: instructions);
  }
  
  void updateResourceId(String? resourceId) {
    _cart = _cart.copyWith(resourceId: resourceId);
  }
  
  void updateDeliveryOption(bool isDelivery) {
    _cart = _cart.copyWith(isDelivery: isDelivery);
  }
  
  void updatePeopleCount(int count) {
    _cart = _cart.copyWith(peopleCount: count);
  }
}