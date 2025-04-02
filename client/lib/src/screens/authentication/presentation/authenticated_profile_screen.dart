import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/firebase_providers.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/location_management/locations_management_section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/profile/profile_edit_section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/theming_selection/theming_setting_section.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';

class AuthenticatedProfileScreen extends ConsumerStatefulWidget {
  final User user;

  const AuthenticatedProfileScreen({super.key, required this.user});

  @override
  _AuthenticatedProfileScreenState createState() =>
      _AuthenticatedProfileScreenState();
}

class _AuthenticatedProfileScreenState
    extends ConsumerState<AuthenticatedProfileScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  bool _isTabBarVisible = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with proper lifecycle management
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    // Debounce scroll direction changes
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isTabBarVisible) {
        setState(() => _isTabBarVisible = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isTabBarVisible) {
        setState(() => _isTabBarVisible = true);
      }
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    // Prevent multiple sign-out attempts
    if (_isSigningOut) return;

    setState(() => _isSigningOut = true);

    try {
      // Reset admin status in cache before signing out
      ref.read(cachedAdminStatusProvider.notifier).state = false;

      // Force refresh the admin provider
      ref.invalidate(isAdminProvider);

      // Sign out
      await ref.read(firebaseAuthProvider).signOut();

      // Safely navigate back to the first route
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Enhanced error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Error al cerrar sesión. Por favor, intente nuevamente.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      // Always reset the signing out state
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        forceMaterialTransparency: true,
        actions: [
          _buildSignOutButton(context),
        ],
      ),
      body: Column(
        children: [
          _buildUserInfo(context),
          Expanded(
            child: SettingsTabContent(user: widget.user),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return IconButton(
      icon: _isSigningOut
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
      onPressed: _isSigningOut ? null : () => _signOut(context, ref),
      tooltip: 'Cerrar Sesión',
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildProfileAvatar(),
            const SizedBox(width: Sizes.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.displayName ?? widget.user.email ?? 'Usuario',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: Sizes.p8),
                  Text(
                    widget.user.email ?? 'Correo no disponible',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // Show phone number if available
                  if (widget.user.phoneNumber != null) ...[
                    const SizedBox(height: Sizes.p4),
                    Text(
                      widget.user.phoneNumber!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final theme = Theme.of(context);
    return CircleAvatar(
      backgroundColor: theme.colorScheme.primary,
      radius: 40,
      child: widget.user.photoURL != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.user.photoURL!,
                fit: BoxFit.cover,
                width: 80,
                height: 80,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  size: 40,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Icon(Icons.person, size: 40, color: theme.colorScheme.onPrimary),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// A component for the Settings tab content
class SettingsTabContent extends ConsumerStatefulWidget {
  final User user;

  const SettingsTabContent({
    required this.user,
    super.key,
  });

  @override
  ConsumerState<SettingsTabContent> createState() => _SettingsTabContentState();
}

class _SettingsTabContentState extends ConsumerState<SettingsTabContent> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Profile Edit Section
        ProfileEditSection(user: widget.user),
        const SizedBox(height: 16),
        // Saved Locations Section
        LocationsSection(userId: widget.user.uid),
        const SizedBox(height: 16),
        // Theme Settings Section
        const ThemeSettingsSection(),
      ],
    );
  }
}

// TabIndicator class for consistent styling
class TabIndicator extends Decoration {
  final Color color;
  final double radius;

  const TabIndicator({
    required this.color,
    required this.radius,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TabIndicatorPainter(color: color, radius: radius);
  }
}

class _TabIndicatorPainter extends BoxPainter {
  final Color color;
  final double radius;

  _TabIndicatorPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }
}

// TabUtils for calculating tab width
class TabUtils {
  static double calculateMaxTabWidth({
    required BuildContext context,
    required List<String> tabTitles,
    double extraWidth = 48.0, // Extra padding
  }) {
    final textTheme = Theme.of(context).textTheme.titleSmall;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double maxWidth = 0;
    for (final title in tabTitles) {
      textPainter.text = TextSpan(
        text: title,
        style: textTheme,
      );
      textPainter.layout();
      maxWidth = maxWidth > textPainter.width ? maxWidth : textPainter.width;
    }

    return maxWidth + extraWidth;
  }
}
