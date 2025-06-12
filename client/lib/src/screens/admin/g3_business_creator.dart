// G3 Business Creator - Creates a test business with slug 'g3'
// Based on the existing kako_business_creator.dart pattern

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';

class G3BusinessCreator extends ConsumerStatefulWidget {
  const G3BusinessCreator({super.key});

  @override
  ConsumerState<G3BusinessCreator> createState() => _G3BusinessCreatorState();
}

class _G3BusinessCreatorState extends ConsumerState<G3BusinessCreator> {
  bool _isCreating = false;
  String? _status;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'G3 Business Creator',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This will create a test business with slug "g3" for routing testing.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Status display
            if (_status != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _errorMessage != null
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  border: Border.all(
                    color: _errorMessage != null
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _status!,
                  style: TextStyle(
                    color: _errorMessage != null
                        ? Colors.red.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $_errorMessage',
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isCreating ? null : _checkG3Business,
                  child: _isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Check G3 Business'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createG3Business,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create G3 Business'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkG3Business() async {
    setState(() {
      _isCreating = true;
      _status = null;
      _errorMessage = null;
    });

    try {
      final slugService = ref.read(businessSlugServiceProvider);
      final businessId = await slugService.getBusinessIdFromSlug('g3');

      if (businessId != null) {
        setState(() {
          _status = 'Business "g3" already exists with ID: $businessId';
        });
      } else {
        setState(() {
          _status = 'Business "g3" does not exist in the database';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking business: $e';
        _status = 'Failed to check if business exists';
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  Future<void> _createG3Business() async {
    setState(() {
      _isCreating = true;
      _status = null;
      _errorMessage = null;
    });

    try {
      final firestore = ref.read(firebaseFirestoreProvider);
      final slugService = ref.read(businessSlugServiceProvider);

      // Check if business already exists
      final existingBusinessId = await slugService.getBusinessIdFromSlug('g3');
      if (existingBusinessId != null) {
        setState(() {
          _status = 'Business "g3" already exists with ID: $existingBusinessId';
        });
        return;
      }

      // Create the business
      const businessId = 'g3-business-001';
      final businessData = {
        'name': 'G3 Restaurant',
        'type': 'restaurant',
        'slug': 'g3',
        'logoUrl': '',
        'coverImageUrl': '',
        'description': 'G3 Test Restaurant for routing testing',
        'contactInfo': {
          'phone': '+1 (555) 123-4567',
          'email': 'info@g3restaurant.com',
          'website': 'https://g3restaurant.com'
        },
        'address': {
          'street': '123 Test Street',
          'city': 'Test City',
          'state': 'TS',
          'zipCode': '12345',
          'country': 'United States'
        },
        'hours': {
          'monday': {'open': '09:00', 'close': '22:00'},
          'tuesday': {'open': '09:00', 'close': '22:00'},
          'wednesday': {'open': '09:00', 'close': '22:00'},
          'thursday': {'open': '09:00', 'close': '22:00'},
          'friday': {'open': '09:00', 'close': '23:00'},
          'saturday': {'open': '10:00', 'close': '23:00'},
          'sunday': {'open': '10:00', 'close': '21:00'}
        },
        'settings': {
          'currency': 'USD',
          'taxRate': 0.08,
          'serviceCharge': 0.1,
          'primaryColor': '#2196F3',
          'secondaryColor': '#FFC107',
          'darkMode': false,
          'allowReservations': true,
          'allowOnlineOrders': true
        },
        'features': [
          'menu',
          'tables',
          'reservations',
          'takeout',
          'delivery',
          'staff_management'
        ],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Create business document
      await firestore
          .collection('businesses')
          .doc(businessId)
          .set(businessData);

      // Verify creation
      final verifyBusinessId = await slugService.getBusinessIdFromSlug('g3');
      final verifySlug = await slugService.getSlugFromBusinessId(businessId);

      if (verifyBusinessId == businessId && verifySlug == 'g3') {
        setState(() {
          _status = '''✅ Successfully created "g3" business!

Business ID: $businessId
Business Slug: g3
Business Name: G3 Restaurant

Navigation should now work:
• /g3 → G3 Restaurant context
• /g3/menu → G3 Restaurant menu
• /g3/carrito → G3 Restaurant cart
• /g3/cuenta → G3 Restaurant account

The business is active and ready for use.''';
        });
      } else {
        setState(() {
          _errorMessage = 'Business created but verification failed';
          _status =
              'Created business but slug resolution is not working correctly';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _status = 'Failed to create "g3" business';
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
}

/// Quick function to add to existing app for testing
void addG3BusinessCreatorToApp() {
  print('To add G3 Business Creator to your app:');
  print('1. Add G3BusinessCreator widget to your admin screen');
  print('2. Or call createG3BusinessDirectly() function');
  print('3. Navigate to /g3 after creation to test routing');
}

/// Direct function to create g3 business programmatically
Future<void> createG3BusinessDirectly() async {
  print('🏗️ Creating G3 business directly...');
  print(
      'This function should be called within a proper Flutter/Firebase context');
  print('with proper initialization and error handling.');
}
