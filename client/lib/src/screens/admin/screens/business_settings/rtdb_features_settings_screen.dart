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

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // We'll load features in didChangeDependencies instead
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load features when dependencies are available, but only once
    if (!_isInitialized) {
      _loadFeaturesFromCurrentBusinessId();
      _isInitialized = true;
    }
  }

  void _loadFeaturesFromCurrentBusinessId() {
    debugPrint(
        'RtdbFeaturesSettingsScreen: Loading features from current business ID');
    final businessId = ref.read(currentBusinessIdProvider);

    if (businessId.isNotEmpty) {
      debugPrint(
          'RtdbFeaturesSettingsScreen: Loading features for business ID: $businessId');
      _loadFeatures(businessId);
    } else {
      debugPrint(
          'RtdbFeaturesSettingsScreen: No valid business ID found from provider');
      // Show a message if context is available (we're mounted)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No business ID available. Please select a business.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadFeatures(String businessId) async {
    if (!mounted) {
      debugPrint(
          'RtdbFeaturesSettingsScreen: Widget not mounted, canceling _loadFeatures');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint(
          'RtdbFeaturesSettingsScreen: Starting to load features for $businessId');
      final service = ref.read(businessFeaturesServiceProvider);

      // Create a stream subscription to get the current values
      final featuresStream = service.getBusinessFeatures(businessId);
      final uiStream = service.getBusinessUI(businessId);

      // Get the first (current) value from each stream
      debugPrint('RtdbFeaturesSettingsScreen: Awaiting features stream');
      final features = await featuresStream.first;
      debugPrint('RtdbFeaturesSettingsScreen: Awaiting UI stream');
      final ui = await uiStream.first;

      // Check if we're still mounted after the async operations
      if (mounted) {
        debugPrint(
            'RtdbFeaturesSettingsScreen: Setting state with loaded features');
        setState(() {
          _features = features;
          _ui = ui;
          _isLoading = false;
        });
        debugPrint(
            'RtdbFeaturesSettingsScreen: Features and UI loaded successfully');
      } else {
        debugPrint(
            'RtdbFeaturesSettingsScreen: Widget no longer mounted after loading features');
      }
    } catch (e) {
      debugPrint('RtdbFeaturesSettingsScreen: Error loading RTDB features: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading features: $e'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      } else {
        debugPrint(
            'RtdbFeaturesSettingsScreen: Widget not mounted, can\'t show error message');
      }
    }
  }

  Future<void> _saveFeatures() async {
    // Initial validation checks
    if (!mounted) {
      debugPrint(
          'RtdbFeaturesSettingsScreen: Widget not mounted, canceling save operation');
      return;
    }

    if (_features == null || _ui == null) {
      debugPrint(
          'RtdbFeaturesSettingsScreen: Features or UI is null, cannot save');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Features data not fully loaded'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId.isEmpty) {
      debugPrint(
          'RtdbFeaturesSettingsScreen: Empty business ID, cannot save features');
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
      debugPrint(
          'RtdbFeaturesSettingsScreen: Saving features and UI for business ID: $businessId');

      // Update both features and UI
      debugPrint('RtdbFeaturesSettingsScreen: Updating business features');
      await service.updateBusinessFeatures(businessId, _features!);
      debugPrint('RtdbFeaturesSettingsScreen: Updating business UI');
      await service.updateBusinessUI(businessId, _ui!);
      debugPrint(
          'RtdbFeaturesSettingsScreen: Features and UI saved successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Realtime Database features updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        debugPrint(
            'RtdbFeaturesSettingsScreen: Widget no longer mounted after saving');
      }
    } catch (e) {
      debugPrint('RtdbFeaturesSettingsScreen: Error saving RTDB features: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving features: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        debugPrint(
            'RtdbFeaturesSettingsScreen: Widget not mounted, can\'t show error message');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      } else {
        debugPrint(
            'RtdbFeaturesSettingsScreen: Widget not mounted in finally block');
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
