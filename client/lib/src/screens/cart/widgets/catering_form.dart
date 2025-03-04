import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';

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
  final String? title;
  final CateringOrderItem? initialData;
  final void Function(CateringFormData formData) onSubmit;

  const CateringForm({
    super.key,
    this.title,
    this.initialData,
    required this.onSubmit,
  });

  @override
  ConsumerState<CateringForm> createState() => _CateringFormState();
}

class _CateringFormState extends ConsumerState<CateringForm> {
  final _formKey = GlobalKey<FormState>();
  final customPersonasFocusNode = FocusNode();
  late TextEditingController eventTypeController;
  late TextEditingController adicionalesController;
  bool isCustomSelected = false;
  List<String> alergiasList = [];
  bool hasChef = false;
  int? cantidadPersonas;

  final peopleQuantity = [10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000, 2000, 5000, 10000];
  final List<String> eventTypes = [
    'Corporativo',
    'Cumpleaños',
    'Boda',
    'Reunión familiar',
    'Conferencia',
    'Otro'
  ];

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
    cantidadPersonas = initialData?.peopleCount ?? 20; // Default to 20 people
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
    if (_formKey.currentState!.validate()) {
      if (cantidadPersonas == null || cantidadPersonas! <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La cantidad de personas es requerida'),
            behavior: SnackBarBehavior.floating,
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    final formContent = Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32.0 : 16.0,
          vertical: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? 'Detalles del Catering',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personaliza tu experiencia gastronómica',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            Divider(color: colorScheme.outline.withOpacity(0.2)),
            const SizedBox(height: 24),
            
            // Number of people section
            _buildSectionTitle('Cantidad de Personas', Icons.people, colorScheme),
            const SizedBox(height: 12),
            
            // People count slider for better UX
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // People count selection
                    Row(
                      children: [
                        Icon(
                          Icons.group, 
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCustomSelected 
                              ? 'Personalizado: ${cantidadPersonas ?? 0}' 
                              : '${cantidadPersonas ?? 0} personas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Show preset quantity chips for quick selection
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        ...peopleQuantity.take(6).map((number) => 
                          ChoiceChip(
                            selected: !isCustomSelected && cantidadPersonas == number,
                            label: Text('$number'),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  isCustomSelected = false;
                                  cantidadPersonas = number;
                                });
                              }
                            },
                          ),
                        ),
                        ChoiceChip(
                          selected: isCustomSelected,
                          label: const Text('Personalizado'),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                isCustomSelected = true;
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  customPersonasFocusNode.requestFocus();
                                });
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    
                    if (isCustomSelected) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: TextEditingController(
                          text: cantidadPersonas?.toString() ?? '',
                        ),
                        focusNode: customPersonasFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Cantidad Personalizada',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.edit),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una cantidad';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Ingresa un número válido';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final customValue = int.tryParse(value);
                          if (customValue != null) {
                            setState(() => cantidadPersonas = customValue);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Event type section
            _buildSectionTitle('Tipo de Evento', Icons.event, colorScheme),
            const SizedBox(height: 12),
            
            // Event type selection with suggestions
            DropdownButtonFormField<String>(
              value: eventTypes.contains(eventTypeController.text) 
                  ? eventTypeController.text
                  : null,
              decoration: InputDecoration(
                labelText: 'Selecciona el tipo de evento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(
                  Icons.celebration,
                  color: colorScheme.primary,
                ),
              ),
              items: [
                ...eventTypes.map(
                  (type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ),
                ),
              ],
              validator: (value) {
                if (eventTypeController.text.isEmpty) {
                  return 'Por favor selecciona o ingresa un tipo de evento';
                }
                return null;
              },
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    eventTypeController.text = value;
                  });
                }
              },
            ),
            
            // Custom event type for "Otro" option
            if (eventTypeController.text == 'Otro') ...[
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Especifica el tipo de evento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(
                    Icons.edit,
                    color: colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor especifica el tipo de evento';
                  }
                  return null;
                },
                onChanged: (value) {
                  eventTypeController.text = value;
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Chef service section
            Card(
              elevation: 0,
              color: hasChef
                  ? colorScheme.primaryContainer.withOpacity(0.6)
                  : colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: Text(
                  'Servicio de Chef',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Un chef profesional preparará todo en tu evento',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasChef
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                value: hasChef,
                onChanged: (value) => setState(() => hasChef = value),
                secondary: Icon(
                  Icons.restaurant,
                  color: hasChef
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Allergies section
            _buildSectionTitle('Alergias y Restricciones', Icons.health_and_safety, colorScheme),
            const SizedBox(height: 12),
            
            // Allergies chips with better visual style
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alergiasList.isEmpty
                        ? 'Sin alergias o restricciones alimenticias'
                        : 'Alergias y restricciones:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ...alergiasList.map(
                        (allergy) => Chip(
                          backgroundColor: colorScheme.primary,
                          label: Text(
                            allergy,
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                          deleteIconColor: colorScheme.onPrimary,
                          onDeleted: () {
                            setState(() => alergiasList.remove(allergy));
                          },
                        ),
                      ),
                      if (alergiasList.length < 10)
                        ActionChip(
                          avatar: Icon(
                            Icons.add, 
                            color: colorScheme.primary,
                          ),
                          backgroundColor: colorScheme.primaryContainer,
                          label: Text(
                            'Agregar',
                            style: TextStyle(color: colorScheme.onPrimaryContainer),
                          ),
                          onPressed: _showAllergyDialog,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Additional notes section
            _buildSectionTitle('Notas Adicionales', Icons.note_alt, colorScheme),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: adicionalesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Instrucciones especiales, preferencias, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 64.0),
                  child: Icon(
                    Icons.speaker_notes,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Confirmar Detalles'),
                onPressed: _handleSubmit,
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    
    // Use different layouts for desktop vs mobile
    if (isDesktop) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 700,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: formContent,
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: formContent,
      );
    }
  }
  
  // Helper method to build section titles
  Widget _buildSectionTitle(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Future<void> _showAllergyDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    String? allergyInput;
    final newAllergy = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.health_and_safety,
              size: 24,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Agregar Alergia o Restricción'),
          ],
        ),
        content: TextField(
          onChanged: (value) => allergyInput = value,
          decoration: InputDecoration(
            hintText: 'Ej. Gluten, Lactosa, Frutos secos...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(
              Icons.no_food,
              color: colorScheme.primary,
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (allergyInput?.isNotEmpty == true) {
                Navigator.pop(context, allergyInput);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (newAllergy?.isNotEmpty == true && !alergiasList.contains(newAllergy)) {
      setState(() => alergiasList.add(newAllergy!));
    }
  }
}