import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/location_management/locations_management_section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/profile/profile_edit_section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/theming_selection/theming_setting_section.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';

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

  Future<void> _signOut() async {
    // Prevent multiple sign-out attempts
    if (_isSigningOut) return;

    setState(() => _isSigningOut = true);

    try {
      // Reset admin status in cache before signing out
      ref.read(cachedAdminStatusProvider.notifier).updateStatus(false);

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            forceMaterialTransparency: false,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: BackButton(color: colorScheme.onSurface),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isTabBarVisible ? 0.0 : 1.0,
                child: Text(
                  'Mi Perfil',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              background: _buildPremiumHeader(context),
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground,
              ],
            ),
            actions: [
              _buildSignOutButton(context),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profile Edit Section
                  ProfileEditSection(user: widget.user),
                  const SizedBox(height: 16),

                  // Saved Locations Section
                  LocationsSection(userId: widget.user.uid),
                  const SizedBox(height: 16),

                  // Theme Settings Section
                  const ThemeSettingsSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.8),
            colorScheme.secondaryContainer.withValues(alpha: 0.5),
            colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle decorative elements
          Positioned(
            right: -60,
            top: -20,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 40,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: colorScheme.secondary.withValues(alpha: 0.05),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'profile_avatar',
                  child: _buildProfileAvatar(),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.displayName ?? widget.user.email ?? 'Usuario',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.user.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (widget.user.phoneNumber != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        widget.user.phoneNumber!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: _isSigningOut
          ? const Center(
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2)))
          : IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 20,
                ),
              ),
              onPressed: _signOut,
              tooltip: 'Cerrar Sesión',
            ),
    );
  }

  Widget _buildProfileAvatar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.surface,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: colorScheme.primary,
        radius: 48,
        child: widget.user.photoURL != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.user.photoURL!,
                  fit: BoxFit.cover,
                  width: 96,
                  height: 96,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 48,
                    color: colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(Icons.person, size: 48, color: colorScheme.onPrimary),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
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
