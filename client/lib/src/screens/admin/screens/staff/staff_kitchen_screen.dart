import 'package:flutter/material.dart';

// Enum to manage kitchen tabs
enum KitchenTab { newOrders, current, upcoming, turns }

class StaffKitchenScreen extends StatefulWidget {
  final KitchenTab initialTab;
  const StaffKitchenScreen({super.key, this.initialTab = KitchenTab.newOrders});

  @override
  State<StaffKitchenScreen> createState() => _StaffKitchenScreenState();
}

class _StaffKitchenScreenState extends State<StaffKitchenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: KitchenTab.values.length,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // This AppBar will appear *below* the main AdminPanelScreen AppBar
        // If using ShellRoute, you might not need a Scaffold/AppBar here,
        // just the TabBar and TabBarView. Let's keep it for now.
        automaticallyImplyLeading:
            false, // No back button needed if part of shell
        title: const Text('Kitchen Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Allow scrolling if many tabs
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Current'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Turns'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('New Orders View - Placeholder')),
          Center(child: Text('Current Orders View - Placeholder')),
          Center(child: Text('Upcoming Orders View - Placeholder')),
          Center(child: Text('Order Turns/Sequence View - Placeholder')),
        ],
      ),
    );
  }
}
