import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/catering_cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/location/location_capture.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  // final List<dynamic> items; // Add this to pass the current tab's items

  const CheckoutScreen({super.key});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
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

  TimeOfDay? _selectedCateringTime;
  TimeOfDay? _selectedMealSubscriptionTime;

  final int _deliveryFee = 200;
  final double _taxRate = 0.067;
  late TabController _tabController;
  int _selectedPaymentMethod = 0;
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

  Future<void> _saveOrderToFirestore(
      List<CartItem> cartItems, Map<String, String>? contactInfo) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final email =
        FirebaseAuth.instance.currentUser?.email ?? contactInfo?['email'];

    if (userId == null && contactInfo == null) {
      throw Exception("User not signed in and no contact info provided");
    }

    // Determine payment status based on payment method
    final paymentMethod = _paymentMethods[_selectedPaymentMethod];
    final paymentStatus = paymentMethod == 'Cardnet' ? 'pagado' : 'pendiente';

    // Separate items into orders and subscriptions
    final orders = cartItems.where((item) => !item.isMealSubscription).toList();
    final subscriptions =
        cartItems.where((item) => item.isMealSubscription).toList();

    final firestore = FirebaseFirestore.instance;
    final orderDate = DateTime.now();

    // Save orders to Firestore
    for (var order in orders) {
      final orderNumber = OrderNumberGenerator.generateOrderNumber();
      final orderData = {
        'orderNumber': orderNumber,
        'email': email,
        'userId': userId ?? 'anon',
        'name': contactInfo?['name'],
        'phone': contactInfo?['phone'],
        'orderType': order.foodType,
        'status': 'pendiente',
        'orderDate': orderDate.toIso8601String(),
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

    // Save subscriptions to Firestore
    for (var subscription in subscriptions) {
      final subscriptionOrderNumber =
          OrderNumberGenerator.generateOrderNumber();
      final subscriptionData = {
        'orderNumber': subscriptionOrderNumber,
        'email': email,
        'userId': userId ?? 'anon',
        'name': contactInfo?['name'],
        'phone': contactInfo?['phone'],
        'planName': subscription.id,
        'totalMeals': subscription.totalMeals,
        'remainingMeals': subscription.remainingMeals,
        'expirationDate': subscription.expirationDate.toIso8601String(),
        'status': 'pendiente',
        'orderDate': orderDate.toIso8601String(),
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

  Future<Map<String, String>?> _checkAndPromptForContactInfo(
      BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.isAnonymous) {
      String? name, phone, email;
      bool showSignInScreen = false; // Flag to control whether to show SignIn

      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setState) {
              if (showSignInScreen) {
                return AlertDialog(
                  title: const Text('Registro'),
                  content: SizedBox(
                    height: 400,
                    width: 400,
                    child: CustomSignInScreen(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                );
              } else {
                return AlertDialog(
                  title: const Text('Información de Contacto'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Proporcione su nombre, teléfono y correo opcional o registrese.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => name = value,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => phone = value,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => email = value,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showSignInScreen = true; // Switch to SignIn
                        });
                      },
                      child: const Text('Registrarse'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Continuar'),
                    ),
                  ],
                );
              }
            },
          );
        },
      );

      if (!showSignInScreen) {
        return {
          'name': name ?? '',
          'phone': phone ?? '',
          'email': email ?? '',
        };
      }
    }

    return {}; // Return empty map if user is already signed in
  }

  Future<void> _sendWhatsAppOrder(
      List<CartItem> cartItems, Map<String, String>? contactInfo) async {
    const String phoneNumber = '+18493590832';
    final String orderNumber = OrderNumberGenerator.generateOrderNumber();
    final String orderDetails =
        _generateOrderDetails(cartItems, contactInfo, orderNumber);
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
    });
  }

// In CheckoutScreen
  Future<void> _processOrder(
      BuildContext context, List<CartItem> cartItems) async {
    final contactInfo = await _checkAndPromptForContactInfo(context);
    if (contactInfo == null) return; // Exit if user cancels

    final mealPlanItem = cartItems.firstWhere(
      (item) => item.isMealSubscription,
      orElse: () => {} as CartItem,
    );

    // Check if meal plan is available and discount eligible
    if (mealPlanItem.remainingMeals > 0) {
      for (var item in cartItems) {
        if (!item.isMealSubscription && item.foodType != 'Catering') {
          ref.read(cartProvider.notifier).consumeMeal(item.title);
          // Trigger in-app notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Consumed a meal from your plan for ${item.title}'),
              backgroundColor: Colors.green,
            ),
          );
          // Save meal consumption to Firebase
          await _recordMealConsumption(mealPlanItem.id, item);
        }
      }
    } else {
      // Prompt to buy a new plan
      _promptToBuyAnotherPlan(context);
      return; // Exit if no meal plan available or no remaining meals
    }

    // Proceed with original order saving logic
    try {
      await _saveOrderToFirestore(cartItems, contactInfo);
      await _sendWhatsAppOrder(cartItems, contactInfo);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing order: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Add method to prompt for new meal plan
  void _promptToBuyAnotherPlan(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Plan Renewal Required'),
          content: Text(
              'Your meal plan is out of meals. Would you like to buy another plan?'),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to meal plan purchasing flow
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Record meal consumption to Firebase
  Future<void> _recordMealConsumption(String mealPlanId, CartItem dish) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return; // Ensure user is authenticated

    final firestore = FirebaseFirestore.instance;
    final consumptionData = {
      'dishTitle': dish.title,
      'consumedAt': FieldValue.serverTimestamp(),
      'details': dish.toJson(),
    };

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('consumptions')
          .add(consumptionData);
    } catch (e) {
      // Retry and notify user if failure
      print('Failed to record consumption: $e');
    }
  }

  String _generateOrderDetails(List<CartItem> cartItems,
      Map<String, String>? contactInfo, String orderNumber) {
    final StringBuffer orderDetailsBuffer = StringBuffer();
    double total = 0.0;

    orderDetailsBuffer.writeln('*Detalles de la Orden*:');
    orderDetailsBuffer.writeln('*Número de Orden*: $orderNumber');

    if (contactInfo != null && contactInfo.isNotEmpty) {
      orderDetailsBuffer.writeln('*Información de Contacto*:');
      if (contactInfo['name']?.isNotEmpty ?? false) {
        orderDetailsBuffer.writeln('Nombre: ${contactInfo['name']}');
      }
      if (contactInfo['phone']?.isNotEmpty ?? false) {
        orderDetailsBuffer.writeln('Teléfono: ${contactInfo['phone']}');
      }
      if (contactInfo['email']?.isNotEmpty ?? false) {
        orderDetailsBuffer.writeln('Email: ${contactInfo['email']}');
      }
    }

    final StringBuffer cateringBuffer = StringBuffer();
    final StringBuffer regularDishesBuffer = StringBuffer();
    final StringBuffer mealSubscriptionBuffer = StringBuffer();

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

    if (cateringBuffer.isNotEmpty) {
      orderDetailsBuffer.writeln('''
      *Catering*:
      Ubicación: ${cateringAddress ?? 'No proporcionada'}
      Google Maps: ${_generateGoogleMapsLink(_cateringLatitude!, _cateringLongitude!)}
      Fecha: ${_cateringDateController.text}
      Hora: ${_cateringTimeController.text}
      $cateringBuffer
    ''');
    }

    if (regularDishesBuffer.isNotEmpty) {
      orderDetailsBuffer.writeln('''
      *Platos Regulares*:
      Ubicación: ${regularAddress ?? 'No proporcionada'}
      Google Maps: ${_generateGoogleMapsLink(_regularDishesLatitude!, _regularDishesLongitude!)}
      (Tiempo estimado de entrega: ${_formatTime(_deliveryStartTime!)} - ${_formatTime(_deliveryEndTime!)})
      $regularDishesBuffer
    ''');
    }

    if (mealSubscriptionBuffer.isNotEmpty) {
      orderDetailsBuffer.writeln('''
      *Suscripciones de Comidas*:
      Ubicación: ${mealSubscriptionAddress ?? 'No proporcionada'}
      Google Maps: ${_generateGoogleMapsLink(_mealSubscriptionLatitude!, _mealSubscriptionLongitude!)}
      Fecha: ${_mealSubscriptionDateController.text}
      Hora: ${_mealSubscriptionTimeController.text}
      $mealSubscriptionBuffer
    ''');
    }

    orderDetailsBuffer.writeln('''
    *Método de Pago*: ${_paymentMethods[_selectedPaymentMethod]}
    *Totales*:
    Envío: RD \$$_deliveryFee
    Impuestos: RD \$${tax.toStringAsFixed(2)}
    Total: RD \$${total.toStringAsFixed(2)}
  ''');

    return orderDetailsBuffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final List<CartItem> cartItems = ref.watch(
        cartProvider); // This contains the regular dishes and meal subscriptions
    final cateringOrder = ref.watch(
        cateringOrderProvider); // Fetch the catering order from the provider

    // Separate regular dishes and meal subscriptions
    final dishes = cartItems
        .where(
            (item) => !item.isMealSubscription && item.foodType != 'Catering')
        .toList();
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
                            'regular',
                          ),
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

                        // Catering Section
                        if (cateringOrder != null) ...[
                          _buildSectionTitle(context, 'Catering'),
                          _buildLocationField(
                            context,
                            _cateringLocationController,
                            _isCateringAddressValid,
                            'catering',
                          ),
                          _buildDateTimePicker(
                            context,
                            _cateringDateController,
                            _cateringTimeController,
                            isCatering: true,
                          ),
                          // Render CateringCartItemView for catering orders
                          CateringCartItemView(
                            order: cateringOrder,
                            onRemoveFromCart: () => ref
                                .read(cateringOrderProvider.notifier)
                                .clearCateringOrder(),
                          ),
                        ],

                        // Meal Subscription Section
                        if (mealSubscriptions.isNotEmpty) ...[
                          _buildSectionTitle(context, 'Subscripciones'),
                          _buildLocationField(
                            context,
                            _mealSubscriptionLocationController,
                            _isMealSubscriptionAddressValid,
                            'mealSubscription',
                          ),
                          _buildDateTimePicker(
                            context,
                            _mealSubscriptionDateController,
                            _mealSubscriptionTimeController,
                            isCatering: false,
                          ),
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

                        const Spacer(),
                        _buildOrderSummary(cartItems),
                        ElevatedButton(
                          onPressed: () => _processOrder(context, cartItems),
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
                fillColor: ColorsPaletteRedonda.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda.deepBrown1,
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
              fillColor: ColorsPaletteRedonda.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: ColorsPaletteRedonda.deepBrown1,
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
