import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';

class LinkAccountScreen extends ConsumerStatefulWidget {
  final String email;

  const LinkAccountScreen({super.key, required this.email});

  @override
  _LinkAccountScreenState createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends ConsumerState<LinkAccountScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _linkAnonymousAccount() async {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;

    if (user != null && user.isAnonymous) {
      setState(() {
        _isLoading = true;
      });

      try {
        final credential = EmailAuthProvider.credential(
          email: widget.email,
          password: _passwordController.text,
        );

        await user.linkWithCredential(credential);

        // Success: Navigate back to the main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'provider-already-linked':
            errorMessage = 'This provider is already linked to your account.';
            break;
          case 'credential-already-in-use':
            errorMessage =
                'This email is already associated with another account.';
            break;
          case 'invalid-credential':
            errorMessage = 'The credential is invalid.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.brown[200], // Light brown background color
          duration:
              const Duration(milliseconds: 500), // Display for half a second,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // User is not anonymous or null
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Your Account'),
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Please enter your password to link your account.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _linkAnonymousAccount,
                        child: const Text('Link Account'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
