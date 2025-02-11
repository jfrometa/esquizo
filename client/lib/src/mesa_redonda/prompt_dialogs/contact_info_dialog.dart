import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class ContactInfoDialog {
  static Future<Map<String, String>?> show(BuildContext context) async {
    bool showSignInScreen = false;
    bool? dialogResult;
    String? name, phone, email;
    bool _isNameValid = true;
    bool _isPhoneValid = true;
    bool _isEmailValid = true;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.isAnonymous) {
      // Reset validation states
      _isNameValid = true;
      _isPhoneValid = true;
      _isEmailValid = true;

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
                      appBar: AppBar(
                        forceMaterialTransparency: true,
                        title: const Text('Registro'),
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => GoRouter.of(ctx).pop(),
                        ),
                      ),
                      body: CustomSignInScreen(),
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
                          onPressed: () => GoRouter.of(ctx).pop(false),
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
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isNameValid
                                          ? ColorsPaletteRedonda.primary
                                          : Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorText: _isNameValid
                                      ? null
                                      : 'El nombre es requerido',
                                ),
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {
                                  setState(() {
                                    name = value;
                                    _isNameValid = value.trim().isNotEmpty;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Teléfono',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isPhoneValid
                                          ? ColorsPaletteRedonda.primary
                                          : Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorText: _isPhoneValid
                                      ? null
                                      : 'El teléfono es requerido',
                                ),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                                onChanged: (value) {
                                  setState(() {
                                    phone = value;
                                    _isPhoneValid = value.trim().isNotEmpty;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: _isEmailValid
                                          ? ColorsPaletteRedonda.primary
                                          : Colors.red,
                                      width: 1.5,
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
                              ),
                            ],
                          ),
                        ),
                      ),
                      bottomNavigationBar: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showSignInScreen = true;
                                });
                              },
                              child: const Text('Registrarse'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                GoRouter.of(ctx).pop(false);
                              },
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final isValid = _validateFields(
                                  setState,
                                  name,
                                  phone,
                                  email,
                                  _isNameValid,
                                  _isPhoneValid,
                                  _isEmailValid,
                                );
                                if (isValid) {
                                  GoRouter.of(ctx).pop(true);
                                }
                              },
                              child: const Text('Continuar'),
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

  static bool _validateEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  static bool _validateFields(
    StateSetter setState,
    String? name,
    String? phone,
    String? email,
    bool isNameValid,
    bool isPhoneValid,
    bool isEmailValid,
  ) {
    setState(() {
      isNameValid = (name?.trim().isNotEmpty ?? false);
      isPhoneValid = (phone?.trim().isNotEmpty ?? false);
      isEmailValid = _validateEmail(email ?? '');
    });

    return isNameValid && isPhoneValid && isEmailValid;
  }
}