import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/setup/initialize_example_data_provider.dart';

/// First-time setup screen for admins
class AdminSetupScreen extends ConsumerStatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  ConsumerState<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends ConsumerState<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _businessName = '';
  String _businessType = 'restaurant';
  bool _isInitializing = false;
  String? _errorMessage;

  final _businessTypes = ['restaurant', 'hotel', 'retail', 'service', 'other'];

  Future<void> _initializeBusinessData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Generate a business ID based on the name
      final businessId = _businessName.toLowerCase().replaceAll(' ', '_');

      // Set the business ID in the provider
      ref.read(currentBusinessIdProvider.notifier).state = businessId;

      // Get current user's email
      final userEmail = ref.read(firebaseAuthProvider).currentUser?.email;
      if (userEmail == null) {
        throw Exception('User not logged in or has no email');
      }

      // Initialize example data
      await ref.read(initializeExampleDataProvider(
        businessId: businessId,
        businessType: _businessType,
        adminEmail: userEmail,
      ).future);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Business setup completed successfully!')),
        );

        // Navigate to home screen or admin panel
        // Navigator.of(context).pushReplacementNamed('/admin');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing business: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if business exists
    final businessAsyncValue = ref.watch(businessConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Setup'),
      ),
      body: Center(
        child: businessAsyncValue.when(
          data: (businessConfig) {
            if (businessConfig != null) {
              // Business already set up
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Business Already Configured',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                      'Your business "${businessConfig.name}" is already set up.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to admin panel
                      // Navigator.of(context).pushReplacementNamed('/admin');
                    },
                    child: const Text('Go to Admin Panel'),
                  ),
                ],
              );
            }

            // Business not set up yet, show the form
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome to Business Setup',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Let\'s get your business set up with sample data',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a business name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _businessName = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Business Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _businessType,
                      items: _businessTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.substring(0, 1).toUpperCase() +
                              type.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _businessType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a business type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed:
                          _isInitializing ? null : _initializeBusinessData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isInitializing
                          ? const CircularProgressIndicator()
                          : const Text('Initialize Business Data'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) {
            // Log the error for debugging purposes
            debugPrint('Error loading business config: $error');
            if (kDebugMode) {
              debugPrintStack(stackTrace: stackTrace);
            }

            return Text('Error: $error');
          },
        ),
      ),
    );
  }
}
