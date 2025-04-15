// File: lib/src/core/setup/business_setup_detector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_setup_manager.dart';
import '../business/business_config_provider.dart';
import '../firebase/firebase_providers.dart';
import '../local_storange/local_storage_service.dart';
 

/// A widget that detects if business setup is needed and shows
/// appropriate UI based on that condition
class BusinessSetupDetector extends ConsumerStatefulWidget {
  final Widget child;
  final Widget setupScreen;

  const BusinessSetupDetector({
    super.key,
    required this.child,
    required this.setupScreen,
  });

  @override
  ConsumerState<BusinessSetupDetector> createState() => _BusinessSetupDetectorState();
}

class _BusinessSetupDetectorState extends ConsumerState<BusinessSetupDetector> {
  bool _isChecking = true;
  bool _needsSetup = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBusinessSetup();
  }

  Future<void> _checkBusinessSetup() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      // Check if business is set up
      final setupManager = ref.read(businessSetupManagerProvider);
      final isSetup = await setupManager.isBusinessSetup();

      if (!isSetup) {
        // No business ID or not found in Firestore
        setState(() {
          _needsSetup = true;
        });
      } else {
        // Business exists, make sure it's loaded
        final localStorage = ref.read(localStorageServiceProvider);
        final businessId = await localStorage.getString('businessId');

        // Set the business ID in the provider
        if (businessId != null && businessId.isNotEmpty) {
          ref.read(currentBusinessIdProvider.notifier).state = businessId;
        }

        setState(() {
          _needsSetup = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking business setup: $e';
        _needsSetup = true; // Show setup screen on error to allow recovery
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If still checking, show loading indicator
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking business configuration...'),
            ],
          ),
        ),
      );
    }

    // If there's an error, show it
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkBusinessSetup,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _needsSetup = true;
                    _errorMessage = null;
                  });
                },
                child: const Text('Go to Setup'),
              ),
            ],
          ),
        ),
      );
    }

    // Show setup screen or main app based on setup status
    return _needsSetup ? widget.setupScreen : widget.child;
  }
}

/// Provider to check if the business config is ready
final isBusinessConfigReadyProvider = Provider<bool>((ref) {
  final businessConfig = ref.watch(businessConfigProvider);
  return businessConfig.hasValue && businessConfig.value != null;
});

/// Provider for the setup screen path
final setupScreenPathProvider = Provider<String>((ref) {
  return '/setup';
});