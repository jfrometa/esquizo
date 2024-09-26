import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/location/location_capture.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/location/location_capture_maps.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, Object>> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController();
  String? _location; // Human-readable address
  String? _latitude; // Latitude for Google Maps
  String? _longitude; // Longitude for Google Maps
  late TabController _tabController;
  int _selectedPaymentMethod = 0;

  bool _isAddressValid = true; // Flag to track address validation
  final int _deliveryFee = 200; // Fixed delivery fee in RD
  final double _taxRate = 0.067; // 6.7% tax rate
  DateTime? _deliveryStartTime;
  DateTime? _deliveryEndTime;

  final List<String> _paymentMethods = [
    'Transferencias',
    'Cardnet WhatsApp',
    'Cardnet'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setDeliveryTime();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setDeliveryTime() {
    final now = DateTime.now();
    setState(() {
      _deliveryStartTime = now.add(const Duration(minutes: 40));
      _deliveryEndTime = now.add(const Duration(minutes: 60));
    });
  }

  // Method to show the bottom sheet and get the location and address
  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return LocationCaptureBottomSheet(
          onLocationCaptured: (latitude, longitude, address) {
            setState(() {
              _location = address;
              _latitude = latitude;
              _longitude = longitude;
              _locationController.text = address;
              _isAddressValid = true; // Reset validation on valid input
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
      _latitude = null;
      _longitude = null;
      _locationController.clear();
    });
  }

  // Helper function to format time in human-readable format
  String _formatTime(DateTime dateTime) {
    final format = DateFormat.jm(); // e.g., 6:45 PM
    return format.format(dateTime);
  }

  // Validation to check if the address is provided
  bool _validateFields() {
    if (_location == null || _location!.isEmpty) {
      setState(() {
        _isAddressValid = false;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
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
                                  readOnly: true,
                                  onTap: () {
                                    _showLocationBottomSheet(context);
                                  },
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color:
                                              ColorsPaletteRedonda.deepBrown),
                                  decoration: InputDecoration(
                                    hintText: 'Obten tu Ubicacion actual',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color:
                                                ColorsPaletteRedonda.deepBrown),
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color: _isAddressValid
                                            ? Colors.grey.shade300
                                            : Colors
                                                .red, // Red border if invalid
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color: _isAddressValid
                                            ? ColorsPaletteRedonda.primary
                                            : Colors
                                                .red, // Red border if invalid
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
                                  onPressed: _clearLocation,
                                  child: const Text('Editar'),
                                ),
                            ],
                          ),
                          if (!_isAddressValid) // Show error message if address is invalid
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Por favor, ingrese una dirección válida',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16.0),

                          // Payment Section with TabBar
                          _buildSectionTitle(context, 'Elige Método de Pago'),
                          const SizedBox(height: 8.0),
                          TabBar(
                            controller: _tabController,
                            indicatorColor: ColorsPaletteRedonda.primary,
                            onTap: (index) {
                              setState(() {
                                _selectedPaymentMethod = index;
                              });
                            },
                            tabs: [
                              _buildTab(context, 'Transferencias', 0),
                              _buildTab(context, 'Cardnet WhatsApp', 1),
                              _buildTab(context, 'Cardnet', 2),
                            ],
                          ),
                          const SizedBox(height: 16.0),

                          // Delivery Time Section
                          _buildSectionTitle(
                              context, 'Entrega estimada en 40 - 60 minutos'),
                          const SizedBox(height: 8.0),
                          Text(
                            'Llegada estimada entre ${_formatTime(_deliveryStartTime!)} y ${_formatTime(_deliveryEndTime!)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: ColorsPaletteRedonda.deepBrown),
                          ),
                          const SizedBox(height: 16.0),

                          // Cart Items
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
                              onRemove: () {},
                              onAdd: () {},
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

  // Helper to build each Tab
  Widget _buildTab(BuildContext context, String label, int index) {
    return Tab(
      child: Text(
        label,
        style: TextStyle(
          color: _selectedPaymentMethod == index
              ? ColorsPaletteRedonda.primary
              : ColorsPaletteRedonda.lightBrown,
          fontSize: 12,
        ),
      ),
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
    final double tax = totalPrice * _taxRate; // Calculate 6.7% tax
    final double orderTotal = totalPrice + _deliveryFee + tax;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de la Orden',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorsPaletteRedonda.primary,
                  ),
            ),
            const SizedBox(height: 16.0),
            _buildOrderSummaryRow(context, 'Items ($totalItems)',
                'RD \$${totalPrice.toStringAsFixed(2)}'),
            _buildOrderSummaryRow(context, 'Envio', 'RD \$$_deliveryFee'),
            _buildOrderSummaryRow(
                context, 'Impuestos', 'RD \$${tax.toStringAsFixed(2)}'),
            const Divider(),
            _buildOrderSummaryRow(
                context, 'Order total', 'RD \$${orderTotal.toStringAsFixed(2)}',
                isBold: true),
            const SizedBox(height: 16.0),

            // Place Order Button
            ElevatedButton(
              onPressed: () async {
                if (_validateFields()) {
                  setState(() {
                    _setDeliveryTime(); // Update the delivery time
                  });

                  const String phoneNumber = '+18493590832';
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
                        const SnackBar(
                            content: Text('Could not open WhatsApp')),
                      );
                    }
                  }
                } else {
                  // Highlight missing fields, if any
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in the required fields.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsPaletteRedonda.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                'Completar',
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
      itemsBuffer.writeln('$quantity x $title @ RD \$$price each');
    }

    final double tax = total * _taxRate;
    total += tax + _deliveryFee;

    final String location = _location != null ? _location! : 'Unknown Address';
    final String paymentMethod = _paymentMethods[_selectedPaymentMethod];

    return '''
      Detalles de la Orden:
      Articulos:
      $itemsBuffer
      Envio: RD \$$_deliveryFee
      Impuestos: RD \$${tax.toStringAsFixed(2)}
      Total: RD \$${total.toStringAsFixed(2)}
      Metodo de Pago: $paymentMethod
      Estimated Delivery: ${_formatTime(_deliveryStartTime!)} - ${_formatTime(_deliveryEndTime!)}
      Direccion: $location
      Google Maps Location: ${_latitude ?? 'N/A'}, ${_longitude ?? 'N/A'}
      ''';
  }
}
