import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

/// A dialog to collect contact information or use existing authenticated user data.
/// Supports three modes:
/// 1. Guest mode: Collects contact info without registration
/// 2. Registration mode: Creates a new user account
/// 3. Authenticated mode: Uses existing user info with option to edit
class ContactInfoDialog {
  /// Shows the contact info dialog
  /// Returns a map with user information or null if canceled
  static Future<Map<String, String>?> show(BuildContext context) async {
    return await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _ContactInfoDialogContent(dialogContext: dialogContext),
    );
  }
}

/// The internal widget for the contact info dialog content
class _ContactInfoDialogContent extends ConsumerStatefulWidget {
  final BuildContext dialogContext;

  const _ContactInfoDialogContent({required this.dialogContext});

  @override
  _ContactInfoDialogContentState createState() => _ContactInfoDialogContentState();
}

class _ContactInfoDialogContentState extends ConsumerState<_ContactInfoDialogContent> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Form validation state
  bool _isNameValid = true;
  bool _isPhoneValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  
  // UI state
  bool _showRegistrationForm = false;
  bool _isEditingInfo = false;
  bool _isProcessing = false;
  String? _errorMessage;

  // User Firestore data
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  /// Initialize form data based on current authentication state
  Future<void> _initializeUserData() async {
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    
    // If no user or anonymous user, nothing to pre-fill
    if (currentUser == null || currentUser.isAnonymous) {
      return;
    }

    // Pre-fill with auth data
    _nameController.text = currentUser.displayName ?? '';
    _emailController.text = currentUser.email ?? '';
    
    // Try to get additional user data from Firestore
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data();
          _phoneController.text = _userData?['phone'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access current user through Riverpod
    final user = ref.watch(authStateChangesProvider).value;
    final bool isUserLoggedIn = user != null && !user.isAnonymous;
    
    // Theme detection
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Responsive width calculation
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 600 ? 500 : screenWidth * 0.85;
    
    // Color scheme based on theme
    final Color backgroundColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.grey[850]!;
    final Color subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final Color dividerColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final Color fieldBorderColor = isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;
    final Color fieldFillColor = isDarkMode ? Colors.grey[800]! : Colors.grey[50]!;
    final Color successColor = isDarkMode ? Colors.green[300]! : Colors.green[600]!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(isUserLoggedIn, textColor, subtitleColor),
              
              const SizedBox(height: 16),
              
              // User info banner for logged-in users
              if (isUserLoggedIn && !_isEditingInfo)
                _buildLoggedInBanner(user!, successColor, textColor, subtitleColor, isDarkMode),
              
              // Toggle between contact info and registration (only for guests)
              if (!isUserLoggedIn && !_isEditingInfo)
                _buildFormToggle(dividerColor, subtitleColor),
              
              // Error message
              if (_errorMessage != null)
                _buildErrorMessage(),
              
              // Form content
              Flexible(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildFormContent(
                      isUserLoggedIn, 
                      textColor, 
                      subtitleColor,
                      fieldBorderColor,
                      fieldFillColor,
                      isDarkMode,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              _buildActionButtons(
                isUserLoggedIn, 
                user, 
                subtitleColor,
              ),
              
              // Login option for contact-only users
              if (!isUserLoggedIn && !_showRegistrationForm)
                _buildLoginOption(subtitleColor),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with title and close button
  Widget _buildHeader(bool isUserLoggedIn, Color textColor, Color subtitleColor) {
    return Row(
      children: [
        Icon(
          isUserLoggedIn && !_isEditingInfo 
              ? Icons.person
              : _showRegistrationForm 
                  ? Icons.app_registration 
                  : Icons.contact_mail_outlined,
          color: ColorsPaletteRedonda.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isUserLoggedIn && !_isEditingInfo
                ? 'Confirmar Información'
                : _showRegistrationForm 
                    ? 'Registro de Usuario' 
                    : 'Información de Contacto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Close button
        IconButton(
          icon: Icon(Icons.close, color: subtitleColor),
          onPressed: () => Navigator.of(widget.dialogContext).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        )
      ],
    );
  }

  /// Builds the logged-in user banner
  Widget _buildLoggedInBanner(User user, Color successColor, Color textColor, Color subtitleColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.green[900]!.withOpacity(0.3) 
            : Colors.green[50]!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: successColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline, 
            color: successColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sesión iniciada como:',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isEditingInfo = true;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: ColorsPaletteRedonda.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  /// Builds the toggle between contact info and registration
  Widget _buildFormToggle(Color dividerColor, Color subtitleColor) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _showRegistrationForm = false;
                _errorMessage = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !_showRegistrationForm 
                        ? ColorsPaletteRedonda.primary 
                        : dividerColor,
                    width: !_showRegistrationForm ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                'Información de Contacto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: !_showRegistrationForm 
                      ? ColorsPaletteRedonda.primary 
                      : subtitleColor,
                  fontWeight: !_showRegistrationForm 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _showRegistrationForm = true;
                _errorMessage = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _showRegistrationForm 
                        ? ColorsPaletteRedonda.primary 
                        : dividerColor,
                    width: _showRegistrationForm ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                'Registrarse',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _showRegistrationForm 
                      ? ColorsPaletteRedonda.primary 
                      : subtitleColor,
                  fontWeight: _showRegistrationForm 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds error message container
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the appropriate form content based on state
  Widget _buildFormContent(
    bool isUserLoggedIn,
    Color textColor,
    Color subtitleColor,
    Color fieldBorderColor,
    Color fieldFillColor,
    bool isDarkMode,
  ) {
    if (isUserLoggedIn && !_isEditingInfo) {
      // Show user info summary for logged-in users
      return _buildUserInfoSummary(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        textColor,
        subtitleColor,
        isDarkMode,
      );
    } else if (_showRegistrationForm) {
      // Show registration form
      return _buildRegistrationForm(
        textColor,
        subtitleColor,
        fieldBorderColor,
        fieldFillColor,
        isDarkMode,
      );
    } else {
      // Show contact info form
      return _buildContactForm(
        textColor,
        subtitleColor,
        fieldBorderColor,
        fieldFillColor,
        isDarkMode,
        isUserLoggedIn && _isEditingInfo,
      );
    }
  }

  /// Builds a summary of the user's info for logged-in users
  Widget _buildUserInfoSummary(
    String name,
    String email,
    String phone,
    Color textColor,
    Color subtitleColor,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoItem(
          'Nombre',
          name,
          Icons.person_outline,
          textColor,
          subtitleColor,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          'Correo electrónico',
          email,
          Icons.email_outlined,
          textColor,
          subtitleColor,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          'Teléfono',
          phone.isEmpty ? 'No especificado' : phone,
          Icons.phone_outlined,
          textColor,
          subtitleColor,
          isDarkMode,
          isEmpty: phone.isEmpty,
        ),
      ],
    );
  }

  /// Builds an individual info item row
  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color textColor,
    Color subtitleColor,
    bool isDarkMode, {
    bool isEmpty = false,
  }) {
    final Color iconColor = isDarkMode 
        ? ColorsPaletteRedonda.primary.withOpacity(0.8) 
        : ColorsPaletteRedonda.primary;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                  color: isEmpty ? subtitleColor : textColor,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the contact information form
  Widget _buildContactForm(
    Color textColor,
    Color subtitleColor,
    Color fieldBorderColor,
    Color fieldFillColor,
    bool isDarkMode,
    bool isEditing,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nombre completo',
          hint: 'Ingrese su nombre',
          icon: Icons.person_outline,
          isValid: _isNameValid,
          errorText: 'Por favor ingrese su nombre',
          inputType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textColor: textColor,
          subtitleColor: subtitleColor,
          fieldBorderColor: fieldBorderColor,
          fieldFillColor: fieldFillColor,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Teléfono',
          hint: '(XXX) XXX-XXXX',
          icon: Icons.phone_outlined,
          isValid: _isPhoneValid,
          errorText: 'Por favor ingrese un número válido',
          inputType: TextInputType.phone,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
            PhoneNumberFormatter(),
          ],
          textColor: textColor,
          subtitleColor: subtitleColor,
          fieldBorderColor: fieldBorderColor,
          fieldFillColor: fieldFillColor,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Correo electrónico',
          hint: 'ejemplo@correo.com',
          icon: Icons.email_outlined,
          isValid: _isEmailValid,
          errorText: 'Por favor ingrese un correo válido',
          inputType: TextInputType.emailAddress,
          textColor: textColor,
          subtitleColor: subtitleColor,
          fieldBorderColor: fieldBorderColor,
          fieldFillColor: fieldFillColor,
          isDarkMode: isDarkMode,
          readOnly: isEditing, // Make email readonly when editing profile
        ),
      ],
    );
  }

  /// Builds the registration form
  Widget _buildRegistrationForm(
    Color textColor,
    Color subtitleColor,
    Color fieldBorderColor,
    Color fieldFillColor,
    bool isDarkMode,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nombre completo',
          hint: 'Ingrese su nombre',
          icon: Icons.person_outline,
          isValid: _isNameValid,
          errorText: 'Por favor ingrese su nombre',
          inputType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textColor: textColor,
          subtitleColor: subtitleColor,
          fieldBorderColor: fieldBorderColor,
          fieldFillColor: fieldFillColor,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Correo electrónico',
          hint: 'ejemplo@correo.com',
          icon: Icons.email_outlined,
          isValid: _isEmailValid,
          errorText: 'Por favor ingrese un correo válido',
          inputType: TextInputType.emailAddress,
          textColor: textColor,
          subtitleColor: subtitleColor,
          fieldBorderColor: fieldBorderColor,
          fieldFillColor: fieldFillColor,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Teléfono',
          hint: '(XXX) XXX-XXXX',
          icon: Icons.phone_outlined,
          isValid: _isPhoneValid,
          errorText: 'Por favor ingrese un número válido',
          inputType: TextInputType.phone,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
            PhoneNumberFormatter(),
          ],
          textColor: textColor,
          subtitleColor: subtitleColor,
          fieldBorderColor: fieldBorderColor,
          fieldFillColor: fieldFillColor,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          icon: Icons.lock_outline,
          isValid: _isPasswordValid,
          errorText: 'La contraseña debe tener al menos 6 caracteres',
          inputType: TextInputType.visiblePassword,
          obscureText: true,
          textColor: textColor,
          subtitleColor: subtitleColor,
          fieldBorderColor: fieldBorderColor,
          fieldFillColor: fieldFillColor,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          hint: 'Repita su contraseña',
          icon: Icons.lock_outline,
          isValid: _isConfirmPasswordValid,
          errorText: 'Las contraseñas no coinciden',
          inputType: TextInputType.visiblePassword,
          obscureText: true,
          textColor: textColor,
          subtitleColor: subtitleColor,
          fieldBorderColor: fieldBorderColor,
          fieldFillColor: fieldFillColor,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  /// Builds a text field with standard styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isValid,
    required String errorText,
    required Color textColor,
    required Color subtitleColor,
    required Color fieldBorderColor,
    required Color fieldFillColor,
    required bool isDarkMode,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          textCapitalization: textCapitalization,
          inputFormatters: formatters,
          obscureText: obscureText,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly ? subtitleColor : textColor,
            fontStyle: readOnly ? FontStyle.italic : FontStyle.normal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: isValid 
                  ? (isDarkMode ? Colors.grey[400] : Colors.grey[600])
                  : Colors.red,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid ? fieldBorderColor : Colors.red,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid ? fieldBorderColor : Colors.red,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid
                    ? ColorsPaletteRedonda.primary
                    : Colors.red,
                width: 1.5,
              ),
            ),
            errorText: isValid ? null : errorText,
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
            filled: true,
            fillColor: fieldFillColor,
            enabled: !readOnly,
          ),
        ),
      ],
    );
  }

  /// Builds action buttons (Continue, Cancel, etc.)
  Widget _buildActionButtons(
    bool isUserLoggedIn,
    User? user, 
    Color subtitleColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel editing button (for logged-in users who are editing)
        if (isUserLoggedIn && _isEditingInfo)
          TextButton(
            onPressed: _isProcessing
                ? null
                : () {
                    setState(() {
                      _isEditingInfo = false;
                      // Reset controllers to original values
                      _nameController.text = user?.displayName ?? '';
                      _emailController.text = user?.email ?? '';
                      _phoneController.text = _userData?['phone'] ?? '';
                    });
                  },
            style: TextButton.styleFrom(
              foregroundColor: subtitleColor,
            ),
            child: const Text('Cancelar Edición'),
          ),
        
        // Regular cancel button
        if (!isUserLoggedIn || !_isEditingInfo)
          TextButton(
            onPressed: _isProcessing
                ? null
                : () => Navigator.of(widget.dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: subtitleColor,
            ),
            child: const Text('Cancelar'),
          ),
        
        const SizedBox(width: 8),
        
        // Main action button (Continue, Register, Save Changes)
        ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () => _handleMainAction(isUserLoggedIn, user),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsPaletteRedonda.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isUserLoggedIn && !_isEditingInfo
                      ? 'Continuar'
                      : _isEditingInfo
                          ? 'Guardar Cambios'
                          : _showRegistrationForm 
                              ? 'Registrarse' 
                              : 'Confirmar',
                ),
        ),
      ],
    );
  }

  /// Builds the "Already have an account?" option
  Widget _buildLoginOption(Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿Ya tiene una cuenta?',
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to sign in screen
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomSignInScreen(),
                ),
              );
            },
            child: Text(
              'Iniciar sesión',
              style: TextStyle(
                color: ColorsPaletteRedonda.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle the main action button press
  Future<void> _handleMainAction(bool isUserLoggedIn, User? user) async {
    // If user is logged in and not editing, just return the info
    if (isUserLoggedIn && !_isEditingInfo) {
      Navigator.of(widget.dialogContext).pop({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'userId': user?.uid ?? '',
      });
      return;
    }
    
    // Validate form fields
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
      _isPhoneValid = _validatePhone(_phoneController.text);
      _isEmailValid = _validateEmail(_emailController.text);
      
      if (_showRegistrationForm) {
        _isPasswordValid = _passwordController.text.length >= 6;
        _isConfirmPasswordValid = 
            _passwordController.text == _confirmPasswordController.text;
      }
    });

    // If any validation fails, return early
    if (!_isNameValid || !_isPhoneValid || !_isEmailValid || 
        (_showRegistrationForm && (!_isPasswordValid || !_isConfirmPasswordValid))) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Handle based on current state
      if (isUserLoggedIn && _isEditingInfo) {
        await _updateUserProfile(user!);
      } else if (_showRegistrationForm) {
        await _registerNewUser();
      } else {
        // Just using contact info without registration
        Navigator.of(widget.dialogContext).pop({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Hubo un error. Por favor intente nuevamente.";
        _isProcessing = false;
      });
    }
  }

  /// Update an existing user's profile
  Future<void> _updateUserProfile(User user) async {
    try {
      // Update user profile in Firebase Auth using our provider
      await user.updateDisplayName(_nameController.text);
      
      // Update phone in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'phone': _phoneController.text,
            'name': _nameController.text,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      // Make sure auth state is refreshed
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.forceRefreshAuthState();
      
      // Return updated info
      if (mounted) {
        Navigator.of(widget.dialogContext).pop({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'userId': user.uid,
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error actualizando el perfil: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  /// Register a new user
  Future<void> _registerNewUser() async {
    try {
      // Get Firebase Auth instance from provider
      final auth = ref.read(firebaseAuthProvider);
      
      // Create new user
      final credentials = await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Update user profile
      await credentials.user?.updateDisplayName(_nameController.text);
      
      // Save additional user info to Firestore
      if (credentials.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credentials.user!.uid)
            .set({
              'name': _nameController.text,
              'email': _emailController.text,
              'phone': _phoneController.text,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }
      
      // Make sure auth state is refreshed
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.forceRefreshAuthState();
      
      // Return user data
      if (mounted) {
        Navigator.of(widget.dialogContext).pop({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'userId': credentials.user?.uid ?? '',
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e);
        _isProcessing = false;
      });
    }
  }

  /// Validate phone number
  static bool _validatePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '').length >= 10;
  }

  /// Validate email format
  static bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
    );
    return emailRegex.hasMatch(email);
  }
  
  /// Get human-readable error message for Firebase errors
  static String _getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Este correo electrónico ya está registrado. Por favor use otro.';
        case 'invalid-email':
          return 'El formato del correo electrónico no es válido.';
        case 'weak-password':
          return 'La contraseña es demasiado débil. Use al menos 6 caracteres.';
        case 'operation-not-allowed':
          return 'El registro con correo y contraseña no está habilitado.';
        case 'user-not-found':
          return 'No se encontró ningún usuario con este correo electrónico.';
        case 'wrong-password':
          return 'Contraseña incorrecta. Por favor intente nuevamente.';
        default:
          return 'Error: ${error.message}';
      }
    }
    return 'Ocurrió un error al procesar su solicitud.';
  }
}

/// Phone number formatter for consistent display
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedValue = _formatPhoneNumber(digitsOnly);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  String _formatPhoneNumber(String digits) {
    if (digits.isEmpty) return '';
    
    // Handle different lengths
    if (digits.length < 4) {
      return '(${digits.padRight(3, ' ').trim()}';
    } else if (digits.length < 7) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3).padRight(3, ' ').trim()}';
    } else {
      final formattedNumber = '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, min(10, digits.length))}';
      return formattedNumber;
    }
  }

  int min(int a, int b) => a < b ? a : b;
}