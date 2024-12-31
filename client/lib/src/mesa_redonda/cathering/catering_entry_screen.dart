import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_item.dart';

class CateringEntryScreen extends StatefulWidget {
  const CateringEntryScreen({super.key});

  @override
  State<CateringEntryScreen> createState() => _CateringEntryScreenState();
}

class _CateringEntryScreenState extends State<CateringEntryScreen> {
  List<CateringItem> items = []; // List to hold added catering items

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            bool isQuote = false;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¿Qué deseas agregar?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setModalState(() => isQuote = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isQuote ? Colors.grey : Colors.blue,
                        ),
                        child: const Text('Orden'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setModalState(() => isQuote = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isQuote ? Colors.blue : Colors.grey,
                        ),
                        child: const Text('Cotización'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isQuote)
                    _buildQuoteForm(setModalState)
                  else
                    _buildOrderForm(setModalState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuoteForm(StateSetter setModalState) {
    final List<int> unitOptions = [25, 50, 75, 100, 150];
    int selectedUnits = 25;

    return Column(
      children: [
        const Text(
          'Selecciona la cantidad de unidades:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedUnits,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: unitOptions
              .map((unit) =>
                  DropdownMenuItem<int>(value: unit, child: Text('$unit')))
              .toList(),
          onChanged: (value) {
            setModalState(() {
              selectedUnits = value ?? 25;
            });
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close the modal
            setState(() {
              items.add(
                CateringItem(
                  title: 'Nueva Cotización',
                  description: 'Unidades seleccionadas: $selectedUnits',
                  quantity: selectedUnits,
                  pricePerUnit: 100.0,
                  img: 'assets/default.png',
                  hasUnitSelection: true,
                  category: '',
                  pricing: items.first.pricePerUnit,
                  ingredients: [],
                ),
              );
            });
          },
          child: const Text('Agregar'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOrderForm(StateSetter setModalState) {
    return Column(
      children: [
        const Text(
          'Ingresa los detalles del pedido:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Nombre del platillo',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Handle order details
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close the modal
            setState(() {
              items.add(
                CateringItem(
                  title: 'Nuevo Pedido',
                  description: 'Detalles del pedido agregado',
                  quantity: 1,
                  pricePerUnit: 100.0,
                  img: 'assets/default.png',
                  hasUnitSelection: false,
                  category: '',
                  pricing: 100.0,
                  ingredients: [],
                ),
              );
            });
          },
          child: const Text('Agregar'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering'),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No hay elementos en el pedido.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showBottomSheet,
                    child: const Text('Agregar elemento'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Image.asset(
                    item.img,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.description),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheet,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
