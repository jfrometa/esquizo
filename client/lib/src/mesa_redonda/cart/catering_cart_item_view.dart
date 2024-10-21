import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class CateringCartItemView extends ConsumerWidget {
  final CateringOrderItem order;
  final VoidCallback onRemoveFromCart;
    final FocusNode customPersonasFocusNode =
      FocusNode(); // Declare the FocusNode
  bool isCustomSelected = false;

  CateringCartItemView({
    super.key,
    required this.order,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPersonasSelected = order.cantidadPersonas != null && order.cantidadPersonas! > 0;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order title and removal button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorsPaletteRedonda.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemoveFromCart,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Order details
            Text(order.description),
            const SizedBox(height: 8),
            Text('Apetito: ${order.apetito}'),
            Text('Alergias: ${order.alergias.isNotEmpty ? order.alergias : "Ninguna"}'),
            Text('Evento: ${order.eventType}'),
            Text('Preferencia: ${order.preferencia}'),
            if (order.adicionales.isNotEmpty)
              Text('Adicionales: ${order.adicionales}'),
            const SizedBox(height: 16),
            // Order items
            Text(
              'Items del Catering:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...order.dishes.map((dish) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${dish.title} - ${dish.peopleCount} personas',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                '\$${(dish.peopleCount * dish.pricePerPerson).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const Divider(),
            // Total order price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Precio Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorsPaletteRedonda.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Button to complete the catering order
            
            if(!isPersonasSelected)
            ElevatedButton(
              onPressed: !isPersonasSelected
                  ? () {
                      _showCateringForm(context, ref);
                    }
                  : null, // Disable button if personas not selected
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey; // Disabled color
                    }
                    return ColorsPaletteRedonda.orange; // Active color
                  },
                ),
              ),
              child: const Text('Completar Orden de Catering'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCateringForm(BuildContext context, WidgetRef ref) {
    // Retrieve the current catering order from the provider
    final cateringOrder = ref.read(cateringOrderProvider);
    // final cateringOrderValue = ref.watch(cateringOrderProvider);
    final peopleQuantity = [
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
    // Set initial values, using provider values if available
    String apetito = (cateringOrder?.apetito != null &&
            cateringOrder?.apetito.isNotEmpty == true)
        ? cateringOrder!.apetito
        : 'regular';
    String preferencia = (cateringOrder?.preferencia != null &&
            cateringOrder?.preferencia.isNotEmpty == true)
        ? cateringOrder!.preferencia
        : 'salado';

    String eventType = cateringOrder?.eventType ?? '';
    String adicionales = cateringOrder?.adicionales ?? '';
    int? cantidadPersonasRead = (cateringOrder?.cantidadPersonas != null &&
            cateringOrder!.cantidadPersonas! > 0)
        ? cateringOrder.cantidadPersonas
        : null;

    List<String> alergiasList = cateringOrder?.alergias.split(',') ?? [];

    if (cantidadPersonasRead != null &&
        !peopleQuantity.contains(cantidadPersonasRead)) {
      isCustomSelected = true;
    }
    // TextController for custom number of persons
    TextEditingController customPersonasController =
        TextEditingController(text: '$cantidadPersonasRead');
    TextEditingController eventTypeController =
        TextEditingController(text: eventType);

    // Helper function to add allergies
    void addAllergy(String value, StateSetter setModalState) {
      if (value.isNotEmpty && !alergiasList.contains(value)) {
        setModalState(() => alergiasList.add(value));
      }
    }

    // Show the modal form
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String? allergyInput = '';
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.0,
            right: 20.0,
            top: 20.0,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
       
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detalles de la orden',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: ColorsPaletteRedonda.deepBrown1),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text('Nivel de Apetito',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: apetito,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Apetito',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorsPaletteRedonda.white,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'poco', child: Text('Poco')),
                        DropdownMenuItem(
                            value: 'regular', child: Text('Regular')),
                        DropdownMenuItem(value: 'mucho', child: Text('Mucho')),
                      ],
                      onChanged: (value) =>
                          setModalState(() => apetito = value ?? 'regular'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cantidad de Personas',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: (cantidadPersonasRead != null &&
                              peopleQuantity.contains(cantidadPersonasRead))
                          ? cantidadPersonasRead
                          : null, // Ensure `null` if no valid option selected
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: isCustomSelected
                            ? 'Cantidad Personalizada'
                            : 'Cantidad de Personas',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorsPaletteRedonda.white,
                      ),
                      items: [
                        for (var number in peopleQuantity)
                          DropdownMenuItem<int>(
                            value: number,
                            child: Text('$number'),
                          ),
                        const DropdownMenuItem<int>(
                          value:
                              -1, // Ensure this value is unique and correctly handled
                          child: Text('Customizado'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == -1) {
                          setModalState(() {
                            isCustomSelected = true; // Custom option selected
                            cantidadPersonasRead =
                                null; // Reset to null for custom input
                          });
                          Future.delayed(Duration(milliseconds: 200), () {
                            customPersonasFocusNode.requestFocus();
                          });
                        } else {
                          setModalState(() {
                            isCustomSelected =
                                false; // Predefined option selected
                            cantidadPersonasRead =
                                value; // Assign the selected value
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (isCustomSelected) // Show the custom input field only if custom is selected
                      TextField(
                        controller: customPersonasController,
                        focusNode:
                            customPersonasFocusNode, // Assign the focus node

                        decoration: InputDecoration(
                          labelText: '${cantidadPersonasRead ?? 0} Personas',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: ColorsPaletteRedonda.white,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final customValue = int.tryParse(value);
                          if (customValue != null) {
                            setModalState(
                                () => cantidadPersonasRead = customValue);
                          }
                        },
                      ),
                    const SizedBox(height: 16),
                    const Text('Alergias',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        for (var allergy in alergiasList)
                          Chip(
                            backgroundColor: ColorsPaletteRedonda.primary,
                            label: Text(
                              allergy,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            deleteIconColor: Colors.white,
                            onDeleted: () {
                              setModalState(() => alergiasList.remove(allergy));
                            },
                          ),
                        if (alergiasList.length < 10)
                          ActionChip(
                            backgroundColor: Colors.white,
                            avatar: Icon(Icons.add,
                                color: ColorsPaletteRedonda.primary),
                            label: const Text('Agregar Alergia'),
                            labelStyle: TextStyle(
                              color: ColorsPaletteRedonda.primary,
                            ),
                            onPressed: () async {
                              final newAllergy = await showDialog<String>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Nueva Alergia'),
                                  content: TextField(
                                    onChanged: (value) =>
                                        {allergyInput = value},
                                    onSubmitted: (value) {
                                      addAllergy(value, setModalState);
                                      Navigator.pop(context, value);
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Ingresa una alergia',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog without saving
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Add the allergy and close the dialog
                                        if (allergyInput != null &&
                                            allergyInput!.isNotEmpty) {
                                          addAllergy(
                                              allergyInput!, setModalState);
                                        }
                                        Navigator.pop(context, allergyInput);
                                      },
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                ),
                              );
                              if (newAllergy != null && newAllergy.isNotEmpty) {
                                addAllergy(newAllergy, setModalState);
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Tipo de Evento',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: eventTypeController,
                      decoration: InputDecoration(
                        labelText: 'Ej. Cumpleaños, Boda',
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorsPaletteRedonda.white,
                      ),
                      onChanged: (value) =>
                          setModalState(() => eventType = value),
                    ),
                    const SizedBox(height: 16),
                    const Text('Preferencia de Sabor',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: preferencia,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Preferencia',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorsPaletteRedonda
                            .white, // Set the background color to white
                      ),
                      style: TextStyle(
                        color: Theme.of(context)
                            .primaryColor, // Set the text color to primary color
                      ),
                      items: const [
                        DropdownMenuItem(value: 'dulce', child: Text('Dulce')),
                        DropdownMenuItem(
                            value: 'salado', child: Text('Salado')),
                      ],
                      onChanged: (value) =>
                          setModalState(() => preferencia = value!),
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: Text('Agregar Adicionales',
                          style: Theme.of(context).textTheme.titleMedium),
                      children: [
                        TextFormField(
                          controller: TextEditingController(),
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Ej. Arroz con fideos 20 personas',
                            filled: true,
                            fillColor: ColorsPaletteRedonda.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: ColorsPaletteRedonda.deepBrown1,
                                  width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: ColorsPaletteRedonda.primary,
                                  width: 2.0),
                            ),
                          ),
                          onChanged: (value) =>
                              setModalState(() => adicionales = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    
                    Center(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(  ColorsPaletteRedonda
                                  .orange // Default color when no people count is set
                               // White background when people count is set
                        ),
                        foregroundColor: WidgetStateProperty.all( 
                               Colors
                                  .white // White text when no people count is set
                          
                        ),
                        side: WidgetStateProperty.all(  BorderSide
                               .none) // No border when no people count is set
                             
                      ),
                          onPressed: () {
                            _finalizeAndAddToCart(
                                ref,
                                apetito,
                                alergiasList.join(','),
                                eventType,
                                preferencia,
                                adicionales,
                                cantidadPersonasRead ?? 0);
                            alergiasList.clear();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Se agregó el Catering al carrito'),
                                backgroundColor: Colors
                                    .brown[200], // Light brown background color
                                duration: const Duration(
                                    milliseconds:
                                        500), // Display for half a second,
                              ),
                            ); 
                            Navigator.pop(context);
                          },
                          child: const Text('Confirmar Detalles de la Orden'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _finalizeAndAddToCart(
      WidgetRef ref,
      String apetito,
      String alergias,
      String eventType,
      String preferencia,
      String adicionales,
      int cantidadPersonas) {
    final cateringOrderProviderNotifier =
        ref.read(cateringOrderProvider.notifier);
    cateringOrderProviderNotifier.finalizeCateringOrder(
      title: 'Orden de Catering',
      img: 'assets/image.png',
      description: 'Catering',
      apetito: apetito,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
      adicionales: adicionales,
      cantidadPersonas: cantidadPersonas,
    );
  }

}
