// File: lib/src/core/business/run_features_example.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_example.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_service.dart';

/// Widget to demonstrate running the BusinessFeaturesExample
class RunFeaturesExampleScreen extends ConsumerStatefulWidget {
  const RunFeaturesExampleScreen({super.key});

  @override
  ConsumerState<RunFeaturesExampleScreen> createState() =>
      _RunFeaturesExampleScreenState();
}

class _RunFeaturesExampleScreenState
    extends ConsumerState<RunFeaturesExampleScreen> {
  bool _isLoading = false;
  String _logOutput = '';
  String _statusMessage = '';
  bool _success = false;
  // Store example instance for build method listeners
  late BusinessFeaturesExample _example;

  // Track which steps have been run successfully
  final Map<String, bool> _stepsCompleted = {
    'initialization': false,
    'uiEnabled': false,
    'featuresEnabled': false,
    'verification': false,
  };

  @override
  void initState() {
    super.initState();
    // Initialize example but defer the method calls to after build
    _example = BusinessFeaturesExample(ref);
    _statusMessage = 'Ready to run example';

    // Run after first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _runExample());
  }

  void _setStatusMessage(String message, {bool isSuccess = false}) {
    setState(() {
      _statusMessage = message;
      _success = isSuccess;
    });
  }

  Future<void> _runExample() async {
    setState(() {
      _isLoading = true;
      _logOutput = 'Running BusinessFeaturesExample...\n';
      _stepsCompleted.updateAll((key, value) => false);
      _setStatusMessage('Running business features example...');
    });

    try {
      // Get current business ID
      final businessId = ref.read(currentBusinessIdProvider);
      _addLog('Using business ID: $businessId');

      if (businessId.isEmpty) {
        _setStatusMessage('⚠️ No business ID available', isSuccess: false);
        _addLog(
            '❌ ERROR: No valid business ID found. Please ensure a business is selected.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Step 1: Initialize the business (try-catch to handle Firebase web issues)
      _addLog('\nStep 1: Setting up business with ALL features enabled');
      _setStatusMessage('Initializing business features...');
      try {
        await _example.setupNewBusiness(businessId);
        _stepsCompleted['initialization'] = true;
      } catch (e) {
        _addLog('⚠️ Setup Error: $e (continuing with example)');
      }

      // Step 2: Customize UI - set all UI components to true
      _addLog('\nStep 2: Enabling ALL UI components');
      _setStatusMessage('Enabling all UI components...');
      try {
        await _example.customizeBusinessUI(businessId);
        _stepsCompleted['uiEnabled'] = true;
      } catch (e) {
        _addLog('⚠️ UI customization error: $e');
      }

      // Step 3: Customize features - set all features to true
      _addLog('\nStep 3: Enabling ALL business features');
      _setStatusMessage('Enabling all business features...');
      try {
        await _example.customizeBusinessFeatures(businessId);
        _stepsCompleted['featuresEnabled'] = true;
      } catch (e) {
        _addLog('⚠️ Features customization error: $e');
      }

      // Step 4: Final check of updated settings
      _addLog('\nStep 4: Verifying business settings');
      _setStatusMessage('Verifying all features are enabled...');
      try {
        await _example.checkBusinessSettings(businessId);
        _stepsCompleted['verification'] = true;
      } catch (e) {
        _addLog('⚠️ Verification error: $e');
      }

      // Check if all steps completed successfully
      final allStepsCompleted = !_stepsCompleted.values.contains(false);
      if (allStepsCompleted) {
        _setStatusMessage(
            '✅ Success! All features and UI elements are enabled.',
            isSuccess: true);
      } else {
        _setStatusMessage(
            '⚠️ Example completed with some errors. Check logs for details.');
      }

      _addLog('\nExample completed! Check console for more detailed logs.');
    } catch (e) {
      _addLog('\n❌ Error running example: $e');
      _setStatusMessage('❌ Error: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkCurrentStatus() async {
    setState(() {
      _isLoading = true;
      _logOutput = 'Checking current business settings...\n';
    });

    try {
      final businessId = ref.read(currentBusinessIdProvider);
      if (businessId.isEmpty) {
        _addLog('❌ No valid business ID found');
        _setStatusMessage('⚠️ No business ID available', isSuccess: false);
        return;
      }

      _addLog('Checking current settings for business ID: $businessId');
      await _example.monitorBusinessSettings(businessId);
      _setStatusMessage('Settings checked successfully');
    } catch (e) {
      _addLog('❌ Error checking settings: $e');
      _setStatusMessage('Error checking settings', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addLog(String message) {
    setState(() {
      _logOutput += '$message\n';
    });
    debugPrint(message);
  }

  @override
  Widget build(BuildContext context) {
    // Simply get the current business ID for display
    final businessId = ref.watch(currentBusinessIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Business Features Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runExample,
            tooltip: 'Run example again',
          ),
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: _isLoading ? null : _checkCurrentStatus,
            tooltip: 'Check current status',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              elevation: 3,
              color: _success ? Colors.green.shade50 : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _success ? Icons.check_circle : Icons.info_outline,
                          color: _success ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Business ID: $businessId',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: _success
                            ? Colors.green.shade800
                            : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress indicators for each step
                    if (_isLoading)
                      const LinearProgressIndicator()
                    else
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildStepChip('Init',
                              _stepsCompleted['initialization'] ?? false),
                          _buildStepChip(
                              'UI', _stepsCompleted['uiEnabled'] ?? false),
                          _buildStepChip('Features',
                              _stepsCompleted['featuresEnabled'] ?? false),
                          _buildStepChip('Verified',
                              _stepsCompleted['verification'] ?? false),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _runExample,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Example'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _checkCurrentStatus,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Check Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example Output',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  _logOutput,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepChip(String label, bool completed) {
    return Chip(
      avatar: Icon(
        completed ? Icons.check_circle : Icons.circle_outlined,
        size: 18,
        color: completed ? Colors.green : Colors.grey,
      ),
      label: Text(label),
      backgroundColor: completed ? Colors.green.shade100 : Colors.grey.shade200,
    );
  }
}
