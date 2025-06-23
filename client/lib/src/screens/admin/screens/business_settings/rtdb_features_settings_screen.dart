// File: lib/src/screens/admin/screens/business_settings/rtdb_features_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';

/// Screen to manage business features in the Realtime Database
/// This provides direct control of which features/UI elements appear in the app
class RtdbFeaturesSettingsScreen extends ConsumerStatefulWidget {
  const RtdbFeaturesSettingsScreen({super.key});

  @override
  ConsumerState<RtdbFeaturesSettingsScreen> createState() =>
      _RtdbFeaturesSettingsScreenState();
}

class _RtdbFeaturesSettingsScreenState
    extends ConsumerState<RtdbFeaturesSettingsScreen> {
  bool _isLoading = false;
  BusinessFeatures? _features;
  BusinessUI? _ui;

  @override
  void initState() {
    super.initState();
    // Load features on init using the current business ID
    _loadFeaturesFromCurrentBusinessId();
  }

  void _loadFeaturesFromCurrentBusinessId() {
    final businessId = ref.read(currentBusinessIdProvider);

    if (businessId.isNotEmpty) {
      debugPrint('Loading features for business ID: $businessId');
      _loadFeatures(businessId);
    } else {
      debugPrint('No valid business ID found from provider');
    }
  }

  Future<void> _loadFeatures(String businessId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(businessFeaturesServiceProvider);
      debugPrint('Fetching features and UI for business ID: $businessId');

      // Create a stream subscription to get the current values
      final featuresStream = service.getBusinessFeatures(businessId);
      final uiStream = service.getBusinessUI(businessId);

      // Get the first (current) value from each stream
      final features = await featuresStream.first;
      final ui = await uiStream.first;

      if (mounted) {
        setState(() {
          _features = features;
          _ui = ui;
          _isLoading = false;
        });
        debugPrint('Features and UI loaded successfully');
      }
    } catch (e) {
      debugPrint('Error loading RTDB features: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading features: $e')),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveFeatures() async {
    if (_features == null || _ui == null) {
      return;
    }

    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No business ID available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(businessFeaturesServiceProvider);
      debugPrint('Saving features and UI for business ID: $businessId');

      // Update both features and UI
      await service.updateBusinessFeatures(businessId, _features!);
      await service.updateBusinessUI(businessId, _ui!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Realtime Database features updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving RTDB features: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving features: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBusinessId = ref.watch(currentBusinessIdProvider);

    if (currentBusinessId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No business ID found'),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('RTDB Features Settings')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_features == null || _ui == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('RTDB Features Settings')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Unable to load features'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadFeatures(currentBusinessId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Database Features'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadFeatures(currentBusinessId),
            tooltip: 'Reload features',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildFeaturesSection(),
            const SizedBox(height: 32),
            _buildUISection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Realtime Database Features Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Business ID: ${ref.watch(currentBusinessIdProvider)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'These settings control which features and UI elements are visible '
              'in the app. Changes take effect immediately.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feature Flags',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enable or disable business features',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Catering'),
                subtitle: const Text('Enable catering services and menu'),
                value: _features!.catering,
                onChanged: (value) {
                  setState(() {
                    _features = _features!.copyWith(catering: value);
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Meal Plans'),
                subtitle: const Text('Enable meal subscriptions and plans'),
                value: _features!.mealPlans,
                onChanged: (value) {
                  setState(() {
                    _features = _features!.copyWith(mealPlans: value);
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('In-Dine'),
                subtitle: const Text('Enable in-restaurant dining features'),
                value: _features!.inDine,
                onChanged: (value) {
                  setState(() {
                    _features = _features!.copyWith(inDine: value);
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Staff Management'),
                subtitle: const Text('Enable staff scheduling and management'),
                value: _features!.staff,
                onChanged: (value) {
                  setState(() {
                    _features = _features!.copyWith(staff: value);
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Kitchen Display'),
                subtitle:
                    const Text('Enable kitchen display and order management'),
                value: _features!.kitchen,
                onChanged: (value) {
                  setState(() {
                    _features = _features!.copyWith(kitchen: value);
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Reservations'),
                subtitle: const Text('Enable table reservations'),
                value: _features!.reservations,
                onChanged: (value) {
                  setState(() {
                    _features = _features!.copyWith(reservations: value);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UI Configuration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Control which UI elements appear in the app',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Landing Page'),
                subtitle: const Text('Show landing page in navigation'),
                value: _ui!.landingPage,
                onChanged: (value) {
                  setState(() {
                    _ui = _ui!.copyWith(landingPage: value);
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Orders'),
                subtitle: const Text('Show orders tab in navigation'),
                value: _ui!.orders,
                onChanged: (value) {
                  setState(() {
                    _ui = _ui!.copyWith(orders: value);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveFeatures,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: const Text('Save Feature Settings'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}
