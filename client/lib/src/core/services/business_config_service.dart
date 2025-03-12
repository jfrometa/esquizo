import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessConfig {
  final String id;
  final String name;
  final String type; // restaurant, retail, service, etc.
  final String logoUrl;
  final String coverImageUrl;
  final String description;
  final Map<String, dynamic> contactInfo;
  final Map<String, dynamic> address;
  final Map<String, dynamic> hours;
  final Map<String, dynamic> settings;
  final List<String> features;
  final bool isActive;
  
  BusinessConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.logoUrl,
    required this.coverImageUrl,
    required this.description,
    required this.contactInfo,
    required this.address,
    required this.hours,
    required this.settings,
    required this.features,
    required this.isActive,
  });
  
  factory BusinessConfig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessConfig(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'generic',
      logoUrl: data['logoUrl'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      description: data['description'] ?? '',
      contactInfo: data['contactInfo'] ?? {},
      address: data['address'] ?? {},
      hours: data['hours'] ?? {},
      settings: data['settings'] ?? {},
      features: List<String>.from(data['features'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'description': description,
      'contactInfo': contactInfo,
      'address': address,
      'hours': hours,
      'settings': settings,
      'features': features,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  // Helper method to check if a feature is enabled
  bool hasFeature(String feature) {
    return features.contains(feature);
  }
  
  // Helper method to get a setting with a default value
  T getSetting<T>(String key, T defaultValue) {
    if (settings.containsKey(key)) {
      final value = settings[key];
      if (value is T) {
        return value;
      }
    }
    return defaultValue;
  }
}

class BusinessConfigService {
  final FirebaseFirestore _firestore;
  
  BusinessConfigService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  // Get business configuration
  Future<BusinessConfig?> getBusinessConfig(String businessId) async {
    try {
      final doc = await _firestore.collection('businesses').doc(businessId).get();
      if (doc.exists) {
        return BusinessConfig.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching business config: $e');
      return null;
    }
  }
  
  // Stream business configuration for real-time updates
  Stream<BusinessConfig?> streamBusinessConfig(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return BusinessConfig.fromFirestore(doc);
          }
          return null;
        });
  }
  
  // Update business configuration
  Future<void> updateBusinessConfig(BusinessConfig config) async {
    await _firestore
        .collection('businesses')
        .doc(config.id)
        .update(config.toFirestore());
  }
}