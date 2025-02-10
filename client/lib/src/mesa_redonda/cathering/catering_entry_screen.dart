import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/manual_quote_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/new_item_form.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
 

/// Assume that the global catering order provider and its notifier are defined.
/// You must have methods such as finalizeCateringOrder, removeFromCart, and addCateringItem.
final cateringOrderProvider =
    StateNotifierProvider<CateringOrderNotifier, CateringOrderItem?>((ref) {
  return CateringOrderNotifier();
});

class CateringOrderNotifier extends StateNotifier<CateringOrderItem?> {
  CateringOrderNotifier() : super(null);

  void finalizeCateringOrder({
    required String title,
    required String img,
    required String description,
    required bool hasChef,
    required String alergias,
    required String eventType,
    required String preferencia,
    required String adicionales,
    required int cantidadPersonas,
  }) {
    // Your implementation to update/finalize the order.
    // For example, you might update the state with a new CateringOrderItem.
    state = CateringOrderItem(
      title: title,
      img: img,
      description: description,
      dishes: state?.dishes ?? [],
      hasChef: hasChef,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
      adicionales: adicionales,
      peopleCount: cantidadPersonas,
    );
  }

  void removeFromCart(int index) {
    if (state != null) {
      final newDishes = List<CateringDish>.from(state!.dishes);
      if (index >= 0 && index < newDishes.length) {
        newDishes.removeAt(index);
        state = state?.copyWith(dishes: newDishes);
      }
    }
  }

  void addCateringItem(CateringDish dish) {
    if (state != null) {
      state = state?.copyWith(dishes: [...state!.dishes, dish]);
    }
  }
}

/// The complete entry screen.
class CateringEntryScreen extends ConsumerStatefulWidget {
  const CateringEntryScreen({Key? key}) : super(key: key);

  @override
  CateringEntryScreenState createState() => CateringEntryScreenState();
}

class CateringEntryScreenState extends ConsumerState<CateringEntryScreen> {
  // Whether a "Custom" number of people was selected.
  bool isCustomSelected = false;
  final customPersonasFocusNode = FocusNode();

  // Controllers that persist between bottom-sheet displays.
  late TextEditingController eventTypeController;
  late TextEditingController customPersonasController;
  late TextEditingController adicionalesController;

  // Temporary local state values.
  bool tempHasChef = false;
  String tempPreferencia = 'salado';
  List<String> tempAlergiasList = [];

  // Static list for people quantity drop-down.
  final _peopleQuantity = [
    10,
    20,
    30,
    40,
    50,
    100,
    200,
    300,
    400,
    500,
    1000,
    2000,
    5000,
    10000
  ];

  @override
  void initState() {
    super.initState();
    _initializeTemporaryValues();
  }

  /// Initialize controllers and temporary state from the current catering order.
  void _initializeTemporaryValues() {
    final cateringOrder = ref.read(cateringOrderProvider);
    tempHasChef = cateringOrder?.hasChef ?? false;
    tempPreferencia = (cateringOrder?.preferencia.isNotEmpty ?? false)
        ? cateringOrder!.preferencia
        : 'salado';
    tempAlergiasList = cateringOrder?.alergias.split(',') ?? [];

    final peopleCount = (cateringOrder?.peopleCount != null &&
            cateringOrder!.peopleCount! > 0)
        ? cateringOrder.peopleCount
        : null;
    if (peopleCount != null && !_peopleQuantity.contains(peopleCount)) {
      isCustomSelected = true;
    }

    eventTypeController =
        TextEditingController(text: cateringOrder?.eventType ?? '');
    customPersonasController =
        TextEditingController(text: peopleCount?.toString() ?? '');
    adicionalesController =
        TextEditingController(text: cateringOrder?.adicionales ?? '');
  }

  @override
  void dispose() {
    customPersonasFocusNode.dispose();
    eventTypeController.dispose();
    customPersonasController.dispose();
    adicionalesController.dispose();
    super.dispose();
  }

void _navigateToManualQuote() async {
  final manualOrder = await Navigator.push<CateringOrderItem>(
    context,
    MaterialPageRoute(
      builder: (_) => const ManualQuoteScreen(),
    ),
  );
  if (manualOrder != null) {
    // Directly update the global order with the manual quote,
    // which includes the complete list of manually added dishes.
    ref.read(cateringOrderProvider.notifier).state = manualOrder;
  }
}
  /// Finalizes the order using values gathered from the bottom sheet
  /// and updates the global catering order provider.
  void _finalizeAndAddToCart(
    WidgetRef ref,
    bool hasChef,
    String alergias,
    String eventType,
    String preferencia,
    String adicionales,
    int cantidadPersonas,
  ) {
    ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
      title: 'Orden de Catering',
      img: 'assets/image.png',
      description: 'Catering',
      hasChef: hasChef,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
      adicionales: adicionales,
      cantidadPersonas: cantidadPersonas,
    );
  }

  /// Builds the event details input section.
  Widget _buildEventDetails() {
    final quote = ref.watch(cateringOrderProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeopleQuantitySection(),
        const SizedBox(height: 16),
        TextField(
          controller: eventTypeController,
          decoration: const InputDecoration(
            labelText: 'Tipo de Evento',
            hintText: 'Ej. Cumpleaños, Boda',
            border: OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (value) {
            // Update event type in the provider.
            ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
              title: '',
              img: '',
              description: '',
              hasChef: false,
              alergias: '',
              eventType: value,
              preferencia: '',
              adicionales: '',
              cantidadPersonas: 0,
            );
          },
        ),
        const SizedBox(height: 16),
        _buildAllergiesSection(),
        const SizedBox(height: 16),
        _buildAdditionalNotesSection(),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Incluir Chef'),
          value: quote?.hasChef ?? false,
          onChanged: (value) {
            ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
              title: '',
              img: '',
              description: '',
              hasChef: value,
              alergias: '',
              eventType: '',
              preferencia: '',
              adicionales: '',
              cantidadPersonas: 0,
            );
          },
        ),
      ],
    );
  }

  /// Builds the people quantity section with a dropdown and optional custom input.
  Widget _buildPeopleQuantitySection() {
    final quote = ref.watch(cateringOrderProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cantidad de Personas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: isCustomSelected ||
                  quote?.peopleCount == null ||
                  !_peopleQuantity.contains(quote?.peopleCount)
              ? null
              : quote?.peopleCount,
          dropdownColor: Theme.of(context).cardColor,
          decoration: const InputDecoration(
            labelText: 'Cantidad de Personas',
            border: OutlineInputBorder(),
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: [
            ..._peopleQuantity.map(
              (number) => DropdownMenuItem<int>(
                value: number,
                child: Text('$number personas'),
              ),
            ),
            const DropdownMenuItem<int>(
              value: -1,
              child: Text('Personalizado'),
            ),
          ],
          onChanged: (value) {
            if (value == -1) {
              setState(() {
                isCustomSelected = true;
                customPersonasController.clear();
                ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                      title: '',
                      img: '',
                      description: '',
                      hasChef: false,
                      alergias: '',
                      eventType: '',
                      preferencia: '',
                      adicionales: '',
                      cantidadPersonas: 0,
                    );
              });
              Future.delayed(const Duration(milliseconds: 200), () {
                customPersonasFocusNode.requestFocus();
              });
            } else {
              setState(() {
                isCustomSelected = false;
                ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                      title: '',
                      img: '',
                      description: '',
                      hasChef: false,
                      alergias: '',
                      eventType: '',
                      preferencia: '',
                      adicionales: '',
                      cantidadPersonas: value ?? 0,
                    );
              });
            }
          },
        ),
        if (isCustomSelected)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: TextField(
                controller: customPersonasController,
                focusNode: customPersonasFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Personalizada',
                  border: OutlineInputBorder(),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final count = int.tryParse(value);
                  if (count != null) {
                    ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                          title: '',
                          img: '',
                          description: '',
                          hasChef: false,
                          alergias: '',
                          eventType: '',
                          preferencia: '',
                          adicionales: '',
                          cantidadPersonas: count,
                        );
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the allergies section.
  Widget _buildAllergiesSection() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alergias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...tempAlergiasList.map(
              (allergy) => Chip(
                backgroundColor: primaryColor,
                label: Text(
                  allergy,
                  style: const TextStyle(color: Colors.white),
                ),
                deleteIconColor: Colors.white,
                onDeleted: () {
                  setState(() {
                    tempAlergiasList.remove(allergy);
                  });
                  ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                        title: '',
                        img: '',
                        description: '',
                        hasChef: false,
                        alergias: tempAlergiasList.join(','),
                        eventType: '',
                        preferencia: '',
                        adicionales: '',
                        cantidadPersonas: 0,
                      );
                },
              ),
            ),
            if (tempAlergiasList.length < 10)
              ActionChip(
                backgroundColor: Colors.white,
                avatar: Icon(Icons.add, color: primaryColor),
                label: Text('Agregar Alergia', style: TextStyle(color: primaryColor)),
                onPressed: () async {
                  String? allergyInput;
                  final newAllergy = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Nueva Alergia'),
                      content: TextField(
                        onChanged: (value) => allergyInput = value,
                        decoration: const InputDecoration(
                          hintText: 'Ingresa una alergia',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (allergyInput?.isNotEmpty == true) {
                              Navigator.pop(context, allergyInput);
                            }
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  if (newAllergy?.isNotEmpty == true &&
                      !tempAlergiasList.contains(newAllergy)) {
                    setState(() => tempAlergiasList.add(newAllergy ?? ''));
                    ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                          title: '',
                          img: '',
                          description: '',
                          hasChef: false,
                          alergias: tempAlergiasList.join(','),
                          eventType: '',
                          preferencia: '',
                          adicionales: '',
                          cantidadPersonas: 0,
                        );
                  }
                },
              ),
          ],
        ),
      ],
    );
  }

  /// Builds the additional notes section as an ExpansionTile.
  Widget _buildAdditionalNotesSection() {
    return ExpansionTile(
      title: const Text('Notas Adicionales'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            controller: adicionalesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Escribe cualquier nota adicional',
              filled: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                    title: '',
                    img: '',
                    description: '',
                    hasChef: false,
                    alergias: '',
                    eventType: '',
                    preferencia: '',
                    adicionales: value,
                    cantidadPersonas: 0,
                  );
            },
          ),
        ),
      ],
    );
  }

  /// Wraps the event details in a collapsible ExpansionTile.
  Widget _buildCollapsibleEventDetails() {
    final quote = ref.watch(cateringOrderProvider);
    final isFilled = (quote?.eventType.isNotEmpty ?? false) &&
        (quote?.peopleCount ?? 0) > 0;
    return ExpansionTile(
      initiallyExpanded: !isFilled,
      title: isFilled
          ? Text('Evento: ${quote?.eventType} - ${quote?.peopleCount} personas')
          : const Text('Detalles del Evento'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildEventDetails(),
        ),
      ],
    );
  }

  /// Builds the list of added items.
  Widget _buildItemsList(List<CateringDish> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              item.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: item.title.isNotEmpty
                ? Text(
                    item.title,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  ref.read(cateringOrderProvider.notifier).removeFromCart(index),
            ),
          ),
        );
      },
    );
  }

  /// Validates required fields and, if valid, finalizes the order.
  void _confirmOrder() {
    final quote = ref.read(cateringOrderProvider);
    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No hay datos de la cotización')),
      );
      return;
    }
    if ((quote.peopleCount ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad de personas es requerida')),
      );
      return;
    }
    if (quote.eventType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El tipo de evento es requerido')),
      );
      return;
    }
    if (quote.dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un item')),
      );
      return;
    }
    try {
      Navigator.pop(context, quote);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar la orden: $e')),
      );
    }
  }

  /// Navigates to the catering selection screen.
  void _navigateToSelectionScreen() async {
    final result = await Navigator.push<CateringDish>(
      context,
      MaterialPageRoute(
        builder: (context) => const CateringSelectionScreen(),
      ),
    );
    if (result is CateringDish) {
      ref.read(cateringOrderProvider.notifier).addCateringItem(result);
      setState(() {});
    }
  }

void _addItem(String name, String description, int? quantity) {
              if (name.trim().isEmpty) return;
              
              ref.read(cateringOrderProvider.notifier).addCateringItem(
                CateringDish(
                  title: name.trim(),
                  quantity: quantity ?? 0,
                  hasUnitSelection: quantity != null,
                  peopleCount: 1,
                  pricePerUnit: 0,
                  pricePerPerson: 0,
                  ingredients: [],
                  pricing: 0,
                ),
              );
            }

     

  @override
  Widget build(BuildContext context) {
    final cateringOrder = ref.watch(cateringOrderProvider);
    final items = cateringOrder?.dishes ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    final eventDetailsCard = Card(
      elevation: 4,
      child: _buildCollapsibleEventDetails(),
    );

    final itemsCard = Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items Solicitados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No hay items agregados',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : _buildItemsList(items),
            // Use the separate NewItemForm component.
            // Add this method to the CateringEntryScreenState class
            NewItemForm(
              onAddItem: () => _addItem('', '', null),
              itemNameController: TextEditingController(),
              quantityController: TextEditingController(),
              itemDescriptionController: TextEditingController(),
            ),
          ],
        ),
      ),
    );

    Widget content;
    if (isDesktop) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: eventDetailsCard),
          const SizedBox(width: 24),
          Expanded(child: itemsCard),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          eventDetailsCard,
          const SizedBox(height: 24),
          itemsCard,
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering'),
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (cateringOrder != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                // Optionally, show the catering form.
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.black),
              onPressed: items.isNotEmpty
                  ? () {
                      GoRouter.of(context)
                          .goNamed(AppRoute.checkout.name, extra: 'catering');
                    }
                  : null,
            ),
          ],
        ],
      ),
      body: cateringOrder == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: ColorsPaletteRedonda.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      // Show regular catering form.
                    },
                    child: const Text('Inicia tu orden'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: ColorsPaletteRedonda.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _navigateToManualQuote,
                    child: const Text('Cotización Manual'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles de la Orden',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Evento: ${cateringOrder?.eventType ?? "-"}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Alergias: ${cateringOrder?.alergias.isNotEmpty == true ? cateringOrder!.alergias : "-"}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Cantidad de Personas: ${cateringOrder?.peopleCount ?? 0}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Preferencia: ${cateringOrder?.preferencia ?? "-"}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Chef Incluido: ${cateringOrder?.hasChef == true ? "Sí" : "No"}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    if (cateringOrder?.adicionales.isNotEmpty == true)
                      Text(
                        'Notas: ${cateringOrder?.adicionales}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    const Divider(height: 24, color: Colors.black),
                    if (items.isEmpty)
                      const Text(
                        'No hay platos seleccionados.',
                        style: TextStyle(color: Colors.black),
                      )
                    else
                      ...items.map(
                        (dish) => Card(
                          color: ColorsPaletteRedonda.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              dish.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              dish.hasUnitSelection
                                  ? '${dish.quantity} unidades'
                                  : '${dish.peopleCount} personas',
                              style: const TextStyle(color: Colors.black),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => ref
                                  .read(cateringOrderProvider.notifier)
                                  .removeFromCart(items.indexOf(dish)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: cateringOrder != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToSelectionScreen,
              label: const Text('Completar Orden'),
              icon: Icon(Icons.shopping_cart_checkout,
                  color: ColorsPaletteRedonda.primary),
              backgroundColor: ColorsPaletteRedonda.primary,
            )
          : null,
    );
  }
}