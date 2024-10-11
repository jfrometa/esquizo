import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class CateringScreen extends ConsumerStatefulWidget {
  const CateringScreen({super.key});

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

void _showCateringForm(BuildContext context, CateringItem item) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      String apetito = 'regular';
      String preferencia = 'salado';
      String alergias = '';
      String eventType = '';
      int peopleCount = 10;

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Dismiss Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catering Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: ColorsPaletteRedonda.deepBrown1),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                // Apetito Dropdown with Title
                const Text(
                  'Nivel de Apetito',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: apetito,
                  decoration: InputDecoration(
                    labelText: 'Apetito',
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: ColorsPaletteRedonda.white,
                  ),
                  items: [
                    DropdownMenuItem(value: 'poco', child: Text('Poco')),
                    DropdownMenuItem(value: 'regular', child: Text('Regular')),
                    DropdownMenuItem(value: 'mucho', child: Text('Mucho')),
                  ],
                  onChanged: (value) => setState(() => apetito = value!),
                ),
                const SizedBox(height: 16),
                // Allergies Input with Title
                const Text(
                  'Alergias',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: [
                    for (var allergy in alergias.split(',').where((a) => a.isNotEmpty))
                      Chip(label: Text(allergy.trim())),
                    ActionChip(
                      avatar: Icon(Icons.add, color: ColorsPaletteRedonda.primary),
                      label: Text('Agregar Alergias'),
                      onPressed: () async {
                        var result = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Nueva Alergia', style: Theme.of(context).textTheme.titleMedium),
                            content: TextField(
                              decoration: InputDecoration(
                                hintText: 'Ingresa una alergia',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => alergias = value,
                            ),
                            actions: [
                              TextButton(
                                child: Text('Aceptar'),
                                onPressed: () => Navigator.pop(context, alergias),
                              ),
                            ],
                          ),
                        );
                        if (result != null && result.isNotEmpty) {
                          setState(() => alergias = '${alergias.isEmpty ? '' : '$alergias,'}$result');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Event Type Input with Title
                const Text(
                  'Tipo de Evento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Ej. Cumpleaños, Boda',
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: ColorsPaletteRedonda.white,
                  ),
                  onChanged: (value) => setState(() => eventType = value),
                ),
                const SizedBox(height: 16),
                // People Count Dropdown with Title
                const Text(
                  'Número de Personas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: peopleCount,
                  decoration: InputDecoration(
                    labelText: 'Número de Personas',
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    border: OutlineInputBorder(),
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
                // Preference Dropdown with Title
                const Text(
                  'Preferencia de Sabor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: preferencia,
                  decoration: InputDecoration(
                    labelText: 'Preferencia',
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: ColorsPaletteRedonda.white,
                  ),
                  items: [
                    DropdownMenuItem(value: 'dulce', child: Text('Dulce')),
                    DropdownMenuItem(value: 'salado', child: Text('Salado')),
                  ],
                  onChanged: (value) => setState(() => preferencia = value!),
                ),
                const SizedBox(height: 24),
                // Confirm Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _addToCartWithForm(item, apetito, alergias, eventType,
                          peopleCount, preferencia);
                      Navigator.pop(context);
                    },
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  void _addToCartWithForm(CateringItem item, String apetito, String alergias,
      String eventType, int peopleCount, String preferencia) {
    ref.read(cartProvider.notifier).addToCart(
      {
        'img': item.img,
        'title': item.title,
        'description': item.description,
        'pricing': (item.pricePerPerson * peopleCount).toStringAsFixed(2),
        'ingredients': item.ingredients,
        'apetito': apetito,
        'alergias': alergias,
        'eventType': eventType,
        'peopleCount': peopleCount,
        'preferencia': preferencia,
      },
      1,
      isCatering: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cateringOptions = ref.watch(cateringProvider);
    final cart = ref.watch(cartProvider);
    // final cartNotifier = ref.read(cartProvider.notifier);
    final categorizedItems = groupCateringItemsByCategory(cateringOptions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering'),
        forceMaterialTransparency: true,
        elevation: 3,
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
                if (cart.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cart.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
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
            Text('Construye tu Buffete',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
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
                          _showCateringForm(context, item);
                        },
                        sideRequestController: sideRequestController,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CateringItemCard extends StatefulWidget {
  final CateringItem item;
  final TextEditingController sideRequestController;
  final void Function(int peopleCount, int quantity) onAddToCart;

  const CateringItemCard({
    required this.item,
    required this.onAddToCart,
    required this.sideRequestController,
    super.key,
  });

  @override
  CateringItemCardState createState() => CateringItemCardState();
}

class CateringItemCardState extends State<CateringItemCard> {
  int selectedPeopleCount = 10;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
            child: Image.asset(
              widget.item.img,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  widget.item.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.item.description),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '\$${widget.item.pricePerPerson.toStringAsFixed(2)} por persona'),
                    DropdownButton<int>(
                      value: selectedPeopleCount,
                      dropdownColor: ColorsPaletteRedonda.white,
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
                      items: const [
                        DropdownMenuItem(value: 10, child: Text('10 personas')),
                        DropdownMenuItem(value: 50, child: Text('50 personas')),
                        DropdownMenuItem(
                            value: 100, child: Text('100 personas')),
                      ],
                      onChanged: (int? value) {
                        setState(() {
                          selectedPeopleCount = value ?? 10;
                        });
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.onAddToCart(selectedPeopleCount, quantity);
                      },
                      child: const Text('Agregar al carrito'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabIndicator extends Decoration {
  final BoxPainter _painter;

  TabIndicator({required Color color, required double radius})
      : _painter = _TabIndicatorPainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _TabIndicatorPainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _TabIndicatorPainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Rect rect = _indicatorRectFor(cfg, offset);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rRect, _paint);
  }

  Rect _indicatorRectFor(ImageConfiguration cfg, Offset offset) {
    final double height = cfg.size?.height ?? 0.0;
    final double width = cfg.size?.width ?? 0.0;

    // Define the desired height of the indicator
    const double indicatorHeight = 32.0; // Adjust as needed
    // Define horizontal padding
    const double horizontalPadding = 8.0; // Adjust to match labelPadding

    // Calculate top position to center the indicator vertically
    final double top = offset.dy + (height - indicatorHeight) / 2;

    // Calculate left position
    final double left = offset.dx + horizontalPadding;

    // Create the rectangle for the indicator
    return Rect.fromLTWH(
      left,
      top,
      width - 2 * horizontalPadding,
      indicatorHeight,
    );
  }
}
