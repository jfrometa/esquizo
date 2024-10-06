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

  // Group items by category
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

  @override
  Widget build(BuildContext context) {
    final cateringOptions = ref.watch(cateringProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    // Group items by category
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
                    // Navigate to the cart screen
                    // context.push('/cart'); // Assuming the cart route is '/cart'
                    context.goNamed(
                      AppRoute.homecart.name,
                    );
                  },
                ),
                if (cart.isNotEmpty)
                  Positioned(
                    top: 0, // Adjusts the vertical position of the badge
                    right: 0, // Adjusts the horizontal position of the badge
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
          enableFeedback: false,
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          controller: _tabController,
          isScrollable: true,
          // labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          final sideRequest = sideRequestController.text;

                          cartNotifier.addToCart({
                            'img': item.img,
                            'title': item.title,
                            'description': item.description,
                            'pricing': (item.pricePerPerson * peopleCount)
                                .toStringAsFixed(2),
                            'ingredients': item.ingredients,
                            'isSpicy':
                                false, // Assuming catering items are not spicy
                            'foodType': 'Catering',
                            'sideRequest': sideRequest,
                          }, quantity,
                              isCatering: true,
                              peopleCount: peopleCount,
                              sideRequest: sideRequest);

                          // Clear the side request after adding to cart
                          sideRequestController.clear();
                        },
                        sideRequestController: sideRequestController,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                'Agregar Adicionales',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              children: [
                TextFormField(
                  controller: sideRequestController,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText:
                        'Arroz con fideos 20 personas, Pimientos rellenos 20 personas',
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
                ),
                const SizedBox(height: 16),
              ],
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
