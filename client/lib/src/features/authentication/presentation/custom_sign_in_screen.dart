import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/link_account_screen.dart';


class CustomSignInScreen extends ConsumerWidget {
  const CustomSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProviders = ref.watch(authProvidersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        forceMaterialTransparency: true,
      ),
      body: SignInScreen(
        providers: authProviders,
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            // User signed in successfully; refresh the UI
            Navigator.of(context).popUntil((route) => route.isFirst);
          }),
          AuthStateChangeAction<UserCreated>((context, state) {
            // Navigate to link account screen to link anonymous account
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LinkAccountScreen(
                  email: state.credential.user?.email ?? '',
                ),
              ),
            );
          }),
        ],
        footerBuilder: (context, action) {
          return const Column(
            children: [
              SizedBox(height: 8),
              Text('By signing in, you agree to our terms and conditions.'),
            ],
          );
        },
      ),
    );
  }
}
