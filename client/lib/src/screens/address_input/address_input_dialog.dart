import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A dialog for collecting delivery address information with modern Material Design
/// Relies entirely on system theme colors for light/dark mode consistency
class AddressInputDialog extends ConsumerStatefulWidget {
  const AddressInputDialog({super.key});

  @override
  ConsumerState<AddressInputDialog> createState() => _AddressInputDialogState();
}

class _AddressInputDialogState extends ConsumerState<AddressInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _floorController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  final _floorFocusNode = FocusNode();
  final _stateFocusNode = FocusNode();
  final _postalCodeFocusNode = FocusNode();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _streetController.dispose();
    _floorController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    
    _floorFocusNode.dispose();
    _stateFocusNode.dispose();
    _postalCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on),
                    const SizedBox(width: 12),
                    Text(
                      'Dirección de entrega',
                      style: textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildAddressField(
                  controller: _streetController,
                  label: 'Dirección *',
                  hint: 'Calle y número',
                  prefixIcon: Icons.home_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateRequiredField(value, 'dirección'),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_floorFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                _buildAddressField(
                  controller: _floorController,
                  label: 'Piso / Departamento *',
                  hint: 'Ej: Piso 3, Depto B',
                  prefixIcon: Icons.apartment_outlined,
                  focusNode: _floorFocusNode,
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateRequiredField(value, 'piso/departamento'),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_stateFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAddressField(
                        controller: _stateController,
                        label: 'Provincia',
                        hint: 'Ej: Buenos Aires',
                        prefixIcon: Icons.map_outlined,
                        focusNode: _stateFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_postalCodeFocusNode);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAddressField(
                        controller: _postalCodeController,
                        label: 'Código Postal',
                        hint: 'Ej: 1425',
                        prefixIcon: Icons.markunread_mailbox_outlined,
                        focusNode: _postalCodeFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitAddress(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '* Campos obligatorios',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submitAddress,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Guardar dirección'),
                                const SizedBox(width: 8),
                                Icon(Icons.check_circle_outline, size: 18),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese su $fieldName';
    }
    return null;
  }

  Future<void> _submitAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isSubmitting = true);
        
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 700));
        
        if (!mounted) return;
        
        Navigator.of(context).pop({
          'direccion': _streetController.text.trim(),
          'piso': _floorController.text.trim(),
          'provincia': _stateController.text.trim(),
          'codigoPostal': _postalCodeController.text.trim(),
        });
      } catch (e) {
        // Show error message if submission fails
        if (!mounted) return;
        
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.clearSnackBars();
        scaffold.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('No se pudo guardar la dirección: ${e.toString()}'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _submitAddress,
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }
}