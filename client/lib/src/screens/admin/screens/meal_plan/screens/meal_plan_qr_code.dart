import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/subscriptions/meal_plan_service.dart';
// import '../../../models/meal_plan.dart';
// import '../../../services/meal_plan_service.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
// Using 'qr' package which is pure Dart with no platform-specific code
import 'package:qr/qr.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';

class MealPlanQRCode extends ConsumerWidget {
  final String mealPlanId;
  
  const MealPlanQRCode({
    super.key,
    required this.mealPlanId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanAsync = ref.watch(mealPlanProvider(mealPlanId));
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan QR Code'),
      ),
      body: mealPlanAsync.when(
        data: (mealPlan) {
          if (mealPlan == null) {
            return const Center(
              child: Text('Meal plan not found'),
            );
          }
          
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mealPlan.title,
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Meals Remaining: ${mealPlan.mealsRemaining}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: mealPlan.mealsRemaining > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          
                          // QR Code using pure Dart implementation
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: QrCodeWidget(
                              data: _generateQRData(mealPlan),
                              size: 200,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'Show this QR code to the staff to use your meal plan.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Valid until: ${mealPlan.expiryDate != null ? "${mealPlan.expiryDate!.day}/${mealPlan.expiryDate!.month}/${mealPlan.expiryDate!.year}" : "No expiration date"}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          if (mealPlan.ownerName.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Assigned to: ${mealPlan.ownerName}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Additional actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.refresh,
                        label: 'Refresh',
                        onPressed: () {
                          ref.invalidate(mealPlanProvider(mealPlanId));
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        context,
                        icon: Icons.share,
                        label: 'Share',
                        onPressed: () {
                          _showShareOptions(context, mealPlan);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    );
  }
  
  String _generateQRData(MealPlan mealPlan) {
    // Create a JSON object with necessary details
    final qrData = {
      'id': mealPlan.id,
      'title': mealPlan.title,
      'owner': mealPlan.ownerName,
      'ownerId': mealPlan.ownerId,
      'remaining': mealPlan.mealsRemaining,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    // Return as JSON string
    return jsonEncode(qrData);
  }
  
  void _showShareOptions(BuildContext context, MealPlan mealPlan) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Meal Plan',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            
            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.content_copy,
                  label: 'Copy ID',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: mealPlan.id));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal Plan ID copied to clipboard')),
                    );
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.qr_code,
                  label: 'Save QR',
                  onTap: () {
                    Navigator.pop(context);
                    _saveMealPlanQR(context, mealPlan);
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaEmail(context, mealPlan);
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.message,
                  label: 'Message',
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaMessage(context, mealPlan);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveMealPlanQR(BuildContext context, MealPlan mealPlan) {
    // In a real app, implement QR code saving functionality
    // This would likely use a platform-agnostic approach for web compatibility
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code saving not implemented in this demo')),
    );
  }
  
  void _shareViaEmail(BuildContext context, MealPlan mealPlan) {
    // Use a web-compatible approach for sharing
    final subject = 'My ${mealPlan.title} Meal Plan';
    final body = '''
Hello,

Here's my meal plan information:

Plan: ${mealPlan.title}
Meals Remaining: ${mealPlan.mealsRemaining}
ID: ${mealPlan.id}

Please present this ID to the staff when using the meal plan.

Thank you!
''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email sharing not implemented in this demo')),
    );
  }
  
  void _shareViaMessage(BuildContext context, MealPlan mealPlan) {
    // Use a web-compatible approach for sharing
    final message = '''
My Meal Plan: ${mealPlan.title}
Meals Remaining: ${mealPlan.mealsRemaining}
ID: ${mealPlan.id}
''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sharing not implemented in this demo')),
    );
  }
}

// Pure Dart QR code implementation that works with web WASM
class QrCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;
  
  const QrCodeWidget({
    super.key,
    required this.data,
    required this.size,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
  });
  
  @override
  Widget build(BuildContext context) {
    // Generate QR code data using the 'qr' library
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    
    // Create QR code image
    return CustomPaint(
      size: Size(size, size),
      painter: QrPainter(
        qrCode: qrCode,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}

// Custom painter for QR code
class QrPainter extends CustomPainter {
  final QrCode qrCode;
  final Color backgroundColor;
  final Color foregroundColor;
  
  QrPainter({
    required this.qrCode,
    required this.backgroundColor,
    required this.foregroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (qrCode.moduleCount == 0) return;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Calculate the size of each module
    final moduleSize = size.width / qrCode.moduleCount;
    
    // Draw background
    paint.color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw modules
    paint.color = foregroundColor;
    
    // for (int row = 0; row < qrCode.moduleCount; row++) {
    //   for (int col = 0; col < qrCode.moduleCount; col++) {
    //     if (qrCode.isDark(row, col)) {
    //       final left = col * moduleSize;
    //       final top = row * moduleSize;
    //       canvas.drawRect(
    //         Rect.fromLTWH(left, top, moduleSize, moduleSize),
    //         paint,
    //       );
    //     }
    //   }
    // }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}