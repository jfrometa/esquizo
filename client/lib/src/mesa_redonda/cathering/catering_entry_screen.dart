import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/manual_quote_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class CateringEntryScreen extends ConsumerStatefulWidget {
  const CateringEntryScreen({Key? key}) : super(key: key);

  @override
  CateringEntryScreenState createState() => CateringEntryScreenState();
}

class CateringEntryScreenState extends ConsumerState<CateringEntryScreen> {
  // Whether the user selected a "Custom" number of people
  bool isCustomSelected = false;
  final customPersonasFocusNode = FocusNode();

  // Controllers that should persist between shows of the BottomSheet
  late TextEditingController eventTypeController;
  late TextEditingController customPersonasController;
  late TextEditingController adicionalesController;

  bool tempHasChef = false;
  String tempPreferencia = 'salado'; // default
  List<String> tempAlergiasList = [];

  @override
  void initState() {
    super.initState();
    _initializeTemporaryValues();
  }

  /// Pull the current provider state and set up local variables + controllers
  void _initializeTemporaryValues() {
    final cateringOrder = ref.read(cateringOrderProvider);

    tempHasChef = cateringOrder?.hasChef ?? false;
    tempPreferencia = (cateringOrder?.preferencia.isNotEmpty == true)
        ? cateringOrder!.preferencia
        : 'salado';
    tempAlergiasList = cateringOrder?.alergias.split(',') ?? [];

    // People count
    final peopleCount =
        (cateringOrder?.peopleCount != null && cateringOrder!.peopleCount! > 0)
            ? cateringOrder.peopleCount
            : null;

    if (peopleCount != null && !_peopleQuantity.contains(peopleCount)) {
      isCustomSelected = true;
    }

    // Initialize controllers
    eventTypeController =
        TextEditingController(text: cateringOrder?.eventType ?? '');
    customPersonasController =
        TextEditingController(text: (peopleCount?.toString() ?? ''));
    adicionalesController =
        TextEditingController(text: cateringOrder?.adicionales ?? '');
  }

  // Example static list for the drop-down
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

  /// BottomSheet to gather all details
  void _showCateringForm(BuildContext context, WidgetRef ref) {
    final cateringOrder = ref.read(cateringOrderProvider);

    // Track local (bottomSheet) states in a `StatefulBuilder`
    int? localPeopleCount =
        (cateringOrder?.peopleCount != null && cateringOrder!.peopleCount! > 0)
            ? cateringOrder.peopleCount
            : null;

    bool localHasChef = cateringOrder?.hasChef ?? false;
    // If the quantity is not in the preset list, mark as custom
    if (localPeopleCount != null &&
        !_peopleQuantity.contains(localPeopleCount)) {
      isCustomSelected = true;
    }

    // A local copy of the allergies list:
    List<String> localAlergiasList = cateringOrder?.alergias
            .split(',')
            ?.where((a) => a.isNotEmpty)
            .toList() ??
        [];

    // Local copy of preferencia
    String localPreferencia = cateringOrder?.preferencia ?? 'salado';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        String? allergyInput = '';

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 20.0,
            right: 20.0,
            top: 20.0,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              // Helper to add an allergy
              void addAllergy(String value) {
                final val = value.trim();
                if (val.isNotEmpty && !localAlergiasList.contains(val)) {
                  setModalState(() => localAlergiasList.add(val));
                }
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Title + close
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
                    const SizedBox(height: 16),

                    /// Cantidad de Personas
                    const Text(
                      'Cantidad de Personas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: (!isCustomSelected && localPeopleCount != null)
                          ? localPeopleCount
                          : null,
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
                        for (var number in _peopleQuantity)
                          DropdownMenuItem<int>(
                            value: number,
                            child: Text('$number'),
                          ),
                        const DropdownMenuItem<int>(
                          value: -1,
                          child: Text('Personalizado'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == -1) {
                          setModalState(() {
                            isCustomSelected = true;
                            localPeopleCount = null;
                          });
                          // Focus the textfield for custom
                          Future.delayed(const Duration(milliseconds: 200), () {
                            customPersonasFocusNode.requestFocus();
                          });
                        } else {
                          setModalState(() {
                            isCustomSelected = false;
                            localPeopleCount = value;
                          });
                          customPersonasController.text =
                              (localPeopleCount?.toString() ?? '');
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (isCustomSelected)
                      TextField(
                        controller: customPersonasController,
                        focusNode: customPersonasFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Personas (custom)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: ColorsPaletteRedonda.white,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final customValue = int.tryParse(value);
                          setModalState(() => localPeopleCount = customValue);
                        },
                      ),
                    const SizedBox(height: 16),

                    /// Alergias
                    const Text(
                      'Alergias',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        for (var allergy in localAlergiasList)
                          Chip(
                            backgroundColor: ColorsPaletteRedonda.primary,
                            label: Text(
                              allergy,
                              style: const TextStyle(color: Colors.white),
                            ),
                            deleteIconColor: Colors.white,
                            onDeleted: () {
                              setModalState(() {
                                localAlergiasList.remove(allergy);
                              });
                            },
                          ),
                        // Add button
                        if (localAlergiasList.length < 10)
                          ActionChip(
                            backgroundColor: Colors.white,
                            avatar: Icon(
                              Icons.add,
                              color: ColorsPaletteRedonda.primary,
                            ),
                            label: const Text('Agregar Alergia'),
                            labelStyle: TextStyle(
                              color: ColorsPaletteRedonda.primary,
                            ),
                            onPressed: () async {
                              final newAllergy = await showDialog<String>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Nueva Alergia'),
                                  content: TextField(
                                    onChanged: (value) => allergyInput = value,
                                    onSubmitted: (value) {
                                      addAllergy(value);
                                      Navigator.pop(dialogContext, value);
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Ingresa una alergia',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (allergyInput != null &&
                                            allergyInput!.isNotEmpty) {
                                          addAllergy(allergyInput!);
                                        }
                                        Navigator.pop(
                                            dialogContext, allergyInput);
                                      },
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                ),
                              );
                              if (newAllergy != null && newAllergy.isNotEmpty) {
                                addAllergy(newAllergy);
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Tipo de Evento
                    const Text(
                      'Tipo de Evento',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: eventTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Ej. Cumpleaños, Boda',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorsPaletteRedonda.white,
                      ),
                      onChanged: (value) {
                        // Only if you need to store locally or do something
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Chef Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Agregar cheffing',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Switch(
                          value: localHasChef,
                          inactiveTrackColor: ColorsPaletteRedonda.deepBrown,
                          activeColor: ColorsPaletteRedonda.primary,
                          onChanged: (bool value) {
                            setModalState(() {
                              localHasChef = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /// Preferencia (salado/dulce) example
                    Text(
                      'Preferencia',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'salado',
                          groupValue: localPreferencia,
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => localPreferencia = val);
                            }
                          },
                        ),
                        const Text('Salado'),
                        Radio<String>(
                          value: 'dulce',
                          groupValue: localPreferencia,
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => localPreferencia = val);
                            }
                          },
                        ),
                        const Text('Dulce'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Notas Adicionales
                    ExpansionTile(
                      title: Text(
                        'Notas Adicionales',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      children: [
                        TextFormField(
                          controller: adicionalesController,
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Escribe cualquier nota adicional',
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
                          onChanged: (value) {
                            // Storing inside expansion tile
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Confirm button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsPaletteRedonda.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // If user chooses custom but never enters a number, default to 0
                          final finalPersonCount = (isCustomSelected &&
                                  localPeopleCount == null)
                              ? int.tryParse(customPersonasController.text) ?? 0
                              : (localPeopleCount ?? 0);

                          // Finalize & update provider
                          _finalizeAndAddToCart(
                            ref,
                            localHasChef,
                            localAlergiasList.join(','),
                            eventTypeController.text,
                            localPreferencia,
                            adicionalesController.text,
                            finalPersonCount,
                          );

                          // Clear ephemeral states if needed
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Se agregó el Catering al carrito'),
                              backgroundColor: Colors.brown[200],
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Confirmar Detalles'),
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

  /// This method finalizes & updates the catering order in the provider
  void _finalizeAndAddToCart(
    WidgetRef ref,
    bool hasChef,
    String alergias,
    String eventType,
    String preferencia,
    String adicionales,
    int cantidadPersonas,
  ) {
    final cateringOrderProviderNotifier =
        ref.read(cateringOrderProvider.notifier);
    cateringOrderProviderNotifier.finalizeCateringOrder(
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

  @override
  Widget build(BuildContext context) {
    final cateringOrder = ref.watch(cateringOrderProvider);
    final dishes = cateringOrder?.dishes ?? [];

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Catering', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (cateringOrder != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => _showCateringForm(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.black),
              onPressed: dishes.isNotEmpty
                  ? () {
                      GoRouter.of(context).goNamed(
                        AppRoute.checkout.name,
                        extra: 'catering',
                      );
                    }
                  : null,
            ),
          ],
        ],
      ),
      body: ((cateringOrder == null))
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
                    onPressed: () => _showCateringForm(context, ref),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManualQuoteScreen(),
                        ),
                      );
                    },
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

                    // Show selected dishes or a message
                    if (dishes.isEmpty)
                      const Text(
                        'No hay platos seleccionados.',
                        style: TextStyle(color: Colors.black),
                      )
                    else
                      ...dishes.map(
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
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => ref
                                  .read(cateringOrderProvider.notifier)
                                  .removeFromCart(dishes.indexOf(dish)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      // Only show FAB if we have an order and completed the initial form
      floatingActionButton: cateringOrder != null
          ? FloatingActionButton(
              backgroundColor: ColorsPaletteRedonda.primary,
              onPressed: _navigateToSelectionScreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
