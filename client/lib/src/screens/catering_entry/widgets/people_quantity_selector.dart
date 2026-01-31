import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/catering/catering_order_provider.dart';

class PeopleQuantitySelector extends ConsumerStatefulWidget {
  final List<int> quantities;

  const PeopleQuantitySelector({
    super.key,
    required this.quantities,
  });

  @override
  ConsumerState<PeopleQuantitySelector> createState() =>
      _PeopleQuantitySelectorState();
}

class _PeopleQuantitySelectorState
    extends ConsumerState<PeopleQuantitySelector> {
  bool isCustomSelected = false;
  final customPersonasFocusNode = FocusNode();
  late TextEditingController customPersonasController;

  @override
  void initState() {
    super.initState();
    final order = ref.read(cateringOrderNotifierProvider);
    customPersonasController = TextEditingController(
      text: order?.peopleCount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    customPersonasFocusNode.dispose();
    customPersonasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(cateringOrderNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cantidad de Personas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: isCustomSelected ||
                  order?.peopleCount == null ||
                  !widget.quantities.contains(order?.peopleCount)
              ? null
              : order?.peopleCount,
          dropdownColor: Theme.of(context).cardColor,
          decoration: const InputDecoration(
            labelText: 'Cantidad de Personas',
            border: OutlineInputBorder(),
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: [
            ...widget.quantities.map(
              (number) => DropdownMenuItem<int>(
                value: number,
                child: Text('$number personas'),
              ),
            ),
            const DropdownMenuItem<int>(
              value: -1,
              child: Text('Personalizado'),
            ),
          ],
          onChanged: _handleQuantityChange,
        ),
        if (isCustomSelected)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: TextField(
                controller: customPersonasController,
                focusNode: customPersonasFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Personalizada',
                  border: OutlineInputBorder(),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: _handleCustomQuantityChange,
              ),
            ),
          ),
      ],
    );
  }

  void _handleQuantityChange(int? value) {
    if (value == -1) {
      setState(() {
        isCustomSelected = true;
        customPersonasController.clear();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        customPersonasFocusNode.requestFocus();
      });
    } else {
      setState(() {
        isCustomSelected = false;
      });
      _updateOrderQuantity(value ?? 0);
    }
  }

  void _handleCustomQuantityChange(String value) {
    final count = int.tryParse(value);
    if (count != null) {
      _updateOrderQuantity(count);
    }
  }

  void _updateOrderQuantity(int count) {
    final order = ref.read(cateringOrderNotifierProvider);
    if (order != null) {
      ref.read(cateringOrderNotifierProvider.notifier).updateOrder(
            order.copyWith(peopleCount: count),
          );
    }
  }
}
