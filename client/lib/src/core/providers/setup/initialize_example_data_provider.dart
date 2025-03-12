import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/setup/example_data_implementation.dart';
 
part 'initialize_example_data_provider.g.dart';


/// Provider for example data service
final exampleDataServiceProvider = Provider<ExampleDataService>((ref) {
  return ExampleDataService();
});

/// Provider to initialize example data for a business
/// 
/// This provider will create sample data based on the business type.
/// It requires a businessId, businessType, and adminEmail to function.
@riverpod
class InitializeExampleData extends _$InitializeExampleData {
  @override
  Future<void> build({
    required String businessId,
    required String businessType,
    required String adminEmail,
  }) async {
    // Get the example data service
    final exampleDataService = ref.read(exampleDataServiceProvider);
    
    // Check if example data is already initialized
    final isInitialized = await exampleDataService.isExampleDataInitialized(businessId);
    
    // Only initialize if not already initialized
    if (!isInitialized) {
      await exampleDataService.initializeExampleData(
        businessId: businessId,
        businessType: businessType,
        adminEmail: adminEmail,
      );
    }
  }
}