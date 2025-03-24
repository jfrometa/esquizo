import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';
import 'dart:convert'; 
// Using a web-safe scanner approach

class MealPlanScanner extends ConsumerStatefulWidget {
  final Function(MealPlan) onMealPlanScanned;
  
  const MealPlanScanner({
    super.key,
    required this.onMealPlanScanned,
  });

  @override
  ConsumerState<MealPlanScanner> createState() => _MealPlanScannerState();
}

class _MealPlanScannerState extends ConsumerState<MealPlanScanner> {
  bool _hasScanned = false;
  String? _errorMessage;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Meal Plan'),
      ),
      body: Stack(
        children: [
          // QR Scanner - using a web-compatible scanner
          WebQRScanner(
            onScan: _onScan,
            constraints: const BoxConstraints.expand(),
          ),
          
          // Scanning overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Stack(
              children: [
                // Scan area cutout
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: SizedBox.shrink(),
                    ),
                  ),
                ),
                
                // Loading or error indicator
                if (_isLoading || _errorMessage != null)
                  Positioned(
                    bottom: 100,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _errorMessage != null
                            ? theme.colorScheme.error.withOpacity(0.8)
                            : theme.colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoading
                          ? Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 16),
                                const Text('Processing...'),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.error,
                                  color: theme.colorScheme.onError,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _errorMessage ?? '',
                                    style: TextStyle(
                                      color: theme.colorScheme.onError,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                
                // Instruction text
                Positioned(
                  top: 100,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Align the QR code within the frame to scan',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _onScan(String qrValue) async {
    if (_hasScanned || _isLoading) return;
    
    _hasScanned = true;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Parse the QR data
      final qrData = jsonDecode(qrValue) as Map<String, dynamic>;
      
      if (!qrData.containsKey('id')) {
        throw Exception('Invalid QR code format');
      }
      
      final mealPlanId = qrData['id'] as String;
      
      // Fetch the meal plan
      final mealPlanService = ref.read(mealPlanServiceProvider);
      final mealPlan = await mealPlanService.getMealPlanById(mealPlanId);
      
      if (mealPlan == null) {
        throw Exception('Meal plan not found');
      }
      
      if (!mealPlan.isActive) {
        throw Exception('This meal plan is not active');
      }
      
      if (mealPlan.mealsRemaining <= 0) {
        throw Exception('No meals remaining in this plan');
      }
      
      if (mealPlan.isExpired) {
        throw Exception('This meal plan has expired');
      }
      
      // Return the meal plan
      widget.onMealPlanScanned(mealPlan);
      
      // Close the scanner
      if (mounted) {
        Navigator.pop(context);
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _hasScanned = false; // Allow scanning again
      });
      
      // Clear the error after some time
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
        }
      });
    }
  }
}

// For web compatibility - this is a stub implementation
// In a real app, you'd implement this package with web-compatible code using HTML5 APIs
class WebQRScanner extends StatelessWidget {
  final Function(String) onScan;
  final BoxConstraints constraints;
  
  const WebQRScanner({
    super.key,
    required this.onScan,
    this.constraints = const BoxConstraints.expand(),
  });
  
  @override
  Widget build(BuildContext context) {
    // For a real implementation, you would use:
    // - On web: HTML5 getUserMedia API with a <video> element
    // - On mobile: A platform-specific implementation
    
    // This is a simplified placeholder that would be replaced with actual web-compatible code
    return ConstrainedBox(
      constraints: constraints,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Camera preview would go here
              const Icon(
                Icons.camera_alt,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 16),
              
              // For demo purposes - manual input option
              ElevatedButton(
                onPressed: () {
                  _showManualEntryDialog(context);
                },
                child: const Text('Enter QR code manually'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter QR Code Data'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'QR Code JSON',
            hintText: '{"id": "abc123", ...}',
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(context).pop();
                onScan(text);
              }
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }
}

// Note: For a real implementation with web WASM compatibility, you could:
// 1. Use jsQR (https://github.com/cozmo/jsQR) in JS interop
// 2. Use HTML5 navigator.mediaDevices.getUserMedia for camera access
// 3. Process frames with a canvas element

// Example web-compatible JS interop implementation would look like:
/*
@JS('jsQR')
external dynamic jsQR(dynamic imageData, int width, int height, dynamic options);

// Then use it in Dart with:
final result = jsQR(imageData, width, height, {});
if (result != null) {
  final qrData = result.data;
  onScan(qrData);
}
*/