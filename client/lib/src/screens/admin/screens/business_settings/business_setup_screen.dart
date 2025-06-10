// File: lib/src/screens/setup/business_setup_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_setup_manager.dart';
import 'package:starter_architecture_flutter_firebase/src/core/local_storange/local_storage_service.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/setup/color_picker_widget.dart';
 
class BusinessSetupScreen extends ConsumerStatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  ConsumerState<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Form data
  final _businessNameController = TextEditingController();
  String _businessType = 'restaurant';
  
  // Logo and cover image files - platform compatible
  File? _logoLightFile;
  File? _logoDarkFile;
  File? _coverImageFile;
  
  // For web platform, store image bytes
  Uint8List? _logoLightBytes;
  Uint8List? _logoDarkBytes;
  Uint8List? _coverImageBytes;
  
  // Page index
  int _currentPage = 0;
  
  // Loading state
  bool _isLoading = false;
  String? _errorMessage;
  
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
  void dispose() {
    _businessNameController.dispose();
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
                break;
              case 'logo_dark':
                _logoDarkBytes = bytes;
                break;
              case 'cover':
                _coverImageBytes = bytes;
                break;
            }
          });
        } else {
          // For mobile platforms, use File objects
          setState(() {
            switch (type) {
              case 'logo_light':
                _logoLightFile = File(pickedFile.path);
                break;
              case 'logo_dark':
                _logoDarkFile = File(pickedFile.path);
                break;
              case 'cover':
                _coverImageFile = File(pickedFile.path);
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
        title: Text('Select ${colorType.substring(0, 1).toUpperCase()}${colorType.substring(1)} Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: current,
            onColorChanged: (color) {
              ref.read(selectedBusinessColorsProvider.notifier).updateColor(colorType, color);
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
  
  Future<void> _createBusiness() async {
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
      
      final businessId = await businessSetupManager.createBusinessConfig(
        businessName: _businessNameController.text,
        businessType: _businessType,
        primaryColor: selectedColors['primary']!,
        secondaryColor: selectedColors['secondary']!,
        tertiaryColor: selectedColors['tertiary']!,
        accentColor: selectedColors['accent']!,
        logoLight: _logoLightFile,
        logoDark: _logoDarkFile,
        coverImage: _coverImageFile,
      );
      
      // Save business ID to provider
      ref.read(currentBusinessIdProvider.notifier).state = businessId;
      
      // Save to local storage
      final localStorage = ref.read(localStorageServiceProvider);
      await localStorage.setString('businessId', businessId);
      
      if (mounted) {
        // Navigate to dashboard/home screen
        Navigator.of(context).pushReplacementNamed('/admin');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create business: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createBusiness();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  String _getBrandingStatus() {
    final hasLightLogo = kIsWeb ? _logoLightBytes != null : _logoLightFile != null;
    final hasDarkLogo = kIsWeb ? _logoDarkBytes != null : _logoDarkFile != null;
    final hasCoverImage = kIsWeb ? _coverImageBytes != null : _coverImageFile != null;
    
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
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColors = ref.watch(selectedBusinessColorsProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: 16),
              _buildProgressIndicator(theme),
              const SizedBox(height: 24),
              Expanded(
                child: Form(
                  key: _formKey,
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
                      _buildReviewPage(theme, selectedColors),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              _buildNavButtons(theme),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(
          Icons.restaurant_menu,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Restaurant App Setup',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Let\'s get your restaurant set up',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildProgressIndicator(ThemeData theme) {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= _currentPage;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildBasicInfoPage(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Restaurant Name',
              hintText: 'Enter your restaurant name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a restaurant name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _businessType,
            decoration: const InputDecoration(
              labelText: 'Restaurant Type',
              border: OutlineInputBorder(),
            ),
            items: _businessTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _businessType = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a restaurant type';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'This information will help us customize your restaurant app experience.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBrandingPage(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Branding',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _buildImageUploader(
            theme,
            title: 'Light Theme Logo',
            subtitle: 'This logo will be used in light theme mode',
            icon: Icons.light_mode,
            file: _logoLightFile,
            bytes: _logoLightBytes,
            onUpload: () => _pickImage(ImageSource.gallery, 'logo_light'),
          ),
          const SizedBox(height: 16),
          _buildImageUploader(
            theme,
            title: 'Dark Theme Logo',
            subtitle: 'This logo will be used in dark theme mode',
            icon: Icons.dark_mode,
            file: _logoDarkFile,
            bytes: _logoDarkBytes,
            onUpload: () => _pickImage(ImageSource.gallery, 'logo_dark'),
          ),
          const SizedBox(height: 16),
          _buildImageUploader(
            theme,
            title: 'Cover Image',
            subtitle: 'This image will be displayed at the top of your restaurant app',
            icon: Icons.image,
            file: _coverImageFile,
            bytes: _coverImageBytes,
            onUpload: () => _pickImage(ImageSource.gallery, 'cover'),
          ),
          const SizedBox(height: 24),
          Text(
            'Adding your restaurant\'s branding helps create a personalized experience.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageUploader(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required Uint8List? bytes,
    required VoidCallback onUpload,
  }) {
    // Build image widget based on platform
    Widget? imageWidget;
    
    if (kIsWeb) {
      if (bytes != null) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      if (file != null) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    
    return InkWell(
      onTap: onUpload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            imageWidget ??
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.upload_file,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorsPage(ThemeData theme, Map<String, Color> selectedColors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme Colors',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _buildColorSelector(
            theme,
            title: 'Primary Color',
            subtitle: 'Main color for your restaurant app',
            color: selectedColors['primary']!,
            onTap: () => _showColorPicker('primary'),
          ),
          const SizedBox(height: 16),
          _buildColorSelector(
            theme,
            title: 'Secondary Color',
            subtitle: 'Used for buttons and interactive elements',
            color: selectedColors['secondary']!,
            onTap: () => _showColorPicker('secondary'),
          ),
          const SizedBox(height: 16),
          _buildColorSelector(
            theme,
            title: 'Tertiary Color',
            subtitle: 'Used for highlighting and emphasis',
            color: selectedColors['tertiary']!,
            onTap: () => _showColorPicker('tertiary'),
          ),
          const SizedBox(height: 16),
          _buildColorSelector(
            theme,
            title: 'Accent Color',
            subtitle: 'Used for important actions and highlights',
            color: selectedColors['accent']!,
            onTap: () => _showColorPicker('accent'),
          ),
          const SizedBox(height: 24),
          _buildColorPreview(theme, selectedColors),
          const SizedBox(height: 24),
          Text(
            'These colors will define your restaurant app\'s look and feel.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildColorSelector(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.color_lens,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorPreview(ThemeData theme, Map<String, Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPreviewButton(
                colors['primary']!,
                Colors.white,
                'Primary',
              ),
              _buildPreviewButton(
                colors['secondary']!,
                Colors.white,
                'Secondary',
              ),
              _buildPreviewButton(
                colors['tertiary']!,
                Colors.white,
                'Tertiary',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors['primary']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colors['primary'],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sample notification with primary color',
                    style: TextStyle(color: colors['primary']),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors['accent'],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Accent Button',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreviewButton(Color color, Color textColor, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildReviewPage(ThemeData theme, Map<String, Color> selectedColors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Setup',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _buildReviewItem(
            theme,
            title: 'Restaurant Name',
            value: _businessNameController.text,
            icon: Icons.restaurant,
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            theme,
            title: 'Restaurant Type',
            value: _businessType.substring(0, 1).toUpperCase() + _businessType.substring(1),
            icon: Icons.category,
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            theme,
            title: 'Branding',
            value: _getBrandingStatus(),
            icon: Icons.image,
          ),
          const SizedBox(height: 16),
          _buildColorPreview(theme, selectedColors),
          const SizedBox(height: 24),
          Text(
            'This is how your restaurant app will be configured. You can always make changes later in the settings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewItem(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          OutlinedButton(
            onPressed: _isLoading ? null : _previousPage,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 8),
                Text('Back'),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
        ElevatedButton(
          onPressed: _isLoading ? null : _nextPage,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(_currentPage < 3 ? Icons.arrow_forward : Icons.check),
              const SizedBox(width: 8),
              Text(_currentPage < 3 ? 'Next' : 'Finish'),
            ],
          ),
        ),
      ],
    );
  }
}