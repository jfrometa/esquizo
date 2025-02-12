import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering_entry/components/catering_quote_new_item.dart';

class NewItemDialog {
  static Future<void> show({
    required BuildContext context,
    required void Function(String name, String description, int? quantity) onAddItem,
  }) async {
    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController itemDescriptionController = TextEditingController();

    try {
      final isDesktop = MediaQuery.of(context).size.width > 600;

      if (isDesktop) {
        return showDialog(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nuevo Item',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    NewItemForm(
                      onAddItem: () {
                         final quantity = int.tryParse(quantityController.text);
                        onAddItem(
                          itemNameController.text.trim(),
                          itemDescriptionController.text.trim(),
                          quantity,
                        );
                        Navigator.of(context).pop();
                      },
                      itemNameController: itemNameController,
                      quantityController: quantityController,
                      itemDescriptionController: itemDescriptionController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nuevo Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              NewItemForm(
                onAddItem: () {
                  final quantity = int.tryParse(quantityController.text);
                  onAddItem(
                    itemNameController.text.trim(),
                    itemDescriptionController.text.trim(),
                    quantity,
                  );
                  Navigator.of(context).pop();
                },
                itemNameController: itemNameController,
                quantityController: quantityController,
                itemDescriptionController: itemDescriptionController,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    } finally {
      // Dispose controllers if they were created internally
      if (itemNameController == null) itemNameController.dispose();
      if (quantityController == null) quantityController.dispose();
      if (itemDescriptionController == null) itemDescriptionController.dispose();
    }
  }
}