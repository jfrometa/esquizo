import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/unified_business_context_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

/// Test script to validate that business context and business ID are determined
/// solely by the current URL/route, not by localStorage.
///
/// This test should verify:
/// 1. Business ID changes when URL changes
/// 2. Business context updates correctly based on URL
/// 3. No localStorage reads/writes affect business logic
/// 4. Provider invalidation works correctly
/// 5. Business ID is correct after navigation or reload simulation

void main() {
  runApp(
    ProviderScope(
      child: BusinessUrlValidationApp(),
    ),
  );
}

class BusinessUrlValidationApp extends ConsumerWidget {
  const BusinessUrlValidationApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Business URL Validation Test',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class BusinessValidationScreen extends ConsumerStatefulWidget {
  final String businessSlug;

  const BusinessValidationScreen({
    super.key,
    required this.businessSlug,
  });

  @override
  ConsumerState<BusinessValidationScreen> createState() =>
      _BusinessValidationScreenState();
}

class _BusinessValidationScreenState
    extends ConsumerState<BusinessValidationScreen> {
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    _addLog('🔄 Screen initialized with slug: ${widget.businessSlug}');
  }

  void _addLog(String message) {
    setState(() {
      logs.add(
          '${DateTime.now().toIso8601String().split('T')[1].split('.')[0]} - $message');
      // Keep only last 20 logs
      if (logs.length > 20) {
        logs.removeAt(0);
      }
    });
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the business providers
    final currentBusinessId = ref.watch(currentBusinessIdProvider);
    final businessContext = ref.watch(unifiedBusinessContextProvider);
    final businessSlugFromUrl = ref.watch(businessSlugFromUrlProvider);

    // Log changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('📍 Current Business ID from provider: $currentBusinessId');
      _addLog('🏢 Business Context: ${businessContext.when(
        data: (context) =>
            'ID=${context.businessId}, Slug=${context.businessSlug}',
        loading: () => 'Loading...',
        error: (e, _) => 'Error: $e',
      )}');
      _addLog('🛣️ Business Slug from URL: $businessSlugFromUrl');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Business URL Validation'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                      'Current State',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('URL Business Slug:', widget.businessSlug),
                    _buildInfoRow('Provider Business ID:', currentBusinessId),
                    _buildInfoRow(
                        'URL Business Slug:', businessSlugFromUrl ?? 'null'),
                    const SizedBox(height: 16),
                    Text(
                      'Business Context:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    businessContext.when(
                      data: (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Business ID:', context.businessId),
                          _buildInfoRow(
                              'Business Slug:', context.businessSlug ?? 'null'),
                          _buildInfoRow(
                              'Is Default:', context.isDefault.toString()),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigation Tests',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    _buildNavigationButton('Default Business', '/'),
                    _buildNavigationButton('G3 Business', '/g3'),
                    _buildNavigationButton('Kako Business', '/kako'),
                    _buildNavigationButton('Test Business', '/test'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _addLog('🧹 Clearing logs...');
                        setState(() {
                          logs.clear();
                        });
                      },
                      child: const Text('Clear Logs'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-time Logs',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.0,
                          ),
                          child: Text(
                            logs[index],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _addLog('🧭 Navigating to: $route');
            context.go(route);
          },
          child: Text('Navigate to $label ($route)'),
        ),
      ),
    );
  }
}
