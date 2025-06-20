import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/tabs/payment_overview_tab.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/tabs/payment_transactions_tab.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/tabs/payment_tips_tab.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/tabs/payment_taxes_tab.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/tabs/payment_service_tracking_tab.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';

class PaymentManagementScreen extends ConsumerStatefulWidget {
  final int initialTab;
  
  const PaymentManagementScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends ConsumerState<PaymentManagementScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab,
    );
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      body: Column(
        children: [
          // Header with search and date filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    if (isDesktop) ...[
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search payments, orders, or customers...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    OutlinedButton.icon(
                      onPressed: _selectDateRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        // Export functionality
                      },
                      icon: const Icon(Icons.download),
                      tooltip: 'Export Report',
                    ),
                  ],
                ),
                if (!isDesktop) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Tabs
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: !isDesktop,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Transactions'),
                Tab(text: 'Tips'),
                Tab(text: 'Taxes'),
                Tab(text: 'Service Tracking'),
              ],
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PaymentOverviewTab(
                  startDate: _startDate,
                  endDate: _endDate,
                  searchQuery: _searchQuery,
                ),
                PaymentTransactionsTab(
                  startDate: _startDate,
                  endDate: _endDate,
                  searchQuery: _searchQuery,
                ),
                PaymentTipsTab(
                  startDate: _startDate,
                  endDate: _endDate,
                  searchQuery: _searchQuery,
                ),
                PaymentTaxesTab(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
                // Service Tracking Tab
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text('Service Tracking Tab - Implementation pending'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
