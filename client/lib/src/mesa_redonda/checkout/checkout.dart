import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/date_time_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/text_capitalization.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/catering_cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/meal_subscription_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/providers/validation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/screens/order_success_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/services/order_details_generator.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/services/order_processor.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/widgets/catering_checkout.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/widgets/date_time_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/widgets/meal_plan_checkout.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/widgets/order_summary.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/widgets/payment_method_dropdown.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/widgets/platos_checkout.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/checkout/widgets/quote_checkout.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/location/location_capture.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/prompt_dialogs/contact_info_dialog.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String displayType; // 'platos', 'catering', or 'subscriptions'

  const CheckoutScreen({super.key, required this.displayType});

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

  int _selectedPaymentMethod = 0; // Variable to track payment selection
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
 
  String? name, phone, email;
  bool showSignInScreen = false;
  bool? dialogResult;

  // Add this to your state class
  bool _isProcessingOrder = false;

  // Add these to your state class
  final ScrollController _scrollController = ScrollController();

  // Add these to your state class variables
  bool _isNameValid = true;
  bool _isPhoneValid = true;
  bool _isEmailValid = true;

  @override
  void dispose() {
    _scrollController.dispose();
    _cateringLocationController.dispose();
    _regularDishesLocationController.dispose();
    _mealSubscriptionLocationController.dispose();
    _cateringDateController.dispose();
    _mealSubscriptionDateController.dispose();
    _cateringTimeController.dispose();
    _mealSubscriptionTimeController.dispose();
    super.dispose();
  }

  double _calculateCateringTotalPrice(CateringOrderItem? cateringOrder) {
    if (cateringOrder == null) return 0.0;
    double sum = 0.0;
    for (var dish in cateringOrder.dishes) {
      // dish.pricing * dish.quantity
      sum += dish.pricing * dish.quantity;
    }
    return sum;
  }

 (List<CartItem>, double) _getItemsAndTotalPrice(
    List<CartItem> cartItems,
    List<CartItem> mealItems,
    CateringOrderItem? cateringOrder,
    CateringOrderItem? cateringQuote,
  ) {
    List<CartItem> itemsToDisplay = [];
    double totalPrice = 0.0;

    switch (widget.displayType) {
      case 'platos':
        itemsToDisplay = cartItems
            .where(
                (item) => !item.isMealSubscription && item.foodType != 'Catering')
            .toList();
        totalPrice = _calculateTotalPrice(itemsToDisplay);
        break;
      case 'subscriptions':
        itemsToDisplay = mealItems;
        totalPrice = _calculateTotalPrice(itemsToDisplay);
        break;
      case 'catering':
        itemsToDisplay = [];
        totalPrice = cateringOrder != null
            ? _calculateCateringTotalPrice(cateringOrder)
            : 0.0;
        break;
      case 'quote':
        itemsToDisplay = [];
        totalPrice = cateringQuote != null
            ? _calculateCateringTotalPrice(cateringQuote)
            : 0.0;
        break;
      default:
        break;
    }

    return (itemsToDisplay, totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    // Fetch items based on displayType
    final List<CartItem> cartItems = ref.watch(cartProvider) ?? [];
    final CateringOrderItem? cateringOrder = ref.watch(cateringOrderProvider);
    final CateringOrderItem? cateringQuote = ref.watch(manualQuoteProvider);
    final List<CartItem> mealItems =
        ref.watch(mealOrderProvider) ?? []; // Fetch meal subscriptions

     final (itemsToDisplay, totalPrice) = _getItemsAndTotalPrice(
      cartItems,
      mealItems,
      cateringOrder,
      cateringQuote,
    );
 
  return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text( widget.displayType == 'quote'
                              ? 'Confirmar Cotización'
                              : 'Confirmar Orden', ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
            _buildCheckoutContent(), 
              const SizedBox(height: 16),
                if (widget.displayType != 'quote') 
              OrderSummary(
                totalPrice: totalPrice,
                deliveryFee: _deliveryFee.toDouble(),
                taxRate: _taxRate, orderType: widget.displayType,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _isProcessingOrder
                      ? null
                      : () async {
                          setState(() {
                            _isProcessingOrder = true;
                          });
                          await _processOrder(
                            context,
                            itemsToDisplay,
                            cateringOrder,
                            cateringQuote,
                          );
                          setState(() {
                            _isProcessingOrder = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessingOrder
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.displayType == 'quote'
                              ? 'Enviar Cotización'
                              : 'Completar Orden',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  

   Widget _buildCheckoutContent() {
    final paymentDropdown = _buildPaymentMethodDropdown();

    // Fetch items based on displayType
    final List<CartItem> cartItems = ref.watch(cartProvider) ?? [];
    final CateringOrderItem? cateringOrder = ref.watch(cateringOrderProvider);
    final CateringOrderItem? cateringQuote = ref.watch(manualQuoteProvider);
    final List<CartItem> mealItems = ref.watch(mealOrderProvider) ?? [];

    switch (widget.displayType) {
      case 'platos':
        return PlatosCheckout(
          items: cartItems,
          locationController: _regularDishesLocationController,
          onLocationTap: _showLocationBottomSheet,
          paymentMethodDropdown: paymentDropdown,
        );
      case 'catering':
        if (cateringOrder == null) {
          return const Center(
            child: Text('No hay orden de catering disponible'),
          );
        }
        return CateringCheckout(
          order: cateringOrder,
          locationController: _cateringLocationController,
          dateController: _cateringDateController,
          timeController: _cateringTimeController,
          onLocationTap: _showLocationBottomSheet,
          onDateTimeTap: _selectDateTime,
          paymentMethodDropdown: paymentDropdown,
        );
      case 'quote':
        if (cateringQuote == null) {
          return const Center(
            child: Text('No hay cotización disponible'),
          );
        }
        return QuoteCheckout(
          quote: cateringQuote,
          locationController: _cateringLocationController,
          dateController: _cateringDateController,
          timeController: _cateringTimeController,
          onLocationTap: _showLocationBottomSheet,
          onDateTimeTap: _selectDateTime,
          paymentMethodDropdown: paymentDropdown,
        );
      case 'subscriptions':
        return MealPlanCheckout(
          items: mealItems,
          locationController: _mealSubscriptionLocationController,
          dateController: _mealSubscriptionDateController,
          timeController: _mealSubscriptionTimeController,
          onLocationTap: _showLocationBottomSheet,
          onDateTimeTap: _selectDateTime,
          paymentMethodDropdown: paymentDropdown,
        );
      default:
        return const SizedBox.shrink();
    }
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

  double _calculateTotalPrice(List<CartItem> items) {
    return items.fold<double>(
      0.0,
      (sum, item) =>
          sum + ((double.tryParse(item.pricing) ?? 0.0) * item.quantity),
    );
  }

  Future<void> _processOrder(BuildContext context, List<CartItem> items,
      CateringOrderItem? cateringOrder, CateringOrderItem? cateringQuote) async {
    // Store context related objects before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final goRouter = GoRouter.of(context);

    if (_validateFields()) {
      final contactInfo = await ContactInfoDialog.show(context);
      if (contactInfo == null || contactInfo.isEmpty) return;

      final processor = OrderProcessor(ref, context);
      final paymentMethod = _paymentMethods[_selectedPaymentMethod];

      try {
        if (widget.displayType == 'platos') {
          await processor.processRegularOrder(
            items,
            contactInfo,
            paymentMethod,
            {
              'address': regularAddress ?? '',
              'latitude': _regularDishesLatitude ?? '',
              'longitude': _regularDishesLongitude ?? '',
            },
            {
              'date': _mealSubscriptionDateController.text,
              'time': _mealSubscriptionTimeController.text,
            },
            _generateOrderDetails(items, contactInfo),
          );
        } else if (widget.displayType == 'subscriptions') {
          await processor.processSubscriptionOrder(
            items,
            contactInfo,
            paymentMethod,
            {
              'address': mealSubscriptionAddress ?? '',
              'latitude': _mealSubscriptionLatitude ?? '',
              'longitude': _mealSubscriptionLongitude ?? '',
            },
            {
              'date': _mealSubscriptionDateController.text,
              'time': _mealSubscriptionTimeController.text,
            },
            _generateSubscriptionOrderDetails(items, contactInfo),
          );
        } else if (widget.displayType == 'catering' && cateringOrder != null) {
          await processor.processCateringOrder(
            cateringOrder,
            contactInfo,
            paymentMethod,
            {
              'address': cateringAddress ?? '',
              'latitude': _cateringLatitude ?? '',
              'longitude': _cateringLongitude ?? '',
            },
            {
              'date': _cateringDateController.text,
              'time': _cateringTimeController.text,
            },
            _generateCateringOrderDetails(cateringOrder, contactInfo),
          );
        } else if (widget.displayType == 'quote' && cateringQuote != null) {
          await processor.processQuoteOrder(
            cateringQuote,
            contactInfo,
            paymentMethod,
            {
              'address': cateringAddress ?? '',
              'latitude': _cateringLatitude ?? '',
              'longitude': _cateringLongitude ?? '',
            },
            {
              'date': _cateringDateController.text,
              'time': _cateringTimeController.text,
            },
            _generateCateringQuoteOrderDetails(cateringQuote, contactInfo),
          );
        }

        // Show success screen
        if (!mounted) return;
        
        await navigator.push(
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
              orderType: widget.displayType,
            ),
          ),
        );

        // Pop back to home after success screen is dismissed
        if (!mounted) return;
        if (goRouter.canPop()) {
          goRouter.pop();
        }
      } catch (error) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error processing order: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

 
 

  // Send WhatsApp message for catering orders
  // Future<void> _sendWhatsAppCateringOrder(
  //     CateringOrderItem cateringOrder, Map<String, String>? contactInfo) async {
  //   final String orderDetails =
  //       _generateCateringOrderDetails(cateringOrder, contactInfo);

  //   const String phoneNumber = '+18493590832';

  //   final String whatsappUrlMobile =
  //       'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(orderDetails)}';
  //   final String whatsappUrlWeb =
  //       'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(orderDetails)}';

  //   if (await canLaunchUrl(Uri.parse(whatsappUrlMobile))) {
  //     await launchUrl(Uri.parse(whatsappUrlMobile));
  //   } else if (await canLaunchUrl(Uri.parse(whatsappUrlWeb))) {
  //     await launchUrl(Uri.parse(whatsappUrlWeb));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('No pude abrir WhatsApp'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }

  //   _clearCateringAndPop();
  // }

  // Generate order details for regular orders
  // Remove the old order detail generation methods and replace with:
  String _generateOrderDetails(
      List<CartItem> items, Map<String, String>? contactInfo) {
    
    final generator = OrderDetailsGenerator(
      taxRate: _taxRate,
      deliveryFee: _deliveryFee,
      paymentMethods: _paymentMethods,
      selectedPaymentMethod: _selectedPaymentMethod,
    );

    return generator.generateRegularOrder(
      items: items,
      contactInfo: contactInfo,
      address: regularAddress ?? 'No proporcionada',
      latitude: _regularDishesLatitude ?? '',
      longitude: _regularDishesLongitude ?? '',
      date: _mealSubscriptionDateController.text,
      time: _mealSubscriptionTimeController.text,
    );
  }

  String _generateSubscriptionOrderDetails(
      List<CartItem> items, Map<String, String>? contactInfo) {
    final generator = OrderDetailsGenerator(
      taxRate: _taxRate,
      deliveryFee: _deliveryFee,
      paymentMethods: _paymentMethods,
      selectedPaymentMethod: _selectedPaymentMethod,
    );

    return generator.generateSubscriptionOrder(
      items: items,
      contactInfo: contactInfo,
      address: mealSubscriptionAddress ?? 'No proporcionada',
      latitude: _mealSubscriptionLatitude ?? '',
      longitude: _mealSubscriptionLongitude ?? '',
      date: _mealSubscriptionDateController.text,
      time: _mealSubscriptionTimeController.text,
    );
  }

  String _generateCateringOrderDetails(
      CateringOrderItem order, Map<String, String>? contactInfo) {
    final generator = OrderDetailsGenerator(
      taxRate: _taxRate,
      deliveryFee: _deliveryFee,
      paymentMethods: _paymentMethods,
      selectedPaymentMethod: _selectedPaymentMethod,
    );

    return generator.generateCateringOrder(
      order: order,
      contactInfo: contactInfo,
      address: cateringAddress ?? 'No proporcionada',
      latitude: _cateringLatitude ?? '',
      longitude: _cateringLongitude ?? '',
      date: _cateringDateController.text,
      time: _cateringTimeController.text,
    );
  }

  String _generateCateringQuoteOrderDetails(
      CateringOrderItem quote, Map<String, String>? contactInfo) {
    final generator = OrderDetailsGenerator(
      taxRate: _taxRate,
      deliveryFee: _deliveryFee,
      paymentMethods: _paymentMethods,
      selectedPaymentMethod: _selectedPaymentMethod,
    );

    return generator.generateCateringOrder(
      order: quote,
      contactInfo: contactInfo,
      address: cateringAddress ?? 'No proporcionada',
      latitude: _cateringLatitude ?? '',
      longitude: _cateringLongitude ?? '',
      date: _cateringDateController.text,
      time: _cateringTimeController.text,
      isQuote: true,
    );
  }


  bool _validateFields() {
    bool isValid = true;
    double scrollOffset = 0;

    switch (widget.displayType) {
      case 'platos':
        // Regular dishes only need location validation
        if (_regularDishesLocationController.text.isEmpty) {
          ref
              .read(validationProvider('regular').notifier)
              .setValid('location', false);
          isValid = false;
          scrollOffset = 0;
        } else {
          ref
              .read(validationProvider('regular').notifier)
              .setValid('location', true);
        }
        break;

      case 'subscriptions':
        // Validate location
        if (_mealSubscriptionLocationController.text.isEmpty) {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('location', false);
          isValid = false;
          scrollOffset = _scrollController.position.maxScrollExtent * 0.0;
        } else {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('location', true);
        }

        // Validate date
        if (_mealSubscriptionDateController.text.isEmpty) {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('date', false);
          isValid = false;
          scrollOffset = _scrollController.position.maxScrollExtent * 0.0;
        } else {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('date', true);
        }

        // Validate time
        if (_mealSubscriptionTimeController.text.isEmpty) {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('time', false);
          isValid = false;
          scrollOffset = _scrollController.position.maxScrollExtent * 0.0;
        } else {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('time', true);
        }

        // Show error message if needed
        if (!isValid) {
          _showValidationError('subscription');
        }
        break;

      case 'catering':
        // Validate location
        if (_cateringLocationController.text.isEmpty) {
          ref
              .read(validationProvider('catering').notifier)
              .setValid('location', false);
          isValid = false;
          scrollOffset = _scrollController.position.maxScrollExtent * 0.0;
        } else {
          ref
              .read(validationProvider('catering').notifier)
              .setValid('location', true);
        }

        // Validate date
        if (_cateringDateController.text.isEmpty) {
          ref
              .read(validationProvider('catering').notifier)
              .setValid('date', false);
          isValid = false;
          scrollOffset = _scrollController.position.maxScrollExtent * 0.0;
        } else {
          ref
              .read(validationProvider('catering').notifier)
              .setValid('date', true);
        }

        // Validate time
        if (_cateringTimeController.text.isEmpty) {
          ref
              .read(validationProvider('catering').notifier)
              .setValid('time', false);
          isValid = false;
          scrollOffset = _scrollController.position.maxScrollExtent * 0.0;
        } else {
          ref
              .read(validationProvider('catering').notifier)
              .setValid('time', true);
        }

        // Show error message if needed
        if (!isValid) {
          _showValidationError('catering');
        }
        break;
    }

    if (!isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }

    return isValid;
  }

  void _showValidationError(String type) {
    String message = '';
    final validationState = ref.read(validationProvider(type));

    if (!validationState['location']!) {
      message += 'ubicación, ';
    }
    if (!validationState['date']!) {
      message += 'fecha, ';
    }
    if (!validationState['time']!) {
      message += 'hora, ';
    }

    if (message.isNotEmpty) {
      message = message.substring(0, message.length - 2); // Remove last comma
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor complete los siguientes campos: $message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLocationBottomSheet(BuildContext context,
      TextEditingController controller, String orderType) {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return LocationCaptureBottomSheet(
          onLocationCaptured: (latitude, longitude, address) {
            if (!mounted) return;
            
            setState(() {
              controller.text = address;
              switch (orderType.toLowerCase()) {
                case 'catering':
                  cateringAddress = address;
                  _cateringLatitude = latitude;
                  _cateringLongitude = longitude;
                  ref
                      .read(validationProvider('catering').notifier)
                      .setValid('location', true);
                  break;
                case 'regular':
                  regularAddress = address;
                  _regularDishesLatitude = latitude;
                  _regularDishesLongitude = longitude;
                  ref
                      .read(validationProvider('regular').notifier)
                      .setValid('location', true);
                  break;
                case 'mealsubscription':
                  mealSubscriptionAddress = address;
                  _mealSubscriptionLatitude = latitude;
                  _mealSubscriptionLongitude = longitude;
                  ref
                      .read(validationProvider('mealSubscription').notifier)
                      .setValid('location', true);
                  break;
              }
            });
          },
        );
      },
    );
  }
  
  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController dateController,
    TextEditingController timeController,
  ) async {
    if (!mounted) return;

    final type = dateController == _cateringDateController
        ? 'catering'
        : 'mealSubscription';

    await DateTimePicker2.show(
      context: context,
      dateController: dateController,
      timeController: timeController,
      onValidationUpdate: (field) {
        if (!mounted) return;
        ref.read(validationProvider(type).notifier).setValid(field, true);
      },
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return PaymentMethodDropdown(
      selectedMethod: _selectedPaymentMethod,
      onMethodSelected: (value) {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      paymentMethods: _paymentMethods,
      getDescription: getPaymentMethodDescription,
    );
  }

}
