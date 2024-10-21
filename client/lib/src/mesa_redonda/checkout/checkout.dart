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
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/meal_subscription_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/location/location_capture.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String displayType; // 'platos', 'catering', or 'subscriptions'

  const CheckoutScreen({Key? key, required this.displayType}) : super(key: key);

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends ConsumerState<CheckoutScreen> {
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

  final int _deliveryFee = 200;
  final double _taxRate = 0.067;
  int _selectedPaymentMethod = 0;
  DateTime? _deliveryStartTime;
  DateTime? _deliveryEndTime;

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
  void dispose() {
    _cateringLocationController.dispose();
    _regularDishesLocationController.dispose();
    _mealSubscriptionLocationController.dispose();
    _cateringDateController.dispose();
    _mealSubscriptionDateController.dispose();
    _cateringTimeController.dispose();
    _mealSubscriptionTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch items based on displayType
    final List<CartItem> cartItems = ref.watch(cartProvider) ?? [];
    final CateringOrderItem? cateringOrder = ref.watch(cateringOrderProvider);
    final List<CartItem> mealItems =
        ref.watch(mealOrderProvider) ?? []; // Fetch meal subscriptions

    List<CartItem> itemsToDisplay = [];
    double totalPrice = 0.0;

    if (widget.displayType == 'platos') {
      itemsToDisplay = cartItems
          .where(
              (item) => !item.isMealSubscription && item.foodType != 'Catering')
          .toList();
      totalPrice = _calculateTotalPrice(itemsToDisplay);
    } else if (widget.displayType == 'subscriptions') {
      itemsToDisplay = mealItems; // Use mealItems from mealOrderProvider
      totalPrice = _calculateTotalPrice(itemsToDisplay);
    } else if (widget.displayType == 'catering') {
      if (cateringOrder != null) {
        totalPrice = cateringOrder.totalPrice ?? 0.0;
      } else {
        totalPrice = 0.0;
      }
    }

    // Check if there are items to display
    bool hasItemsToDisplay;
    if (widget.displayType == 'platos' ||
        widget.displayType == 'subscriptions') {
      hasItemsToDisplay = itemsToDisplay.isNotEmpty;
    } else if (widget.displayType == 'catering') {
      hasItemsToDisplay = (cateringOrder != null);
    } else {
      hasItemsToDisplay = false;
    }

    if (!hasItemsToDisplay) {
      // No items to display, pop the screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      // Return an empty container while the screen is being popped
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Completar Orden'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (widget.displayType == 'platos' &&
                  itemsToDisplay.isNotEmpty) ...[
                _buildSectionTitle(context, 'Platos'),
                _buildLocationField(
                  context,
                  _regularDishesLocationController,
                  _isRegularCateringAddressValid,
                  'regular',
                ),
                for (var item in itemsToDisplay)
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
              if (widget.displayType == 'subscriptions' &&
                  itemsToDisplay.isNotEmpty) ...[
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
                for (var item in itemsToDisplay)
                  MealSubscriptionItemView(
                    item: item,
                    onConsumeMeal: () => ref
                        .read(mealOrderProvider.notifier)
                        .consumeMeal(item.title),
                    onRemoveFromCart: () => ref
                        .read(mealOrderProvider.notifier)
                        .removeFromCart(item.id),
                  ),
              ],
              if (widget.displayType == 'catering' &&
                  cateringOrder != null) ...[
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
                CateringCartItemView(
                  order: cateringOrder,
                  onRemoveFromCart: () => ref
                      .read(cateringOrderProvider.notifier)
                      .clearCateringOrder(),
                ),
              ],
              const SizedBox(height: 16.0),
              _buildOrderSummary(totalPrice),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () =>
                      _processOrder(context, itemsToDisplay, cateringOrder),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalPrice(List<CartItem> items) {
    return items.fold<double>(
      0.0,
      (sum, item) =>
          sum + ((double.tryParse(item.pricing) ?? 0.0) * item.quantity),
    );
  }

  Future<void> _processOrder(BuildContext context, List<CartItem> items,
      CateringOrderItem? cateringOrder) async {
    final contactInfo = await _checkAndPromptForContactInfo(context);
    if (contactInfo == null || contactInfo.isEmpty) return;

    try {
      if (widget.displayType == 'platos') {
        await _saveOrderToFirestore(items, contactInfo);
        await _sendWhatsAppOrder(items, contactInfo);
      } else if (widget.displayType == 'subscriptions') {
        await _saveSubscriptionToFirestore(items, contactInfo);
        await _sendWhatsAppSubscriptionOrder(items, contactInfo);
      } else if (widget.displayType == 'catering' && cateringOrder != null) {
        await _saveCateringOrderToFirestore(cateringOrder, contactInfo);
        await _sendWhatsAppCateringOrder(cateringOrder, contactInfo);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing order: $error')),
      );
    }
  }

  // Save regular orders to Firestore
  Future<void> _saveOrderToFirestore(
      List<CartItem> items, Map<String, String>? contactInfo) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final email =
        FirebaseAuth.instance.currentUser?.email ?? contactInfo?['email'] ?? '';

    final firestore = FirebaseFirestore.instance;
    final orderDate = DateTime.now();

    for (var item in items) {
      if (item == null) continue;

      final double price = double.tryParse(item.pricing) ?? 0.0;
      final int quantity = item.quantity;

      final orderData = {
        'email': email,
        'userId': userId ?? 'anon',
        'orderType': item.foodType ?? 'Unknown',
        'status': 'pending',
        'orderDate': orderDate.toIso8601String(),
        'location': {
          'address': regularAddress ?? '',
          'latitude': _regularDishesLatitude ?? '',
          'longitude': _regularDishesLongitude ?? '',
        },
        'items': [item.toJson()],
        'paymentMethod': _paymentMethods[_selectedPaymentMethod],
        'totalAmount': price * quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await firestore.collection('orders').add(orderData);
    }
  }

  // Save subscriptions to Firestore
  Future<void> _saveSubscriptionToFirestore(
      List<CartItem> items, Map<String, String>? contactInfo) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final email =
        FirebaseAuth.instance.currentUser?.email ?? contactInfo?['email'] ?? '';

    final firestore = FirebaseFirestore.instance;
    final orderDate = DateTime.now();

    for (var item in items) {
      if (item == null) continue;

      final double price = double.tryParse(item.pricing) ?? 0.0;
      final int quantity = item.quantity;

      final subscriptionData = {
        'email': email,
        'userId': userId ?? 'anon',
        'planName': item.title,
        'status': 'pending',
        'orderDate': orderDate.toIso8601String(),
        'location': {
          'address': mealSubscriptionAddress ?? '',
          'latitude': _mealSubscriptionLatitude ?? '',
          'longitude': _mealSubscriptionLongitude ?? '',
        },
        'items': [item.toJson()],
        'paymentMethod': _paymentMethods[_selectedPaymentMethod],
        'totalAmount': price * quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await firestore.collection('subscriptions').add(subscriptionData);
    }
  }

  // Save catering orders to Firestore
  Future<void> _saveCateringOrderToFirestore(
      CateringOrderItem cateringOrder, Map<String, String>? contactInfo) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final email =
        FirebaseAuth.instance.currentUser?.email ?? contactInfo?['email'] ?? '';

    final firestore = FirebaseFirestore.instance;
    final orderDate = DateTime.now();

    final orderData = {
      'email': email,
      'userId': userId ?? 'anon',
      'orderType': 'Catering',
      'status': 'pending',
      'orderDate': orderDate.toIso8601String(),
      'location': {
        'address': cateringAddress ?? '',
        'latitude': _cateringLatitude ?? '',
        'longitude': _cateringLongitude ?? '',
      },
      'items': cateringOrder.dishes.map((dish) => dish.toJson()).toList(),
      'paymentMethod': _paymentMethods[_selectedPaymentMethod],
      'totalAmount': cateringOrder.totalPrice ?? 0.0,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await firestore.collection('orders').add(orderData);
  }

  // Send WhatsApp message for regular orders
  Future<void> _sendWhatsAppOrder(
      List<CartItem> items, Map<String, String>? contactInfo) async {
    const String phoneNumber = '+18493590832';
    final String orderDetails = _generateOrderDetails(items, contactInfo);
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

  // Send WhatsApp message for subscriptions
  Future<void> _sendWhatsAppSubscriptionOrder(
      List<CartItem> items, Map<String, String>? contactInfo) async {
    // Similar to _sendWhatsAppOrder but with subscription details
    // Implement as needed
    const String phoneNumber = '+18493590832';
    final String orderDetails = _generateOrderDetails(items, contactInfo);
    final String whatsappUrlMobile =
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(orderDetails)}';
    final String whatsappUrlWeb =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(orderDetails)}';

    if (await canLaunchUrl(Uri.parse(whatsappUrlMobile))) {
      await launchUrl(Uri.parse(whatsappUrlMobile));
      ref.read(mealOrderProvider.notifier).clearCart();
      GoRouter.of(context).goNamed(AppRoute.home.name);
    } else if (await canLaunchUrl(Uri.parse(whatsappUrlWeb))) {
      await launchUrl(Uri.parse(whatsappUrlWeb));
      ref.read(mealOrderProvider.notifier).clearCart();
      GoRouter.of(context).goNamed(AppRoute.home.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pude abrir WhatsApp')),
      );
    }
  }

  // Send WhatsApp message for catering orders
  Future<void> _sendWhatsAppCateringOrder(
      CateringOrderItem cateringOrder, Map<String, String>? contactInfo) async {
    const String phoneNumber = '+18493590832';
    final String orderDetails =
        _generateCateringOrderDetails(cateringOrder, contactInfo);
    final String whatsappUrlMobile =
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(orderDetails)}';
    final String whatsappUrlWeb =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(orderDetails)}';

    if (await canLaunchUrl(Uri.parse(whatsappUrlMobile))) {
      await launchUrl(Uri.parse(whatsappUrlMobile));
      ref.read(cateringOrderProvider.notifier).clearCateringOrder();
      GoRouter.of(context).goNamed(AppRoute.home.name);
    } else if (await canLaunchUrl(Uri.parse(whatsappUrlWeb))) {
      await launchUrl(Uri.parse(whatsappUrlWeb));
      ref.read(cateringOrderProvider.notifier).clearCateringOrder();
      GoRouter.of(context).goNamed(AppRoute.home.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pude abrir WhatsApp')),
      );
    }
  }

  // Generate order details for regular orders
  String _generateOrderDetails(
      List<CartItem> items, Map<String, String>? contactInfo) {
    final StringBuffer orderDetailsBuffer = StringBuffer();
    double total = 0.0;

    orderDetailsBuffer.writeln('*Detalles de la Orden*:');

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

    for (var item in items) {
      if (item == null) continue;

      final String title = item.title;
      final int quantity = item.quantity;
      final double price = double.tryParse(item.pricing) ?? 0.0;
      total += price * quantity;
      orderDetailsBuffer.writeln('$quantity x $title @ RD \$$price each');
    }

    final double tax = total * _taxRate;
    final double grandTotal = total + tax + _deliveryFee;

    orderDetailsBuffer.writeln('''
*Totales*:
Envío: RD \$$_deliveryFee
Impuestos: RD \$${tax.toStringAsFixed(2)}
Total: RD \$${grandTotal.toStringAsFixed(2)}
''');

    return orderDetailsBuffer.toString();
  }

  // Generate order details for catering orders
  String _generateCateringOrderDetails(
      CateringOrderItem cateringOrder, Map<String, String>? contactInfo) {
    final StringBuffer orderDetailsBuffer = StringBuffer();

    orderDetailsBuffer.writeln('*Detalles de la Orden de Catering*:');

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

    for (var dish in cateringOrder.dishes) {
      final String title = dish.title ?? 'Unknown Dish';
      final int quantity = dish.quantity ?? 0;
      final double price = double.tryParse(dish.pricing ?? '0') ?? 0.0;
      orderDetailsBuffer.writeln('$quantity x $title @ RD \$$price each');
    }

    final double total = cateringOrder.totalPrice ?? 0.0;
    final double tax = total * _taxRate;
    final double grandTotal = total + tax + _deliveryFee;

    orderDetailsBuffer.writeln('''
*Totales*:
Envío: RD \$$_deliveryFee
Impuestos: RD \$${tax.toStringAsFixed(2)}
Total: RD \$${grandTotal.toStringAsFixed(2)}
''');

    return orderDetailsBuffer.toString();
  }

  Future<Map<String, String>?> _checkAndPromptForContactInfo(
      BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.isAnonymous) {
      String? name, phone, email;
      bool showSignInScreen = false;
      bool? dialogResult;

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
                  content: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: Column(
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
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showSignInScreen = true;
                        });
                      },
                      child: const Text('Registrarse'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: const Text('Continuar'),
                    ),
                  ],
                );
              }
            },
          );
        },
      ).then((value) {
        dialogResult = value as bool?;
      });

      if (dialogResult != true) {
        return null;
      }

      if (!showSignInScreen) {
        return {
          'name': name ?? '',
          'phone': phone ?? '',
          'email': email ?? '',
        };
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    return {
      'name': user?.displayName ?? '',
      'phone': user?.phoneNumber ?? '',
      'email': user?.email ?? '',
    };
  }

  Widget _buildLocationField(BuildContext context,
      TextEditingController controller, bool isValid, String name) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    );
  }

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

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller,
      {required bool isCatering}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate == null) {
      debugPrint('Selección de fecha cancelada');
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime == null) {
      debugPrint('Selección de hora cancelada');
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

  Widget _buildOrderSummary(double totalPrice) {
    final double tax = totalPrice * _taxRate;
    final double orderTotal = totalPrice + _deliveryFee + tax;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 150),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 16.0),
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
              _buildOrderSummaryRow(
                  'Items', 'RD \$${totalPrice.toStringAsFixed(2)}'),
              _buildOrderSummaryRow('Envio', 'RD \$$_deliveryFee'),
              _buildOrderSummaryRow(
                  'Impuestos', 'RD \$${tax.toStringAsFixed(2)}'),
              const Divider(),
              _buildOrderSummaryRow(
                  'Order total', 'RD \$${orderTotal.toStringAsFixed(2)}',
                  isBold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 20),
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
      ),
    );
  }
}
