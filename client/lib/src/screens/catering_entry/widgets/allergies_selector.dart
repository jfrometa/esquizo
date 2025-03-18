import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/catering/catering_order_provider.dart';

class AllergiesSelector extends ConsumerStatefulWidget {
  final int maxAllergies;
  
  const AllergiesSelector({
    super.key,
    this.maxAllergies = 10,
  });

  @override
  ConsumerState<AllergiesSelector> createState() => _AllergiesSelectorState();
}

class _AllergiesSelectorState extends ConsumerState<AllergiesSelector> {
  List<String> allergiesList = [];

  @override
  void initState() {
    super.initState();
    final order = ref.read(cateringOrderProvider);
    allergiesList = order?.alergias.split(',').where((e) => e.isNotEmpty).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alergias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...allergiesList.map(
              (allergy) => Chip(
                backgroundColor: primaryColor,
                label: Text(
                  allergy,
                  style: const TextStyle(color: Colors.white),
                ),
                deleteIconColor: Colors.white,
                onDeleted: () => _removeAllergy(allergy),
              ),
            ),
            if (allergiesList.length < widget.maxAllergies)
              ActionChip(
                backgroundColor: Colors.white,
                avatar: Icon(Icons.add, color: primaryColor),
                label: Text('Agregar Alergia', 
                    style: TextStyle(color: primaryColor)),
                onPressed: _showAllergyDialog,
              ),
          ],
        ),
      ],
    );
  }

  void _removeAllergy(String allergy) {
    setState(() {
      allergiesList.remove(allergy);
    });
    _updateOrderAllergies();
  }

  Future<void> _showAllergyDialog() async {
    String? allergyInput;
    final newAllergy = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Alergia'),
        content: TextField(
          onChanged: (value) => allergyInput = value,
          decoration: const InputDecoration(
            hintText: 'Ingresa una alergia',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (allergyInput?.isNotEmpty == true) {
                Navigator.pop(context, allergyInput);
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (newAllergy?.isNotEmpty == true && 
        !allergiesList.contains(newAllergy)) {
      setState(() => allergiesList.add(newAllergy!));
      _updateOrderAllergies();
    }
  }

  void _updateOrderAllergies() {
    final order = ref.read(cateringOrderProvider);
    if (order != null) {
      ref.read(cateringOrderProvider.notifier).updateOrder(
        order.copyWith(alergias: allergiesList.join(',')),
      );
    }
  }
}