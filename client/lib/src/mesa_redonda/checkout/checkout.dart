import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/location/location_capture.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, Object>> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  TextEditingController _locationController = TextEditingController();
  String? _location;

  // Method to show the bottom sheet and get the location
  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the BottomSheet to grow
      builder: (context) {
        return LocationCaptureBottomSheet(
          onLocationCaptured: (latitude, longitude, address) {
            // Update the TextField with the captured location
            setState(() {
              _location = address;
              _locationController.text = address; // Set the TextField value
            });
          },
        );
      },
    );
  }

  // Method to clear the location field
  void _clearLocation() {
    setState(() {
      _location = null;
      _locationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Orden'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),

                        // Location Section with TextField and Edit Button
                        _buildSectionTitle(context, 'Ubicacion'),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                readOnly: true, // Make the field non-editable
                                onTap: () {
                                  _showLocationBottomSheet(
                                      context); // Open bottom sheet on tap
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: ColorsPaletteRedonda.deepBrown),
                                decoration: InputDecoration(
                                  hintText: 'Obten tu Ubicacion actual',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color:
                                              ColorsPaletteRedonda.deepBrown),
                                  filled: true,
                                  focusColor: ColorsPaletteRedonda.primary,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: ColorsPaletteRedonda.primary,
                                      width: 2.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 10.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            if (_location != null)
                              TextButton(
                                onPressed: _clearLocation, // Clear the field
                                child: const Text('Editar'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16.0),

                        // Payment Section
                        _buildSectionTitle(
                            context, 'Paying with Mastercard 8668'),
                        const SizedBox(height: 8.0),
                        _buildInfoRow(
                          context,
                          'Use a gift card, voucher, or promo code',
                          'Change',
                          () {},
                        ),
                        const SizedBox(height: 16.0),

                        // Delivery Date Section
                        _buildSectionTitle(
                            context, 'Arriving Sep 24, 2024 - Oct 15, 2024'),
                        const SizedBox(height: 8.0),
                        _buildInfoRow(
                          context,
                          'Tuesday, Sep 24 - Tuesday, Oct 15\n   \$6.90 - Delivery',
                          '',
                          null,
                        ),
                        const SizedBox(height: 16.0),

                        // Cart Items (built from cartItems list)
                        for (var cartItem in widget.cartItems)
                          CartItem(
                            img: cartItem['img'] as String,
                            title: cartItem['title'] as String,
                            description: cartItem['description'] as String,
                            pricing: cartItem['pricing'] as String,
                            ingredients:
                                cartItem['ingredients'] as List<String>,
                            isSpicy: cartItem['isSpicy'] as bool,
                            foodType: cartItem['foodType'] as String,
                            quantity: cartItem['quantity'] as int,
                            onRemove: () {}, // Add functionality as needed
                            onAdd: () {}, // Add functionality as needed
                          ),
                        const SizedBox(height: 16.0),

                        const Spacer(),

                        // Order Summary Card
                        _buildOrderSummary(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  // Info Row Widget with Edit Button
  Widget _buildInfoRow(BuildContext context, String info, String actionText,
      VoidCallback? onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            info,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        if (onEdit != null)
          TextButton(
            onPressed: onEdit,
            child: Text(actionText),
          ),
      ],
    );
  }

  // Order Summary Widget
  Widget _buildOrderSummary(BuildContext context) {
    final int totalItems = widget.cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );
    final double totalPrice = widget.cartItems.fold<double>(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item['pricing'] as String) ?? 0.0) *
              (item['quantity'] as int)),
    );

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorsPaletteRedonda.primary,
                  ),
            ),
            const SizedBox(height: 16.0),
            _buildOrderSummaryRow(
                context, 'Items ($totalItems)', '\$$totalPrice'),
            _buildOrderSummaryRow(context, 'Shipping & handling', '\$6.90'),
            _buildOrderSummaryRow(context, 'Estimated tax', '\$13.37'),
            const Divider(),
            _buildOrderSummaryRow(
                context, 'Order total', '\$${totalPrice + 6.90 + 13.37}',
                isBold: true),
            const SizedBox(height: 16.0),

            // Button to Place Order
            ElevatedButton(
              onPressed: () async {
                const String phoneNumber = '+18493590832'; // WhatsApp number
                final String orderDetails = _generateOrderDetails();
                final String whatsappUrlMobile =
                    'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(orderDetails)}';
                final String whatsappUrlWeb =
                    'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(orderDetails)}';
                if (await canLaunchUrl(Uri.parse(whatsappUrlMobile))) {
                  await launchUrl(Uri.parse(whatsappUrlMobile));
                } else if (await canLaunchUrl(Uri.parse(whatsappUrlWeb))) {
                  await launchUrl(Uri.parse(whatsappUrlWeb));
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open WhatsApp')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsPaletteRedonda.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                'Place your order',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Order Summary Row Widget
  Widget _buildOrderSummaryRow(BuildContext context, String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: ColorsPaletteRedonda.deepBrown),
          ),
        ],
      ),
    );
  }

  // Helper function to generate order details for WhatsApp
  String _generateOrderDetails() {
    final StringBuffer itemsBuffer = StringBuffer();
    double total = 0.0;

    for (var item in widget.cartItems) {
      final String title = item['title'] as String;
      final int quantity = item['quantity'] as int;
      final double price = item['price'] as double;

      total += price * quantity;
      itemsBuffer.writeln('$quantity x $title @ \$$price each');
    }

    const double shippingFee = 6.90;
    const double estimatedTax = 13.37;
    total += shippingFee + estimatedTax;

    final String location = _location != null ? _location! : 'Unknown Location';

    return '''
      Order Details:
      Items:
      $itemsBuffer
      Shipping: \$$shippingFee
      Estimated Tax: \$$estimatedTax
      Total: \$$total
      Deliver to: $location
      ''';
  }
}
