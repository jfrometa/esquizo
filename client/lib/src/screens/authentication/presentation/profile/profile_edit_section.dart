import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/core/user_preference/user_preference_provider.dart';

class ProfileEditSection extends ConsumerStatefulWidget {
  final User user;

  const ProfileEditSection({
    required this.user,
    super.key,
  });

  @override
  ConsumerState<ProfileEditSection> createState() => _ProfileEditSectionState();
}

class _ProfileEditSectionState extends ConsumerState<ProfileEditSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isUpdating = false;
  bool _isPhoneNumberEditing = false;

  @override
  void initState() {
    super.initState();
    _setupInitialValues();
  }

  void _setupInitialValues() {
    _nameController.text = widget.user.displayName ?? '';

    // Try to get phone from Firebase Auth first
    String initialPhone = widget.user.phoneNumber ?? '';

    // If not available, check our own database
    if (initialPhone.isEmpty) {
      final userPreferencesAsyncValue =
          ref.read(userPreferencesProvider(widget.user.uid));

      userPreferencesAsyncValue.whenData((preferences) {
        if (preferences.phoneNumber != null &&
            preferences.phoneNumber!.isNotEmpty) {
          setState(() {
            _phoneController.text = preferences.phoneNumber!;
          });
        }
      });
    } else {
      _phoneController.text = initialPhone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      // Only update display name if it has changed
      if (_nameController.text != widget.user.displayName) {
        await widget.user.updateDisplayName(_nameController.text);
      }

      // Update phone in our database (since Firebase Auth requires more verification)
      if (_phoneController.text.isNotEmpty) {
        // TODO: Implement phone number update logic
        final repository = ref.read(userPreferencesRepositoryProvider);
        // await repository.updatePhoneNumber(widget.user.uid, _phoneController.text);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isPhoneNumberEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error actualizando el perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Información Personal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPhoneNumberEditing = !_isPhoneNumberEditing;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: _isPhoneNumberEditing,
                validator: (value) {
                  if (_isPhoneNumberEditing &&
                      (value == null || value.isEmpty)) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Número Telefónico',
                  hintText: '+52 1 55 1234 5678',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                enabled: _isPhoneNumberEditing,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                ],
                validator: (value) {
                  if (_isPhoneNumberEditing &&
                      value != null &&
                      value.isNotEmpty) {
                    // Simple phone validation - could be enhanced
                    if (value.length < 10) {
                      return 'El número telefónico debe tener al menos 10 dígitos';
                    }
                  }
                  return null;
                },
              ),

              if (_isPhoneNumberEditing) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isUpdating
                          ? null
                          : () {
                              setState(() {
                                _isPhoneNumberEditing = false;
                                _setupInitialValues(); // Reset values
                              });
                            },
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _updateProfile,
                      child: _isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
