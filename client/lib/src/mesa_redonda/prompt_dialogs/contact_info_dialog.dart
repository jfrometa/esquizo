import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_sign_in_screen.dart';


class ContactInfoDialog {
  // Add these static variables at the class level
  static bool _isNameValid = true;
  static bool _isPhoneValid = true;
  static bool _isEmailValid = true;

  static Future<Map<String, String>?> show(BuildContext context) async {
    bool showSignInScreen = false;
    bool? dialogResult;
    String? name, phone, email;
    
    // Reset validation states at the beginning
    _isNameValid = true;
    _isPhoneValid = true;
    _isEmailValid = true;
    
    // Create focus nodes to manage field focus
    final nameFocusNode = FocusNode();
    final phoneFocusNode = FocusNode();
    final emailFocusNode = FocusNode();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.isAnonymous) {
      // No need to reset validation states here since we did it above
      
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setState) {
              if (showSignInScreen) {
                return Dialog(
                  insetPadding: EdgeInsets.zero,
                  child: SizedBox.expand(
                    child: Scaffold(
                      body: const CustomSignInScreen(),
                      // Remove bottom navigation bar to avoid duplication
                    ),
                  ),
                );
              } else {
                return Dialog(
                  insetPadding: EdgeInsets.zero,
                  child: SizedBox.expand(
                    child: Scaffold(
                      appBar: AppBar(
                        forceMaterialTransparency: true,
                        title: const Text('Información de Contacto'),
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(false),
                        ),
                      ),
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Todos los campos son obligatorios.'),
                              const SizedBox(height: 16),
                              TextField(
                                focusNode: nameFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isNameValid
                                          ? Theme.of(ctx).colorScheme.outline
                                          : Theme.of(ctx).colorScheme.error,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isNameValid
                                          ? Theme.of(ctx).colorScheme.primary
                                          : Theme.of(ctx).colorScheme.error,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorText: _isNameValid
                                      ? null
                                      : 'El nombre debe tener al menos 3 caracteres',
                                ),
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {
                                  setState(() {
                                    name = value;
                                    _isNameValid = _validateName(value);
                                  });
                                },
                                onSubmitted: (_) {
                                  phoneFocusNode.requestFocus();
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                focusNode: phoneFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Teléfono',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isPhoneValid
                                          ? Theme.of(ctx).colorScheme.outline
                                          : Theme.of(ctx).colorScheme.error,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isPhoneValid
                                          ? Theme.of(ctx).colorScheme.primary
                                          : Theme.of(ctx).colorScheme.error,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorText: _isPhoneValid
                                      ? null
                                      : 'Ingrese un número de teléfono válido (mínimo 10 dígitos)',
                                ),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                                onChanged: (value) {
                                  setState(() {
                                    phone = value;
                                    _isPhoneValid = _validatePhone(value);
                                  });
                                },
                                onSubmitted: (_) {
                                  emailFocusNode.requestFocus();
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                focusNode: emailFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isEmailValid
                                          ? Theme.of(ctx).colorScheme.outline
                                          : Theme.of(ctx).colorScheme.error,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isEmailValid
                                          ? Theme.of(ctx).colorScheme.primary
                                          : Theme.of(ctx).colorScheme.error,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorText: _isEmailValid
                                      ? null
                                      : 'Ingrese un correo electrónico válido',
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                    email = value;
                                    _isEmailValid = _validateEmail(value);
                                  });
                                },
                                onSubmitted: (_) {
                                  _validateAndSubmit(
                                    ctx, 
                                    setState, 
                                    name, 
                                    phone, 
                                    email, 
                                    nameFocusNode, 
                                    phoneFocusNode, 
                                    emailFocusNode
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      bottomNavigationBar: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Make "Registrarse" the main option
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(ctx).colorScheme.primary,
                                foregroundColor: Theme.of(ctx).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  showSignInScreen = true;
                                });
                              },
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _validateAndSubmit(
                                      ctx, 
                                      setState, 
                                      name, 
                                      phone, 
                                      email, 
                                      nameFocusNode, 
                                      phoneFocusNode, 
                                      emailFocusNode
                                    );
                                  },
                                  child: const Text('Continuar como invitado'),
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
            },
          );
        },
      ).then((value) {
        dialogResult = value as bool?;
        // Clean up focus nodes
        nameFocusNode.dispose();
        phoneFocusNode.dispose();
        emailFocusNode.dispose();
      });

      if (dialogResult != true) {
        return null;
      }

      if (!showSignInScreen) {
        return {
          'name': name ?? '',
          'phone': phone ?? '',
          'email': email ?? '',
        };
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    return {
      'name': user?.displayName ?? '',
      'phone': user?.phoneNumber ?? '',
      'email': user?.email ?? '',
    };
  }

  static void _validateAndSubmit(
    BuildContext context,
    StateSetter setState,
    String? name,
    String? phone,
    String? email,
    FocusNode nameFocusNode,
    FocusNode phoneFocusNode,
    FocusNode emailFocusNode,
  ) {
    bool isNameValid = name != null && _validateName(name);
    bool isPhoneValid = phone != null && _validatePhone(phone);
    bool isEmailValid = email != null && _validateEmail(email ?? '');

    setState(() {
      // Update validation states using the class-level static variables
      _isNameValid = isNameValid;
      _isPhoneValid = isPhoneValid;
      _isEmailValid = isEmailValid;
    });

    // Focus on the first invalid field
    if (!isNameValid) {
      nameFocusNode.requestFocus();
      return;
    } else if (!isPhoneValid) {
      phoneFocusNode.requestFocus();
      return;
    } else if (!isEmailValid) {
      emailFocusNode.requestFocus();
      return;
    }

    // All fields are valid, proceed
    // Use Navigator.of(context).pop instead of GoRouter to avoid layout issues
    Navigator.of(context).pop(true);
  }

  static bool _validateEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }
  
  // Add phone validation method
  static bool _validatePhone(String phone) {
    if (phone.isEmpty) return false;
    // Basic phone validation - at least 10 digits
    final phoneRegExp = RegExp(r'^\d{10,}$');
    return phoneRegExp.hasMatch(phone.replaceAll(RegExp(r'[^0-9]'), ''));
  }
  
  // Add name validation method
  static bool _validateName(String name) {
    return name.trim().length >= 3; // Name should be at least 3 characters
  }

  // static bool _validateFields(
  //   StateSetter setState,
  //   String? name,
  //   String? phone,
  //   String? email,
  // ) {
  //   setState(() {
  //     _isNameValid = name != null && _validateName(name);
  //     _isPhoneValid = phone != null && _validatePhone(phone);
  //     _isEmailValid = email != null && _validateEmail(email);
  //   });

  //   return _isNameValid && _isPhoneValid && _isEmailValid;
  // }
}