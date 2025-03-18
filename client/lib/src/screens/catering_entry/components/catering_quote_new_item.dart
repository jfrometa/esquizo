// lib/src/mesa_redonda/catering_entry/widgets/new_item_form.dart
import 'package:flutter/material.dart';

class NewItemForm extends StatelessWidget {
  final VoidCallback onAddItem;
  final TextEditingController itemNameController;
  final TextEditingController quantityController;
  final TextEditingController itemDescriptionController;
  const NewItemForm({
    super.key,
    required this.onAddItem,
    required this.itemNameController,
    required this.quantityController,
    required this.itemDescriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agregar Nuevo Item',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: itemNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Item',
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: itemDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción (Opcional)',
            border: OutlineInputBorder(),
            filled: true,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: quantityController,
          decoration: const InputDecoration(
            labelText: 'Cantidad (Opcional)',
            border: OutlineInputBorder(),
            filled: true,
          ),
          keyboardType: TextInputType.number,
          onSubmitted: (_) => onAddItem(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onAddItem,
          child: const Text('Agregar Item'),
        ),
      ],
    );
  }
}