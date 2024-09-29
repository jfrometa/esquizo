import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/order_history_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/subscription_list_screen.dart';

class AuthenticatedProfileScreen extends ConsumerWidget {
  final User user;

  const AuthenticatedProfileScreen({super.key, required this.user});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseAuthProvider).signOut();
      // Navigate back to the home screen or sign-in screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      // Handle sign-out error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: screenWidth > 600
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserInfo(context),
                          const SizedBox(height: Sizes.p24),
                          const Text(
                            'My Subscriptions',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: Sizes.p12),
                          const SubscriptionsList(),
                        ],
                      ),
                    ),
                    const SizedBox(width: Sizes.p24),
                    // Right Side
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order History',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: Sizes.p12),
                          const OrderHistoryList(),
                          const SizedBox(height: Sizes.p24),
                          ElevatedButton(
                            onPressed: () => _signOut(context, ref),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfo(context),
                    const SizedBox(height: Sizes.p24),
                    const Text(
                      'My Subscriptions',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: Sizes.p12),
                    const SubscriptionsList(),
                    const SizedBox(height: Sizes.p24),
                    const Text(
                      'Order History',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: Sizes.p12),
                    const OrderHistoryList(),
                    const SizedBox(height: Sizes.p24),
                    ElevatedButton(
                      onPressed: () => _signOut(context, ref),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

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
          child: Text(
            user.displayName ?? user.email ?? 'User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
