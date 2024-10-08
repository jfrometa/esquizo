import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/order_history_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/subscription_list_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';


class AuthenticatedProfileScreen extends ConsumerWidget {
  final User user;

  const AuthenticatedProfileScreen({super.key, required this.user});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseAuthProvider).signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          forceMaterialTransparency: true,
          
        ),
        body: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            children: [
              _buildUserInfo(context),
              const SizedBox(height: Sizes.p16),
              const TabBar(
                dividerColor: ColorsPaletteRedonda.primary,
                indicatorColor: ColorsPaletteRedonda.primary,
                enableFeedback: true,
                tabs: [
                  Tab(text: 'My Subscriptions'),
                  Tab(text: 'Order History'),
                ],
              ),
              const SizedBox(height: Sizes.p16),
              const Expanded(
                child: TabBarView(
                  children: [
                    // Subscriptions List
                    SubscriptionsList(),
                    // Order History List
                    OrderHistoryList(),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _signOut(context, ref),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.redAccent,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // User information section
  Widget _buildUserInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
              user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child:
              user.photoURL == null ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(width: Sizes.p16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? user.email ?? 'User',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Sizes.p8),
              Text(
                user.email ?? 'No email available',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}