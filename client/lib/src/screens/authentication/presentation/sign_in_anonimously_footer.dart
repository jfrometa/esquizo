import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/firebase/firebase_providers.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

class SignInAnonymouslyFooter extends ConsumerWidget {
  const SignInAnonymouslyFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: Sizes.p8),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Sizes.p8),
              child: Text('or'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        TextButton(
          onPressed: () async {
            try {
              await ref.read(firebaseAuthProvider).signInAnonymously();
              // Navigate to the profile screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            } on Exception {
              // Handle anonymous sign-in error
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to sign in anonymously.'),
                backgroundColor:
                    Colors.brown[200], // Light brown background color
                duration:
                    Duration(milliseconds: 500), // Display for half a second),
              ));
            }
          },
          child: const Text('Continue as Guest'),
        ),
      ],
    );
  }
}
