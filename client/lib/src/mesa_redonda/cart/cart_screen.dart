import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final bool isAuthenticated;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.isAuthenticated,
  });

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cartItems;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _cartItems = widget.cartItems;
    _calculateTotal();
  }

  void _calculateTotal() {
    _totalPrice = _cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
      _calculateTotal();
    });
  }

  void _saveForLater(int index) {
    if (widget.isAuthenticated) {
      setState(() {
        _cartItems.removeAt(index);
        _calculateTotal();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item saved for later!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please sign in to save items for later.')),
      );
    }
  }

  String _getStockStatus() {
    // if (item['inStock']) {
    //   return 'In Stock';
    // } else if (item['minOrderQuantity'] != null) {
    //   return 'Requires minimum order of ${item['minOrderQuantity']}';
    // } else if (item['orderBefore'] != null) {
    return 'Order before 22/02/2023';
    // } else {
    //   return 'Out of Stock';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Carrito'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 450;

          return Column(
            children: [
              SizedBox(
                height: constraints.maxHeight - 100,
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _cartItems[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Section
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  item["img"],
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              const SizedBox(width: 16.0),

                              // Details Section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["title"],
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      item["address"],
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      _getStockStatus(),
                                      //   style: TextStyle(
                                      //     fontSize: 12.0,
                                      //     color: item['inStock']
                                      //         ? Colors.green
                                      //         : Colors.red,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      "\$${item["price"].toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          // Quantity and Remove/Save buttons under image
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Quantity control under the image
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (item['quantity'] > 1) {
                                          item['quantity']--;
                                        }
                                        _calculateTotal();
                                      });
                                    },
                                  ),
                                  Text('${item["quantity"]}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        item['quantity']++;
                                        _calculateTotal();
                                      });
                                    },
                                  ),
                                ],
                              ),

                              // Remove and Save for later buttons
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _removeItem(index),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  if (widget.isAuthenticated)
                                    TextButton(
                                      onPressed: () => _saveForLater(index),
                                      child: const Text('Save for later'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _buildTotalSection(),
              ElevatedButton(
                onPressed: () {
                  Random random = Random();
                  // Navigate to the checkout screen
                  GoRouter.of(context).pushNamed(
                    AppRoute.checkout.name,
                    pathParameters: {
                      "detailItemId": (random.nextInt(40) + 510).toString(),
                      "cartItemId": (random.nextInt(460) + 4810).toString()
                    },
                  );
                },
                child: const Text('Proceed to Checkout'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Subtotal (${_cartItems.length} items): ',
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${_totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
