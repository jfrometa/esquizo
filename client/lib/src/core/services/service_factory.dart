import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'resource_service.dart';
import 'catalog_service.dart';
import 'order_service.dart';
import '../providers/business/business_config_provider.dart';

/// Factory for creating business-type specific services
class ServiceFactory {
  final String businessId;
  final String businessType;
  final FirebaseFirestore firestore;
  
  ServiceFactory({
    required this.businessId,
    required this.businessType,
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;
  
  // Create a resource service appropriate for the business type
  ResourceService createResourceService(String resourceType) {
    switch (businessType) {
      case 'restaurant':
        return ResourceService(
          businessId: businessId,
          resourceType: resourceType,
          firestore: firestore,
        );
      case 'hotel':
        return ResourceService(
          businessId: businessId,
          resourceType: resourceType,
          firestore: firestore,
        );
      default:
        return ResourceService(
          businessId: businessId,
          resourceType: resourceType,
          firestore: firestore,
        );
    }
  }
  
  // Create a catalog service appropriate for the business type
  CatalogService createCatalogService(String catalogType) {
    switch (businessType) {
      case 'restaurant':
        return CatalogService(
          businessId: businessId,
          catalogType: catalogType,
          firestore: firestore,
        );
      case 'retail':
        return CatalogService(
          businessId: businessId,
          catalogType: catalogType,
          firestore: firestore,
        );
      default:
        return CatalogService(
          businessId: businessId,
          catalogType: catalogType,
          firestore: firestore,
        );
    }
  }
  
  // Create an order service appropriate for the business type
  OrderService createOrderService() {
    switch (businessType) {
      case 'restaurant':
        return OrderService(
           firestore,
            businessId,
        );
      case 'retail':
        return OrderService(
           firestore,
            businessId,
        );
      default:
        return OrderService(
           firestore,
            businessId,
        );
    }
  }
}

// Provider for service factory
final serviceFactoryProvider = Provider<ServiceFactory>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  final businessType = ref.watch(businessTypeProvider);
  
  return ServiceFactory(
    businessId: businessId,
    businessType: businessType,
  );
});