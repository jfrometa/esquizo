import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget to create the "kako" business in the live Firestore database
/// This resolves the navigation issue where the slug is detected but the business doesn't exist
class CreateKakoBusinessScreen extends ConsumerStatefulWidget {
  const CreateKakoBusinessScreen({super.key});

  @override
  ConsumerState<CreateKakoBusinessScreen> createState() =>
      _CreateKakoBusinessScreenState();
}

class _CreateKakoBusinessScreenState
    extends ConsumerState<CreateKakoBusinessScreen> {
  bool _isCreating = false;
  String? _status;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Kako Business'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚀 Create "kako" Business',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will create the "kako" business in the Firestore database to resolve navigation issues.',
                    ),
                    const SizedBox(height: 16),
                    const Text('Business Details:'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Name:', 'Kako Restaurant'),
                    _buildDetailRow('Slug:', 'kako'),
                    _buildDetailRow('Type:', 'restaurant'),
                    _buildDetailRow('Status:', 'Active'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_status != null) ...[
              Card(
                color: _errorMessage != null
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _errorMessage != null ? '❌ Error' : '✅ Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _errorMessage != null ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_status!),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCreating ? null : _createKakoBusiness,
                icon: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_business),
                label: Text(_isCreating
                    ? 'Creating Business...'
                    : 'Create Kako Business'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isCreating ? null : _checkKakoBusiness,
                icon: const Icon(Icons.search),
                label: const Text('Check if Kako Business Exists'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _checkKakoBusiness() async {
    setState(() {
      _isCreating = true;
      _status = null;
      _errorMessage = null;
    });

    try {
      final slugService = ref.read(businessSlugServiceProvider);

      final businessId = await slugService.getBusinessIdFromSlug('kako');

      if (businessId != null) {
        setState(() {
          _status = 'Business "kako" already exists with ID: $businessId';
        });
      } else {
        setState(() {
          _status = 'Business "kako" does not exist in the database';
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

  Future<void> _createKakoBusiness() async {
    setState(() {
      _isCreating = true;
      _status = null;
      _errorMessage = null;
    });

    try {
      final firestore = ref.read(firebaseFirestoreProvider);
      final slugService = ref.read(businessSlugServiceProvider);

      // Check if business already exists
      final existingBusinessId =
          await slugService.getBusinessIdFromSlug('kako');
      if (existingBusinessId != null) {
        setState(() {
          _status =
              'Business "kako" already exists with ID: $existingBusinessId';
        });
        return;
      }

      // Create the business
      const businessId = 'kako-business-001';
      final businessData = {
        'name': 'Kako Restaurant',
        'type': 'restaurant',
        'slug': 'kako',
        'logoUrl': '',
        'coverImageUrl': '',
        'description': 'Kako Restaurant - A delicious dining experience',
        'contactInfo': {
          'email': 'contact@kako.com',
          'phone': '+1-555-KAKO',
          'website': 'https://kako.com'
        },
        'address': {
          'street': '123 Main Street',
          'city': 'City',
          'state': 'State',
          'postalCode': '12345',
          'country': 'USA'
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
          'primaryColor': '#FF5722',
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
          'staff_management',
          'inventory'
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
      final verifyBusinessId = await slugService.getBusinessIdFromSlug('kako');
      final verifySlug = await slugService.getSlugFromBusinessId(businessId);

      if (verifyBusinessId == businessId && verifySlug == 'kako') {
        setState(() {
          _status = '''✅ Successfully created "kako" business!

Business ID: $businessId
Business Slug: kako
Business Name: Kako Restaurant

Navigation should now work:
• /kako → Kako Restaurant context
• /kako/menu → Kako Restaurant menu
• /kako/cart → Kako Restaurant cart

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
        _status = 'Failed to create "kako" business';
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
}

/// Quick function to add to existing app for testing
class KakoBusinessCreatorWidget extends ConsumerWidget {
  const KakoBusinessCreatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateKakoBusinessScreen(),
          ),
        );
      },
      icon: const Icon(Icons.add_business),
      label: const Text('Create Kako'),
      backgroundColor: Colors.orange,
    );
  }
}
