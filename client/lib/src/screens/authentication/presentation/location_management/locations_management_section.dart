import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_architecture_flutter_firebase/src/core/providers/user_preference/user_preference_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class LocationsSection extends ConsumerStatefulWidget {
  final String userId;

  const LocationsSection({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<LocationsSection> createState() => _LocationsSectionState();
}

class _LocationsSectionState extends ConsumerState<LocationsSection> {
  SavedLocation? _locationBeingEdited;
  bool _isAddingLocation = false;

  @override
  Widget build(BuildContext context) {
    final userPreferencesAsyncValue = ref.watch(userPreferencesProvider(widget.userId));
    
    return userPreferencesAsyncValue.when(
      data: (preferences) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mis Ubicaciones',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_location_alt,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isAddingLocation = true;
                          _locationBeingEdited = SavedLocation(
                            id: '',
                            name: '',
                            address: '',
                            latitude: 0,
                            longitude: 0,
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (_isAddingLocation || _locationBeingEdited != null)
                  _buildLocationForm(preferences)
                else if (preferences.savedLocations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No tienes ubicaciones guardadas.\nAgrega una ubicación para entregas más rápidas.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  _buildLocationsList(preferences),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsList(UserPreferences preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final location in preferences.savedLocations)
          LocationCard(
            location: location,
            isDefault: location.id == preferences.defaultLocationId,
            onEdit: () {
              setState(() {
                _locationBeingEdited = location;
              });
            },
            onDelete: () async {
              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Ubicación'),
                  content: Text('¿Estás seguro que deseas eliminar la ubicación "${location.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                try {
                  final repository = ref.read(userPreferencesRepositoryProvider);
                  await repository.deleteSavedLocation(widget.userId, location.id);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ubicación eliminada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error eliminando la ubicación: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            onSetDefault: () async {
              try {
                final repository = ref.read(userPreferencesRepositoryProvider);
                await repository.setDefaultLocation(widget.userId, location.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ubicación establecida como predeterminada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error estableciendo la ubicación: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
      ],
    );
  }

  Widget _buildLocationForm(UserPreferences preferences) {
    final isEditing = _locationBeingEdited?.id.isNotEmpty ?? false;
    final formKey = GlobalKey<FormState>();
    
    // Form controllers
    final nameController = TextEditingController(text: _locationBeingEdited?.name ?? '');
    final addressController = TextEditingController(text: _locationBeingEdited?.address ?? '');
    final latController = TextEditingController(
      text: _locationBeingEdited?.latitude != 0 ? _locationBeingEdited?.latitude.toString() : '',
    );
    final lngController = TextEditingController(
      text: _locationBeingEdited?.longitude != 0 ? _locationBeingEdited?.longitude.toString() : '',
    );
    final notesController = TextEditingController(text: _locationBeingEdited?.notes ?? '');
    
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Editar Ubicación' : 'Añadir Ubicación',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          
          // Name field
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la ubicación',
              hintText: 'Ej: Casa, Trabajo',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          
          // Address field
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              hintText: 'Ej: Calle Principal #123, Ciudad',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una dirección';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          
          // Coordinates row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: latController,
                  decoration: const InputDecoration(
                    labelText: 'Latitud',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Inválido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: lngController,
                  decoration: const InputDecoration(
                    labelText: 'Longitud',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Notes field
          TextFormField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notas (opcional)',
              hintText: 'Ej: Edificio azul, segundo piso',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isAddingLocation = false;
                    _locationBeingEdited = null;
                  });
                },
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
               
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final repository = ref.read(userPreferencesRepositoryProvider);
                      
                      final location = SavedLocation(
                        id: _locationBeingEdited?.id ?? '',
                        name: nameController.text,
                        address: addressController.text,
                        latitude: double.parse(latController.text),
                        longitude: double.parse(lngController.text),
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                      );
                      
                      if (isEditing) {
                        await repository.updateSavedLocation(widget.userId, location);
                      } else {
                        await repository.addSavedLocation(widget.userId, location);
                      }
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'Ubicación actualizada correctamente'
                                  : 'Ubicación guardada correctamente',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        
                        setState(() {
                          _isAddingLocation = false;
                          _locationBeingEdited = null;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(isEditing ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final SavedLocation location;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const LocationCard({
    required this.location,
    required this.isDefault,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDefault
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      'Predeterminada',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.address,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (location.notes != null && location.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      location.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDefault)
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Establecer como predeterminada'),
                    onPressed: onSetDefault,
                  ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}