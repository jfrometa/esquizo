import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';

/// Script to create the "kako" business in Firestore database
/// This resolves the issue where the slug is detected in URL routing
/// but the business doesn't exist in the database
void main() async {
  print('🚀 Creating "kako" business in Firestore database...');
  
  try {
    final firestore = FirebaseFirestore.instance;
    final slugService = BusinessSlugService(firestore: firestore);
    
    // Check if "kako" business already exists
    final existingBusinessId = await slugService.getBusinessIdFromSlug('kako');
    if (existingBusinessId != null) {
      print('✅ Business "kako" already exists with ID: $existingBusinessId');
      return;
    }
    
    print('📝 Business "kako" not found, creating...');
    
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
    print('✅ Created business document with ID: $businessId');
    
    // Verify the creation
    final verifyBusinessId = await slugService.getBusinessIdFromSlug('kako');
    if (verifyBusinessId == businessId) {
      print('✅ Verification successful: slug "kako" resolves to business ID "$businessId"');
    } else {
      print('❌ Verification failed: slug resolution returned $verifyBusinessId');
    }
    
    // Verify reverse lookup
    final verifySlug = await slugService.getSlugFromBusinessId(businessId);
    if (verifySlug == 'kako') {
      print('✅ Reverse lookup successful: business ID "$businessId" resolves to slug "kako"');
    } else {
      print('❌ Reverse lookup failed: returned slug "$verifySlug"');
    }
    
    print('');
    print('🎉 "kako" business creation completed successfully!');
    print('');
    print('📋 Summary:');
    print('   Business ID: $businessId');
    print('   Business Slug: kako');
    print('   Business Name: Kako Restaurant');
    print('   Status: Active');
    print('');
    print('🔗 URL Navigation:');
    print('   /kako -> Should now resolve to business context');
    print('   /kako/menu -> Should show Kako Restaurant menu');
    print('   /kako/cart -> Should show Kako Restaurant cart');
    print('');
    print('🧪 Next Steps:');
    print('1. Test navigation to /kako URL');
    print('2. Verify business context is maintained');
    print('3. Check that business-specific data loads correctly');
    
  } catch (e, stackTrace) {
    print('❌ Error creating "kako" business: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Alternative function to create business using BusinessConfig
Future<void> createKakoBusinessWithConfig() async {
  print('🚀 Creating "kako" business using BusinessConfig...');
  
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
    await firestore
        .collection('businesses')
        .doc(businessConfig.id)
        .set({
      ...businessConfig.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ Successfully created "kako" business using BusinessConfig');
    
  } catch (e, stackTrace) {
    print('❌ Error creating "kako" business with BusinessConfig: $e');
    print('Stack trace: $stackTrace');
  }
}
