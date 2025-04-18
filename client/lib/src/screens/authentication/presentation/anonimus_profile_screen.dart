import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'custom_sign_in_screen.dart';

class AnonymousProfileScreen extends StatelessWidget {
  final User user;

  const AnonymousProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: Hide the app bar if desired
      appBar: AppBar(
        title: const Text('Bienvenido!'),
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Estas en la vista de invitados',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the sign-in screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomSignInScreen(),
                    ),
                  );
                },
                child: const Text('Registrate para crear una cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
