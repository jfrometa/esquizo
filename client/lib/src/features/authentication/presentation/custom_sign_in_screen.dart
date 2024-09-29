import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/sign_in_anonimously_footer.dart';

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
            // Navigate to the profile screen after successful sign-in
            Navigator.of(context).popUntil((route) => route.isFirst);
          }),
        ],
        footerBuilder: (context, action) => const SignInAnonymouslyFooter(),
      ),
    );
  }
}
