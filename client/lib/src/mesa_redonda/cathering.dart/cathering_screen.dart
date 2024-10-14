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
  const CateringScreen({Key? key}) : super(key: key);

  @override
  _CateringScreenState createState() => _CateringScreenState();
}

class _CateringScreenState extends ConsumerState<CateringScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController sideRequestController = TextEditingController();
  late TabController _tabController;

  Map<String, List<CateringItem>> groupCateringItemsByCategory(
      List<CateringItem> items) {
    Map<String, List<CateringItem>> categorizedItems = {};
    for (var item in items) {
      categorizedItems.putIfAbsent(item.category, () => []).add(item);
    }
    return categorizedItems;
  }

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
    int peopleCount = 10;
    String adicionales = '';
    List<String> alergiasList = [];

    void addAllergy(String value) {
      if (value.isNotEmpty) {
        value = value.toLowerCase().trim();
        if (!alergiasList.contains(value)) {
          setState(() => alergiasList.add(value));
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String? newAllergy = '';

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
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
                      icon: Icon(Icons.close, color: ColorsPaletteRedonda.deepBrown1),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const Text('Nivel de Apetito', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: apetito,
                  decoration: InputDecoration(
                    labelText: 'Apetito',
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: ColorsPaletteRedonda.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'poco', child: Text('Poco')),
                    DropdownMenuItem(value: 'regular', child: Text('Regular')),
                    DropdownMenuItem(value: 'mucho', child: Text('Mucho')),
                  ],
                  onChanged: (value) => setState(() => apetito = value!),
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
                          setState(() => alergiasList.remove(allergy));
                        },
                      ),
                    if (alergiasList.length < 10)
                      ActionChip(
                        avatar: Icon(Icons.add, color: ColorsPaletteRedonda.primary),
                        label: const Text('Agregar Alergia'),
                        onPressed: () async {
                          newAllergy = await showDialog<String>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Nueva Alergia',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              content: TextField(
                                onChanged: (value) => newAllergy = value,
                                onSubmitted: (value) {
                                  addAllergy(value);
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
                                    addAllergy(newAllergy ?? '');
                                    Navigator.pop(context, newAllergy);
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            ),
                          );
                          if (newAllergy != null) {
                            addAllergy(newAllergy!);
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
                  onChanged: (value) => setState(() => eventType = value),
                ),
                const SizedBox(height: 16),
                const Text('Número de Personas', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: peopleCount,
                  decoration: InputDecoration(
                    labelText: 'Número de Personas',
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: ColorsPaletteRedonda.white,
                  ),
                  items: [
                    for (var i = 10; i <= 50; i += 10)
                      DropdownMenuItem(value: i, child: Text('$i personas')),
                    for (var i = 100; i <= 500; i += 100)
                      DropdownMenuItem(value: i, child: Text('$i personas')),
                  ],
                  onChanged: (value) => setState(() => peopleCount = value!),
                ),
                const SizedBox(height: 16),
                const Text('Preferencia de Sabor', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: preferencia,
                  decoration: InputDecoration(
                    labelText: 'Preferencia',
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: ColorsPaletteRedonda.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'dulce', child: Text('Dulce')),
                    DropdownMenuItem(value: 'salado', child: Text('Salado')),
                  ],
                  onChanged: (value) => setState(() => preferencia = value!),
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: Text('Agregar Adicionales', style: Theme.of(context).textTheme.titleMedium),
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
                      onChanged: (value) => setState(() => adicionales = value),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _addToCartWithForm(
                        apetito, 
                        alergiasList.join(','), 
                        eventType,
                        peopleCount, 
                        preferencia, 
                        adicionales
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCartWithForm(
      String apetito,
      String alergias,
      String eventType,
      int peopleCount,
      String preferencia,
      String adicionales,
    ) {
    final cateringOrder = ref.read(cateringOrderProvider);
    if (cateringOrder.isNotEmpty) {
      final totalPrice = cateringOrder.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      final combinedIngredients = cateringOrder
          .expand((orderItem) => orderItem.combinedIngredients)
          .toList();

      final newOrderItem = CartItem(
        id: 'catering_${DateTime.now().millisecondsSinceEpoch}',
        img: cateringOrder[0].img,
        title: 'Catering Order',
        description: 'Catering order for $peopleCount people',
        pricing: totalPrice.toStringAsFixed(2),
        ingredients: combinedIngredients,
        isSpicy: false,
        foodType: 'Catering',
        quantity: 1,
        isOffer: false,
        peopleCount: peopleCount,
        sideRequest: adicionales,
        apetito: apetito,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
      );

      ref.read(cartProvider.notifier).addToCart(newOrderItem.toJson(), 1);
      ref.read(cateringOrderProvider.notifier).clearCateringOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cateringOptions = ref.watch(cateringProvider);
    final cart = ref.watch(cartProvider);
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
                if (cateringOrder.isNotEmpty || cart.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cart.length + cateringOrder.length}',
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
                        onAddToCart: (int peopleCount, int quantity) {
                          ref.read(cateringOrderProvider.notifier)
                              .addCateringItem(CateringDish(
                                title: item.title,
                                peopleCount: peopleCount,
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
            if (cateringOrder.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () => _showCateringForm(context),
                  child: const Text('Completar Pedido de Catering'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}