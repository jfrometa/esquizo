import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/order_history_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/subscription_list_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

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
  late final TabController _tabController;

  bool _isTabBarVisible = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with proper lifecycle management
    _scrollController = ScrollController()..addListener(_scrollListener);

    _tabController = TabController(length: 2, vsync: this);
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
      await ref.read(firebaseAuthProvider).signOut();

      // Safely navigate back to the first route
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      // Enhanced error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Error al cerrar sesión. Por favor, intente nuevamente.'),
          backgroundColor: Colors.redAccent.shade100,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Always reset the signing out state
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const tabTitles = [
      'Mis Subscripciones',
      'Historial de Ordenes',
    ];

    // Precompute max tab width for consistency
    final double maxTabWidth = TabUtils.calculateMaxTabWidth(
      context: context,
      tabTitles: tabTitles,
      extraWidth: 10.0,
    );

    return DefaultTabController(
      length: tabTitles.length,
      child: Scaffold(
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
            _buildAnimatedTabBar(context, tabTitles, maxTabWidth),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const SubscriptionsList(),
                  const OrderHistoryList(),
                ],
              ),
            ),
          ],
        ),
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
          : const Icon(Icons.logout, color: Colors.redAccent),
      onPressed: _isSigningOut ? null : () => _signOut(context, ref),
      tooltip: 'Cerrar Sesión',
    );
  }

  Widget _buildAnimatedTabBar(
      BuildContext context, List<String> tabTitles, double maxTabWidth) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isTabBarVisible ? 56.0 : 0.0,
      child: _isTabBarVisible
          ? Material(
              color: ColorsPaletteRedonda.background,
              elevation: 1,
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorColor: ColorsPaletteRedonda.primary,
                isScrollable: true,
                labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
                labelColor: ColorsPaletteRedonda.white,
                unselectedLabelColor: ColorsPaletteRedonda.primary1,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: TabIndicator(
                  color: ColorsPaletteRedonda.primary,
                  radius: 16.0,
                ),
                tabs: tabTitles.map((title) {
                  return Container(
                    width: maxTabWidth,
                    alignment: Alignment.center,
                    child: Tab(text: title),
                  );
                }).toList(),
              ),
            )
          : null,
    );
  }

  Widget _buildScrollableContent(Widget child) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          _scrollListener();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p8),
          child: child,
        ),
      ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      backgroundColor: ColorsPaletteRedonda.primary,
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
                errorWidget: (context, url, error) => const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            )
          : const Icon(Icons.person, size: 40, color: Colors.white),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
