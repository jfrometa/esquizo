// Quick fix: Create G3 business for routing testing
// Run this script in your Flutter app to create the missing business

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createG3BusinessForTesting() async {
  print('🏗️ Creating G3 business for routing testing...');

  try {
    final firestore = FirebaseFirestore.instance;

    const businessData = {
      'name': 'G3 Restaurant',
      'type': 'restaurant',
      'slug': 'g3',
      'logoUrl': '',
      'coverImageUrl': '',
      'description': 'G3 Test Restaurant for routing',
      'contactInfo': {
        'phone': '+1 (555) 123-4567',
        'email': 'info@g3restaurant.com'
      },
      'address': {
        'street': '123 Test Street',
        'city': 'Test City',
        'state': 'TS',
        'zipCode': '12345'
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
        'primaryColor': '#2196F3',
        'secondaryColor': '#FFC107',
      },
      'features': ['menu', 'online_ordering', 'takeout'],
      'isActive': true,
      // 'createdAt': FieldValue.serverTimestamp(),
      // 'updatedAt': FieldValue.serverTimestamp(),
    };

    // Create the business document
    await firestore
        .collection('businesses')
        .doc('g3-business-001')
        .set(businessData);

    print('✅ Successfully created G3 business!');
    print('Business ID: g3-business-001');
    print('Business Slug: g3');
    print('');
    print('🔗 Navigation should now work:');
    print('• /g3 → G3 Restaurant context');
    print('• /g3/menu → G3 Restaurant menu');
    print('• /g3/carrito → G3 Restaurant cart');
    print('• /g3/cuenta → G3 Restaurant account');
  } catch (e) {
    print('❌ Error creating G3 business: $e');
  }
}

void main() async {
  await createG3BusinessForTesting();
}
