import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/auth_providers.dart';

class CustomSignInScreen extends ConsumerStatefulWidget {
  const CustomSignInScreen({super.key});

  @override
  ConsumerState<CustomSignInScreen> createState() => _CustomSignInScreenState();
}

class _CustomSignInScreenState extends ConsumerState<CustomSignInScreen> {
  @override
  Widget build(BuildContext context) {
    final authProviders = ref.watch(authProvidersProvider);

    // Add FirebaseAuth listener for debugging
    // FirebaseAuth.instance.authStateChanges().listen((user) {
    //   if ((user?.isAnonymous ?? true)) {
    //     print("User is signed in with UID: ${user?.uid}");
    //     Navigator.of(context).pop(); // Pop the screen upon successful login
    //   } else {
    //     print("User is signed out.");
    //   }
    // });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        forceMaterialTransparency: true,
      ),
      body: SignInScreen(
        auth: FirebaseAuth.instance,
        providers: authProviders,
        showPasswordVisibilityToggle: true,
        actions: [
          AuthStateChangeAction((context, state) {
            final user = switch (state) {
              SignedIn(user: final user) => user,
              CredentialLinked(user: final user) => user,
              UserCreated(credential: final cred) => cred.user,
              _ => null,
            };

            switch (user) {
              case User(emailVerified: true):
                Navigator.pop(context);
              case User(emailVerified: false, email: final String _):
                final authRepo = ref.read(authRepositoryProvider);
                authRepo.forceRefreshAuthState();
                Navigator.of(context).pop();
            }
          }),
          // AuthStateChangeAction<UserCreated>((context, state) {
          //   print("User account created.");
          //   Navigator.of(context).pop();
          // }),
          // AuthStateChangeAction<SignedIn>((context, state) {
          //   print("User signed in.");
          //   Navigator.of(context).pop();
          // }),
        ],
        footerBuilder: (context, action) {
          return const Column(
            children: [
              SizedBox(height: 8),
              Text('Registrate para crear una cuenta'),
            ],
          );
        },
      ),
    );
  }
}
