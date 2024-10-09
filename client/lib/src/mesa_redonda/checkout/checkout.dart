import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/location/location_capture.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  // Separate location controllers for each order type
  final TextEditingController _cateringLocationController =
      TextEditingController();
  final TextEditingController _regularDishesLocationController =
      TextEditingController();
  final TextEditingController _mealSubscriptionLocationController =
      TextEditingController();

  final TextEditingController _cateringDateController = TextEditingController();
  final TextEditingController _mealSubscriptionDateController =
      TextEditingController();
  final TextEditingController _cateringTimeController = TextEditingController();
  final TextEditingController _mealSubscriptionTimeController =
      TextEditingController();

  DateTime? _selectedCateringDate;
  DateTime? _selectedMealSubscriptionDate;
  TimeOfDay? _selectedCateringTime;
  TimeOfDay? _selectedMealSubscriptionTime;

  final int _deliveryFee = 200;
  final double _taxRate = 0.067;
  late TabController _tabController;
  int _selectedPaymentMethod = 0; // Add a variable to track payment selection
  DateTime? _deliveryStartTime;
  DateTime? _deliveryEndTime;

  List<CartItem> dishes = [];
  List<CartItem> cateringItems = [];
  List<CartItem> mealSubscriptions = [];

  final List<String> _paymentMethods = [
    'Transferencias',
    'Pagos por WhatsApp',
    'Cardnet'
  ];

  // Address and Lat/Long variables for each order type
  String? cateringAddress;
  String? regularAddress;
  String? mealSubscriptionAddress;

  String? _cateringLatitude;
  String? _cateringLongitude;

  String? _mealSubscriptionLatitude;
  String? _mealSubscriptionLongitude;

  String? _regularDishesLatitude;
  String? _regularDishesLongitude;

  bool _isCateringAddressValid = true;
  bool _isMealSubscriptionAddressValid = true;
  bool _isRegularCateringAddressValid = true;

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

  String getPaymentMethodDescription(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return 'La transferencia es manual desde su cuenta bancaria a la nuestra.';
      case 1:
        return 'El pago por WhatsApp le llevará a WhatsApp para completar el pago.';
      case 2:
        return 'Con CARNET, puede pagar directamente con su tarjeta a través de la plataforma de transacciones CARNET.';
      default:
        return '';
    }
  }

  // Generate Google Maps link from lat/long
  String _generateGoogleMapsLink(String latitude, String longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }

  // Method to show the bottom sheet and get the location for any order type
  void _showLocationBottomSheet(BuildContext context,
      TextEditingController controller, String orderType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return LocationCaptureBottomSheet(
          onLocationCaptured: (latitude, longitude, address) {
            setState(() {
              controller.text = address;
              switch (orderType.toLowerCase()) {
                case 'catering':
                  cateringAddress = address;
                  _cateringLatitude = latitude;
                  _cateringLongitude = longitude;
                  _isCateringAddressValid = true;
                  break;
                case 'regular':
                  regularAddress = address;
                  _regularDishesLatitude = latitude;
                  _regularDishesLongitude = longitude;
                  _isRegularCateringAddressValid = true;
                  break;
                case 'mealsubscription':
                  mealSubscriptionAddress = address;
                  _mealSubscriptionLatitude = latitude;
                  _mealSubscriptionLongitude = longitude;
                  _isMealSubscriptionAddressValid = true;
                  break;
              }
            });
          },
        );
      },
    );
  }

  // Method to clear the location field for any order type
  void _clearLocation(TextEditingController controller) {
    setState(() {
      controller.clear();
    });
  }

  // Validation to check if all locations are provided
  bool _validateFields(List<CartItem> cartItems) {
    bool isValid = true;

    final List<CartItem> dishes = cartItems
        .where(
            (item) => !item.isMealSubscription && item.foodType != 'Catering')
        .toList();

    final List<CartItem> cateringItems =
        cartItems.where((item) => item.foodType == 'Catering').toList();

    final List<CartItem> mealSubscriptions =
        cartItems.where((item) => item.isMealSubscription).toList();

    if (cateringItems.isNotEmpty) {
      if (_cateringLocationController.text.isEmpty) {
        setState(() {
          _isCateringAddressValid = false;
        });
        isValid = false;
      }
    }

    if (dishes.isNotEmpty) {
      if (_regularDishesLocationController.text.isEmpty) {
        setState(() {
          _isRegularCateringAddressValid = false;
        });
        isValid = false;
      }
    }

    if (mealSubscriptions.isNotEmpty) {
      if (_mealSubscriptionLocationController.text.isEmpty) {
        setState(() {
          _isMealSubscriptionAddressValid = false;
        });
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _saveOrderToFirestore(List<CartItem> cartItems) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;

    if (userId == null) {
      throw Exception("User not signed in");
    }

    // Determine payment status based on payment method
    final paymentMethod = _paymentMethods[_selectedPaymentMethod];
    final paymentStatus = paymentMethod == 'Cardnet' ? 'pagado' : 'pendiente';

    // Separate items into orders and subscriptions
    final orders = cartItems.where((item) => !item.isMealSubscription).toList();
    final subscriptions =
        cartItems.where((item) => item.isMealSubscription).toList();

    // Prepare Firestore instances
    final firestore = FirebaseFirestore.instance;
    final orderDate =
        DateTime.now(); // Capture the current date and time as the order date

    // Save orders to the orders collection
    for (var order in orders) {
      final orderNumber = OrderNumberGenerator.generateOrderNumber();
      final orderData = {
        'orderNumber': orderNumber,
        'email': email,
        'userId': userId,
        'orderType': order.foodType,
        'status': 'pendiente', // Set initial status to 'pendiente'
        'orderDate': orderDate.toIso8601String(), // Save order date
        'location': {
          'address':
              order.foodType == 'Catering' ? cateringAddress : regularAddress,
          'latitude': order.foodType == 'Catering'
              ? _cateringLatitude
              : _regularDishesLatitude,
          'longitude': order.foodType == 'Catering'
              ? _cateringLongitude
              : _regularDishesLongitude,
        },
        'items': [order.toJson()],
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'totalAmount': double.parse(order.pricing) * order.quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await firestore.collection('orders').add(orderData);
    }

    // Save subscriptions to the subscriptions collection
    for (var subscription in subscriptions) {
      final subscriptionOrderNumber =
          OrderNumberGenerator.generateOrderNumber();
      final subscriptionData = {
        'orderNumber': subscriptionOrderNumber,
        'email': email,
        'userId': userId,
        'planName': subscription.id,
        'totalMeals': subscription.totalMeals,
        'remainingMeals': subscription.remainingMeals,
        'expirationDate': subscription.expirationDate.toIso8601String(),
        'status': 'pendiente', // Set initial status to 'pendiente'
        'orderDate': orderDate.toIso8601String(), // Save order date
        'location': {
          'address': mealSubscriptionAddress,
          'latitude': _mealSubscriptionLatitude,
          'longitude': _mealSubscriptionLongitude,
        },
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'totalAmount': double.parse(subscription.pricing),
        'timestamp': FieldValue.serverTimestamp(),
      };
      await firestore.collection('subscriptions').add(subscriptionData);
    }
  }

  Future<void> _sendWhatsAppOrder(List<CartItem> cartItems) async {
    if (_validateFields(cartItems)) {
      await _saveOrderToFirestore(cartItems);

      const String phoneNumber = '+18493590832';
      final String orderDetails = _generateOrderDetails(cartItems);
      final String whatsappUrlMobile =
          'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(orderDetails)}';
      final String whatsappUrlWeb =
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(orderDetails)}';

      if (await canLaunchUrl(Uri.parse(whatsappUrlMobile))) {
        await launchUrl(Uri.parse(whatsappUrlMobile));
        ref.read(cartProvider.notifier).clearCart();
        GoRouter.of(context).goNamed(AppRoute.home.name);
      } else if (await canLaunchUrl(Uri.parse(whatsappUrlWeb))) {
        await launchUrl(Uri.parse(whatsappUrlWeb));
        ref.read(cartProvider.notifier).clearCart();
        GoRouter.of(context).goNamed(AppRoute.home.name);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pude abrir WhatsApp')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos requeridos.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime); // e.g., 6:45 PM
  }

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller,
      {required bool isCatering}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate == null) {
      debugPrint('Seleccion de fecha cancelada');
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedTime == null) {
      debugPrint('Seleccion de tiempo cancelada');
      return;
    }

    final DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      final formattedDateTime =
          DateFormat('yyyy-MM-dd – HH:mm').format(selectedDateTime);
      controller.text = formattedDateTime;

      if (isCatering) {
        _selectedCateringDate = selectedDateTime;
      } else {
        _selectedMealSubscriptionDate = selectedDateTime;
      }
    });
  }

  // Helper function to generate order details for WhatsApp
  String _generateOrderDetails(List<CartItem> cartItems) {
    final StringBuffer cateringBuffer = StringBuffer();
    final StringBuffer regularDishesBuffer = StringBuffer();
    final StringBuffer mealSubscriptionBuffer = StringBuffer();
    double total = 0.0;

    for (var item in cartItems) {
      final String title = item.title;
      final int quantity = item.quantity;
      final double price = double.parse(item.pricing);
      total += price * quantity;

      if (item.foodType == 'Catering') {
        cateringBuffer.writeln('$quantity x $title @ RD \$$price each');
      } else if (!item.isMealSubscription) {
        regularDishesBuffer.writeln('$quantity x $title @ RD \$$price each');
      } else {
        mealSubscriptionBuffer.writeln('$quantity x $title @ RD \$$price each');
      }
    }

    final double tax = total * _taxRate;
    total += tax + _deliveryFee;

    String cateringGoogleMapsLink =
        _cateringLatitude != null && _cateringLongitude != null
            ? _generateGoogleMapsLink(_cateringLatitude!, _cateringLongitude!)
            : 'Not Available';

    String regularDishesGoogleMapsLink =
        _regularDishesLatitude != null && _regularDishesLongitude != null
            ? _generateGoogleMapsLink(
                _regularDishesLatitude!, _regularDishesLongitude!)
            : 'Not Available';

    String mealSubscriptionGoogleMapsLink =
        _mealSubscriptionLatitude != null && _mealSubscriptionLongitude != null
            ? _generateGoogleMapsLink(
                _mealSubscriptionLatitude!, _mealSubscriptionLongitude!)
            : 'Not Available';

    final StringBuffer orderDetailsBuffer = StringBuffer();

    orderDetailsBuffer.writeln('*Detalles de la Orden*:');

    if (cateringBuffer.isNotEmpty) {
      orderDetailsBuffer.writeln('''
    *Catering*:
    Ubicacion: ${cateringAddress ?? 'Not Provided'}
    Google Maps: $cateringGoogleMapsLink
    Fecha: ${_cateringDateController.text}
    Hora: ${_cateringTimeController.text}
    $cateringBuffer
    ''');
    }

    if (regularDishesBuffer.isNotEmpty) {
      orderDetailsBuffer.writeln('''
    *Regular Dishes*:
    Ubicacion: ${regularAddress ?? 'Not Provided'}
    Google Maps: $regularDishesGoogleMapsLink
    (Estimated delivery time: ${_formatTime(_deliveryStartTime!)} - ${_formatTime(_deliveryEndTime!)})
    $regularDishesBuffer
    ''');
    }

    if (mealSubscriptionBuffer.isNotEmpty) {
      orderDetailsBuffer.writeln('''
    *Meal Subscriptions*:
    Ubicacion: ${mealSubscriptionAddress ?? 'Not Provided'}
    Google Maps: $mealSubscriptionGoogleMapsLink
    Fecha: ${_mealSubscriptionDateController.text}
    Hora: ${_mealSubscriptionTimeController.text}
    $mealSubscriptionBuffer
    ''');
    }

    orderDetailsBuffer.writeln('''
    *Metodo de Pago*: ${_paymentMethods[_selectedPaymentMethod]}
    *Totales*:
    Envio: RD \$$_deliveryFee
    Impuestos: RD \$${tax.toStringAsFixed(2)}
    Total: RD \$${total.toStringAsFixed(2)}
  ''');

    return orderDetailsBuffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final dishes = cartItems
        .where(
            (item) => !item.isMealSubscription && item.foodType != 'Catering')
        .toList();
    final cateringItems =
        cartItems.where((item) => item.foodType == 'Catering').toList();
    final mealSubscriptions =
        cartItems.where((item) => item.isMealSubscription).toList();

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
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

                        // Regular Dishes Section
                        if (dishes.isNotEmpty) ...[
                          _buildSectionTitle(context, 'Platos'),
                          _buildLocationField(
                              context,
                              _regularDishesLocationController,
                              _isRegularCateringAddressValid,
                              'regular'),
                          for (var item in dishes)
                            CartItemView(
                              img: item.img,
                              title: item.title,
                              description: item.description,
                              pricing: item.pricing,
                              offertPricing: item.offertPricing,
                              ingredients: item.ingredients,
                              isSpicy: item.isSpicy,
                              foodType: item.foodType,
                              quantity: item.quantity,
                              onRemove: () => ref
                                  .read(cartProvider.notifier)
                                  .decrementQuantity(item.title),
                              onAdd: () => ref
                                  .read(cartProvider.notifier)
                                  .incrementQuantity(item.title),
                              peopleCount: 0,
                              sideRequest: '',
                            ),
                        ],

                        // Catering Section with Date/Time Picker
                        if (cateringItems.isNotEmpty) ...[
                          _buildSectionTitle(context, 'Catering'),
                          _buildLocationField(
                              context,
                              _cateringLocationController,
                              _isCateringAddressValid,
                              'catering'),
                          _buildDateTimePicker(context, _cateringDateController,
                              _cateringTimeController,
                              isCatering: true),
                          for (var item in cateringItems)
                            CartItemView(
                              img: item.img,
                              title: item.title,
                              description: item.description,
                              pricing: item.pricing,
                              offertPricing: item.offertPricing,
                              ingredients: item.ingredients,
                              isSpicy: item.isSpicy,
                              foodType: item.foodType,
                              quantity: item.quantity,
                              onRemove: () => ref
                                  .read(cartProvider.notifier)
                                  .decrementCateringQuantity(item.title),
                              onAdd: () => ref
                                  .read(cartProvider.notifier)
                                  .incrementCateringQuantity(item.title),
                              peopleCount: item.peopleCount,
                              sideRequest: item.sideRequest,
                            ),
                        ],

                        // Meal Subscription Section with Date/Time Picker
                        if (mealSubscriptions.isNotEmpty) ...[
                          _buildSectionTitle(context, 'Subscripciones'),
                          _buildLocationField(
                              context,
                              _mealSubscriptionLocationController,
                              _isMealSubscriptionAddressValid,
                              'mealSubscription'),
                          _buildDateTimePicker(
                              context,
                              _mealSubscriptionDateController,
                              _mealSubscriptionTimeController,
                              isCatering: false),
                          for (var item in mealSubscriptions)
                            CartItemView(
                              img: item.img,
                              title: item.title,
                              description: item.description,
                              pricing: item.pricing,
                              offertPricing: item.offertPricing,
                              ingredients: item.ingredients,
                              isSpicy: item.isSpicy,
                              foodType: item.foodType,
                              quantity: item.quantity,
                              onRemove: () => ref
                                  .read(cartProvider.notifier)
                                  .decrementQuantity(item.title),
                              onAdd: () => ref
                                  .read(cartProvider.notifier)
                                  .incrementQuantity(item.title),
                              peopleCount: 0,
                              sideRequest: '',
                            ),
                        ],

                        // Payment Method Dropdown
                        // Payment Method Dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<int>(
                                dropdownColor: ColorsPaletteRedonda.white,
                                value: _selectedPaymentMethod,
                                items: List.generate(_paymentMethods.length,
                                    (index) {
                                  return DropdownMenuItem<int>(
                                    value: index,
                                    child: Text(
                                      _paymentMethods[index],
                                      style: const TextStyle(
                                          color: ColorsPaletteRedonda.primary),
                                    ),
                                  );
                                }),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Método de pago',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: ColorsPaletteRedonda.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  getPaymentMethodDescription(
                                      _selectedPaymentMethod),
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 231, 107, 24),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _buildOrderSummary(cartItems),

                        ElevatedButton(
                          onPressed: () => _sendWhatsAppOrder(cartItems),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsPaletteRedonda.primary,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: Text(
                            'Completar',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
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

  // Build the location field for any order type
  Widget _buildLocationField(BuildContext context,
      TextEditingController controller, bool isValid, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true,
              onTap: () => _showLocationBottomSheet(context, controller, name),
              style: Theme.of(context).textTheme.labelLarge,
              decoration: InputDecoration(
                hintText: 'Ingrese Ubicación',
                filled: true,
                fillColor:
                    ColorsPaletteRedonda.white, // Gray background when filled
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda
                        .deepBrown1, // Red border when not selected
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda
                        .primary, // Black border when focused
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(
      BuildContext context,
      TextEditingController dateController,
      TextEditingController timeController,
      {required bool isCatering}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCatering
                ? 'Selecciona la fecha y hora de tu catering'
                : 'Selecciona la fecha y hora de tu entrega',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          TextField(
            style: Theme.of(context).textTheme.labelLarge,
            controller: dateController,
            readOnly: true,
            onTap: () => _selectDateTime(context, dateController,
                isCatering: isCatering),
            decoration: InputDecoration(
              hintText:
                  isCatering ? '2024-11-23 - 13:00' : '2024-11-23 - 13:00',
              filled: true,
              fillColor:
                  ColorsPaletteRedonda.white, // Gray background when filled
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: ColorsPaletteRedonda
                      .deepBrown1, // Red border when not selected
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color:
                      ColorsPaletteRedonda.primary, // Black border when focused
                  width: 2.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrderSummary(List<CartItem> cartItems) {
    final int totalItems =
        cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final double totalPrice = cartItems.fold<double>(
        0.0,
        (sum, item) =>
            sum + ((double.tryParse(item.pricing) ?? 0.0) * item.quantity));
    final double tax = totalPrice * _taxRate;
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
          ],
        ),
      ),
    );
  }

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
}
