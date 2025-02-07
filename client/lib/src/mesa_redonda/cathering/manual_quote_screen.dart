import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

final manualQuoteProvider = StateNotifierProvider<ManualQuoteNotifier, CateringOrderItem?>((ref) {
  return ManualQuoteNotifier();
});

class ManualQuoteNotifier extends StateNotifier<CateringOrderItem?> {
  ManualQuoteNotifier() : super(CateringOrderItem(
    title: 'Manual Quote',
    img: '',
    description: '',
    dishes: [],
    hasChef: false,
    alergias: '',
    eventType: '',
    preferencia: '',
    adicionales: '',
    peopleCount: 0,
  ));

  void addManualItem(CateringDish dish) {
    state = state?.copyWith(
      dishes: [...state!.dishes, dish],
    );
  }

  void removeItem(int index) {
    final newDishes = List<CateringDish>.from(state!.dishes);
    newDishes.removeAt(index);
    state = state?.copyWith(dishes: newDishes);
  }

  void updateQuoteDetails({
    bool? hasChef,
    String? alergias,
    String? eventType,
    String? preferencia,
    String? adicionales,
    int? peopleCount,
  }) {
    state = state?.copyWith(
      hasChef: hasChef ?? state?.hasChef,
      alergias: alergias ?? state?.alergias,
      eventType: eventType ?? state?.eventType,
      preferencia: preferencia ?? state?.preferencia,
      adicionales: adicionales ?? state?.adicionales,
      peopleCount: peopleCount ?? state?.peopleCount,
    );
  }
}

class ManualQuoteScreen extends ConsumerStatefulWidget {
  const ManualQuoteScreen({super.key});

  @override
  ConsumerState<ManualQuoteScreen> createState() => _ManualQuoteScreenState();
}

class _ManualQuoteScreenState extends ConsumerState<ManualQuoteScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool isEditing = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Item',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _itemDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Precio por Unidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final price = double.tryParse(_priceController.text) ?? 0;
              final quantity = int.tryParse(_quantityController.text) ?? 1;
              
              ref.read(manualQuoteProvider.notifier).addManualItem(
                CateringDish(
                  title: _itemNameController.text,
                  pricePerUnit: price,
                  quantity: quantity,
                  hasUnitSelection: true,
                  peopleCount: 1, pricePerPerson: 0, ingredients: [], pricing: 0,
                ),
              );

              _itemNameController.clear();
              _itemDescriptionController.clear();
              _priceController.clear();
              _quantityController.clear();
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quote = ref.watch(manualQuoteProvider);
    final items = quote?.dishes ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotización Manual'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () => setState(() => isEditing = !isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles del Evento',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildEventDetails(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items Solicitados',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _showAddItemDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildItemsList(items),
                    if (items.isNotEmpty) ...[
                      const Divider(),
                      Text(
                        'Total: \$${quote?.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: items.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement quote submission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsPaletteRedonda.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Solicitar Cotización'),
              ),
            )
          : null,
    );
  }

  Widget _buildEventDetails() {
    final quote = ref.watch(manualQuoteProvider);
    return Column(
      children: [
        _buildDetailField(
          'Cantidad de Personas',
          quote?.peopleCount.toString() ?? '0',
          (value) {
            final count = int.tryParse(value);
            if (count != null) {
              ref.read(manualQuoteProvider.notifier).updateQuoteDetails(
                peopleCount: count,
              );
            }
          },
        ),
        _buildDetailField(
          'Tipo de Evento',
          quote?.eventType ?? '',
          (value) => ref.read(manualQuoteProvider.notifier).updateQuoteDetails(
            eventType: value,
          ),
        ),
        _buildDetailField(
          'Alergias',
          quote?.alergias ?? '',
          (value) => ref.read(manualQuoteProvider.notifier).updateQuoteDetails(
            alergias: value,
          ),
        ),
        _buildDetailField(
          'Notas Adicionales',
          quote?.adicionales ?? '',
          (value) => ref.read(manualQuoteProvider.notifier).updateQuoteDetails(
            adicionales: value,
          ),
        ),
        SwitchListTile(
          title: const Text('Incluir Chef'),
          value: quote?.hasChef ?? false,
          onChanged: (value) => ref.read(manualQuoteProvider.notifier).updateQuoteDetails(
            hasChef: value,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailField(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isEditing
          ? TextField(
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(
                TextPosition(offset: value.length),
              ),
              onChanged: onChanged,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value.isEmpty ? 'No especificado' : value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
    );
  }

  Widget _buildItemsList(List<CateringDish> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text('${item.quantity}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text('\$${(item.pricePerUnit * item.quantity).toStringAsFixed(2)}'),
              if (isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => ref.read(manualQuoteProvider.notifier).removeItem(index),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}