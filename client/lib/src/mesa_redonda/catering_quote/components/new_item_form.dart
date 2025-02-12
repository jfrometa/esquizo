import 'package:flutter/material.dart';

class NewItemFormData {
  final String name;
  final String description;
  final int? quantity;

  NewItemFormData({
    required this.name,
    required this.description,
    this.quantity,
  });
}

class NewItemForm extends StatefulWidget {
  final void Function(NewItemFormData formData) onSubmit;
  final bool autofocus;

  const NewItemForm({
    super.key,
    required this.onSubmit,
    this.autofocus = true,
  });

  @override
  State<NewItemForm> createState() => _NewItemFormState();
}

class _NewItemFormState extends State<NewItemForm> {
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_itemNameController.text.trim().isEmpty) return;

    widget.onSubmit(
      NewItemFormData(
        name: _itemNameController.text.trim(),
        description: _itemDescriptionController.text.trim(),
        quantity: int.tryParse(_quantityController.text),
      ),
    );

    _itemNameController.clear();
    _itemDescriptionController.clear();
    _quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar Nuevo Item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Item *',
                border: OutlineInputBorder(),
                filled: true,
              ),
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _itemDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (Opcional)',
                border: OutlineInputBorder(),
                filled: true,
              ),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad (Opcional)',
                border: OutlineInputBorder(),
                filled: true,
                hintText: 'Dejar vacío para usar cantidad general',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitForm(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Agregar Item'),
            ),
          ],
        ),
      ),
    );
  }
}