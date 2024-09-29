import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'link_account_screen.dart';

class AnonymousProfileScreen extends StatelessWidget {
  final User user;

  const AnonymousProfileScreen({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'You are currently browsing as a guest.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the account linking screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LinkAccountScreen(),
                    ),
                  );
                },
                child: const Text('Sign In or Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
