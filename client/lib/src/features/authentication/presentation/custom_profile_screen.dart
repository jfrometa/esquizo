import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/anonimus_profile_screen.dart';

import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/authenticated_profile_screen.dart';

// custom_profile_screen.dart

class CustomProfileScreen extends ConsumerStatefulWidget {
  const CustomProfileScreen({super.key});

  @override
  ConsumerState<CustomProfileScreen> createState() =>
      _CustomProfileScreenState();
}

class _CustomProfileScreenState extends ConsumerState<CustomProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return authStateChanges.when(
      data: (user) {
        if (user == null) {
          authRepo.signInAnonymously();
          // User is not signed in; this shouldn't happen as we sign in anonymously
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (user.isAnonymous) {
          // User is anonymous
          return AnonymousProfileScreen(user: user);
        } else {
          // User is authenticated

          return AuthenticatedProfileScreen(user: user);
        }

        setState(() {});
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
