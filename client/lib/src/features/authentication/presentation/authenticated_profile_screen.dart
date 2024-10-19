import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    extends ConsumerState<AuthenticatedProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isTabBarVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Hide TabBar when scrolling down
      if (_isTabBarVisible) setState(() => _isTabBarVisible = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // Show TabBar when scrolling up
      if (!_isTabBarVisible) setState(() => _isTabBarVisible = true);
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseAuthProvider).signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          forceMaterialTransparency: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () => _signOut(context, ref),
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildUserInfo(context),
            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 300), // Smoother transition
              curve: Curves.easeInOut, // Smooth curve for better animation
              height: _isTabBarVisible
                  ? 56.0
                  : 0.0, // Increased height for better spacing
              child: _isTabBarVisible
                  ? Material(
                      elevation:
                          4.0, // Slight elevation to provide depth and shadow
                      shadowColor:
                          ColorsPaletteRedonda.deepBrown1, // Subtle shadow
                      child: TabBar(
                        dividerColor:
                            Colors.transparent, // No divider between tabs
                        indicatorColor: ColorsPaletteRedonda
                            .primary, // Your provided primary color
                        isScrollable: true,
                        labelStyle:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight
                                      .w600, // Material 3 recommended weight for labels
                                ),
                        unselectedLabelStyle:
                            Theme.of(context).textTheme.titleSmall,

                        labelColor: ColorsPaletteRedonda
                            .white, // Selected tab label color
                        unselectedLabelColor: ColorsPaletteRedonda
                            .deepBrown1, // Unselected tab label color
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: TabIndicator(
                          color: ColorsPaletteRedonda
                              .primary, // Background color for selected tab
                          radius: 16.0, // Smooth rounded corners for M3 design
                        ),
                        tabs: const [
                          Tab(text: 'Mis Subscripciones'),
                          Tab(text: 'Historial de Ordenes'),
                        ],
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildScrollableContent(const SubscriptionsList()),
                  _buildScrollableContent(const OrderHistoryList()),
                ],
              ),
            ),
          ],
        ),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p8),
          child: child,
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: ColorsPaletteRedonda.primary,
            radius: 40,
            backgroundImage: widget.user.photoURL != null
                ? NetworkImage(widget.user.photoURL!)
                : null,
            child: widget.user.photoURL == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
        ),
        const SizedBox(width: Sizes.p16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.displayName ?? widget.user.email ?? 'User',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Sizes.p8),
              Text(
                widget.user.email ?? 'No email available',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
