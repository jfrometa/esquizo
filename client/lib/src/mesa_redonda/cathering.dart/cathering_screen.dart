import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_item.dart'; 
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    sideRequestController.dispose();
    super.dispose();
  }

  void _showCateringForm(BuildContext context) {
    String apetito = 'regular';
    String preferencia = 'salado';
    String eventType = '';
    String adicionales = '';

    void addAllergy(String value, StateSetter setModalState) {
      if (value.isNotEmpty && !alergiasList.contains(value)) {
        setModalState(() => alergiasList.add(value));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
                          'Catering Details',
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
                      decoration: InputDecoration(
                        labelText: 'Apetito',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorsPaletteRedonda.white,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'poco', child: Text('Poco')),
                        DropdownMenuItem(value: 'regular', child: Text('Regular')),
                        DropdownMenuItem(value: 'mucho', child: Text('Mucho')),
                      ],
                      onChanged: (value) => setModalState(() => apetito = value!),
                    ),
                    const SizedBox(height: 16),
                    const Text('Alergias', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        for (var allergy in alergiasList)
                          Chip(
                            label: Text(allergy),
                            onDeleted: () {
                              setModalState(() => alergiasList.remove(allergy));
                            },
                          ),
                        if (alergiasList.length < 10)
                          ActionChip(
                            avatar: Icon(Icons.add,
                                color: ColorsPaletteRedonda.primary),
                            label: const Text('Agregar Alergia'),
                            onPressed: () async {
                               newAllergy = await showDialog<String>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Nueva Alergia'),
                                  content: TextField(
                                    onChanged: (value) => newAllergy = value,
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
                                        addAllergy(newAllergy ?? '', setModalState);
                                        Navigator.pop(context, newAllergy);
                                      },
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                ),
                              );
                              if (newAllergy != null) {
                                addAllergy(newAllergy!, setModalState);
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Tipo de Evento', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Ej. Cumpleaños, Boda',
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorsPaletteRedonda.white,
                      ),
                      onChanged: (value) => setModalState(() => eventType = value),
                    ),
                    const SizedBox(height: 16),
                    const Text('Preferencia de Sabor', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: preferencia,
                      decoration: InputDecoration(
                        labelText: 'Preferencia',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: ColorsPaletteRedonda.white,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'dulce', child: Text('Dulce')),
                        DropdownMenuItem(value: 'salado', child: Text('Salado')),
                      ],
                      onChanged: (value) => setModalState(() => preferencia = value!),
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: Text('Agregar Adicionales',
                          style: Theme.of(context).textTheme.titleMedium),
                      children: [
                        TextFormField(
                          controller: sideRequestController,
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
                          onChanged: (value) => setModalState(() => adicionales = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _finalizeAndAddToCart(
                            apetito, alergiasList.join(','),
                            eventType, preferencia, adicionales);
                          alergiasList.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Confirmar'),
                      ),
                    ),
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
    String apetito, String alergias,
    String eventType, String preferencia, String adicionales
  ) {
    final cateringOrderProviderNotifier = ref.read(cateringOrderProvider.notifier);
    cateringOrderProviderNotifier.finalizeCateringOrder(
      title: 'Catering Order',
      img: 'assets/image.png',
      description: 'Catering Order for Event',
      apetito: apetito,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
      adicionales: adicionales,
    );

    final cateringOrderItems = ref.read(cateringOrderProvider);
    final cateringOrder = cateringOrderItems.last;

    final newCartItem = CartItem(
      id: 'catering_${DateTime.now().millisecondsSinceEpoch}',
      img: cateringOrder.img,
      title: cateringOrder.title,
      description: cateringOrder.description,
      pricing: cateringOrder.totalPrice.toStringAsFixed(2),
      ingredients: cateringOrder.combinedIngredients,
      isSpicy: false,
      foodType: 'Catering',
      quantity: 1,
      isOffer: false,
      peopleCount: cateringOrder.dishes.fold(0, (sum, dish) => sum + dish.peopleCount),
      sideRequest: adicionales,
      apetito: apetito,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
    );

    ref.read(cartProvider.notifier).addToCart(newCartItem.toJson(), 1);
    cateringOrderProviderNotifier.clearCateringOrder();
  }

    Map<String, List<CateringItem>> groupCateringItemsByCategory(List<CateringItem> items) {
    Map<String, List<CateringItem>> categorizedItems = {};
    for (var item in items) {
      categorizedItems.putIfAbsent(item.category, () => []).add(item);
    }
    return categorizedItems;
  }

  @override
  Widget build(BuildContext context) {
    final cateringOptions = ref.watch(cateringProvider);
    final cateringOrder = ref.watch(cateringOrderProvider);
    final categorizedItems = groupCateringItemsByCategory(cateringOptions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    context.goNamed(AppRoute.homecart.name);
                  },
                ),
                if (cateringOrder.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cateringOrder.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: Theme.of(context).textTheme.titleSmall,
          unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
          labelColor: ColorsPaletteRedonda.white,
          unselectedLabelColor: ColorsPaletteRedonda.deepBrown1,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: TabIndicator(
            color: ColorsPaletteRedonda.primary,
            radius: 16.0,
          ),
          tabs: categorizedItems.keys
              .map((category) => Tab(text: category))
              .toList(),
        ),
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
              child: TabBarView(
                controller: _tabController,
                children: categorizedItems.keys.map((category) {
                  final items = categorizedItems[category]!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CateringItemCard(
                        item: item,
                        onAddToCart: (int quantity) {
                          ref
                              .read(cateringOrderProvider.notifier)
                              .addCateringItem(CateringDish(
                                title: item.title,
                                peopleCount: 10,
                                pricePerPerson: item.pricePerPerson,
                                ingredients: item.ingredients,
                              ));
                        },
                        sideRequestController: sideRequestController,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _showCateringForm(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Completar Pedido de Catering'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}