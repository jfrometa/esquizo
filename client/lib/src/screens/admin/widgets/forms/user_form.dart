import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api_services/auth_services/auth_service.dart';

class UserForm extends ConsumerStatefulWidget {
  final AppUser? user;
  final Function(AppUser, String) onSave;
  final VoidCallback onCancel;

  const UserForm({
    super.key,
    this.user,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<UserForm> createState() => _UserFormState();
}

class _UserFormState extends ConsumerState<UserForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _photoURLController = TextEditingController();
  
  // Form state
  List<String> _selectedRoles = ['customer'];
  bool _isActive = true;
  final Map<String, dynamic> _metadata = {};
  bool _isEditMode = false;
  bool _showPassword = false;
  
  @override
  void initState() {
    super.initState();
    _isEditMode = widget.user != null;
    
    if (_isEditMode) {
      // Populate form with existing user data
      _emailController.text = widget.user!.email;
      _displayNameController.text = widget.user!.displayName ?? '';
      _photoURLController.text = widget.user!.photoURL ?? '';
      _selectedRoles = List<String>.from(widget.user!.roles);
      _isActive = widget.user!.isActive;
      _metadata.addAll(widget.user!.metadata);
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _photoURLController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? 'Edit User' : 'Add New User',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // User avatar preview
              _buildAvatarPreview(),
              const SizedBox(height: 16),
              
              // Photo URL
              TextFormField(
                controller: _photoURLController,
                decoration: InputDecoration(
                  labelText: 'Photo URL',
                  hintText: 'Enter URL for profile photo',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {});
                    },
                    tooltip: 'Refresh preview',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter user email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isEditMode, // Email can't be changed once created
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegExp.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Display name field
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter display name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password fields (only shown when creating new user)
              if (!_isEditMode) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      tooltip: _showPassword ? 'Hide password' : 'Show password',
                    ),
                  ),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      tooltip: _showPassword ? 'Hide password' : 'Show password',
                    ),
                  ),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // User roles
              const Text(
                'User Roles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _buildRoleChips(),
              ),
              const SizedBox(height: 16),
              
              // Is active toggle
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Toggle user account status'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Custom metadata section - expandable
              ExpansionTile(
                title: const Text('Additional Metadata'),
                children: [
                  _buildMetadataFields(),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Field'),
                    onPressed: _addMetadataField,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Form actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: Text(_isEditMode ? 'Update User' : 'Create User'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAvatarPreview() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundImage: _photoURLController.text.isNotEmpty
                ? NetworkImage(_photoURLController.text)
                : null,
            child: _photoURLController.text.isEmpty
                ? Text(
                    _displayNameController.text.isNotEmpty
                        ? _displayNameController.text[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            _displayNameController.text.isNotEmpty
                ? _displayNameController.text
                : 'User',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            _emailController.text.isNotEmpty
                ? _emailController.text
                : 'email@example.com',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildRoleChips() {
    const availableRoles = [
      'admin',
      'manager',
      'staff',
      'customer',
    ];
    
    return availableRoles.map((role) {
      final isSelected = _selectedRoles.contains(role);
      return FilterChip(
        label: Text(role),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedRoles.add(role);
            } else {
              // Prevent removing all roles
              if (_selectedRoles.length > 1) {
                _selectedRoles.remove(role);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User must have at least one role')),
                );
              }
            }
          });
        },
      );
    }).toList();
  }
  
  Widget _buildMetadataFields() {
    return Column(
      children: _metadata.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: entry.key,
                  decoration: const InputDecoration(
                    labelText: 'Field',
                    hintText: 'Key',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final oldValue = entry.value;
                    _metadata.remove(entry.key);
                    _metadata[value] = oldValue;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: entry.value.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    hintText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _metadata[entry.key] = value;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _metadata.remove(entry.key);
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  void _addMetadataField() {
    setState(() {
      _metadata['field${_metadata.length + 1}'] = '';
    });
  }
  
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Create AppUser object
    final user = AppUser(
      uid: _isEditMode ? widget.user!.uid : '', // UID will be set after creation
      email: _emailController.text,
      displayName: _displayNameController.text.isEmpty ? null : _displayNameController.text,
      photoURL: _photoURLController.text.isEmpty ? null : _photoURLController.text,
      metadata: _metadata,
      roles: _selectedRoles,
      isActive: _isActive,
    );
    
    // Pass to parent handler with password (only used for new users)
    widget.onSave(user, _passwordController.text);
  }
}