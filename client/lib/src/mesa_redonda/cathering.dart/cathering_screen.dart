import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_order_details.dart'
    as orderDetails;
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

final localCateringItemCountProvider = StateProvider<int>((ref) {
  final cateringOrder = ref.watch(cateringOrderProvider);
  return cateringOrder?.dishes.length ?? 0;
});

class CateringScreen extends ConsumerStatefulWidget {
  const CateringScreen({super.key});

  @override
  CateringScreenState createState() => CateringScreenState();
}

class CateringScreenState extends ConsumerState<CateringScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController sideRequestController = TextEditingController();

  late TabController _tabController;
  List<String> alergiasList = [];
  String? newAllergy = '';
  final FocusNode customPersonasFocusNode =
      FocusNode(); // Declare the FocusNode
  bool isCustomSelected = false;
  late ScrollController _scrollController;
  bool _isTabBarVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateItemCount(ref);
    });
  }

  // Update the item count whenever the screen is shown
  void _updateItemCount(WidgetRef ref) {
    final cateringOrder = ref.read(cateringOrderProvider);
    final itemCount = cateringOrder?.dishes.length ?? 0;
    ref.read(localCateringItemCountProvider.notifier).state = itemCount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cateringOptions = ref.watch(cateringProvider);
    final categorizedItems = groupCateringItemsByCategory(cateringOptions);
    _tabController = TabController(
      length: categorizedItems.keys.length,
      vsync: this,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isTabBarVisible) {
        setState(() {
          _isTabBarVisible = false; // Hide TabBar when scrolling down
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isTabBarVisible) {
        setState(() {
          _isTabBarVisible = true; // Show TabBar when scrolling up
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    sideRequestController.dispose();
    _scrollController.dispose();
    super.dispose();
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
            cateringOrder!.cantidadPersonas > 0)
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

  Map<String, List<CateringItem>> groupCateringItemsByCategory(
      List<CateringItem> items) {
    Map<String, List<CateringItem>> categorizedItems = {};
    for (var item in items) {
      String category =
          item.category.isNotEmpty ? item.category : 'Uncategorized';
      categorizedItems.putIfAbsent(category, () => []).add(item);
    }
    return categorizedItems;
  }

  @override
  Widget build(BuildContext context) {
    final cateringOptions = ref.watch(cateringProvider);
    final categorizedItems = groupCateringItemsByCategory(cateringOptions);
    // Inside the build method where the button is rendered
    final cateringItemCount = ref.watch(localCateringItemCountProvider);

    // Retrieve the current catering order from the provider
    // final cateringOrder = ref.read(cateringOrderProvider);
    final cateringOrderUpdate = ref.watch(cateringOrderProvider);
    // Set initial values, using provider values if available
    int? cantidadPersonas = cateringOrderUpdate?.cantidadPersonas;
    final double maxTabWidth = TabUtils.calculateMaxTabWidth(
      context: context,
      tabTitles: categorizedItems.keys.toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering'),
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.library_books),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const orderDetails.CateringOrderDetailsScreen()),
                    );
                  },
                ),
                cateringItemCount > 0
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$cateringItemCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ),
        ],
        bottom: _isTabBarVisible
            ? TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                isScrollable: true,
                labelStyle: Theme.of(context).textTheme.titleSmall,
                unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
                labelColor: ColorsPaletteRedonda.white,
                unselectedLabelColor: ColorsPaletteRedonda.deepBrown1,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: TabIndicator(
                  color: ColorsPaletteRedonda
                      .primary, // Background color of the selected tab
                  radius: 16.0, // Radius for rounded corners
                ),
                tabs: categorizedItems.keys
                    .map(
                      (category) => Container(
                        width: maxTabWidth, // Set fixed width for each tab
                        alignment: Alignment.center,
                        child: Tab(text: category),
                      ),
                    )
                    .toList(),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Construye tu Buffete',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.reverse &&
                      _isTabBarVisible) {
                    setState(() {
                      _isTabBarVisible = false;
                    });
                  } else if (notification.direction ==
                          ScrollDirection.forward &&
                      !_isTabBarVisible) {
                    setState(() {
                      _isTabBarVisible = true;
                    });
                  }
                  return true;
                },
                child: TabBarView(
                  controller: _tabController,
                  children: categorizedItems.keys.map((category) {
                    final items = categorizedItems[category]!;
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return CateringItemCard(
                          item: item,
                          onAddToCart: (int quantity) {
                            ref
                                .read(cateringOrderProvider.notifier)
                                .addCateringItem(
                                  CateringDish(
                                    title: item.title,
                                    peopleCount: quantity,
                                    pricePerPerson: item.pricePerPerson,
                                    ingredients: item.ingredients,
                                    pricing: item.pricing,
                                  ),
                                );
                          },
                          sideRequestController: sideRequestController,
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            if (cateringItemCount > 0) // Conditionally render the button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          cantidadPersonas == null || cantidadPersonas < 1
                              ? ColorsPaletteRedonda
                                  .primary // Default color when no people count is set
                              : Colors
                                  .white, // White background when people count is set
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          cantidadPersonas == null || cantidadPersonas < 1
                              ? Colors
                                  .white // White text when no people count is set
                              : Theme.of(context)
                                  .primaryColor, // Primary color for text when people count is set
                        ),
                        side: WidgetStateProperty.all(
                          cantidadPersonas == null || cantidadPersonas < 1
                              ? BorderSide
                                  .none // No border when no people count is set
                              : BorderSide(
                                  color: Colors
                                      .white, // Primary color border when people count is set
                                ),
                        ),
                      ),
                      onPressed: () {
                        _showCateringForm(context, ref);
                      },
                      child: Text(
                        cantidadPersonas == null || cantidadPersonas < 1
                            ? 'Completar Orden' // Text when no people count is set
                            : 'Actualizar Catering', // Text when people count is set
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
