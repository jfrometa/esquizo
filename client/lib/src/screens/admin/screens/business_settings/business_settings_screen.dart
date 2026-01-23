import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_setup_screen.dart';
import 'rtdb_features_settings_screen.dart';

class BusinessSettingsScreen extends ConsumerStatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  ConsumerState<BusinessSettingsScreen> createState() =>
      _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends ConsumerState<BusinessSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _logoUrlController;
  late TextEditingController _coverImageUrlController;
  String _businessType = 'restaurant';
  Map<String, dynamic> _contactInfo = {};
  Map<String, dynamic> _address = {};
  Map<String, dynamic> _hours = {};
  Map<String, dynamic> _settings = {};
  List<String> _features = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Initialize controllers
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _logoUrlController = TextEditingController();
    _coverImageUrlController = TextEditingController();

    // Load business config
    _loadBusinessConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    _coverImageUrlController.dispose();
    super.dispose();
  }

  void _loadBusinessConfig() {
    final businessConfigAsync = ref.read(businessConfigProvider);

    businessConfigAsync.whenData((config) {
      if (config != null) {
        setState(() {
          _nameController.text = config.name;
          _descriptionController.text = config.description;
          _logoUrlController.text = config.logoUrl;
          _coverImageUrlController.text = config.coverImageUrl;
          _businessType = config.type;
          _contactInfo = Map<String, dynamic>.from(config.contactInfo);
          _address = Map<String, dynamic>.from(config.address);
          _hours = Map<String, dynamic>.from(config.hours);
          _settings = Map<String, dynamic>.from(config.settings);
          _features = List<String>.from(config.features);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ref.watch(businessConfigProvider).when(
            data: (config) {
              if (config == null) {
                return const Center(
                  child: Text('Business configuration not found'),
                );
              }

              return Column(
                children: [
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'General'),
                        Tab(text: 'Contact & Location'),
                        Tab(text: 'Hours & Availability'),
                        Tab(text: 'Features & Settings'),
                        Tab(text: 'Setup Wizard'),
                      ],
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurface,
                      isScrollable: true,
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGeneralTab(config),
                        _buildContactLocationTab(config),
                        _buildHoursTab(config),
                        _buildFeaturesSettingsTab(config),
                        const BusinessSetupScreen(),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          ),
    );
  }

  Widget _buildGeneralTab(BusinessConfig config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Business name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                hintText: 'Enter your business name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a business name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Business type
            DropdownButtonFormField<String>(
              initialValue: _businessType,
              decoration: const InputDecoration(
                labelText: 'Business Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'restaurant', child: Text('Restaurant')),
                DropdownMenuItem(value: 'cafe', child: Text('Café')),
                DropdownMenuItem(value: 'bar', child: Text('Bar')),
                DropdownMenuItem(value: 'retail', child: Text('Retail Store')),
                DropdownMenuItem(
                    value: 'service', child: Text('Service Business')),
                DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  _businessType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Business description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter a description of your business',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Logo URL
            TextFormField(
              controller: _logoUrlController,
              decoration: const InputDecoration(
                labelText: 'Logo URL',
                hintText: 'Enter URL for your business logo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Cover image URL
            TextFormField(
              controller: _coverImageUrlController,
              decoration: const InputDecoration(
                labelText: 'Cover Image URL',
                hintText: 'Enter URL for your cover image',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Preview section
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildBusinessPreview(),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _saveGeneralInfo(config),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactLocationTab(BusinessConfig config) {
    // Clone the contactInfo and address maps for editing
    final contactInfo = Map<String, dynamic>.from(_contactInfo);
    final address = Map<String, dynamic>.from(_address);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            initialValue: contactInfo['phone'] ?? '',
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your business phone number',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              contactInfo['phone'] = value;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            initialValue: contactInfo['email'] ?? '',
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your business email',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              contactInfo['email'] = value;
            },
          ),
          const SizedBox(height: 16),

          // Website
          TextFormField(
            initialValue: contactInfo['website'] ?? '',
            decoration: const InputDecoration(
              labelText: 'Website',
              hintText: 'Enter your business website',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              contactInfo['website'] = value;
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Address',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Street
          TextFormField(
            initialValue: address['street'] ?? '',
            decoration: const InputDecoration(
              labelText: 'Street Address',
              hintText: 'Enter your street address',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              address['street'] = value;
            },
          ),
          const SizedBox(height: 16),

          // City and ZIP
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: address['city'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'City',
                    hintText: 'Enter city',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    address['city'] = value;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: address['zip'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'ZIP Code',
                    hintText: 'Enter ZIP',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    address['zip'] = value;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // State and Country
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: address['state'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'State/Province',
                    hintText: 'Enter state',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    address['state'] = value;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: address['country'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'Enter country',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    address['country'] = value;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Google Maps coordinates
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: address['latitude']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    hintText: 'For Google Maps',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    address['latitude'] = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: address['longitude']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    hintText: 'For Google Maps',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    address['longitude'] = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _contactInfo = contactInfo;
                        _address = address;
                      });
                      _saveContactLocation(config);
                    },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursTab(BusinessConfig config) {
    // Create a clone of hours for editing
    final hours = Map<String, dynamic>.from(_hours);
    final daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Hours',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysOfWeek.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final day = daysOfWeek[index];
              final dayData = hours[day] as Map<String, dynamic>? ?? {};
              final isOpen = dayData['isOpen'] ?? false;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _capitalizeFirst(day),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Switch(
                        value: isOpen,
                        onChanged: (value) {
                          setState(() {
                            if (hours[day] == null) {
                              hours[day] = {};
                            }
                            (hours[day] as Map<String, dynamic>)['isOpen'] =
                                value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(isOpen ? 'Open' : 'Closed'),
                    ],
                  ),
                  if (isOpen) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: dayData['openTime'] ?? '09:00',
                            decoration: const InputDecoration(
                              labelText: 'Opening Time',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              (hours[day] as Map<String, dynamic>)['openTime'] =
                                  value;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: dayData['closeTime'] ?? '17:00',
                            decoration: const InputDecoration(
                              labelText: 'Closing Time',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              (hours[day]
                                  as Map<String, dynamic>)['closeTime'] = value;
                            },
                          ),
                        ),
                      ],
                    ),

                    // Break times
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Break Time / Split Hours'),
                      value: dayData['hasBreak'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          (hours[day] as Map<String, dynamic>)['hasBreak'] =
                              value;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),

                    if (dayData['hasBreak'] == true) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: dayData['breakStart'] ?? '13:00',
                              decoration: const InputDecoration(
                                labelText: 'Break Start',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                (hours[day]
                                        as Map<String, dynamic>)['breakStart'] =
                                    value;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: dayData['breakEnd'] ?? '14:00',
                              decoration: const InputDecoration(
                                labelText: 'Break End',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                (hours[day]
                                        as Map<String, dynamic>)['breakEnd'] =
                                    value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Special hours / holidays
          Text(
            'Special Hours / Holidays',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),

          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Special Hours'),
            onPressed: () {
              // TODO: Implement special hours dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Special hours feature coming soon')),
              );
            },
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _hours = hours;
                      });
                      _saveHours(config);
                    },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to clean up problematic values in the settings map
  void _cleanUpSettingsMap(Map<String, dynamic> settings) {
    debugPrint('🧹 Cleaning up settings map');

    // List of keys that should be strings
    final stringKeys = [
      'theme',
      'currency',
      'language',
      'timeFormat',
      'dateFormat'
    ];

    // List of keys that should be doubles
    final doubleKeys = [
      'taxRate',
      'serviceCharge',
      'deliveryFee',
      'minimumOrder'
    ];

    // Process string keys
    for (final key in stringKeys) {
      if (settings.containsKey(key)) {
        final value = settings[key];
        if (value != null && value is! String) {
          debugPrint(
              '  ⚙️ Converting non-string "$key" to string: "$value" (${value.runtimeType})');
          if (value is Map) {
            // For map values, set a default string value
            final defaultValue = _getDefaultStringValue(key);
            settings[key] = defaultValue;
            debugPrint('    → Set to default: "$defaultValue"');
          } else {
            // For other types, convert to string
            settings[key] = value.toString();
            debugPrint('    → Converted to: "${value.toString()}"');
          }
        }
      }
    }

    // Process double keys
    for (final key in doubleKeys) {
      if (settings.containsKey(key)) {
        final value = settings[key];
        if (value != null && value is! double) {
          debugPrint(
              '  ⚙️ Converting non-double "$key" to double: "$value" (${value.runtimeType})');
          if (value is int) {
            settings[key] = value.toDouble();
            debugPrint('    → Converted to: ${value.toDouble()}');
          } else if (value is String) {
            final parsedValue = double.tryParse(value);
            if (parsedValue != null) {
              settings[key] = parsedValue;
              debugPrint('    → Parsed to: $parsedValue');
            } else {
              settings[key] = 0.0;
              debugPrint('    → Could not parse, set to default: 0.0');
            }
          } else {
            settings[key] = 0.0;
            debugPrint('    → Set to default: 0.0');
          }
        }
      }
    }
  }

  // Helper method to get default string values for specific settings
  String _getDefaultStringValue(String key) {
    switch (key) {
      case 'theme':
        return 'system';
      case 'currency':
        return 'USD';
      case 'language':
        return 'en';
      case 'timeFormat':
        return '12h';
      case 'dateFormat':
        return 'MM/DD/YYYY';
      default:
        return '';
    }
  }

  // Helper method to safely extract String values from settings
  String _extractStringFromSetting(
      Map<String, dynamic> settings, String key, String defaultValue) {
    final value = settings[key];
    debugPrint(
        '💾 Extracting value for key "$key": ${value?.toString() ?? 'null'} (${value?.runtimeType})');

    if (value == null) {
      debugPrint('  ⚠️ Key not found, using default: "$defaultValue"');
      return defaultValue;
    }

    if (value is String) {
      debugPrint('  ✅ Value is String: "$value"');
      return value;
    }

    // Special case: If the value is a Map, it cannot be used directly in a dropdown
    // Return the default value instead of trying to convert the map to a string
    if (value is Map) {
      debugPrint(
          '  ❌ Value is Map: $value - Using default value: "$defaultValue"');

      // Clean up the map value by replacing it with the default string
      settings[key] = defaultValue;
      return defaultValue;
    }

    // Try to convert to string if it's another simple type
    debugPrint(
        '  ⚠️ Converting ${value.runtimeType} to String: "${value.toString()}"');
    return value.toString();
  }

  // Helper method to safely extract double values from settings
  double _extractDoubleFromSetting(
      Map<String, dynamic> settings, String key, double defaultValue) {
    final value = settings[key];
    debugPrint(
        '🔢 Extracting double for key "$key": ${value?.toString() ?? 'null'} (${value?.runtimeType})');

    if (value == null) {
      debugPrint('  ⚠️ Key not found, using default: $defaultValue');
      return defaultValue;
    }

    if (value is double) {
      debugPrint('  ✅ Value is double: $value');
      return value;
    }

    if (value is int) {
      debugPrint('  ✅ Converting int to double: $value → ${value.toDouble()}');
      return value.toDouble();
    }

    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        debugPrint('  ✅ Parsed string to double: "$value" → $parsed');
        return parsed;
      } else {
        debugPrint(
            '  ❌ Could not parse string to double: "$value" - Using default: $defaultValue');
        return defaultValue;
      }
    }

    if (value is Map) {
      debugPrint('  ❌ Value is Map: $value - Using default: $defaultValue');
      // Clean up the map value by replacing it with the default double
      settings[key] = defaultValue;
    }

    debugPrint(
        '  ⚠️ Unsupported type ${value.runtimeType}, using default: $defaultValue');
    return defaultValue;
  }

  Widget _buildFeaturesSettingsTab(BusinessConfig config) {
    // Create copies for editing
    final features = List<String>.from(_features);
    final settings = Map<String, dynamic>.from(_settings);

    // Debug settings map content
    debugPrint('🔍 Settings map content:');
    settings.forEach((key, value) {
      final valueType = value.runtimeType;
      debugPrint('  - $key ($valueType): $value');
    });

    // Clean up problematic settings values
    _cleanUpSettingsMap(settings);

    // After cleanup, log settings again
    debugPrint('🧹 Settings map after cleanup:');
    settings.forEach((key, value) {
      final valueType = value.runtimeType;
      debugPrint('  - $key ($valueType): $value');
    });

    // Define available features for your business type
    final availableFeatures = _getAvailableFeatures();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Advanced Settings Section
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.admin_panel_settings),
                      const SizedBox(width: 8),
                      Text(
                        'Advanced Settings',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage feature flags in the Realtime Database to control which UI elements are visible in the app.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RtdbFeaturesSettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Manage Realtime Database Features'),
                  ),
                ],
              ),
            ),
          ),

          Text(
            'Features',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Enable or disable features for your business',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Features list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: availableFeatures.length,
            itemBuilder: (context, index) {
              final feature = availableFeatures[index];
              final isEnabled = features.contains(feature.key);

              return CheckboxListTile(
                title: Text(feature.name),
                subtitle: Text(feature.description),
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      if (!features.contains(feature.key)) {
                        features.add(feature.key);
                        // Update main state variable immediately
                        _features.add(feature.key);
                      }
                    } else {
                      features.remove(feature.key);
                      // Update main state variable immediately
                      _features.remove(feature.key);
                    }
                    debugPrint(
                        'Checkbox updated: ${feature.key} is now ${value == true ? 'enabled' : 'disabled'}');
                  });
                },
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure additional settings for your business',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Tax rate setting
          TextFormField(
            initialValue:
                _extractDoubleFromSetting(settings, 'taxRate', 0.0).toString(),
            decoration: const InputDecoration(
              labelText: 'Tax Rate (%)',
              hintText: 'Enter tax rate percentage',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final taxRate = double.tryParse(value);
              if (taxRate != null) {
                settings['taxRate'] = taxRate;
              }
            },
          ),
          const SizedBox(height: 16),

          // Service charge setting
          TextFormField(
            initialValue:
                _extractDoubleFromSetting(settings, 'serviceCharge', 0.0)
                    .toString(),
            decoration: const InputDecoration(
              labelText: 'Service Charge (%)',
              hintText: 'Enter service charge percentage',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final serviceCharge = double.tryParse(value);
              if (serviceCharge != null) {
                settings['serviceCharge'] = serviceCharge;
              }
            },
          ),
          const SizedBox(height: 16),

          // Currency setting
          Builder(builder: (context) {
            // Get currency value safely
            final currencyValue =
                _extractStringFromSetting(settings, 'currency', 'USD');

            // Debug the currency value
            debugPrint(
                'Using currency value: $currencyValue (${currencyValue.runtimeType})');

            return DropdownButtonFormField<String>(
              initialValue: currencyValue,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                DropdownMenuItem(
                    value: 'GBP', child: Text('GBP - British Pound')),
                DropdownMenuItem(
                    value: 'MXN', child: Text('MXN - Mexican Peso')),
                DropdownMenuItem(
                    value: 'CAD', child: Text('CAD - Canadian Dollar')),
                DropdownMenuItem(
                    value: 'JPY', child: Text('JPY - Japanese Yen')),
                // Add more currencies as needed
              ],
              onChanged: (value) {
                if (value != null) {
                  settings['currency'] = value;
                }
              },
            );
          }),
          const SizedBox(height: 16),

          // Theme settings
          Builder(
            builder: (context) {
              // Get theme value safely
              final themeValue =
                  _extractStringFromSetting(settings, 'theme', 'system');

              // Debug the theme value
              debugPrint(
                  'Using theme value: $themeValue (${themeValue.runtimeType})');

              return DropdownButtonFormField<String>(
                initialValue: themeValue,
                decoration: const InputDecoration(
                  labelText: 'Default Theme',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'system', child: Text('System Default')),
                  DropdownMenuItem(value: 'light', child: Text('Light Theme')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark Theme')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    // Check if the current theme value is a Map and handle it appropriately
                    if (settings['theme'] is Map) {
                      debugPrint(
                          'Converting existing Map theme to String value: $value');
                      // We need to preserve the theme settings but update the mode
                      settings['theme'] = value;
                    } else {
                      settings['theme'] = value;
                    }
                  }
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      // Only update settings since _features is already updated by the checkboxes
                      setState(() {
                        _settings = settings;
                      });
                      _saveFeaturesSettings(config);
                    },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessPreview() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _coverImageUrlController.text.isNotEmpty
                ? Image.network(
                    _coverImageUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Center(
                      child: Icon(Icons.business, size: 48),
                    ),
                  ),
          ),

          // Business info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Logo
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _logoUrlController.text.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _logoUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.business),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/appIcon.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.business),
                            ),
                          )),
                const SizedBox(width: 16),

                // Business details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : 'Business Name',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _businessType.isNotEmpty
                            ? _capitalizeFirst(_businessType)
                            : 'Business Type',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _descriptionController.text.isNotEmpty
                            ? _descriptionController.text
                            : 'Business description will appear here',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Save operations
  Future<void> _saveGeneralInfo(BusinessConfig config) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated business config
      final updatedConfig = BusinessConfig(
        id: config.id,
        name: _nameController.text,
        type: _businessType,
        slug: config.slug,
        logoUrl: _logoUrlController.text,
        coverImageUrl: _coverImageUrlController.text,
        description: _descriptionController.text,
        contactInfo: _contactInfo,
        address: _address,
        hours: _hours,
        settings: _settings,
        features: _features,
        isActive: config.isActive,
      );

      // Update in Firestore
      final businessConfigService = ref.read(businessConfigServiceProvider);
      await businessConfigService.updateBusinessConfig(updatedConfig);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Business information updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating business information: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContactLocation(BusinessConfig config) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated business config
      final updatedConfig = BusinessConfig(
        id: config.id,
        name: _nameController.text,
        type: _businessType,
        slug: config.slug,
        logoUrl: _logoUrlController.text,
        coverImageUrl: _coverImageUrlController.text,
        description: _descriptionController.text,
        contactInfo: _contactInfo,
        address: _address,
        hours: _hours,
        settings: _settings,
        features: _features,
        isActive: config.isActive,
      );

      // Update in Firestore
      final businessConfigService = ref.read(businessConfigServiceProvider);
      await businessConfigService.updateBusinessConfig(updatedConfig);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Contact and location updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating contact and location: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHours(BusinessConfig config) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated business config
      final updatedConfig = BusinessConfig(
        id: config.id,
        name: _nameController.text,
        type: _businessType,
        slug: config.slug,
        logoUrl: _logoUrlController.text,
        coverImageUrl: _coverImageUrlController.text,
        description: _descriptionController.text,
        contactInfo: _contactInfo,
        address: _address,
        hours: _hours,
        settings: _settings,
        features: _features,
        isActive: config.isActive,
      );

      // Update in Firestore
      final businessConfigService = ref.read(businessConfigServiceProvider);
      await businessConfigService.updateBusinessConfig(updatedConfig);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business hours updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating business hours: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFeaturesSettings(BusinessConfig config) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Print for debugging - check the state of features list
      debugPrint('Features to save: $_features (${_features.length} items)');
      for (var feature in _features) {
        debugPrint('  - $feature');
      }

      // Create updated business config
      final updatedConfig = BusinessConfig(
        id: config.id,
        name: _nameController.text,
        type: _businessType,
        slug: config.slug,
        logoUrl: _logoUrlController.text,
        coverImageUrl: _coverImageUrlController.text,
        description: _descriptionController.text,
        contactInfo: _contactInfo,
        address: _address,
        hours: _hours,
        settings: _settings,
        features: _features,
        isActive: config.isActive,
      );

      // Update in Firestore
      final businessConfigService = ref.read(businessConfigServiceProvider);
      debugPrint('Updating business config in Firestore...');
      await businessConfigService.updateBusinessConfig(updatedConfig);
      debugPrint('✅ Firestore update successful');

      // Manually sync with Realtime Database to make sure UI components update correctly
      try {
        final businessFeaturesService =
            ref.read(businessFeaturesServiceProvider);
        final businessFeatures =
            _mapFirestoreFeaturesToBusinessFeatures(_features);
        debugPrint('Syncing features to RTDB: ${businessFeatures.toMap()}');
        await businessFeaturesService.updateBusinessFeatures(
            config.id, businessFeatures);
        debugPrint('✅ Features synced to RTDB manually');
      } catch (syncError) {
        debugPrint('❌ Error syncing features to RTDB: $syncError');
        // Continue even if RTDB sync fails
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Features and settings updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating features and settings: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to map Firestore features to BusinessFeatures object
  BusinessFeatures _mapFirestoreFeaturesToBusinessFeatures(
      List<String> firestoreFeatures) {
    return BusinessFeatures(
      catering: firestoreFeatures.contains('catering') ||
          firestoreFeatures.contains('online_catering'),
      mealPlans: firestoreFeatures.contains('meal_plans') ||
          firestoreFeatures.contains('meal_subscriptions'),
      inDine: firestoreFeatures.contains('in_dine') ||
          firestoreFeatures.contains('table_management'),
      staff: firestoreFeatures.contains('staff') ||
          firestoreFeatures.contains('employee_management'),
      kitchen: firestoreFeatures.contains('kitchen_display') ||
          firestoreFeatures.contains('kitchen'),
      reservations: firestoreFeatures.contains('reservations') ||
          firestoreFeatures.contains('table_reservations'),
    );
  }

  // Helper methods
  List<FeatureItem> _getAvailableFeatures() {
    // Define common features
    final commonFeatures = [
      const FeatureItem(
        key: 'online_ordering',
        name: 'Online Ordering',
        description: 'Allow customers to place orders online',
      ),
      const FeatureItem(
        key: 'reservations',
        name: 'Reservations',
        description: 'Allow customers to make reservations',
      ),
      const FeatureItem(
        key: 'loyalty_program',
        name: 'Loyalty Program',
        description: 'Enable customer loyalty program',
      ),
      const FeatureItem(
        key: 'gift_cards',
        name: 'Gift Cards',
        description: 'Sell and accept gift cards',
      ),
    ];

    // Add business-type specific features
    switch (_businessType) {
      case 'restaurant':
        return [
          ...commonFeatures,
          const FeatureItem(
            key: 'table_management',
            name: 'Table Management',
            description: 'Manage tables and seating',
          ),
          const FeatureItem(
            key: 'kitchen_display',
            name: 'Kitchen Display',
            description: 'Show orders in kitchen',
          ),
          const FeatureItem(
            key: 'delivery',
            name: 'Delivery',
            description: 'Offer delivery service',
          ),
        ];
      case 'retail':
        return [
          ...commonFeatures,
          const FeatureItem(
            key: 'inventory_management',
            name: 'Inventory Management',
            description: 'Track and manage inventory',
          ),
          const FeatureItem(
            key: 'barcode_scanning',
            name: 'Barcode Scanning',
            description: 'Scan barcodes for checkout',
          ),
        ];
      case 'hotel':
        return [
          ...commonFeatures,
          const FeatureItem(
            key: 'room_management',
            name: 'Room Management',
            description: 'Manage rooms and bookings',
          ),
          const FeatureItem(
            key: 'housekeeping',
            name: 'Housekeeping',
            description: 'Track room cleaning status',
          ),
        ];
      default:
        return commonFeatures;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class FeatureItem {
  final String key;
  final String name;
  final String description;

  const FeatureItem({
    required this.key,
    required this.name,
    required this.description,
  });
}
