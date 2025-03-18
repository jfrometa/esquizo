import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/components/catering_quote_new_item.dart';

class NewItemDialog {
  static Future<void> show({
    required BuildContext context,
    required void Function(String name, String description, int? quantity) onAddItem,
  }) async {
    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController itemDescriptionController = TextEditingController();

    try {
      final isDesktop = MediaQuery.sizeOf(context).width > 600;

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
            bottom: MediaQuery.viewInsetsOf(context).bottom,
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
      if (quantityController == null) quantityController.dispose();
    }
  }
}