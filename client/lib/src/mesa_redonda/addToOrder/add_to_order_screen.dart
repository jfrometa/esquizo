import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/restaurants.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class AddToOrderScreen extends StatefulWidget {
  const AddToOrderScreen({super.key, required this.index});
  final int index; // Index passed from the previous screen

  @override
  State<AddToOrderScreen> createState() => _AddToOrderScreenState();
}

class _AddToOrderScreenState extends State<AddToOrderScreen> {
  late final Map<String, dynamic> selectedItem; // The selected item data
  int quantity = 1; // Default quantity set to 1

  @override
  void initState() {
    super.initState();
    selectedItem = plans[widget.index]; // Retrieve data based on index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          selectedItem['title'],
          style: const TextStyle(color: ColorsPaletteRedonda.primary),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: ColorsPaletteRedonda.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300, // Image max height
                    width: double.infinity,
                    child: Image.asset(selectedItem['img'], fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      selectedItem['title'],
                      style: const TextStyle(
                        color: ColorsPaletteRedonda.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "\$${(double.tryParse(selectedItem['pricing'].toString())?.toStringAsFixed(2) ?? '0.00')}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.orangeAccent[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      selectedItem['description'],
                      style: const TextStyle(
                        color: ColorsPaletteRedonda.deepBrown,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Tipo: ${selectedItem['foodType']}",
                          style: const TextStyle(
                            color: ColorsPaletteRedonda.deepBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        if (selectedItem['isSpicy'])
                          const Text(
                            "Picante 🌶️",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Ingredientes:",
                      style: TextStyle(
                        color: ColorsPaletteRedonda.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: selectedItem['ingredients']
                          .map<Widget>((ingredient) => Chip(
                                side: BorderSide.none,
                                label: Text(
                                  ingredient,
                                  style: const TextStyle(
                                      color: ColorsPaletteRedonda.white,
                                      fontStyle: FontStyle.normal),
                                ),
                                backgroundColor: ColorsPaletteRedonda.primary,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quantity section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove,
                  color: ColorsPaletteRedonda.lightBrown,
                ),
                onPressed: () {
                  setState(() {
                    if (quantity > 1) {
                      quantity--; // Decrease quantity
                    }
                  });
                },
              ),
              Text(
                quantity.toString(), // Display the current quantity
                style: const TextStyle(
                    fontSize: 24, color: ColorsPaletteRedonda.primary),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  color: ColorsPaletteRedonda.lightBrown,
                ),
                onPressed: () {
                  setState(() {
                    quantity++; // Increase quantity
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).goNamed(AppRoute.homecart.name);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  'Agregar al carrito',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                    color: ColorsPaletteRedonda.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
