import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class CateringFormData {
  final String eventType;
  final int peopleCount;
  final List<String> allergies;
  final bool hasChef;
  final String additionalNotes;

  CateringFormData({
    required this.eventType,
    required this.peopleCount,
    required this.allergies,
    required this.hasChef,
    required this.additionalNotes,
  });
}

class CateringForm extends ConsumerStatefulWidget {
  final CateringOrderItem? initialData;
  final void Function(CateringFormData formData) onSubmit;

  const CateringForm({
    super.key,
    this.initialData,
    required this.onSubmit,
  });

  @override
  ConsumerState<CateringForm> createState() => _CateringFormState();
}

class _CateringFormState extends ConsumerState<CateringForm> {
  final customPersonasFocusNode = FocusNode();
  late TextEditingController eventTypeController;
  late TextEditingController adicionalesController;
  bool isCustomSelected = false;
  List<String> alergiasList = [];
  bool hasChef = false;
  int? cantidadPersonas;

  final peopleQuantity = [10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000, 2000, 5000, 10000];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final initialData = widget.initialData;
    eventTypeController = TextEditingController(text: initialData?.eventType ?? '');
    adicionalesController = TextEditingController(text: initialData?.adicionales ?? '');
    hasChef = initialData?.hasChef ?? false;
    cantidadPersonas = initialData?.peopleCount;
    alergiasList = initialData?.alergias.split(',').where((e) => e.isNotEmpty).toList() ?? [];

    if (cantidadPersonas != null && !peopleQuantity.contains(cantidadPersonas)) {
      isCustomSelected = true;
    }
  }

  @override
  void dispose() {
    customPersonasFocusNode.dispose();
    eventTypeController.dispose();
    adicionalesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (cantidadPersonas == null || cantidadPersonas! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad de personas es requerida')),
      );
      return;
    }

    if (eventTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El tipo de evento es requerido')),
      );
      return;
    }

    widget.onSubmit(CateringFormData(
      eventType: eventTypeController.text,
      peopleCount: cantidadPersonas!,
      allergies: alergiasList,
      hasChef: hasChef,
      additionalNotes: adicionalesController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detalles de la orden',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: Icon(Icons.close, color: ColorsPaletteRedonda.deepBrown1),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Cantidad de Personas',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: !isCustomSelected && peopleQuantity.contains(cantidadPersonas)
                ? cantidadPersonas
                : null,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              labelText: isCustomSelected
                  ? 'Cantidad Personalizada'
                  : 'Cantidad de Personas',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: ColorsPaletteRedonda.white,
            ),
            items: [
              ...peopleQuantity.map(
                (number) => DropdownMenuItem<int>(
                  value: number,
                  child: Text('$number'),
                ),
              ),
              const DropdownMenuItem<int>(
                value: -1,
                child: Text('Personalizado'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                if (value == -1) {
                  isCustomSelected = true;
                  cantidadPersonas = null;
                  Future.delayed(const Duration(milliseconds: 200), () {
                    customPersonasFocusNode.requestFocus();
                  });
                } else {
                  isCustomSelected = false;
                  cantidadPersonas = value;
                }
              });
            },
          ),
          if (isCustomSelected) ...[
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: cantidadPersonas?.toString()),
              focusNode: customPersonasFocusNode,
              decoration: const InputDecoration(
                labelText: 'Cantidad Personalizada',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: ColorsPaletteRedonda.white,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final customValue = int.tryParse(value);
                if (customValue != null) {
                  setState(() => cantidadPersonas = customValue);
                }
              },
            ),
          ],
          const SizedBox(height: 16),
          const Text('Alergias', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: [
              ...alergiasList.map(
                (allergy) => Chip(
                  backgroundColor: ColorsPaletteRedonda.primary,
                  label: Text(
                    allergy,
                    style: const TextStyle(color: Colors.white),
                  ),
                  deleteIconColor: Colors.white,
                  onDeleted: () {
                    setState(() => alergiasList.remove(allergy));
                  },
                ),
              ),
              if (alergiasList.length < 10)
                ActionChip(
                  backgroundColor: Colors.white,
                  avatar: Icon(Icons.add, color: ColorsPaletteRedonda.primary),
                  label: Text('Agregar Alergia',
                      style: TextStyle(color: ColorsPaletteRedonda.primary)),
                  onPressed: _showAllergyDialog,
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Tipo de Evento',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: eventTypeController,
            decoration: const InputDecoration(
              labelText: 'Ej. Cumpleaños, Boda',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: ColorsPaletteRedonda.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agregar Servicio de Chef',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: hasChef,
                inactiveTrackColor: ColorsPaletteRedonda.deepBrown,
                activeColor: ColorsPaletteRedonda.primary,
                onChanged: (value) => setState(() => hasChef = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ExpansionTile(
            title: const Text('Notas Adicionales'),
            children: [
              TextFormField(
                controller: adicionalesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '',
                  filled: true,
                  fillColor: ColorsPaletteRedonda.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: ColorsPaletteRedonda.deepBrown1,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: ColorsPaletteRedonda.primary,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 42,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(ColorsPaletteRedonda.orange),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: _handleSubmit,
                child: const Text('Confirmar Detalles'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
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

    if (newAllergy?.isNotEmpty == true && !alergiasList.contains(newAllergy)) {
      setState(() => alergiasList.add(newAllergy!));
    }
  }
}