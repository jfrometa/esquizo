// File: lib/src/core/setup/business_setup_detector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../business/business_config_provider.dart';

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
  ConsumerState<BusinessSetupDetector> createState() =>
      _BusinessSetupDetectorState();
}

class _BusinessSetupDetectorState extends ConsumerState<BusinessSetupDetector> {
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeBusinessConfig();
  }

  Future<void> _initializeBusinessConfig() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Note: Business ID is now handled by URL-aware routing system
      // No need to manually initialize it here

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing business configuration: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If still initializing, show loading indicator
    if (_isInitializing) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Initializing application...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If there's an error, show it
    if (_errorMessage != null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _initializeBusinessConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Check if business config exists and is complete
    final businessConfigAsync = ref.watch(businessConfigProvider);

    return businessConfigAsync.when(
      data: (businessConfig) {
        // If business is already configured, show the main app
        if (businessConfig != null && businessConfig.isActive) {
          return widget.child;
        }
        // If no business config or inactive, show setup screen
        return widget.setupScreen;
      },
      loading: () {
        // OPTIMIZATION: If we already have a previous value, keep showing the child
        // to prevent unmounting the entire MaterialApp/GoRouter and causing loops.
        if (businessConfigAsync.hasValue &&
            businessConfigAsync.value != null &&
            businessConfigAsync.value!.isActive) {
          debugPrint(
              '🔄 Business context refreshing in background, keeping UI mounted');
          return widget.child;
        }

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading business configuration...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) => Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Error loading business configuration: $error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _initializeBusinessConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
