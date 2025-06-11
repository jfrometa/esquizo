// File: lib/src/core/business/business_slug_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../firebase/firebase_providers.dart';

/// Service to handle business slug to ID mapping and resolution
class BusinessSlugService {
  final FirebaseFirestore _firestore;

  BusinessSlugService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get business ID from slug
  Future<String?> getBusinessIdFromSlug(String slug) async {
    try {
      final querySnapshot = await _firestore
          .collection('businesses')
          .where('slug', isEqualTo: slug)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting business ID from slug: $e');
      return null;
    }
  }

  /// Get slug from business ID
  Future<String?> getSlugFromBusinessId(String businessId) async {
    try {
      final doc =
          await _firestore.collection('businesses').doc(businessId).get();

      if (doc.exists) {
        final data = doc.data();
        return data?['slug'] as String?;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting slug from business ID: $e');
      return null;
    }
  }

  /// Check if a slug exists and is available
  Future<bool> isSlugAvailable(String slug) async {
    try {
      final querySnapshot = await _firestore
          .collection('businesses')
          .where('slug', isEqualTo: slug)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      debugPrint('Error checking slug availability: $e');
      return false;
    }
  }

  /// Update business slug
  Future<bool> updateBusinessSlug(String businessId, String newSlug) async {
    try {
      // First check if the new slug is available
      if (!await isSlugAvailable(newSlug)) {
        return false;
      }

      // Update the business document
      await _firestore.collection('businesses').doc(businessId).update({
        'slug': newSlug,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error updating business slug: $e');
      return false;
    }
  }

  /// Get a list of suggested slugs based on business name
  Future<List<String>> getSuggestedSlugs(String businessName) async {
    final baseSlugs = <String>[];

    // Generate different variations
    final cleanName = businessName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    if (cleanName.isNotEmpty) {
      baseSlugs.add(cleanName);

      // Add variations with common business suffixes
      baseSlugs.add('$cleanName-restaurant');
      baseSlugs.add('$cleanName-cafe');
      baseSlugs.add('$cleanName-food');
      baseSlugs.add('$cleanName-kitchen');

      // Add variations with numbers
      for (int i = 1; i <= 5; i++) {
        baseSlugs.add('$cleanName-$i');
      }
    } else {
      baseSlugs.add('business');
    }

    // Filter out taken slugs
    final availableSlugs = <String>[];
    for (final slug in baseSlugs) {
      if (await isSlugAvailable(slug)) {
        availableSlugs.add(slug);
      }
    }

    return availableSlugs.take(10).toList(); // Return max 10 suggestions
  }

  /// Get all businesses for admin purposes (with slug information)
  Stream<List<Map<String, dynamic>>> streamBusinessesWithSlugs() {
    return _firestore
        .collection('businesses')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'slug': data['slug'] ?? '',
          'type': data['type'] ?? '',
          'isActive': data['isActive'] ?? true,
        };
      }).toList();
    });
  }
}

// Provider for BusinessSlugService
final businessSlugServiceProvider = Provider<BusinessSlugService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return BusinessSlugService(firestore: firestore);
});

// Provider to get business ID from slug
final businessIdFromSlugProvider =
    FutureProvider.family<String?, String>((ref, slug) async {
  final slugService = ref.watch(businessSlugServiceProvider);
  return await slugService.getBusinessIdFromSlug(slug);
});

// Provider to get slug from business ID
final slugFromBusinessIdProvider =
    FutureProvider.family<String?, String>((ref, businessId) async {
  final slugService = ref.watch(businessSlugServiceProvider);
  return await slugService.getSlugFromBusinessId(businessId);
});

// Provider to check slug availability
final slugAvailabilityProvider =
    FutureProvider.family<bool, String>((ref, slug) async {
  final slugService = ref.watch(businessSlugServiceProvider);
  return await slugService.isSlugAvailable(slug);
});
