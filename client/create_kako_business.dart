import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';

/// Script to create the "kako" business in Firestore database
/// This resolves the issue where the slug is detected in URL routing
/// but the business doesn't exist in the database
void main() async {
  debugPrint('🚀 Creating "kako" business in Firestore database...');

  try {
    final firestore = FirebaseFirestore.instance;
    final slugService = BusinessSlugService(firestore: firestore);

    // Check if "kako" business already exists
    final existingBusinessId = await slugService.getBusinessIdFromSlug('kako');
    if (existingBusinessId != null) {
      debugPrint(
          '✅ Business "kako" already exists with ID: $existingBusinessId');
      return;
    }

    debugPrint('📝 Business "kako" not found, creating...');

    // Create the "kako" business
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
    await firestore.collection('businesses').doc(businessId).set(businessData);
    debugPrint('✅ Created business document with ID: $businessId');

    // Verify the creation
    final verifyBusinessId = await slugService.getBusinessIdFromSlug('kako');
    if (verifyBusinessId == businessId) {
      debugPrint(
          '✅ Verification successful: slug "kako" resolves to business ID "$businessId"');
    } else {
      debugPrint(
          '❌ Verification failed: slug resolution returned $verifyBusinessId');
    }

    // Verify reverse lookup
    final verifySlug = await slugService.getSlugFromBusinessId(businessId);
    if (verifySlug == 'kako') {
      debugPrint(
          '✅ Reverse lookup successful: business ID "$businessId" resolves to slug "kako"');
    } else {
      debugPrint('❌ Reverse lookup failed: returned slug "$verifySlug"');
    }

    debugPrint('');
    debugPrint('🎉 "kako" business creation completed successfully!');
    debugPrint('');
    debugPrint('📋 Summary:');
    debugPrint('   Business ID: $businessId');
    debugPrint('   Business Slug: kako');
    debugPrint('   Business Name: Kako Restaurant');
    debugPrint('   Status: Active');
    debugPrint('');
    debugPrint('🔗 URL Navigation:');
    debugPrint('   /kako -> Should now resolve to business context');
    debugPrint('   /kako/menu -> Should show Kako Restaurant menu');
    debugPrint('   /kako/cart -> Should show Kako Restaurant cart');
    debugPrint('');
    debugPrint('🧪 Next Steps:');
    debugPrint('1. Test navigation to /kako URL');
    debugPrint('2. Verify business context is maintained');
    debugPrint('3. Check that business-specific data loads correctly');
  } catch (e, stackTrace) {
    debugPrint('❌ Error creating "kako" business: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

/// Alternative function to create business using BusinessConfig
Future<void> createKakoBusinessWithConfig() async {
  debugPrint('🚀 Creating "kako" business using BusinessConfig...');

  try {
    final firestore = FirebaseFirestore.instance;

    // Create BusinessConfig object
    final businessConfig = BusinessConfig(
      id: 'kako-business-001',
      name: 'Kako Restaurant',
      type: 'restaurant',
      slug: 'kako',
      logoUrl: '',
      coverImageUrl: '',
      description: 'Kako Restaurant - A delicious dining experience',
      contactInfo: {
        'email': 'contact@kako.com',
        'phone': '+1-555-KAKO',
        'website': 'https://kako.com'
      },
      address: {
        'street': '123 Main Street',
        'city': 'City',
        'state': 'State',
        'postalCode': '12345',
        'country': 'USA'
      },
      hours: {
        'monday': {'open': '09:00', 'close': '22:00'},
        'tuesday': {'open': '09:00', 'close': '22:00'},
        'wednesday': {'open': '09:00', 'close': '22:00'},
        'thursday': {'open': '09:00', 'close': '22:00'},
        'friday': {'open': '09:00', 'close': '23:00'},
        'saturday': {'open': '10:00', 'close': '23:00'},
        'sunday': {'open': '10:00', 'close': '21:00'}
      },
      settings: {
        'currency': 'USD',
        'taxRate': 0.08,
        'serviceCharge': 0.1,
        'primaryColor': '#FF5722',
        'secondaryColor': '#FFC107',
        'darkMode': false,
        'allowReservations': true,
        'allowOnlineOrders': true
      },
      features: [
        'menu',
        'tables',
        'reservations',
        'takeout',
        'delivery',
        'staff_management',
        'inventory'
      ],
      isActive: true,
    );

    // Save using BusinessConfig toFirestore method
    await firestore.collection('businesses').doc(businessConfig.id).set({
      ...businessConfig.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('✅ Successfully created "kako" business using BusinessConfig');
  } catch (e, stackTrace) {
    debugPrint('❌ Error creating "kako" business with BusinessConfig: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}
