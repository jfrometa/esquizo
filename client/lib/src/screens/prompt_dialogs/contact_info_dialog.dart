import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';

/// A dialog to collect contact information or use existing authenticated user data.
/// Supports four modes:
/// 1. Guest mode: Collects contact info without registration
/// 2. Registration mode: Creates a new user account
/// 3. Login mode: Allows existing users to log in
/// 4. Authenticated mode: Uses existing user info with option to edit
class ContactInfoDialog {
  /// Shows the contact info dialog
  /// Returns a map with user information or null if canceled
  static Future<Map<String, String>?> show(BuildContext context) async {
    return await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) =>
          _ContactInfoDialogContent(dialogContext: dialogContext),
    );
  }
}

// UI state
enum FormMode { contact, register, login }

/// The internal widget for the contact info dialog content
class _ContactInfoDialogContent extends ConsumerStatefulWidget {
  final BuildContext dialogContext;

  const _ContactInfoDialogContent({required this.dialogContext});

  @override
  _ContactInfoDialogContentState createState() =>
      _ContactInfoDialogContentState();
}

class _ContactInfoDialogContentState
    extends ConsumerState<_ContactInfoDialogContent> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Login form controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Form validation state
  bool _isNameValid = true;
  bool _isPhoneValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isLoginEmailValid = true;
  bool _isLoginPasswordValid = true;

  FormMode _formMode = FormMode.contact;
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
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access current user through Riverpod
    final user = ref.watch(authStateChangesProvider).value;
    final bool isUserLoggedIn = user != null && !user.isAnonymous;

    // Theme data
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Responsive width calculation
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double dialogWidth = screenWidth > 600 ? 500 : screenWidth * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(isUserLoggedIn, colorScheme),

              const SizedBox(height: 16),

              // User info banner for logged-in users
              if (isUserLoggedIn && !_isEditingInfo)
                _buildLoggedInBanner(user, colorScheme),

              // Toggle between form modes (only for guests)
              if (!isUserLoggedIn && !_isEditingInfo)
                _buildFormToggle(colorScheme),

              // Error message
              if (_errorMessage != null) _buildErrorMessage(colorScheme),

              // Form content
              Flexible(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildFormContent(isUserLoggedIn, colorScheme),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(isUserLoggedIn, user, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with title and close button
  Widget _buildHeader(bool isUserLoggedIn, ColorScheme colorScheme) {
    IconData headerIcon;
    String headerTitle;

    if (isUserLoggedIn && !_isEditingInfo) {
      headerIcon = Icons.person;
      headerTitle = 'Confirmar Información';
    } else if (_isEditingInfo) {
      headerIcon = Icons.edit;
      headerTitle = 'Editar Información';
    } else {
      switch (_formMode) {
        case FormMode.contact:
          headerIcon = Icons.contact_mail_outlined;
          headerTitle = 'Información de Contacto';
          break;
        case FormMode.register:
          headerIcon = Icons.app_registration;
          headerTitle = 'Registro de Usuario';
          break;
        case FormMode.login:
          headerIcon = Icons.login;
          headerTitle = 'Iniciar Sesión';
          break;
      }
    }

    return Row(
      children: [
        Icon(
          headerIcon,
          color: colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            headerTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.onSurface,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Close button
        IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.of(widget.dialogContext).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        )
      ],
    );
  }

  /// Builds the logged-in user banner
  Widget _buildLoggedInBanner(User user, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: colorScheme.primary,
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
                    color: colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    color: colorScheme.onSurface,
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
              foregroundColor: colorScheme.primary,
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

  /// Builds the toggle between form modes
  Widget _buildFormToggle(ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            // Contact Info Tab
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _formMode = FormMode.contact;
                    _errorMessage = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _formMode == FormMode.contact
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: _formMode == FormMode.contact ? 2 : 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Contacto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _formMode == FormMode.contact
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: _formMode == FormMode.contact
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),

            // Login Tab
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _formMode = FormMode.login;
                    _errorMessage = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _formMode == FormMode.login
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: _formMode == FormMode.login ? 2 : 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _formMode == FormMode.login
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: _formMode == FormMode.login
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),

            // Register Tab
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _formMode = FormMode.register;
                    _errorMessage = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _formMode == FormMode.register
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: _formMode == FormMode.register ? 2 : 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Registrarse',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _formMode == FormMode.register
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: _formMode == FormMode.register
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Subtitle for the selected mode
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            _getFormModeSubtitle(),
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// Get subtitle text based on form mode
  String _getFormModeSubtitle() {
    switch (_formMode) {
      case FormMode.contact:
        return 'Complete su pedido sin crear una cuenta';
      case FormMode.register:
        return 'Cree una cuenta para facilitar sus compras futuras';
      case FormMode.login:
        return 'Acceda a su cuenta existente';
    }
  }

  /// Builds error message container
  Widget _buildErrorMessage(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the appropriate form content based on state
  Widget _buildFormContent(
    bool isUserLoggedIn,
    ColorScheme colorScheme,
  ) {
    if (isUserLoggedIn && !_isEditingInfo) {
      // Show user info summary for logged-in users
      return _buildUserInfoSummary(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        colorScheme,
      );
    } else if (isUserLoggedIn && _isEditingInfo) {
      // Show edit form for logged-in users
      return _buildContactForm(
        colorScheme,
        true, // isEditing = true
      );
    } else {
      // Show form based on selected mode
      switch (_formMode) {
        case FormMode.contact:
          return _buildContactForm(
            colorScheme,
            false, // isEditing = false
          );
        case FormMode.register:
          return _buildRegistrationForm(colorScheme);
        case FormMode.login:
          return _buildLoginForm(colorScheme);
      }
    }
  }

  /// Builds a summary of the user's info for logged-in users
  Widget _buildUserInfoSummary(
    String name,
    String email,
    String phone,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoItem(
          'Nombre',
          name,
          Icons.person_outline,
          colorScheme,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          'Correo electrónico',
          email,
          Icons.email_outlined,
          colorScheme,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          'Teléfono',
          phone.isEmpty ? 'No especificado' : phone,
          Icons.phone_outlined,
          colorScheme,
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
    ColorScheme colorScheme, {
    bool isEmpty = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: colorScheme.primary,
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
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                  color: isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
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
    ColorScheme colorScheme,
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
          colorScheme: colorScheme,
          readOnly: false,
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
          colorScheme: colorScheme,
          readOnly: false,
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
          colorScheme: colorScheme,
          readOnly: isEditing, // Make email readonly when editing profile
        ),
      ],
    );
  }

  /// Builds the login form
  Widget _buildLoginForm(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _loginEmailController,
          label: 'Correo electrónico',
          hint: 'ejemplo@correo.com',
          icon: Icons.email_outlined,
          isValid: _isLoginEmailValid,
          errorText: 'Por favor ingrese un correo válido',
          inputType: TextInputType.emailAddress,
          colorScheme: colorScheme,
          readOnly: false,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _loginPasswordController,
          label: 'Contraseña',
          hint: 'Su contraseña',
          icon: Icons.lock_outline,
          isValid: _isLoginPasswordValid,
          errorText: 'Por favor ingrese su contraseña',
          inputType: TextInputType.visiblePassword,
          obscureText: true,
          colorScheme: colorScheme,
          readOnly: false,
        ),
        const SizedBox(height: 16),
        // Password recovery link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Show password reset dialog
              _showPasswordResetDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '¿Olvidó su contraseña?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the registration form
  Widget _buildRegistrationForm(ColorScheme colorScheme) {
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
          colorScheme: colorScheme,
          readOnly: false,
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
          colorScheme: colorScheme,
          readOnly: false,
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
          colorScheme: colorScheme,
          readOnly: false,
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
          colorScheme: colorScheme,
          readOnly: false,
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
          colorScheme: colorScheme,
          readOnly: false,
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
    required ColorScheme colorScheme,
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
            color: colorScheme.onSurface,
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
            color:
                readOnly ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
            fontStyle: readOnly ? FontStyle.italic : FontStyle.normal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: isValid ? colorScheme.onSurfaceVariant : colorScheme.error,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid ? colorScheme.outline : colorScheme.error,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid ? colorScheme.outline : colorScheme.error,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid ? colorScheme.primary : colorScheme.error,
                width: 1.5,
              ),
            ),
            errorText: isValid ? null : errorText,
            errorStyle: TextStyle(
              color: colorScheme.error,
              fontSize: 12,
            ),
            filled: true,
            fillColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
    ColorScheme colorScheme,
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
              foregroundColor: colorScheme.onSurfaceVariant,
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
              foregroundColor: colorScheme.onSurfaceVariant,
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
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _getActionButtonText(isUserLoggedIn),
                ),
        ),
      ],
    );
  }

  /// Get the appropriate text for the main action button
  String _getActionButtonText(bool isUserLoggedIn) {
    if (isUserLoggedIn && !_isEditingInfo) {
      return 'Continuar';
    } else if (_isEditingInfo) {
      return 'Guardar Cambios';
    } else {
      switch (_formMode) {
        case FormMode.contact:
          return 'Confirmar';
        case FormMode.register:
          return 'Registrarse';
        case FormMode.login:
          return 'Iniciar Sesión';
      }
    }
  }

  /// Shows a dialog to reset password
  Future<void> _showPasswordResetDialog(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    bool isProcessing = false;
    String? errorMessage;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Restablecer Contraseña'),
              backgroundColor: colorScheme.surface,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ingrese su correo electrónico y le enviaremos un enlace para restablecer su contraseña.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                      labelStyle:
                          TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          if (emailController.text.isEmpty) {
                            setState(() {
                              errorMessage =
                                  'Por favor ingrese su correo electrónico';
                            });
                            return;
                          }

                          setState(() {
                            isProcessing = true;
                            errorMessage = null;
                          });

                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: emailController.text,
                            );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Hemos enviado un enlace para restablecer su contraseña'),
                                backgroundColor: colorScheme.primary,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              errorMessage = _getFirebaseErrorMessage(e);
                              isProcessing = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
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

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Handle based on current state/mode
      if (isUserLoggedIn && _isEditingInfo) {
        await _updateUserProfile(user!);
      } else {
        switch (_formMode) {
          case FormMode.contact:
            // Validate contact form
            if (!_validateContactForm()) {
              setState(() => _isProcessing = false);
              return;
            }

            // Just using contact info without registration
            Navigator.of(widget.dialogContext).pop({
              'name': _nameController.text,
              'phone': _phoneController.text,
              'email': _emailController.text,
            });
            break;

          case FormMode.register:
            // Validate registration form
            if (!_validateRegistrationForm()) {
              setState(() => _isProcessing = false);
              return;
            }

            await _registerNewUser();
            break;

          case FormMode.login:
            // Validate login form
            if (!_validateLoginForm()) {
              setState(() => _isProcessing = false);
              return;
            }

            await _loginUser();
            break;
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Hubo un error. Por favor intente nuevamente.";
        _isProcessing = false;
      });
    }
  }

  /// Validate the contact form
  bool _validateContactForm() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
      _isPhoneValid = _validatePhone(_phoneController.text);
      _isEmailValid = _validateEmail(_emailController.text);
    });

    return _isNameValid && _isPhoneValid && _isEmailValid;
  }

  /// Validate the registration form
  bool _validateRegistrationForm() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
      _isPhoneValid = _validatePhone(_phoneController.text);
      _isEmailValid = _validateEmail(_emailController.text);
      _isPasswordValid = _passwordController.text.length >= 6;
      _isConfirmPasswordValid =
          _passwordController.text == _confirmPasswordController.text;
    });

    return _isNameValid &&
        _isPhoneValid &&
        _isEmailValid &&
        _isPasswordValid &&
        _isConfirmPasswordValid;
  }

  /// Validate the login form
  bool _validateLoginForm() {
    setState(() {
      _isLoginEmailValid = _loginEmailController.text.trim().isNotEmpty &&
          _validateEmail(_loginEmailController.text);
      _isLoginPasswordValid = _loginPasswordController.text.trim().isNotEmpty;
    });

    return _isLoginEmailValid && _isLoginPasswordValid;
  }

  /// Login an existing user
  Future<void> _loginUser() async {
    try {
      // Get Firebase Auth instance from provider
      final auth = ref.read(firebaseAuthProvider);

      // Sign in user
      final credentials = await auth.signInWithEmailAndPassword(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );

      // Initialize user data for the view
      _nameController.text = credentials.user?.displayName ?? '';
      _emailController.text = credentials.user?.email ?? '';

      // Try to get additional user info from Firestore
      if (credentials.user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(credentials.user!.uid)
              .get();

          if (userDoc.exists) {
            _userData = userDoc.data();
            _phoneController.text = _userData?['phone'] ?? '';
          } else {
            // Create user document if it doesn't exist
            await FirebaseFirestore.instance
                .collection('users')
                .doc(credentials.user!.uid)
                .set({
              'name': credentials.user?.displayName ?? '',
              'email': credentials.user?.email ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          debugPrint('Error fetching/creating user data: $e');
        }
      }

      // Make sure auth state is refreshed
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.forceRefreshAuthState();

      // Return user data
      if (mounted && widget.dialogContext.mounted) {
        Navigator.of(widget.dialogContext).pop({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'userId': credentials.user?.uid ?? '',
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e);
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión: ${e.toString()}';
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
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'phone': _phoneController.text,
        'name': _nameController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Make sure auth state is refreshed
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.forceRefreshAuthState();

      // Return updated info
      if (mounted && widget.dialogContext.mounted) {
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
      if (mounted && widget.dialogContext.mounted) {
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
        case 'user-disabled':
          return 'Esta cuenta ha sido desactivada. Contacte al administrador.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Por favor, inténtelo más tarde.';
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
      final formattedNumber =
          '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, min(10, digits.length))}';
      return formattedNumber;
    }
  }

  int min(int a, int b) => a < b ? a : b;
}
