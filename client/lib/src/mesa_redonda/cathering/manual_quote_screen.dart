import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class ManualQuoteScreen extends ConsumerStatefulWidget {
  const ManualQuoteScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ManualQuoteScreen> createState() => _ManualQuoteScreenState();
}

class _ManualQuoteScreenState extends ConsumerState<ManualQuoteScreen> {
  // Controllers for new item form and event details.
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _customPersonasController = TextEditingController();
  final FocusNode _customPersonasFocusNode = FocusNode();
  final List<int> peopleQuantity =
      const [10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000];

  // Local UI state.
  bool isCustomSelected = false;
  bool isEditing = true;
  List<String> alergiasList = [];

  // Controls whether the event details are collapsed.
  // When required fields are filled, the header shows a summary.
  bool _eventDetailsCollapsed = false;

  @override
  void initState() {
    super.initState();
    // Initialize manual quote details.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(manualQuoteProvider.notifier).updateQuoteDetails(
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: '',
        adicionales: '',
        peopleCount: 0,
      );
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    _eventTypeController.dispose();
    _customPersonasController.dispose();
    _customPersonasFocusNode.dispose();
    super.dispose();
  }

  /// Adds a new item to the quote.
  /// If the manual quantity is not provided, uses the general quantity (people count).
  void _addItem() {
    if (_itemNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del item es requerido')),
      );
      return;
    }
    final manualQuantity = int.tryParse(_quantityController.text);
    final generalQuantity = ref.read(manualQuoteProvider)?.peopleCount ?? 0;
    final quantity = manualQuantity ?? generalQuantity;

    try {
      ref.read(manualQuoteProvider.notifier).addManualItem(
        CateringDish(
          title: _itemNameController.text.trim(),
          quantity: quantity,
          hasUnitSelection: manualQuantity != null,
          peopleCount: quantity != 0 ? quantity : generalQuantity ,
          pricePerUnit: 0,
          pricePerPerson: 0,
          ingredients: [],
          pricing: 0,
        ),
      );
      _itemNameController.clear();
      _itemDescriptionController.clear();
      _quantityController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar item: $e')),
      );
    }
  }

  /// Builds an inline form for adding a new item.
  Widget _buildNewItemForm() {
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
              autofocus: true,
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
              onSubmitted: (_) => _addItem(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Agregar Item'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of added items.
  Widget _buildItemsList(List<CateringDish> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: item.title.isNotEmpty
                ? Text(
                    item.title,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  )
                : null,
            trailing: isEditing
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        ref.read(manualQuoteProvider.notifier).removeFromCart(index),
                  )
                : null,
          ),
        );
      },
    );
  }

  /// Builds the event details input fields.
  Widget _buildEventDetails() {
    final quote = ref.watch(manualQuoteProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeopleQuantitySection(),
        const SizedBox(height: 16),
        TextField(
          controller: _eventTypeController,
          decoration: const InputDecoration(
            labelText: 'Tipo de Evento',
            hintText: 'Ej. Cumpleaños, Boda',
            border: OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (value) {
            ref
                .read(manualQuoteProvider.notifier)
                .updateQuoteDetails(eventType: value);
          },
        ),
        const SizedBox(height: 16),
        _buildAllergiesSection(),
        const SizedBox(height: 16),
        _buildAdditionalNotesSection(),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Incluir Chef'),
          value: quote?.hasChef ?? false,
          onChanged: (value) {
            ref
                .read(manualQuoteProvider.notifier)
                .updateQuoteDetails(hasChef: value);
          },
        ),
      ],
    );
  }

  /// Wraps the event details in a collapsible (ExpansionTile) widget.
  Widget _buildCollapsibleEventDetails() {
    final quote = ref.watch(manualQuoteProvider);
    final isFilled =
        (quote?.eventType.isNotEmpty ?? false) && (quote?.peopleCount ?? 0) > 0;
    return ExpansionTile(
      initiallyExpanded: !isFilled,
      title: isFilled
          ? Text('Evento: ${quote?.eventType} - ${quote?.peopleCount} personas')
          : const Text('Detalles del Evento'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildEventDetails(),
        ),
      ],
      onExpansionChanged: (expanded) {
        setState(() {
          _eventDetailsCollapsed = !expanded;
        });
      },
    );
  }

  /// Builds the people quantity section with a dropdown and optional custom field.
  Widget _buildPeopleQuantitySection() {
    final quote = ref.watch(manualQuoteProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cantidad de Personas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: isCustomSelected ||
                  quote?.peopleCount == null ||
                  !peopleQuantity.contains(quote?.peopleCount)
              ? null
              : quote?.peopleCount,
          dropdownColor: Theme.of(context).cardColor,
          decoration: const InputDecoration(
            labelText: 'Cantidad de Personas',
            border: OutlineInputBorder(),
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: [
            ...peopleQuantity.map(
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
          onChanged: (value) {
            if (value == -1) {
              setState(() {
                isCustomSelected = true;
                _customPersonasController.clear();
                ref.read(manualQuoteProvider.notifier)
                    .updateQuoteDetails(peopleCount: 0);
              });
              Future.delayed(const Duration(milliseconds: 200), () {
                _customPersonasFocusNode.requestFocus();
              });
            } else {
              setState(() {
                isCustomSelected = false;
                ref.read(manualQuoteProvider.notifier)
                    .updateQuoteDetails(peopleCount: value);
              });
            }
          },
        ),
        if (isCustomSelected)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: TextField(
                controller: _customPersonasController,
                focusNode: _customPersonasFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Personalizada',
                  border: OutlineInputBorder(),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final count = int.tryParse(value);
                  if (count != null) {
                    ref.read(manualQuoteProvider.notifier)
                        .updateQuoteDetails(peopleCount: count);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the allergies section.
  Widget _buildAllergiesSection() {
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
            ...alergiasList.map(
              (allergy) => Chip(
                backgroundColor: primaryColor,
                label: Text(
                  allergy,
                  style: const TextStyle(color: Colors.white),
                ),
                deleteIconColor: Colors.white,
                onDeleted: () {
                  setState(() {
                    alergiasList.remove(allergy);
                  });
                  ref
                      .read(manualQuoteProvider.notifier)
                      .updateQuoteDetails(alergias: alergiasList.join(', '));
                },
              ),
            ),
            if (alergiasList.length < 10)
              ActionChip(
                backgroundColor: Colors.white,
                avatar: Icon(Icons.add, color: primaryColor),
                label: Text('Agregar Alergia', style: TextStyle(color: primaryColor)),
                onPressed: () async {
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
                      !alergiasList.contains(newAllergy)) {
                    setState(() => alergiasList.add(newAllergy ?? ''));
                    ref
                        .read(manualQuoteProvider.notifier)
                        .updateQuoteDetails(alergias: alergiasList.join(', '));
                  }
                },
              ),
          ],
        ),
      ],
    );
  }

  /// Builds an expansion tile for additional notes.
  Widget _buildAdditionalNotesSection() {
    final quote = ref.watch(manualQuoteProvider);
    return ExpansionTile(
      title: const Text('Notas Adicionales', style: TextStyle(color: ColorsPaletteRedonda.primary)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            initialValue: quote?.adicionales,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Escribe cualquier nota adicional',
              filled: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref
                  .read(manualQuoteProvider.notifier)
                  .updateQuoteDetails(adicionales: value);
            },
          ),
        ),
      ],
    );
  }

  /// Validates required fields and, if all is well, returns the completed order.
  void _confirmOrder() {
    final quote = ref.read(manualQuoteProvider);
    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No hay datos de la cotización')),
      );
      return;
    }
    if ((quote.peopleCount ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad de personas es requerida')),
      );
      return;
    }
    if (quote.eventType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El tipo de evento es requerido')),
      );
      return;
    }
    if (quote.dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un item')),
      );
      return;
    }
    try {
      // Finalize the manual order. (In a full app you might perform further processing here.)
      Navigator.pop(context, quote);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar la orden: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = ref.watch(manualQuoteProvider);
    final items = quote?.dishes ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    final eventDetailsCard = Card(
      elevation: 4,
      child: _buildCollapsibleEventDetails(),
    );

    final itemsCard = Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items Solicitados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No hay items agregados',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : _buildItemsList(items),
            _buildNewItemForm(),
          ],
        ),
      ),
    );

    Widget content;
    if (isDesktop) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: eventDetailsCard),
          const SizedBox(width: 24),
          Expanded(child: itemsCard),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          eventDetailsCard,
          const SizedBox(height: 24),
          itemsCard,
        ],
      );
    }

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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isDesktop ? 1000 : double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                  .copyWith(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  content,
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _confirmOrder,
                    child: const Text('Confirmar Orden'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}