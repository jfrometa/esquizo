import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_setup_manager.dart';
import 'package:starter_architecture_flutter_firebase/src/core/local_storange/local_storage_service.dart';
import 'dart:io';

import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/setup/color_picker_widget.dart';

class BusinessSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSetupComplete;

  const BusinessSetupScreen({
    super.key,
    this.onSetupComplete,
  });

  @override
  ConsumerState<BusinessSetupScreen> createState() =>
      _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Form data
  final _businessNameController = TextEditingController();
  String _businessType = 'restaurant';

  // Logo and cover image files
  File? _logoLightFile;
  File? _logoDarkFile;
  File? _coverImageFile;

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
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showImageSourceOptions(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, type);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, type);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Business setup completed successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Call onSetupComplete callback if provided
        if (widget.onSetupComplete != null) {
          widget.onSetupComplete!();
        } else {
          // Navigate to dashboard/home screen if no callback
          Navigator.of(context).pushReplacementNamed('/admin');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create business: $e';
      });

      // Show error snackbar for better visibility
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isCompact = screenWidth < 600;

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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant_menu,
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Restaurant App Setup',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
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
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * (_currentPage + 1) / 4 -
              48, // Adjust for padding
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoPage(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              labelText: 'Restaurant Name',
              hintText: 'Enter your restaurant name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              prefixIcon: const Icon(Icons.business),
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
            decoration: InputDecoration(
              labelText: 'Restaurant Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              prefixIcon: const Icon(Icons.category),
            ),
            items: _businessTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                    type.substring(0, 1).toUpperCase() + type.substring(1)),
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
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Why this matters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This information will help us customize your restaurant app experience with features relevant to your business type.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildImageUploader(
            theme,
            title: 'Light Theme Logo',
            subtitle: 'This logo will be used in light theme mode',
            icon: Icons.light_mode,
            file: _logoLightFile,
            onUpload: () => _showImageSourceOptions('logo_light'),
          ),
          const SizedBox(height: 16),
          _buildImageUploader(
            theme,
            title: 'Dark Theme Logo',
            subtitle: 'This logo will be used in dark theme mode',
            icon: Icons.dark_mode,
            file: _logoDarkFile,
            onUpload: () => _showImageSourceOptions('logo_dark'),
          ),
          const SizedBox(height: 16),
          _buildImageUploader(
            theme,
            title: 'Cover Image',
            subtitle:
                'This image will be displayed at the top of your restaurant app',
            icon: Icons.image,
            file: _coverImageFile,
            onUpload: () => _showImageSourceOptions('cover'),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Branding Tips',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adding your restaurant\'s branding helps create a personalized experience for your customers. Use high-quality images with transparent backgrounds for best results.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
    required VoidCallback onUpload,
  }) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: file != null
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.5),
          width: file != null ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onUpload,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (file != null)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      file,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          file != null ? Icons.check_circle : Icons.add_circle,
                          size: 16,
                          color: file != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          file != null ? 'Uploaded' : 'Upload Image',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: file != null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
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
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Color Theory Tips',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose colors that reflect your restaurant\'s brand. Complementary colors work well together and create visual harmony. These colors will define your restaurant app\'s look and feel.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: ThemeData.estimateBrightnessForColor(color) ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
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
      ),
    );
  }

  Widget _buildColorPreview(ThemeData theme, Map<String, Color> colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: colors['accent'],
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Accent Button',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewButton(Color color, Color textColor, String label) {
    return Column(
      children: [
        Material(
          elevation: 4,
          shape: const CircleBorder(),
          color: color,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: textColor,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
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
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildReviewItem(
            theme,
            title: 'Restaurant Name',
            value: _businessNameController.text.isNotEmpty
                ? _businessNameController.text
                : 'Not provided',
            icon: Icons.restaurant,
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            theme,
            title: 'Restaurant Type',
            value: _businessType.substring(0, 1).toUpperCase() +
                _businessType.substring(1),
            icon: Icons.category,
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            theme,
            title: 'Branding',
            value:
                '${_logoLightFile != null ? "Light Logo ✓" : "Light Logo ✗"}, '
                '${_logoDarkFile != null ? "Dark Logo ✓" : "Dark Logo ✗"}, '
                '${_coverImageFile != null ? "Cover Image ✓" : "Cover Image ✗"}',
            icon: Icons.image,
          ),
          const SizedBox(height: 16),
          _buildColorReviewItem(theme, selectedColors),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Almost Done!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is how your restaurant app will be configured. You can always make changes later in the settings.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorReviewItem(ThemeData theme, Map<String, Color> colors) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.color_lens,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Theme Colors',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorPreviewChip(
                  color: colors['primary']!,
                  label: 'Primary',
                ),
                _buildColorPreviewChip(
                  color: colors['secondary']!,
                  label: 'Secondary',
                ),
                _buildColorPreviewChip(
                  color: colors['tertiary']!,
                  label: 'Tertiary',
                ),
                _buildColorPreviewChip(
                  color: colors['accent']!,
                  label: 'Accent',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreviewChip({required Color color, required String label}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _previousPage,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _nextPage,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_currentPage < 3 ? Icons.arrow_forward : Icons.check),
          label: Text(_currentPage < 3 ? 'Next' : 'Finish'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
