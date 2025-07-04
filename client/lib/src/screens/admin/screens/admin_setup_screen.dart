import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/setup/initialize_example_data_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/local_storange/local_storage_service.dart';

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

      // Store business ID in local storage for future reference
      final localStorage = ref.read(localStorageServiceProvider);
      await localStorage.setString('businessId', businessId);

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
            content: Text('Business setup completed successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Refresh the business config provider to trigger app state change
        // This will cause BusinessSetupDetector to switch to the main app
        ref.invalidate(businessConfigProvider);

        // The BusinessSetupDetector will automatically switch to the main app
        // which has GoRouter context and will navigate to admin panel
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
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Business Already Configured',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your business "${businessConfig.name}" is already set up.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to admin panel
                          try {
                            // Try GoRouter first
                            if (GoRouter.maybeOf(context) != null) {
                              context.go('/admin');
                            } else {
                              // Fallback: refresh business config to trigger app state change
                              ref.invalidate(businessConfigProvider);
                            }
                          } catch (e) {
                            // Last resort: refresh business config
                            ref.invalidate(businessConfigProvider);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Go to Admin Panel'),
                      ),
                    ),
                  ],
                ),
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
          error: (error, stackTrace) => Text('Error: $error'),
        ),
      ),
    );
  }
}
