import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/auth_services/auth_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/user_form.dart';
 

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and filters section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildRoleFilter(),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Staff & Admins'),
                    Tab(text: 'Customers'),
                  ],
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                  isScrollable: true,
                ),
              ],
            ),
          ),
          
          // Users list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersList(isStaff: true),
                _buildUsersList(isStaff: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        tooltip: 'Add User',
        child: const Icon(Icons.person_add),
      ),
    );
  }
  
  Widget _buildRoleFilter() {
    return DropdownButton<String>(
      value: _selectedRole.isEmpty ? 'all' : _selectedRole,
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Roles')),
        DropdownMenuItem(value: 'admin', child: Text('Admins')),
        DropdownMenuItem(value: 'manager', child: Text('Managers')),
        DropdownMenuItem(value: 'staff', child: Text('Staff')),
        DropdownMenuItem(value: 'customer', child: Text('Customers')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRole = value == 'all' ? '' : value!;
        });
      },
      hint: const Text('Filter by Role'),
    );
  }
  
  Widget _buildUsersList({required bool isStaff}) {
    // Define which roles to include based on the tab
    final roleFilter = isStaff 
        ? ['admin', 'manager', 'staff'] 
        : ['customer'];
    
    return ref.watch(usersStreamProvider).when(
      data: (users) {
        // Filter users based on role, search, and selected role filter
        final filteredUsers = users.where((user) {
          // Filter by staff/customer role
          final matchesTab = isStaff 
              ? roleFilter.any((role) => user.roles.contains(role))
              : user.roles.contains('customer') && user.roles.length == 1;
          
          // Filter by search query
          final matchesSearch = _searchQuery.isEmpty ||
              user.email.toLowerCase().contains(_searchQuery) ||
              (user.displayName?.toLowerCase() ?? '').contains(_searchQuery);
          
          // Filter by selected role
          final matchesRole = _selectedRole.isEmpty || 
              user.roles.contains(_selectedRole);
          
          return matchesTab && matchesSearch && matchesRole;
        }).toList();
        
        if (filteredUsers.isEmpty) {
          return const Center(
            child: Text('No users found'),
          );
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _buildUserListTile(user);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
  
  Widget _buildUserListTile(AppUser user) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider).value;
    final isCurrentUser = currentUser?.uid == user.uid;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundImage: user.photoURL != null 
            ? NetworkImage(user.photoURL!) 
            : null,
        child: user.displayName != null && user.displayName!.isNotEmpty
            ? Text(user.displayName![0].toUpperCase())
            : const Icon(Icons.person),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.displayName ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: user.roles.map((role) {
              return Chip(
                label: Text(role),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelStyle: const TextStyle(fontSize: 12),
              );
            }).toList(),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditUserDialog(user),
            tooltip: 'Edit',
          ),
          if (!isCurrentUser) // Don't allow deactivating the current user
            IconButton(
              icon: Icon(
                user.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: user.isActive ? Colors.green : Colors.red,
              ),
              onPressed: () => _toggleUserActive(user),
              tooltip: user.isActive ? 'Deactivate' : 'Activate',
            ),
        ],
      ),
      onTap: () => _showUserDetails(user),
    );
  }
  
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: UserForm(
            onSave: (user, password) => _addUser(user, password),
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
  
  void _showEditUserDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: UserForm(
            user: user,
            onSave: (updatedUser, _) => _updateUser(updatedUser),
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
  
  void _showUserDetails(AppUser user) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider).value;
    final isCurrentUser = currentUser?.uid == user.uid;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundImage: user.photoURL != null 
                      ? NetworkImage(user.photoURL!) 
                      : null,
                  child: user.displayName != null && user.displayName!.isNotEmpty
                      ? Text(
                          user.displayName![0].toUpperCase(),
                          style: const TextStyle(fontSize: 24),
                        )
                      : const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName ?? 'No Name',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          if (isCurrentUser)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Roles',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.roles.map((role) {
                return Chip(
                  label: Text(role),
                  backgroundColor: theme.colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Status',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit User'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditUserDialog(user);
                  },
                ),
                if (!isCurrentUser) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: Icon(
                      user.isActive ? Icons.person_off : Icons.person,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    label: Text(
                      user.isActive ? 'Deactivate' : 'Activate',
                      style: TextStyle(
                        color: user.isActive ? Colors.red : Colors.green,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleUserActive(user);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // CRUD operations
  Future<void> _addUser(AppUser user, String password) async {
    try {
      final authService = ref.read(authServiceProvider);
      
      // Create user in Firebase Auth
      final userCredential = await authService.createUserWithEmailAndPassword(
        user.email,
        password,
      );
      
      // Get the user ID from the credential
      final uid = userCredential.user!.uid;
      
      // Create the user document in Firestore with additional data
      final userDoc = {
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'metadata': user.metadata,
        'roles': user.roles,
        'isActive': user.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance.collection('users').doc(uid).set(userDoc);
      
      // Close the dialog
      Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user: $e')),
        );
      }
    }
  }
  
  Future<void> _updateUser(AppUser user) async {
    try {
      // Update Firestore user document
      final userDoc = {
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'metadata': user.metadata,
        'roles': user.roles,
        'isActive': user.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(userDoc);
      
      // Close the dialog
      Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }
  }
  
  Future<void> _toggleUserActive(AppUser user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isActive': !user.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            user.isActive 
                ? 'User deactivated successfully' 
                : 'User activated successfully'
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling user status: $e')),
        );
      }
    }
  }
}

// Provider for all users stream
final usersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  return FirebaseFirestore.instance
    .collection('users')
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => AppUser.fromFirestore(doc))
      .toList());
});