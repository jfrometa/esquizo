import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

// Generic resource model that can be extended for specific use cases
class Resource {
  final String id;
  final String businessId;
  final String type;
  final String name;
  final String? description;
  final Map<String, dynamic> attributes;
  final TableStatusEnum status;
  final bool isActive;
  
  Resource({
    required this.id,
    required this.businessId,
    required this.type,
    required this.name,
    this.description = '',
    this.attributes = const {},
    this.status = TableStatusEnum.available,
    this.isActive = true,
  });
  
  factory Resource.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Resource(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      type: data['type'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      attributes: data['attributes'] ?? {},
      status: data['status'] ?? 'available',
      isActive: data['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'type': type,
      'name': name,
      'description': description,
      'attributes': attributes,
      'status': status,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// Resource stats
class ResourceStats {
  final int totalResources;
  final Map<String, int> statusCounts;
  
  ResourceStats({
    required this.totalResources,
    required this.statusCounts,
  });
}

class ResourceService {
  final FirebaseFirestore _firestore;
  final String _businessId;
  final String _resourceType;
  
  ResourceService({
    FirebaseFirestore? firestore,
    required String businessId,
    required String resourceType,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _businessId = businessId,
    _resourceType = resourceType;
  
  // Collection reference
  CollectionReference get _resourcesCollection => 
      _firestore.collection('businesses').doc(_businessId).collection('resources');
  
  // Get all resources of a specific type
  Stream<List<Resource>> getResourcesStream() {
    return _resourcesCollection
        .where('type', isEqualTo: _resourceType)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Resource.fromFirestore(doc))
            .toList());
  }
  
  // Get active resources of a specific type
  Stream<List<Resource>> getActiveResourcesStream() {
    return _resourcesCollection
        .where('type', isEqualTo: _resourceType)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Resource.fromFirestore(doc))
            .toList());
  }
  
  // Get resources by status
  Stream<List<Resource>> getResourcesByStatusStream(String status) {
    return _resourcesCollection
        .where('type', isEqualTo: _resourceType)
        .where('status', isEqualTo: status)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Resource.fromFirestore(doc))
            .toList());
  }
  
  // Get resource by ID
  Future<Resource?> getResourceById(String resourceId) async {
    try {
      final doc = await _resourcesCollection.doc(resourceId).get();
      if (doc.exists) {
        return Resource.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching resource: $e');
      return null;
    }
  }
  
  // Update resource status
  Future<void> updateResourceStatus(String resourceId, String status) async {
    await _resourcesCollection.doc(resourceId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Get resource statistics
  Future<ResourceStats> getResourceStats() async {
    try {
      final snapshot = await _resourcesCollection
          .where('type', isEqualTo: _resourceType)
          .get();
      
      final resources = snapshot.docs
          .map((doc) => Resource.fromFirestore(doc))
          .toList();
      
      final totalResources = resources.where((r) => r.isActive).length;
      
      // Count resources by status
      final statusCounts = <String, int>{};
      for (final resource in resources.where((r) => r.isActive)) {
        statusCounts[resource.status.name] = (statusCounts[resource.status.name] ?? 0) + 1;
      }
      
      return ResourceStats(
        totalResources: totalResources,
        statusCounts: statusCounts,
      );
    } catch (e) {
      print('Error calculating resource stats: $e');
      return ResourceStats(
        totalResources: 0,
        statusCounts: {},
      );
    }
  }
}