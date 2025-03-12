import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/providers/validation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/screens/order_success_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/services/order_details_generator.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/services/order_processor.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/widgets/catering_checkout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/widgets/date_time_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/widgets/meal_plan_checkout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/widgets/order_summary.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/widgets/platos_checkout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/widgets/quote_checkout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/location/location_capture.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/prompt_dialogs/contact_info_dialog.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/manual_quote_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String displayType; // 'platos', 'catering', 'subscriptions', or 'quote'

  const CheckoutScreen({super.key, required this.displayType});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Controllers
  final TextEditingController _cateringLocationController = TextEditingController();
  final TextEditingController _regularDishesLocationController = TextEditingController();
  final TextEditingController _mealSubscriptionLocationController = TextEditingController();
  final TextEditingController _cateringDateController = TextEditingController();
  final TextEditingController _mealSubscriptionDateController = TextEditingController();
  final TextEditingController _cateringTimeController = TextEditingController();
  final TextEditingController _mealSubscriptionTimeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Constants
  final int _deliveryFee = 200;
  final double _taxRate = 0.067;

  // State variables
  int _currentStep = 0;
  int _selectedPaymentMethod = 0;
  final List<String> _paymentMethods = [
    'Transferencias',
    'Pagos por WhatsApp',
    'Cardnet'
  ];

  // Location data
  String? cateringAddress;
  String? regularAddress;
  String? mealSubscriptionAddress;

  String? _cateringLatitude;
  String? _cateringLongitude;
  String? _mealSubscriptionLatitude;
  String? _mealSubscriptionLongitude;
  String? _regularDishesLatitude;
  String? _regularDishesLongitude;
 
  // User data
  String? name, phone, email;
  bool showSignInScreen = false;
  bool? dialogResult;

  // Process state
  bool _isProcessingOrder = false;
  
  // Animation
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Validation state
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
            .where((item) => !item.isMealSubscription && item.foodType != 'Catering')
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
    // Get theme data
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Responsive layout sizing
    final screenSize = MediaQuery.sizeOf(context);
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;
    
    // Fetch items based on displayType
    final List<CartItem> cartItems = ref.watch(cartProvider) ?? [];
    final CateringOrderItem? cateringOrder = ref.watch(cateringOrderProvider);
    final CateringOrderItem? cateringQuote = ref.watch(manualQuoteProvider);
    final List<CartItem> mealItems = ref.watch(mealOrderProvider) ?? [];

    final (itemsToDisplay, totalPrice) = _getItemsAndTotalPrice(
      cartItems,
      mealItems,
      cateringOrder,
      cateringQuote,
    );
    
    // Calculate number of steps based on order type
    final int totalSteps = widget.displayType == 'quote' ? 2 : 3;

    // Build responsive layout
    Widget content;
    if (isDesktop) {
      // Desktop layout: Side-by-side checkout steps and summary
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left panel: Checkout steps
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildStepTitle(colorScheme),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStepContent(
                    totalSteps, 
                    colorScheme
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right panel: Order Summary
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (widget.displayType != 'quote')
                  OrderSummary(
                    totalPrice: totalPrice,
                    deliveryFee: _deliveryFee.toDouble(),
                    taxRate: _taxRate,
                    orderType: widget.displayType,
                  ),
                const SizedBox(height: 16),
                _buildActionButtons(
                  itemsToDisplay, 
                  cateringOrder, 
                  cateringQuote, 
                  totalSteps, 
                  colorScheme
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile/Tablet layout: Vertical stacked elements
      content = Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildStepTitle(colorScheme),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentStepContent(
                        totalSteps, 
                        colorScheme
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActions(
            itemsToDisplay, 
            cateringOrder, 
            cateringQuote, 
            totalPrice, 
            totalSteps, 
            colorScheme
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        foregroundColor: colorScheme.primary,
        title: Column(
          children: [
            Text(
              widget.displayType == 'quote'
                  ? 'Confirmar Cotización'
                  : 'Confirmar Orden',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            _buildProgressIndicator(totalSteps, colorScheme),
          ],
        ),
      ),
      body: SafeArea(
        child: content,
      ),
    );
  }

  Widget _buildProgressIndicator(int totalSteps, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalSteps,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 24,
          height: 4,
          decoration: BoxDecoration(
            color: _currentStep >= index
                ? colorScheme.primary
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildStepTitle(ColorScheme colorScheme) {
    String title;
    switch (_currentStep) {
      case 0:
        title = 'Detalles de Entrega';
        break;
      case 1:
        title = widget.displayType == 'quote' 
            ? 'Resumen de Cotización' 
            : 'Método de Pago';
        break;
      case 2:
        title = 'Resumen de Pedido';
        break;
      default:
        title = '';
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.onBackground,
      ),
    );
  }

  Widget _buildCurrentStepContent(
    int totalSteps, 
    ColorScheme colorScheme
  ) {
    switch (_currentStep) {
      case 0:
        return _buildDeliveryStep(colorScheme);
      case 1:
        return widget.displayType == 'quote' && totalSteps == 2
            ? _buildFinalSummaryStep(colorScheme)
            : _buildPaymentStep(colorScheme);
      case 2:
        return _buildFinalSummaryStep(colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDeliveryStep(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildCheckoutContent(),
      ),
    );
  }

  Widget _buildPaymentStep(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccione su método de pago preferido',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOptions(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(ColorScheme colorScheme) {
    return Column(
      children: List.generate(
        _paymentMethods.length,
        (index) => _buildPaymentOption(index, colorScheme),
      ),
    );
  }

  Widget _buildPaymentOption(int index, ColorScheme colorScheme) {
    final bool isSelected = _selectedPaymentMethod == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? colorScheme.primary 
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? colorScheme.primary 
                      : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _paymentMethods[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? colorScheme.primary 
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getPaymentMethodDescription(index),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalSummaryStep(ColorScheme colorScheme) {
    // Fetch items based on displayType
    final List<CartItem> cartItems = ref.watch(cartProvider) ?? [];
    final CateringOrderItem? cateringOrder = ref.watch(cateringOrderProvider);
    final CateringOrderItem? cateringQuote = ref.watch(manualQuoteProvider);
    final List<CartItem> mealItems = ref.watch(mealOrderProvider) ?? [];

    final (itemsToDisplay, totalPrice) = _getItemsAndTotalPrice(
      cartItems,
      mealItems,
      cateringOrder,
      cateringQuote,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles del Pedido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildOrderDetails(colorScheme),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.displayType != 'quote')
          OrderSummary(
            totalPrice: totalPrice,
            deliveryFee: _deliveryFee.toDouble(),
            taxRate: _taxRate,
            orderType: widget.displayType,
          ),
      ],
    );
  }

  Widget _buildOrderDetails(ColorScheme colorScheme) {
    Widget? content;
    
    switch (widget.displayType) {
      case 'platos':
        content = _buildDetailRow(
          'Ubicación', 
          _regularDishesLocationController.text.isNotEmpty 
              ? _regularDishesLocationController.text 
              : 'No especificada',
          Icons.location_on,
          colorScheme,
        );
        break;
      case 'catering':
        content = Column(
          children: [
            _buildDetailRow(
              'Ubicación', 
              _cateringLocationController.text.isNotEmpty 
                  ? _cateringLocationController.text 
                  : 'No especificada',
              Icons.location_on,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Fecha y Hora', 
              _cateringDateController.text.isNotEmpty 
                  ? '${_cateringDateController.text} - ${_cateringTimeController.text}' 
                  : 'No especificada',
              Icons.calendar_today,
              colorScheme,
            ),
          ],
        );
        break;
      case 'subscriptions':
        content = Column(
          children: [
            _buildDetailRow(
              'Ubicación', 
              _mealSubscriptionLocationController.text.isNotEmpty 
                  ? _mealSubscriptionLocationController.text 
                  : 'No especificada',
              Icons.location_on,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Fecha y Hora', 
              _mealSubscriptionDateController.text.isNotEmpty 
                  ? '${_mealSubscriptionDateController.text} - ${_mealSubscriptionTimeController.text}' 
                  : 'No especificada',
              Icons.calendar_today,
              colorScheme,
            ),
          ],
        );
        break;
      case 'quote':
        final CateringOrderItem? quote = ref.watch(manualQuoteProvider);
        content = quote != null 
            ? Column(
                children: [
                  _buildDetailRow(
                    'Tipo', 
                    'Cotización de catering',
                    Icons.assignment,
                    colorScheme,
                  ),
                  if (_cateringLocationController.text.isNotEmpty)
                  ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Ubicación', 
                      _cateringLocationController.text,
                      Icons.location_on,
                      colorScheme,
                    ),
                  ],
                  if (_cateringDateController.text.isNotEmpty)
                  ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Fecha y Hora', 
                      '${_cateringDateController.text} - ${_cateringTimeController.text}',
                      Icons.calendar_today,
                      colorScheme,
                    ),
                  ],
                ],
              ) 
            : Center(
                child: Text(
                  'No hay cotización disponible',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              );
        break;
    }
    
    return content ?? const SizedBox.shrink();
  }

  Widget _buildDetailRow(
    String label, 
    String value, 
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(
    List<CartItem> itemsToDisplay, 
    CateringOrderItem? cateringOrder, 
    CateringOrderItem? cateringQuote, 
    double totalPrice,
    int totalSteps,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Atrás',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isProcessingOrder
                  ? null
                  : () async {
                      if (_currentStep < totalSteps - 1) {
                        // Validate current step
                        if (_currentStep == 0 && !_validateDeliveryStep()) {
                          return;
                        }
                        
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        // Final step - process order
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
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessingOrder
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep < totalSteps - 1
                          ? 'Continuar'
                          : widget.displayType == 'quote'
                              ? 'Enviar Cotización'
                              : 'Completar Orden',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    List<CartItem> itemsToDisplay, 
    CateringOrderItem? cateringOrder, 
    CateringOrderItem? cateringQuote, 
    int totalSteps,
    ColorScheme colorScheme,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentStep > 0)
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Atrás',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isProcessingOrder
                ? null
                : () async {
                    if (_currentStep < totalSteps - 1) {
                      // Validate current step
                      if (_currentStep == 0 && !_validateDeliveryStep()) {
                        return;
                      }
                      
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      // Final step - process order
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
                    }
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessingOrder
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentStep < totalSteps - 1
                        ? 'Continuar'
                        : widget.displayType == 'quote'
                            ? 'Enviar Cotización'
                            : 'Completar Orden',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutContent() {
    // Fetch items based on displayType
    final List<CartItem> cartItems = ref.watch(cartProvider) ?? [];
    final CateringOrderItem? cateringOrder = ref.watch(cateringOrderProvider);
    final CateringOrderItem? cateringQuote = ref.watch(manualQuoteProvider);
    final List<CartItem> mealItems = ref.watch(mealOrderProvider) ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    switch (widget.displayType) {
      case 'platos':
        return PlatosCheckout(
          items: cartItems,
          locationController: _regularDishesLocationController,
          onLocationTap: _showLocationBottomSheet,
          paymentMethodDropdown: const SizedBox.shrink(), // We handle payment in separate step
        );
      case 'catering':
        if (cateringOrder == null) {
          return Center(
            child: Text(
              'No hay orden de catering disponible',
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          );
        }
        return CateringCheckout(
          order: cateringOrder,
          locationController: _cateringLocationController,
          dateController: _cateringDateController,
          timeController: _cateringTimeController,
          onLocationTap: _showLocationBottomSheet,
          onDateTimeTap: _selectDateTime,
          paymentMethodDropdown: const SizedBox.shrink(), // We handle payment in separate step
        );
      case 'quote':
        if (cateringQuote == null) {
          return Center(
            child: Text(
              'No hay cotización disponible',
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          );
        }
        return QuoteCheckout(
          quote: cateringQuote,
          locationController: _cateringLocationController,
          dateController: _cateringDateController,
          timeController: _cateringTimeController,
          onLocationTap: _showLocationBottomSheet,
          onDateTimeTap: _selectDateTime,
          paymentMethodDropdown: const SizedBox.shrink(), // We handle payment in separate step
        );
      case 'subscriptions':
        return MealPlanCheckout(
          items: mealItems,
          locationController: _mealSubscriptionLocationController,
          dateController: _mealSubscriptionDateController,
          timeController: _mealSubscriptionTimeController,
          onLocationTap: _showLocationBottomSheet,
          onDateTimeTap: _selectDateTime,
          paymentMethodDropdown: const SizedBox.shrink(), // We handle payment in separate step
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

  Future<void> _processOrder(
    BuildContext context, 
    List<CartItem> items,
    CateringOrderItem? cateringOrder, 
    CateringOrderItem? cateringQuote
  ) async {
    // Store context related objects before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final goRouter = GoRouter.of(context);
    final colorScheme = Theme.of(context).colorScheme;

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
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ));
      }
    }
  }

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

  bool _validateDeliveryStep() {
    bool isValid = true;

    switch (widget.displayType) {
      case 'platos':
        // Regular dishes only need location validation
        if (_regularDishesLocationController.text.isEmpty) {
          ref
              .read(validationProvider('regular').notifier)
              .setValid('location', false);
          isValid = false;
          _showValidationError('regular');
        }
        break;

      case 'subscriptions':
        // Validate location
        if (_mealSubscriptionLocationController.text.isEmpty) {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('location', false);
          isValid = false;
        }
        // Validate date
        if (_mealSubscriptionDateController.text.isEmpty) {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('date', false);
          isValid = false;
        }
        // Validate time
        if (_mealSubscriptionTimeController.text.isEmpty) {
          ref
              .read(validationProvider('mealSubscription').notifier)
              .setValid('time', false);
          isValid = false;
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
        }
        // Validate date
        if (_cateringDateController.text.isEmpty) {
          ref
              .read(validationProvider('catering').notifier)
              .setValid('date', false);
          isValid = false;
        }
        // Validate time
        if (_cateringTimeController.text.isEmpty) {
          ref
              .read(validationProvider('catering').notifier)
              .setValid('time', false);
          isValid = false;
        }
        // Show error message if needed
        if (!isValid) {
          _showValidationError('catering');
        }
        break;
      
      case 'quote':
        // For quotes, no validation needed in first step
        isValid = true;
        break;
    }
    
    return isValid;
  }

  bool _validateFields() {
    bool isValid = true;
    double scrollOffset = 0;
    final colorScheme = Theme.of(context).colorScheme;

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
      
      case 'quote':
        // For quotes, minimal validation
        isValid = true;
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
    final colorScheme = Theme.of(context).colorScheme;

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
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.onError,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Por favor complete: $message'),
              ),
            ],
          ),
          backgroundColor: colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLocationBottomSheet(BuildContext context,
      TextEditingController controller, String orderType) {
    if (!mounted) return;
    
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: LocationCaptureBottomSheet(
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
            ),
          ),
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
}