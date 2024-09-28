import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class CateringScreen extends ConsumerWidget {
  const CateringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cateringOptions = ref.watch(cateringProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final TextEditingController sideRequestController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering'),
        forceMaterialTransparency: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cateringOptions.length,
                itemBuilder: (context, index) {
                  final item = cateringOptions[index];
                  return CateringItemCard(
                    item: item,
                    onAddToCart: (int peopleCount, int quantity) {
                      final sideRequest = sideRequestController.text;

                      // Adding to the cart as a CartItem
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
                        'sideRequest':
                            sideRequest, // Add side request to the item
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
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: sideRequestController,
              style: Theme.of(context).textTheme.labelLarge,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Aditionales',
                // labelStyle: Theme.of(context).textTheme,
                hintText:
                    'Arroz con fideos 20 personas, Pimientos rellenos 20 personas',
                filled: true,
                fillColor:
                    ColorsPaletteRedonda.white, // Gray background when filled
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda
                        .deepBrown1, // Red border when not selected
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda
                        .primary, // Black border when focused
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Complete Order'),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.item.description),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '\$${widget.item.pricePerPerson.toStringAsFixed(2)} per person'),
                DropdownButton<int>(
                  value: selectedPeopleCount,
                  dropdownColor: ColorsPaletteRedonda.white,
                  underline: Container(
                    height: 0, // Removes the underline
                    color: Colors.transparent,
                  ),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10 people')),
                    DropdownMenuItem(value: 50, child: Text('50 people')),
                    DropdownMenuItem(value: 100, child: Text('100 people')),
                  ],
                  onChanged: (int? value) {
                    setState(() {
                      selectedPeopleCount = value ?? 10;
                    });

                    // Ensure this is a separate statement
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Controls
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
    );
  }
}
