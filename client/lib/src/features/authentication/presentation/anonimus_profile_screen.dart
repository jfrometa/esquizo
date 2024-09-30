import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'link_account_screen.dart';
// anonymous_profile_screen.dart
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
        title: const Text('Welcome, Guest'),
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You are browsing as a guest.',
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
                child: const Text('Sign In or Create an Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
