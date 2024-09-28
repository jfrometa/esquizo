import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

// Using SingleTickerProviderStateMixin to handle vsync
class CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController();
  String? _location;
  String? _latitude;
  String? _longitude;
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
  bool _isAddressValid = true;
  final int _deliveryFee = 200;
  final double _taxRate = 0.067;
  late TabController _tabController;
  int _selectedPaymentMethod = 0;
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
    _tabController = TabController(
        length: 3, vsync: this); // vsync is now provided correctly
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

  // Printing selectTime function
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller,
      {required bool isCatering}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null && picked.hour >= 9 && picked.hour <= 21) {
      setState(() {
        if (isCatering) {
          _selectedCateringTime = picked;
          controller.text = picked.format(context);
        } else {
          _selectedMealSubscriptionTime = picked;
          controller.text = picked.format(context);
        }
      });
      print(
          'Selected time: ${picked.format(context)}'); // Print statement to display the selected time
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time between 9 AM and 9 PM'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),

                          // Regular Dishes Section
                          if (dishes.isNotEmpty)
                            _buildSectionTitle(context,
                                'Regular Dishes (Estimated 40-60 mins)'),
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

                          // Catering Section with Date/Time Picker
                          if (cateringItems.isNotEmpty) ...[
                            _buildSectionTitle(context, 'Catering Orders'),
                            _buildDateTimePicker(
                                context,
                                _cateringDateController,
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
                                    .decrementQuantity(item.title),
                                onAdd: () => ref
                                    .read(cartProvider.notifier)
                                    .incrementQuantity(item.title),
                                peopleCount: item.peopleCount,
                                sideRequest: item.sideRequest,
                              ),
                          ],

                          // Meal Subscription Section with Date/Time Picker
                          if (mealSubscriptions.isNotEmpty) ...[
                            _buildSectionTitle(context, 'Meal Subscriptions'),
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

                          const Spacer(),
                          _buildOrderSummary(cartItems),
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

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {required bool isCatering}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default to current date
      firstDate: DateTime.now(), // Only allow future dates
      lastDate: DateTime.now()
          .add(const Duration(days: 30)), // Allow up to 30 days in the future
    );

    if (picked != null) {
      setState(() {
        if (isCatering) {
          _selectedCateringDate = picked;
          controller.text = DateFormat('yyyy-MM-dd')
              .format(picked); // Format the selected date
        } else {
          _selectedMealSubscriptionDate = picked;
          controller.text = DateFormat('yyyy-MM-dd')
              .format(picked); // Format the selected date
        }
      });
      print(
          'Selected date: ${DateFormat('yyyy-MM-dd').format(picked)}'); // Print selected date
    } else {
      print('Date selection was canceled.');
    }
  }

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller,
      {required bool isCatering}) async {
    // First, select the date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default to current date
      firstDate: DateTime.now(), // Only allow future dates
      lastDate: DateTime.now()
          .add(const Duration(days: 30)), // Allow up to 30 days in the future
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context)
                  .colorScheme
                  .primary, // Use primary color for header
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .primary, // Use primary color for text buttons
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    // If the date is not picked, cancel the process
    if (pickedDate == null) {
      print('Date selection was canceled.');
      return;
    }

    // Then, select the time after the date is picked
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0), // Default time (9 AM)
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context)
                  .colorScheme
                  .primary, // Use primary color for header
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .primary, // Use primary color for text buttons
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedTime == null) {
      print('Time selection was canceled.');
      return;
    }

    // Combine the selected date and time into a single DateTime object
    final DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Update the state and controller with the combined date and time
    setState(() {
      final formattedDateTime = DateFormat('yyyy-MM-dd – HH:mm')
          .format(selectedDateTime); // Combine date and time in desired format
      controller.text = formattedDateTime;
      print(
          'Selected date and time: $formattedDateTime'); // Print the selected date and time
      if (isCatering) {
        _selectedCateringDate = selectedDateTime;
      } else {
        _selectedMealSubscriptionDate = selectedDateTime;
      }
    });
  }

  Widget _buildDateTimePicker(
      BuildContext context,
      TextEditingController dateTimeController,
      TextEditingController mealSubscriptionTimeController,
      {required bool isCatering}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCatering
                ? 'Select Catering Delivery Date & Time'
                : 'Select Meal Subscription Date & Time',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: dateTimeController,
            readOnly: true,
            onTap: () => _selectDateTime(context, dateTimeController,
                isCatering: isCatering),
            decoration: InputDecoration(
              hintText: isCatering
                  ? 'Select Catering Date & Time'
                  : 'Select Subscription Date & Time',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle checkout button logic
              },
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
