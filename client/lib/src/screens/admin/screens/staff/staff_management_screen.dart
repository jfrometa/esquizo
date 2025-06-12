import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/staff/staff_kitchen_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/staff/staff_waiter_screen.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const StaffManagementScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const StaffKitchenScreen(),
    const StaffWaiterTableSelectScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(widget.initialIndex);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show the screen based on the initial index without internal navigation
    return _screens[widget.initialIndex.clamp(0, _screens.length - 1)];
  }
}
