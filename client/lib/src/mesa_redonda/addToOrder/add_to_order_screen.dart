import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/restaurants.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class AddToOrderScreen extends StatefulWidget {
  const AddToOrderScreen({super.key, required this.index});
  final int index;  // Index passed from previous screen

  @override
  State<AddToOrderScreen> createState() => _AddToOrderScreenState();
}

class _AddToOrderScreenState extends State<AddToOrderScreen> {
  late final Map<String, dynamic> selectedItem;  // The selected item data

  @override
  void initState() {
    super.initState();
    selectedItem = plans[widget.index];  // Retrieve data based on index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(selectedItem['title'], style: const TextStyle(color: ColorsPaletteRedonda.primary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorsPaletteRedonda.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: ColorsPaletteRedonda.primary),
            onPressed: () {
              // Handle cart action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 350,  // Image max height
              width: double.infinity,
              child: Image.network(selectedItem['img'], fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedItem['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "\$${selectedItem['pricing']}",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedItem['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            if (selectedItem['quantity'] > 1) {
                              selectedItem['quantity']--;
                            }
                          });
                        },
                        backgroundColor: Colors.black,
                        child: const Icon(Icons.remove, color: Colors.white),
                      ),
                      Text(
                        selectedItem['quantity'].toString(),
                        style: const TextStyle(fontSize: 24),
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            selectedItem['quantity']++;
                          });
                        },
                        backgroundColor: Colors.black,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      ),
                      onPressed: () {
                        // Handle add to cart
                      },
                      child: const Text("Add to Cart"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}