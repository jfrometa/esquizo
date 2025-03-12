import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/resource_service.dart';
import '../business/business_config_provider.dart';

// Provider for resource type
final currentResourceTypeProvider = StateProvider<String>((ref) => 'table');

// Provider for resource service
final resourceServiceProvider = Provider<ResourceService>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  final resourceType = ref.watch(currentResourceTypeProvider);
  
  return ResourceService(
    businessId: businessId,
    resourceType: resourceType,
  );
});

// Provider for resources stream
final resourcesStreamProvider = StreamProvider<List<Resource>>((ref) {
  final resourceService = ref.watch(resourceServiceProvider);
  return resourceService.getResourcesStream();
});

// Provider for active resources
final activeResourcesProvider = StreamProvider<List<Resource>>((ref) {
  final resourceService = ref.watch(resourceServiceProvider);
  return resourceService.getActiveResourcesStream();
});

// Provider for resources by status
final resourcesByStatusProvider = StreamProvider.family<List<Resource>, String>((ref, status) {
  final resourceService = ref.watch(resourceServiceProvider);
  return resourceService.getResourcesByStatusStream(status);
});

// Provider for resource by ID
final resourceByIdProvider = FutureProvider.family<Resource?, String>((ref, resourceId) {
  final resourceService = ref.watch(resourceServiceProvider);
  return resourceService.getResourceById(resourceId);
});

// Provider for resource stats
final resourceStatsProvider = FutureProvider<ResourceStats>((ref) {
  final resourceService = ref.watch(resourceServiceProvider);
  return resourceService.getResourceStats();
});