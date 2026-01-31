// File: lib/src/screens/setup/business_setup_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_setup_manager.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/local_storange/local_storage_service.dart';
import 'dart:io';

import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/setup/color_picker_widget.dart';

class BusinessSetupScreen extends ConsumerStatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  ConsumerState<BusinessSetupScreen> createState() =>
      _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late PageController _pageController;

  // Form data
  final _businessNameController = TextEditingController();
  String _businessType = 'restaurant';

  // Business contact & location info
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  // Logo and cover image files - platform compatible
  File? _logoLightFile;
  File? _logoDarkFile;
  File? _coverImageFile;

  // For web platform, store image bytes
  Uint8List? _logoLightBytes;
  Uint8List? _logoDarkBytes;
  Uint8List? _coverImageBytes;

  // Image URLs for existing images
  String? _logoLightUrl;
  String? _logoDarkUrl;
  String? _coverImageUrl;

  // Page index
  int _currentPage = 0;

  // Loading state
  bool _isLoading = false;
  bool _isInitLoading = true;
  String? _errorMessage;

  // Business ID for updating
  String? _existingBusinessId;

  // Business features settings
  BusinessFeatures? _businessFeatures;
  BusinessUI? _businessUI;
  bool _featuresLoading = false;

  // Business types for dropdown
  final List<String> _businessTypes = [
    'restaurant',
    'cafe',
    'bar',
    'hotel',
    'retail',
    'service',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Load existing business data if available
    _loadExistingBusinessData();
    // Initialize default features
    _businessFeatures = const BusinessFeatures();
    _businessUI = const BusinessUI();
  }

  Future<void> _loadExistingBusinessData() async {
    setState(() {
      _isInitLoading = true;
    });

    try {
      // Get current business ID
      final businessId = ref.read(currentBusinessIdProvider);
      if (businessId.isNotEmpty) {
        _existingBusinessId = businessId;
        debugPrint(
            'Loading existing business data for ID: $_existingBusinessId');

        // Get business config
        final businessConfigAsync = ref.read(businessConfigProvider);

        await businessConfigAsync.when(
          data: (config) {
            if (config != null) {
              _existingBusinessId = config.id;

              // Set form fields from existing data
              setState(() {
                _businessNameController.text = config.name;
                _businessType = config.type;

                // Set contact info if available
                if (config.contactInfo.containsKey('email')) {
                  final emailValue = config.contactInfo['email'];
                  _emailController.text =
                      (emailValue is String) ? emailValue : '';
                }
                if (config.contactInfo.containsKey('phone')) {
                  final phoneValue = config.contactInfo['phone'];
                  _phoneController.text =
                      (phoneValue is String) ? phoneValue : '';
                }
                if (config.contactInfo.containsKey('website')) {
                  final websiteValue = config.contactInfo['website'];
                  _websiteController.text =
                      (websiteValue is String) ? websiteValue : '';
                }

                // Set address if available
                if (config.address.containsKey('street')) {
                  final streetValue = config.address['street'];
                  _addressController.text =
                      (streetValue is String) ? streetValue : '';
                }
                if (config.address.containsKey('city')) {
                  final cityValue = config.address['city'];
                  _cityController.text = (cityValue is String) ? cityValue : '';
                }
                if (config.address.containsKey('state')) {
                  final stateValue = config.address['state'];
                  _stateController.text =
                      (stateValue is String) ? stateValue : '';
                }
                if (config.address.containsKey('zip')) {
                  final zipValue = config.address['zip'];
                  _zipController.text = (zipValue is String) ? zipValue : '';
                }
                if (config.address.containsKey('country')) {
                  final countryValue = config.address['country'];
                  _countryController.text =
                      (countryValue is String) ? countryValue : '';
                }

                // Set image URLs
                _logoLightUrl = config.logoUrl;
                _logoDarkUrl = config.logoUrl;
                _coverImageUrl = config.coverImageUrl;

                // Set colors
                if (config.settings.containsKey('primaryColor')) {
                  final primaryColorValue = config.settings['primaryColor'];
                  final secondaryColorValue = config.settings['secondaryColor'];
                  final tertiaryColorValue = config.settings['tertiaryColor'];
                  final accentColorValue = config.settings['accentColor'];

                  final primaryColorHex = (primaryColorValue is String)
                      ? primaryColorValue
                      : '#6200EE';
                  final secondaryColorHex = (secondaryColorValue is String)
                      ? secondaryColorValue
                      : '#03DAC6';
                  final tertiaryColorHex = (tertiaryColorValue is String)
                      ? tertiaryColorValue
                      : '#FFC107';
                  final accentColorHex = (accentColorValue is String)
                      ? accentColorValue
                      : '#FF4081';

                  // Extract colors
                  final primaryColor = _hexToColor(primaryColorHex);
                  final secondaryColor = _hexToColor(secondaryColorHex);
                  final tertiaryColor = _hexToColor(tertiaryColorHex);
                  final accentColor = _hexToColor(accentColorHex);

                  // Update color state
                  ref
                      .read(selectedBusinessColorsProvider.notifier)
                      .updateColor('primary', primaryColor);
                  ref
                      .read(selectedBusinessColorsProvider.notifier)
                      .updateColor('secondary', secondaryColor);
                  ref
                      .read(selectedBusinessColorsProvider.notifier)
                      .updateColor('tertiary', tertiaryColor);
                  ref
                      .read(selectedBusinessColorsProvider.notifier)
                      .updateColor('accent', accentColor);
                }
              });

              debugPrint('Loaded existing business data successfully');
            }
          },
          loading: () {},
          error: (error, stack) {
            debugPrint('Error loading business config: $error');
          },
        );
      }

      // Also load RTDB features
      await _loadBusinessFeatures();
    } catch (e) {
      debugPrint('Error loading existing business data: $e');
    } finally {
      setState(() {
        _isInitLoading = false;
      });
    }
  }

  Future<void> _loadBusinessFeatures() async {
    if (_existingBusinessId == null || _existingBusinessId!.isEmpty) {
      return;
    }

    setState(() {
      _featuresLoading = true;
    });

    try {
      final service = ref.read(businessFeaturesServiceProvider);

      // Get features and UI settings
      final featuresStream = service.getBusinessFeatures(_existingBusinessId!);
      final uiStream = service.getBusinessUI(_existingBusinessId!);

      // Wait for both streams to complete
      final features = await featuresStream.first;
      final ui = await uiStream.first;

      if (mounted) {
        setState(() {
          _businessFeatures = features;
          _businessUI = ui;
          _featuresLoading = false;
          debugPrint('Loaded business features and UI settings successfully');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _featuresLoading = false;
        });
        debugPrint('Error loading business features: $e');
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web platform, load image bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            switch (type) {
              case 'logo_light':
                _logoLightBytes = bytes;
                _logoLightUrl = null; // Clear previous URL
                break;
              case 'logo_dark':
                _logoDarkBytes = bytes;
                _logoDarkUrl = null; // Clear previous URL
                break;
              case 'cover':
                _coverImageBytes = bytes;
                _coverImageUrl = null; // Clear previous URL
                break;
            }
          });
        } else {
          // For mobile platforms, use File objects
          setState(() {
            switch (type) {
              case 'logo_light':
                _logoLightFile = File(pickedFile.path);
                _logoLightUrl = null; // Clear previous URL
                break;
              case 'logo_dark':
                _logoDarkFile = File(pickedFile.path);
                _logoDarkUrl = null; // Clear previous URL
                break;
              case 'cover':
                _coverImageFile = File(pickedFile.path);
                _coverImageUrl = null; // Clear previous URL
                break;
            }
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showColorPicker(String colorType) {
    final currentColors = ref.read(selectedBusinessColorsProvider);
    final current = currentColors[colorType] ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Select ${colorType.substring(0, 1).toUpperCase()}${colorType.substring(1)} Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: current,
            onColorChanged: (color) {
              ref
                  .read(selectedBusinessColorsProvider.notifier)
                  .updateColor(colorType, color);
            },
            pickerType: PickerType.materialDesign,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBusinessData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final businessSetupManager = ref.read(businessSetupManagerProvider);
      final selectedColors = ref.read(selectedBusinessColorsProvider);

      // Prepare contact info and address
      final contactInfo = {
        'email': _emailController.text,
        'phone': _phoneController.text,
        'website': _websiteController.text,
      };

      final address = {
        'street': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip': _zipController.text,
        'country': _countryController.text,
      };

      if (_existingBusinessId != null) {
        // Update existing business
        await businessSetupManager.updateBusinessConfig(
          businessId: _existingBusinessId!,
          businessName: _businessNameController.text,
          businessType: _businessType,
          primaryColor: selectedColors['primary']!,
          secondaryColor: selectedColors['secondary']!,
          tertiaryColor: selectedColors['tertiary']!,
          accentColor: selectedColors['accent']!,
          logoLight: _logoLightFile,
          logoDark: _logoDarkFile,
          coverImage: _coverImageFile,
          contactInfo: contactInfo,
          address: address,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Business settings updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Create new business
        final result = await businessSetupManager.createBusinessConfig(
          businessName: _businessNameController.text,
          businessType: _businessType,
          primaryColor: selectedColors['primary']!,
          secondaryColor: selectedColors['secondary']!,
          tertiaryColor: selectedColors['tertiary']!,
          accentColor: selectedColors['accent']!,
          logoLight: _logoLightFile,
          logoDark: _logoDarkFile,
          coverImage: _coverImageFile,
          contactInfo: contactInfo,
          address: address,
        );

        // Save to local storage for future reference
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.setString('businessId', result.businessId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Business created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      // Refresh the business config provider to trigger app state change
      ref.invalidate(businessConfigProvider);

      // Save features to RTDB
      await _saveBusinessFeatures();

      // Load the updated data
      await _loadExistingBusinessData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBusinessFeatures() async {
    if (_existingBusinessId == null || _existingBusinessId!.isEmpty) {
      debugPrint('Cannot save features - no business ID available');
      return;
    }

    if (_businessFeatures == null || _businessUI == null) {
      debugPrint('Cannot save features - features or UI is null');
      return;
    }

    try {
      final service = ref.read(businessFeaturesServiceProvider);

      // Update both features and UI
      await service.updateBusinessFeatures(
          _existingBusinessId!, _businessFeatures!);
      await service.updateBusinessUI(_existingBusinessId!, _businessUI!);

      debugPrint('✅ Business features and UI updated successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Features and UI settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving business features: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving features: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    } else {
      _saveBusinessData();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  String _getBrandingStatus() {
    final hasLightLogo = _logoLightUrl != null ||
        (kIsWeb ? _logoLightBytes != null : _logoLightFile != null);
    final hasDarkLogo = _logoDarkUrl != null ||
        (kIsWeb ? _logoDarkBytes != null : _logoDarkFile != null);
    final hasCoverImage = _coverImageUrl != null ||
        (kIsWeb ? _coverImageBytes != null : _coverImageFile != null);

    final List<String> status = [];
    if (hasLightLogo) status.add("Light Logo ✓");
    if (hasDarkLogo) status.add("Dark Logo ✓");
    if (hasCoverImage) status.add("Cover Image ✓");

    if (status.isEmpty) return "No images uploaded";
    return status.join(", ");
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha value if not provided
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColors = ref.watch(selectedBusinessColorsProvider);

    if (_isInitLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(theme),

              // Progress indicator
              _buildProgressIndicator(theme),

              // Main content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildBasicInfoPage(theme),
                    _buildBrandingPage(theme),
                    _buildColorsPage(theme, selectedColors),
                    _buildFeaturesPage(theme),
                    _buildReviewPage(theme, selectedColors),
                  ],
                ),
              ),

              // Navigation buttons
              _buildNavButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _existingBusinessId != null
                            ? 'Edit Business Settings'
                            : 'Create New Business',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_existingBusinessId != null)
                        Text(
                          'ID: $_existingBusinessId',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 5; i++)
            Container(
              width: 55,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i <= _currentPage
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Information',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s set up your business profile',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Business name
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
              hintText: 'Enter your business name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Business name is required';
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
            ),
            items: _businessTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                    type.substring(0, 1).toUpperCase() + type.substring(1)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _businessType = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          // Contact info section
          Text(
            'Contact Information',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter business email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              hintText: 'Enter business phone',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 16),

          // Website
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'Website',
              hintText: 'Enter business website',
              prefixIcon: Icon(Icons.language),
            ),
          ),
          const SizedBox(height: 24),

          // Address section
          Text(
            'Business Address',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Street address
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Street Address',
              hintText: 'Enter street address',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),

          // City and ZIP
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    hintText: 'Enter city',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _zipController,
                  decoration: const InputDecoration(
                    labelText: 'ZIP Code',
                    hintText: 'Enter ZIP',
                  ),
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
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State/Province',
                    hintText: 'Enter state',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'Enter country',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Branding',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your business logo and cover image',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Current status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Current uploads: ${_getBrandingStatus()}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Light logo
          _buildImageUploader(
            theme,
            title: 'Light Mode Logo',
            subtitle: 'Used on light backgrounds',
            iconData: Icons.light_mode,
            onUpload: () => _pickImage(ImageSource.gallery, 'logo_light'),
            onCamera: () => _pickImage(ImageSource.camera, 'logo_light'),
            imageUrl: _logoLightUrl,
            imageBytes: _logoLightBytes,
            imageFile: _logoLightFile,
          ),
          const SizedBox(height: 16),

          // Dark logo
          _buildImageUploader(
            theme,
            title: 'Dark Mode Logo',
            subtitle: 'Used on dark backgrounds',
            iconData: Icons.dark_mode,
            onUpload: () => _pickImage(ImageSource.gallery, 'logo_dark'),
            onCamera: () => _pickImage(ImageSource.camera, 'logo_dark'),
            imageUrl: _logoDarkUrl,
            imageBytes: _logoDarkBytes,
            imageFile: _logoDarkFile,
          ),
          const SizedBox(height: 16),

          // Cover image
          _buildImageUploader(
            theme,
            title: 'Cover Image',
            subtitle: 'Used as background on profile page',
            iconData: Icons.image,
            onUpload: () => _pickImage(ImageSource.gallery, 'cover'),
            onCamera: () => _pickImage(ImageSource.camera, 'cover'),
            imageUrl: _coverImageUrl,
            imageBytes: _coverImageBytes,
            imageFile: _coverImageFile,
          ),
        ],
      ),
    );
  }

  // Helper for displaying images in branding page
  Widget _buildImageUploader(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData iconData,
    required VoidCallback onUpload,
    required VoidCallback onCamera,
    String? imageUrl,
    Uint8List? imageBytes,
    File? imageFile,
  }) {
    final hasImage =
        imageUrl != null || imageBytes != null || imageFile != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(iconData, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Display image preview if available
            if (hasImage) ...[
              Container(
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildImagePreview(imageUrl, imageBytes, imageFile),
              ),
              const SizedBox(height: 12),
            ],

            // Upload buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: Text(hasImage ? 'Change' : 'Upload'),
                    onPressed: onUpload,
                  ),
                ),
                const SizedBox(width: 12),
                if (!kIsWeb)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: onCamera,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(
      String? imageUrl, Uint8List? imageBytes, File? imageFile) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 64);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const CircularProgressIndicator();
        },
      );
    } else if (imageBytes != null) {
      return Image.memory(imageBytes, fit: BoxFit.contain);
    } else if (imageFile != null) {
      return Image.file(imageFile, fit: BoxFit.contain);
    }
    return const SizedBox();
  }

  Widget _buildColorsPage(ThemeData theme, Map<String, Color> selectedColors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme Colors',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose colors for your business theme',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Color selectors
          _buildColorSelector(
            theme,
            color: selectedColors['primary']!,
            name: 'Primary Color',
            description: 'Main branding color',
            onTap: () => _showColorPicker('primary'),
          ),
          const SizedBox(height: 16),

          _buildColorSelector(
            theme,
            color: selectedColors['secondary']!,
            name: 'Secondary Color',
            description: 'Used for buttons and highlights',
            onTap: () => _showColorPicker('secondary'),
          ),
          const SizedBox(height: 16),

          _buildColorSelector(
            theme,
            color: selectedColors['tertiary']!,
            name: 'Tertiary Color',
            description: 'Accent for specific UI elements',
            onTap: () => _showColorPicker('tertiary'),
          ),
          const SizedBox(height: 16),

          _buildColorSelector(
            theme,
            color: selectedColors['accent']!,
            name: 'Accent Color',
            description: 'Used for special highlights',
            onTap: () => _showColorPicker('accent'),
          ),
          const SizedBox(height: 32),

          // Color preview
          _buildColorPreview(theme, selectedColors),
        ],
      ),
    );
  }

  Widget _buildColorSelector(
    ThemeData theme, {
    required Color color,
    required String name,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview(ThemeData theme, Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPreviewButton(
                    colors['primary']!,
                    Colors.white,
                    'Primary',
                  ),
                  const SizedBox(width: 12),
                  _buildPreviewButton(
                    colors['secondary']!,
                    Colors.white,
                    'Secondary',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPreviewButton(
                    colors['tertiary']!,
                    Colors.white,
                    'Tertiary',
                  ),
                  const SizedBox(width: 12),
                  _buildPreviewButton(
                    colors['accent']!,
                    Colors.white,
                    'Accent',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors['primary']!.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Header Example',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors['primary'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('This is how text might appear in your app.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors['secondary'],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Secondary Button'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewPage(ThemeData theme, Map<String, Color> selectedColors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Complete',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _existingBusinessId != null
                ? 'Review your changes and save'
                : 'Review your business information before creating',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Business basics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Basics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    icon: Icons.business,
                    label: 'Name',
                    value: _businessNameController.text,
                  ),
                  _buildReviewItem(
                    icon: Icons.category,
                    label: 'Type',
                    value: _businessType,
                  ),
                  if (_emailController.text.isNotEmpty)
                    _buildReviewItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: _emailController.text,
                    ),
                  if (_phoneController.text.isNotEmpty)
                    _buildReviewItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: _phoneController.text,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Features and UI
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features & UI',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_businessFeatures != null) ...[
                    _buildReviewItem(
                      icon: Icons.restaurant_menu,
                      label: 'Catering',
                      value:
                          _businessFeatures!.catering ? 'Enabled' : 'Disabled',
                      chip: Icon(
                        _businessFeatures!.catering
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _businessFeatures!.catering
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                    _buildReviewItem(
                      icon: Icons.calendar_today,
                      label: 'Meal Plans',
                      value:
                          _businessFeatures!.mealPlans ? 'Enabled' : 'Disabled',
                      chip: Icon(
                        _businessFeatures!.mealPlans
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _businessFeatures!.mealPlans
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                    _buildReviewItem(
                      icon: Icons.people,
                      label: 'Staff',
                      value: _businessFeatures!.staff ? 'Enabled' : 'Disabled',
                      chip: Icon(
                        _businessFeatures!.staff
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _businessFeatures!.staff
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                    _buildReviewItem(
                      icon: Icons.table_restaurant,
                      label: 'In-Dine',
                      value: _businessFeatures!.inDine ? 'Enabled' : 'Disabled',
                      chip: Icon(
                        _businessFeatures!.inDine
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _businessFeatures!.inDine
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                    _buildReviewItem(
                      icon: Icons.kitchen,
                      label: 'Kitchen',
                      value:
                          _businessFeatures!.kitchen ? 'Enabled' : 'Disabled',
                      chip: Icon(
                        _businessFeatures!.kitchen
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _businessFeatures!.kitchen
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                    _buildReviewItem(
                      icon: Icons.book_online,
                      label: 'Reservations',
                      value: _businessFeatures!.reservations
                          ? 'Enabled'
                          : 'Disabled',
                      chip: Icon(
                        _businessFeatures!.reservations
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _businessFeatures!.reservations
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                    if (_businessUI != null) ...[
                      const Divider(height: 24),
                      _buildReviewItem(
                        icon: Icons.web,
                        label: 'Landing Page UI',
                        value: _businessUI!.landingPage ? 'Visible' : 'Hidden',
                        chip: Icon(
                          _businessUI!.landingPage
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _businessUI!.landingPage
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                      ),
                      _buildReviewItem(
                        icon: Icons.shopping_cart,
                        label: 'Orders UI',
                        value: _businessUI!.orders ? 'Visible' : 'Hidden',
                        chip: Icon(
                          _businessUI!.orders
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              _businessUI!.orders ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Branding
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branding',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    icon: Icons.image,
                    label: 'Images',
                    value: _getBrandingStatus(),
                  ),
                  _buildReviewItem(
                    icon: Icons.palette,
                    label: 'Primary Color',
                    value: _colorToHex(selectedColors['primary']!),
                    chip: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: selectedColors['primary'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_existingBusinessId != null)
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Text(
                'Note: Existing business ID: $_existingBusinessId',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  Widget _buildReviewItem({
    required IconData icon,
    required String label,
    required String value,
    Widget? chip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
          if (chip != null) chip,
        ],
      ),
    );
  }

  Widget _buildNavButtons(ThemeData theme) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _isLoading ? null : _nextPage,
            style: buttonStyle.copyWith(
              backgroundColor:
                  WidgetStatePropertyAll(theme.colorScheme.primary),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const SizedBox.shrink(),
                if (_isLoading) const SizedBox(width: 8),
                Text(
                  _currentPage < 4
                      ? 'Continue'
                      : (_existingBusinessId != null
                          ? 'Update Business'
                          : 'Create Business'),
                ),
                if (!_isLoading && _currentPage < 4)
                  const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(ThemeData theme) {
    if (_featuresLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final features = _businessFeatures;
    final ui = _businessUI;

    if (features == null || ui == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load features'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBusinessFeatures,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Create modifiable copies
    final businessFeatures = features.copyWith();
    final businessUI = ui.copyWith();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Management',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Control which features and UI elements are enabled',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Features section
          _buildFeaturesSection(theme, businessFeatures),

          const SizedBox(height: 32),

          // UI components section
          _buildUIComponentsSection(theme, businessUI),

          const SizedBox(height: 24),

          // Info card about features
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'About Business Features',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'These settings control which features and UI elements will be available in your business app. '
                    'You can change these settings later in the admin panel.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(ThemeData theme, BusinessFeatures features) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Business Features',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),

          // Catering toggle
          SwitchListTile(
            title: const Text('Catering'),
            subtitle: const Text('Enable catering services and menu'),
            value: features.catering,
            onChanged: (value) {
              setState(() {
                _businessFeatures =
                    _businessFeatures?.copyWith(catering: value);
              });
            },
          ),

          const Divider(height: 1),
          // Meal Plans toggle
          SwitchListTile(
            title: const Text('Meal Plans'),
            subtitle: const Text('Enable meal subscriptions and plans'),
            value: features.mealPlans,
            onChanged: (value) {
              setState(() {
                _businessFeatures =
                    _businessFeatures?.copyWith(mealPlans: value);
              });
            },
          ),

          const Divider(height: 1),
          // InDine toggle
          SwitchListTile(
            title: const Text('In-Dine'),
            subtitle: const Text('Enable in-restaurant dining features'),
            value: features.inDine,
            onChanged: (value) {
              setState(() {
                _businessFeatures = _businessFeatures?.copyWith(inDine: value);
              });
            },
          ),

          const Divider(height: 1),
          // Staff toggle
          SwitchListTile(
            title: const Text('Staff Management'),
            subtitle: const Text('Enable staff scheduling and management'),
            value: features.staff,
            onChanged: (value) {
              setState(() {
                _businessFeatures = _businessFeatures?.copyWith(staff: value);
              });
            },
          ),

          const Divider(height: 1),
          // Kitchen toggle
          SwitchListTile(
            title: const Text('Kitchen Display'),
            subtitle: const Text('Enable kitchen display and order management'),
            value: features.kitchen,
            onChanged: (value) {
              setState(() {
                _businessFeatures = _businessFeatures?.copyWith(kitchen: value);
              });
            },
          ),

          const Divider(height: 1),
          // Reservations toggle
          SwitchListTile(
            title: const Text('Reservations'),
            subtitle: const Text('Enable table reservations'),
            value: features.reservations,
            onChanged: (value) {
              setState(() {
                _businessFeatures =
                    _businessFeatures?.copyWith(reservations: value);
              });
            },
          ),

          const Divider(height: 1),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _businessFeatures = const BusinessFeatures(
                        catering: false,
                        mealPlans: false,
                        inDine: false,
                        staff: false,
                        kitchen: false,
                        reservations: false,
                      );
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Disable All'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _businessFeatures = const BusinessFeatures(
                        catering: true,
                        mealPlans: true,
                        inDine: true,
                        staff: true,
                        kitchen: true,
                        reservations: true,
                      );
                    });
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Enable All'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUIComponentsSection(ThemeData theme, BusinessUI ui) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'UI Components',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),

          // Landing Page toggle
          SwitchListTile(
            title: const Text('Landing Page'),
            subtitle: const Text('Show landing page in navigation'),
            value: ui.landingPage,
            onChanged: (value) {
              setState(() {
                _businessUI = _businessUI?.copyWith(landingPage: value);
              });
            },
          ),

          const Divider(height: 1),
          // Orders toggle
          SwitchListTile(
            title: const Text('Orders'),
            subtitle: const Text('Show orders tab in navigation'),
            value: ui.orders,
            onChanged: (value) {
              setState(() {
                _businessUI = _businessUI?.copyWith(orders: value);
              });
            },
          ),

          const Divider(height: 1),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _businessUI = const BusinessUI(
                        landingPage: false,
                        orders: false,
                      );
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Disable All'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _businessUI = const BusinessUI(
                        landingPage: true,
                        orders: true,
                      );
                    });
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Enable All'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewButton(Color color, Color textColor, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
