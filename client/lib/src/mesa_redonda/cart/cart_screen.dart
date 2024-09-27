import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'cart_item.dart'; // Import the CartItem widget here

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
      _cartItems[index]['quantity']--;
      if (_cartItems[index]['quantity'] <= 0) {
        _cartItems.removeAt(index);
      }
      _calculateTotal();
    });
  }

  void _addItem(int index) {
    setState(() {
      _cartItems[index]['quantity']++;
      _calculateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 3,
        title: const Text('Carrito'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = _cartItems[index];

                      return CartItem(
                        img: item['img'],
                        title: item['title'],
                        description: item['description'],
                        pricing: item['pricing'].toString(),
                        offertPricing: item['offertPricing'],
                        ingredients: List<String>.from(item['ingredients']),
                        isSpicy: item['isSpicy'],
                        foodType: item['foodType'],
                        quantity: item['quantity'],
                        onRemove: () => _removeItem(index),
                        onAdd: () => _addItem(index),
                      );
                    },
                  ),
                ),
              ),
              _buildTotalSection(),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the checkout screen
                    GoRouter.of(context).goNamed(
                      AppRoute.homecheckout.name,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPaletteRedonda.primary,
                    foregroundColor: ColorsPaletteRedonda.white,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(
                    'Realizar pedido',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                      
                    ),
                  ),
                ),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color.fromARGB(255, 235, 66, 15),
                ),
          ),
          Text(
            '\$${_totalPrice.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorsPaletteRedonda.primary,
                ),
          ),
        ],
      ),
    );
  }
}
