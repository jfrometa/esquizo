import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';

import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class CustomSignInScreen extends ConsumerStatefulWidget {
  const CustomSignInScreen({super.key});

  @override
  ConsumerState<CustomSignInScreen> createState() => _CustomSignInScreenState();
}

class _CustomSignInScreenState extends ConsumerState<CustomSignInScreen> {
  @override
  Widget build(BuildContext context) {
    final authProviders = ref.watch(authProvidersProvider);

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
          AuthStateChangeAction((context, state) async {
            // Handle sign out case to reset admin status
            if (state.toString().contains('SignedOut') ||
                FirebaseAuth.instance.currentUser == null) {
              // Force refresh the admin provider
              ref.invalidate(isAdminProvider);

              // Navigate to home with animation
              if (context.mounted) {
                context.goToBusinessHome();
              }
              return;
            }

            final user = switch (state) {
              SignedIn(user: final user) => user,
              CredentialLinked(user: final user) => user,
              UserCreated(credential: final cred) => cred.user,
              _ => null,
            };

            if (user != null) {
              // Force refresh auth state to update providers
              final authRepo = ref.read(authRepositoryProvider);
              authRepo.forceRefreshAuthState();

              // Check admin status and refresh the provider
              final _ = await ref.refresh(isAdminProvider.future);
              final isAdmin = await ref.read(isAdminProvider.future);

              if (isAdmin) {
                // Navigate to admin panel and rebuild the navigation
                await Future.delayed(const Duration(milliseconds: 300));
                if (context.mounted) {
                  // Use pushReplacementNamed to force rebuild of navigation
                  context.goNamed(
                    AppRoute.adminPanel.name,
                    extra: user,
                  );
                }
                return;
              }

              if (!context.mounted) return;

              // Handle non-admin user navigation
              final RouteMatch lastMatch =
                  GoRouter.of(context).routerDelegate.currentConfiguration.last;
              final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
                  ? lastMatch.matches
                  : GoRouter.of(context).routerDelegate.currentConfiguration;
              final String location = matchList.uri.toString();

              switch (user) {
                case User(emailVerified: true):
                  GoRouter.of(context).pop(true);
                case User(emailVerified: false, email: final String _):
                  if (location == '/cuenta') {
                    // Handle account page navigation
                  } else if (location == '/carrito/completar-orden') {
                    GoRouter.of(context).pop(true);
                  }
              }
            }
          }),
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
