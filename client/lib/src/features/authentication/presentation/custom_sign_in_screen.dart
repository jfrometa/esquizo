import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart'; 
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/authenticated_profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/services/admin_providers.dart';
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
          AuthStateChangeAction((context, state) {
            final user = switch (state) {
              SignedIn(user: final user) => user,
              CredentialLinked(user: final user) => user,
              UserCreated(credential: final cred) => cred.user,
              _ => null,
            };

            // if (user != null) {
              // Obtener la ruta actual con GoRouter
              final RouteMatch lastMatch = GoRouter.of(context).routerDelegate.currentConfiguration.last;
              final RouteMatchList matchList = lastMatch is ImperativeRouteMatch ? 
                lastMatch.matches : GoRouter.of(context).routerDelegate.currentConfiguration;

              final String location = matchList.uri.toString();
              // final int index = matchList.matches.indexWhere((match) => match.matchedLocation == location);

              final isAdmin = ref.watch(isAdminProvider).value ?? false;
              // final isAdmin = ref.watch(isAdminProvider);
              //         return isAdmin.when(
              //           data: (isAdmin) => isAdmin 
              //             ? const AdminManagementScreen()
              //             : const UnauthorizedScreen(),
              //           loading: () => const CircularProgressIndicator(),
              //           error: (_, __) => const UnauthorizedScreen(),
              //         );
              // Add admin
              if (isAdmin) {
                 context.goNamed(
                      AppRoute.adminPanel.name,
                      extra: user,
                  );
                return;
              }

              switch (user) {
              case User(emailVerified: true):
                GoRouter.of(context).pop(true);
              case User(emailVerified: false, email: final String _):

                final authRepo = ref.read(authRepositoryProvider);
                authRepo.forceRefreshAuthState();
                
                
                if (location == '/cuenta') {
                // Comportamiento para la ruta /cuenta
                // GoRouter.of(context).pushReplacement('/cuenta');
                 // Reemplaza la pantalla de registro con la pantalla de perfil autenticado
             

                  // context.goNamed(
                  //     AppRoute.authenticatedProfile.name,
                  //     extra: user,
                  // );
              } else if (location == '/carrito/completar-orden') {
                // Comportamiento para la ruta /carrito
                GoRouter.of(context).pop(true);
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