// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart'; 
// import 'package:path_provider/path_provider.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/services/meal_plan_service.dart'; 
 
// import 'dart:io';

// import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart'; 

// // Date range provider for exports
// final exportDateRangeProvider = StateProvider<DateTimeRange>((ref) {
//   final now = DateTime.now();
//   return DateTimeRange(
//     start: DateTime(now.year, now.month - 1, now.day),
//     end: now,
//   );
// });

// // Report type
// enum ReportType {
//   mealPlans,
//   mealUsage,
//   customerUsage
// }

// // Provider for loading data for reports
// final reportDataProvider = FutureProvider.family<List<dynamic>, ReportType>((ref, reportType) async {
//   final service = ref.watch(mealPlanServiceProvider);
//   final dateRange = ref.watch(exportDateRangeProvider);
  
//   switch (reportType) {
//     case ReportType.mealPlans:
//       // Get all meal plans
//       final allPlans = await service.getMealPlansStream().first;
//       return allPlans;
      
//     case ReportType.mealUsage:
//       // Get all consumed items within date range
//       final allPlans = await service.getMealPlansStream().first;
      
//       final allConsumedItems = <ConsumedItem>[];
//       for (final plan in allPlans) {
//         final items = await service.getConsumedItemsStream(plan.id).first;
//         allConsumedItems.addAll(items);
//       }
      
//       // Filter by date range
//       return allConsumedItems.where((item) {
//         return item.consumedAt.isAfter(dateRange.start) && 
//                item.consumedAt.isBefore(dateRange.end.add(const Duration(days: 1)));
//       }).toList();
      
//     case ReportType.customerUsage:
//       // Get all meal plans
//       final allPlans = await service.getMealPlanItemsStream().first;
      
//       // Group by customer
//       final customerUsage = <String, List<MealPlan>>{};
      
//       for (final plan in allPlans) {
//         if (plan.ownerId.isEmpty) continue; // Skip plans without owner
        
//         if (!customerUsage.containsKey(plan.ownerId)) {
//           customerUsage[plan.ownerId] = [];
//         }
        
//         customerUsage[plan.ownerId]!.add(plan);
//       }
      
//       // Convert to list
//       final result = <Map<String, dynamic>>[];
      
//       for (final entry in customerUsage.entries) {
//         final customerId = entry.key;
//         final plans = entry.value;
        
//         final customerName = plans.first.ownerName;
//         double totalMeals = 0;
//         double usedMeals = 0;
//         double totalValue = 0;
        
//         for (final plan in plans) {
//           totalMeals += plan.totalMeals;
//           usedMeals += plan.totalMeals - plan.mealsRemaining;
//           totalValue += double.tryParse(plan.price) ?? 0.0;
//         }
        
//         result.add({
//           'customerId': customerId,
//           'customerName': customerName,
//           'totalPlans': plans.length,
//           'totalMeals': totalMeals,
//           'usedMeals': usedMeals,
//           'remainingMeals': totalMeals - usedMeals,
//           'totalValue': totalValue,
//         });
//       }
      
//       return result;
//   }
// });

// class MealPlanExportScreen extends ConsumerStatefulWidget {
//   const MealPlanExportScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<MealPlanExportScreen> createState() => _MealPlanExportScreenState();
// }

// class _MealPlanExportScreenState extends ConsumerState<MealPlanExportScreen> {
//   ReportType _selectedReportType = ReportType.mealPlans;
//   String _exportFormat = 'CSV';
//   bool _isExporting = false;
//   String? _exportError;
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final dateRange = ref.watch(exportDateRangeProvider);
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Export Reports'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Report configuration card
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Report Configuration',
//                       style: theme.textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Report type
//                     Text(
//                       'Report Type',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),
//                     SegmentedButton<ReportType>(
//                       segments: const [
//                         ButtonSegment(
//                           value: ReportType.mealPlans,
//                           label: Text('Meal Plans'),
//                           icon: Icon(Icons.assignment),
//                         ),
//                         ButtonSegment(
//                           value: ReportType.mealUsage,
//                           label: Text('Usage'),
//                           icon: Icon(Icons.restaurant),
//                         ),
//                         ButtonSegment(
//                           value: ReportType.customerUsage,
//                           label: Text('Customer'),
//                           icon: Icon(Icons.people),
//                         ),
//                       ],
//                       selected: {_selectedReportType},
//                       onSelectionChanged: (newSelection) {
//                         setState(() {
//                           _selectedReportType = newSelection.first;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Date range
//                     Text(
//                       'Date Range',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextButton.icon(
//                             icon: const Icon(Icons.calendar_today, size: 16),
//                             label: Text(
//                               '${DateFormat.yMMMd().format(dateRange.start)} - ${DateFormat.yMMMd().format(dateRange.end)}',
//                             ),
//                             onPressed: () => _selectDateRange(context),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Export format
//                     Text(
//                       'Format',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),
//                     SegmentedButton<String>(
//                       segments: const [
//                         ButtonSegment(
//                           value: 'CSV',
//                           label: Text('CSV'),
//                           icon: Icon(Icons.table_chart),
//                         ),
//                         ButtonSegment(
//                           value: 'PDF',
//                           label: Text('PDF'),
//                           icon: Icon(Icons.picture_as_pdf),
//                         ),
//                       ],
//                       selected: {_exportFormat},
//                       onSelectionChanged: (newSelection) {
//                         setState(() {
//                           _exportFormat = newSelection.first;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Report preview
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Report Preview',
//                       style: theme.textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildReportPreview(),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Export button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: _isExporting
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.download),
//                 label: Text(_isExporting ? 'Exporting...' : 'Export Report'),
//                 onPressed: _isExporting ? null : _exportReport,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.all(16),
//                 ),
//               ),
//             ),
            
//             if (_exportError != null) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.error.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: theme.colorScheme.error,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.error,
//                       color: theme.colorScheme.error,
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Text(
//                         _exportError!,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.error,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildReportPreview() {
//     final reportDataAsync = ref.watch(reportDataProvider(_selectedReportType));
    
//     return reportDataAsync.when(
//       data: (data) {
//         if (data.isEmpty) {
//           return const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Center(
//               child: Text('No data available for the selected date range.'),
//             ),
//           );
//         }
        
//         switch (_selectedReportType) {
//           case ReportType.mealPlans:
//             return _buildMealPlansPreview(data.cast<MealPlan>());
//           case ReportType.mealUsage:
//             return _buildMealUsagePreview(data.cast<ConsumedItem>());
//           case ReportType.customerUsage:
//             return _buildCustomerUsagePreview(data.cast<Map<String, dynamic>>());
//         }
//       },
//       loading: () => const Center(
//         child: CircularProgressIndicator(),
//       ),
//       error: (error, _) => Center(
//         child: Text('Error: $error'),
//       ),
//     );
//   }
  
//   Widget _buildMealPlansPreview(List<MealPlan> plans) {
//     return SizedBox(
//       height: 300,
//       child: ListView.builder(
//         itemCount: plans.length > 5 ? 5 : plans.length,
//         itemBuilder: (context, index) {
//           final plan = plans[index];
          
//           return ListTile(
//             title: Text(plan.title),
//             subtitle: Text(
//               'Owner: ${plan.ownerName.isNotEmpty ? plan.ownerName : "N/A"} • ' +
//               'Meals: ${plan.mealsRemaining}/${plan.totalMeals}'
//             ),
//             trailing: Text('\$${plan.price}'),
//           );
//         },
//       ),
//     );
//   }
  
//   Widget _buildMealUsagePreview(List<ConsumedItem> items) {
//     return SizedBox(
//       height: 300,
//       child: ListView.builder(
//         itemCount: items.length > 5 ? 5 : items.length,
//         itemBuilder: (context, index) {
//           final item = items[index];
          
//           return ListTile(
//             title: Text(item.itemName),
//             subtitle: Text(
//               'Date: ${DateFormat.yMMMd().add_jm().format(item.consumedAt)}' +
//               (item.notes.isNotEmpty ? ' • Notes: ${item.notes}' : '')
//             ),
//             trailing: Text('Plan ID: ${item.mealPlanId.substring(0, 6)}...'),
//           );
//         },
//       ),
//     );
//   }
  
//   Widget _buildCustomerUsagePreview(List<Map<String, dynamic>> customerData) {
//     return SizedBox(
//       height: 300,
//       child: ListView.builder(
//         itemCount: customerData.length > 5 ? 5 : customerData.length,
//         itemBuilder: (context, index) {
//           final customer = customerData[index];
          
//           return ListTile(
//             title: Text(customer['customerName'] ?? 'Unknown'),
//             subtitle: Text(
//               'Plans: ${customer['totalPlans']} • ' +
//               'Meals: ${customer['usedMeals']}/${customer['totalMeals']}'
//             ),
//             trailing: Text('\$${customer['totalValue'].toStringAsFixed(2)}'),
//           );
//         },
//       ),
//     );
//   }
  
//   Future<void> _selectDateRange(BuildContext context) async {
//     final currentRange = ref.read(exportDateRangeProvider);
    
//     final newRange = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       initialDateRange: currentRange,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: Theme.of(context).colorScheme.copyWith(
//               primary: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
    
//     if (newRange != null) {
//       ref.read(exportDateRangeProvider.notifier).state = newRange;
//     }
//   }
  
//   Future<void> _exportReport() async {
//     setState(() {
//       _isExporting = true;
//       _exportError = null;
//     });
    
//     try {
//       final reportData = await ref.read(reportDataProvider(_selectedReportType).future);
      
//       if (reportData.isEmpty) {
//         throw Exception('No data to export');
//       }
      
//       switch (_exportFormat) {
//         case 'CSV':
//           await _exportToCsv(reportData);
//           break;
//         case 'PDF':
//           await _exportToPdf(reportData);
//           break;
//       }
//     } catch (e) {
//       setState(() {
//         _exportError = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isExporting = false;
//       });
//     }
//   }
  
//   Future<void> _exportToCsv(List<dynamic> data) async {
//     // Generate CSV data
//     List<List<dynamic>> csvData = [];
    
//     // Add headers
//     switch (_selectedReportType) {
//       case ReportType.mealPlans:
//         csvData.add([
//           'ID',
//           'Title',
//           'Owner',
//           'Owner ID',
//           'Price',
//           'Total Meals',
//           'Meals Remaining',
//           'Category',
//           'Is Available',
//           'Status',
//           'Created Date',
//           'Expiry Date',
//         ]);
        
//         // Add rows
//         for (final plan in data.cast<MealPlan>()) {
//           csvData.add([
//             plan.id,
//             plan.title,
//             plan.ownerName,
//             plan.ownerId,
//             plan.price,
//             plan.totalMeals,
//             plan.mealsRemaining,
//             plan.categoryName,
//             plan.isAvailable ? 'Yes' : 'No',
//             plan.status.name,
//             DateFormat.yMMMd().format(plan.createdAt),
//             plan.expiryDate != null ? DateFormat.yMMMd().format(plan.expiryDate!) : 'N/A',
//           ]);
//         }
//         break;
        
//       case ReportType.mealUsage:
//         csvData.add([
//           'ID',
//           'Meal Plan ID',
//           'Item Name',
//           'Item ID',
//           'Consumed Date',
//           'Consumed By',
//           'Notes',
//         ]);
        
//         // Add rows
//         for (final item in data.cast<ConsumedItem>()) {
//           csvData.add([
//             item.id,
//             item.mealPlanId,
//             item.itemName,
//             item.itemId,
//             DateFormat.yMMMd().add_jm().format(item.consumedAt),
//             item.consumedBy,
//             item.notes,
//           ]);
//         }
//         break;
        
//       case ReportType.customerUsage:
//         csvData.add([
//           'Customer ID',
//           'Customer Name',
//           'Total Plans',
//           'Total Meals',
//           'Used Meals',
//           'Remaining Meals',
//           'Total Value',
//         ]);
        
//         // Add rows
//         for (final customer in data.cast<Map<String, dynamic>>()) {
//           csvData.add([
//             customer['customerId'],
//             customer['customerName'],
//             customer['totalPlans'],
//             customer['totalMeals'],
//             customer['usedMeals'],
//             customer['remainingMeals'],
//             customer['totalValue'],
//           ]);
//         }
//         break;
//     }
    
//     // Generate CSV string
//     final csvString = const ListToCsvConverter().convert(csvData);
    
//     // Save to temp file
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/${_getReportFileName()}.csv');
//     await file.writeAsString(csvString);
    
//     // Share the file
//     await Share.shareXFiles([XFile(file.path)], subject: _getReportFileName());
//   }
  
//   Future<void> _exportToPdf(List<dynamic> data) async {
//     // Create a PDF document
//     final pdf = pw.Document();
    
//     // Add page with title and date
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         header: (context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(
//               _getReportTitle(),
//               style: const pw.TextStyle(
//                 fontSize: 20,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//             pw.SizedBox(height: 8),
//             pw.Text(
//               'Generated on ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
//               style: const pw.TextStyle(
//                 fontSize: 12,
//                 fontStyle: pw.FontStyle.italic,
//               ),
//             ),
//             pw.SizedBox(height: 8),
//             pw.Divider(),
//           ],
//         ),
//         footer: (context) => pw.Column(
//           children: [
//             pw.Divider(),
//             pw.SizedBox(height: 4),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text(
//                   'Restaurant Name',
//                   style: const pw.TextStyle(fontSize: 10),
//                 ),
//                 pw.Text(
//                   'Page ${context.pageNumber} of ${context.pagesCount}',
//                   style: const pw.TextStyle(fontSize: 10),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         build: (context) {
//           final widgets = <pw.Widget>[];
          
//           // Add report content
//           switch (_selectedReportType) {
//             case ReportType.mealPlans:
//               final plans = data.cast<MealPlan>();
              
//               // Add summary
//               widgets.add(
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(16),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey200,
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                     children: [
//                       _pdfSummaryItem('Total Plans', plans.length.toString()),
//                       _pdfSummaryItem(
//                         'Active Plans',
//                         plans.where((p) => p.isActive).length.toString(),
//                       ),
//                       _pdfSummaryItem(
//                         'Total Value',
//                         '\$${plans.fold(0.0, (sum, plan) => sum + double.parse(plan.price)).toStringAsFixed(2)}',
//                       ),
//                     ],
//                   ),
//                 ),
//               );
              
//               widgets.add(pw.SizedBox(height: 16));
              
//               // Add table
//               widgets.add(
//                 pw.Table.fromTextArray(
//                   border: null,
//                   headers: [
//                     'Title',
//                     'Owner',
//                     'Price',
//                     'Meals',
//                     'Remaining',
//                     'Status',
//                   ],
//                   data: plans.map((plan) => [
//                     plan.title,
//                     plan.ownerName.isNotEmpty ? plan.ownerName : 'N/A',
//                     '\$${plan.price}',
//                     plan.totalMeals.toString(),
//                     plan.mealsRemaining.toString(),
//                     plan.status.name,
//                   ]).toList(),
//                   headerStyle: pw.TextStyle(
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.white,
//                   ),
//                   headerDecoration: const pw.BoxDecoration(
//                     color: PdfColors.blueAccent,
//                   ),
//                   rowDecoration: const pw.BoxDecoration(
//                     border: pw.Border(
//                       bottom: pw.BorderSide(
//                         color: PdfColors.grey300,
//                         width: 0.5,
//                       ),
//                     ),
//                   ),
//                   cellAlignment: pw.Alignment.center,
//                   cellPadding: const pw.EdgeInsets.all(8),
//                 ),
//               );
//               break;
              
//             case ReportType.mealUsage:
//               final items = data.cast<ConsumedItem>();
              
//               // Calculate statistics
//               final itemCounts = <String, int>{};
//               for (final item in items) {
//                 itemCounts[item.itemName] = (itemCounts[item.itemName] ?? 0) + 1;
//               }
              
//               final topItems = itemCounts.entries.toList()
//                 ..sort((a, b) => b.value.compareTo(a.value));
              
//               final dateRange = ref.read(exportDateRangeProvider);
              
//               // Add summary
//               widgets.add(
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(16),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey200,
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'Date Range: ${DateFormat.yMMMd().format(dateRange.start)} - ${DateFormat.yMMMd().format(dateRange.end)}',
//                         style: const pw.TextStyle(
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.SizedBox(height: 8),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                         children: [
//                           _pdfSummaryItem('Total Items Used', items.length.toString()),
//                           _pdfSummaryItem(
//                             'Most Popular Item',
//                             topItems.isNotEmpty ? topItems.first.key : 'N/A',
//                           ),
//                           _pdfSummaryItem(
//                             'Unique Items',
//                             itemCounts.length.toString(),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
              
//               widgets.add(pw.SizedBox(height: 16));
              
//               // Add popular items chart
//               if (topItems.isNotEmpty) {
//                 widgets.add(
//                   pw.Text(
//                     'Most Popular Items',
//                     style: pw.TextStyle(
//                       fontSize: 16,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 );
                
//                 widgets.add(pw.SizedBox(height: 8));
                
//                 // Show top 5 items
//                 final displayItems = topItems.take(5).toList();
                
//                 widgets.add(
//                   pw.Table.fromTextArray(
//                     border: null,
//                     headers: ['Item', 'Count'],
//                     data: displayItems.map((entry) => [
//                       entry.key,
//                       entry.value.toString(),
//                     ]).toList(),
//                     headerStyle: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.white,
//                     ),
//                     headerDecoration: const pw.BoxDecoration(
//                       color: PdfColors.blueAccent,
//                     ),
//                     rowDecoration: const pw.BoxDecoration(
//                       border: pw.Border(
//                         bottom: pw.BorderSide(
//                           color: PdfColors.grey300,
//                           width: 0.5,
//                         ),
//                       ),
//                     ),
//                     cellAlignment: pw.Alignment.center,
//                     cellPadding: const pw.EdgeInsets.all(8),
//                   ),
//                 );
                
//                 widgets.add(pw.SizedBox(height: 16));
//               }
              
//               // Add table of usage
//               widgets.add(
//                 pw.Text(
//                   'Usage Details',
//                   style: pw.TextStyle(
//                     fontSize: 16,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               );
              
//               widgets.add(pw.SizedBox(height: 8));
              
//               widgets.add(
//                 pw.Table.fromTextArray(
//                   border: null,
//                   headers: [
//                     'Date',
//                     'Item',
//                     'Plan ID',
//                     'User',
//                   ],
//                   data: items.map((item) => [
//                     DateFormat.yMMMd().format(item.consumedAt),
//                     item.itemName,
//                     item.mealPlanId.substring(0, 6),
//                     item.consumedBy.isNotEmpty ? item.consumedBy : 'N/A',
//                   ]).toList(),
//                   headerStyle: pw.TextStyle(
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.white,
//                   ),
//                   headerDecoration: const pw.BoxDecoration(
//                     color: PdfColors.blueAccent,
//                   ),
//                   rowDecoration: const pw.BoxDecoration(
//                     border: pw.Border(
//                       bottom: pw.BorderSide(
//                         color: PdfColors.grey300,
//                         width: 0.5,
//                       ),
//                     ),
//                   ),
//                   cellAlignment: pw.Alignment.center,
//                   cellPadding: const pw.EdgeInsets.all(8),
//                 ),
//               );
//               break;
              
//             case ReportType.customerUsage:
//               final customers = data.cast<Map<String, dynamic>>();
              
//               // Sort by total meals
//               customers.sort((a, b) => (b['totalMeals'] as int).compareTo(a['totalMeals'] as int));
              
//               // Calculate totals
//               final totalCustomers = customers.length;
//               final totalPlans = customers.fold(0, (sum, customer) => sum + (customer['totalPlans'] as int));
//               final totalMeals = customers.fold(0, (sum, customer) => sum + (customer['totalMeals'] as int));
//               final totalValue = customers.fold(0.0, (sum, customer) => sum + (customer['totalValue'] as double));
              
//               // Add summary
//               widgets.add(
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(16),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey200,
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'Customer Usage Summary',
//                         style: const pw.TextStyle(
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.SizedBox(height: 8),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                         children: [
//                           _pdfSummaryItem('Total Customers', totalCustomers.toString()),
//                           _pdfSummaryItem('Total Plans', totalPlans.toString()),
//                           _pdfSummaryItem('Total Meals', totalMeals.toString()),
//                           _pdfSummaryItem('Total Value', '\$${totalValue.toStringAsFixed(2)}'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
              
//               widgets.add(pw.SizedBox(height: 16));
              
//               // Add table
//               widgets.add(
//                 pw.Table.fromTextArray(
//                   border: null,
//                   headers: [
//                     'Customer',
//                     'Plans',
//                     'Total Meals',
//                     'Used',
//                     'Remaining',
//                     'Value',
//                   ],
//                   data: customers.map((customer) => [
//                     customer['customerName'] ?? 'Unknown',
//                     customer['totalPlans'].toString(),
//                     customer['totalMeals'].toString(),
//                     customer['usedMeals'].toString(),
//                     customer['remainingMeals'].toString(),
//                     '\$${(customer['totalValue'] as double).toStringAsFixed(2)}',
//                   ]).toList(),
//                   headerStyle: pw.TextStyle(
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.white,
//                   ),
//                   headerDecoration: const pw.BoxDecoration(
//                     color: PdfColors.blueAccent,
//                   ),
//                   rowDecoration: const pw.BoxDecoration(
//                     border: pw.Border(
//                       bottom: pw.BorderSide(
//                         color: PdfColors.grey300,
//                         width: 0.5,
//                       ),
//                     ),
//                   ),
//                   cellAlignment: pw.Alignment.center,
//                   cellPadding: const pw.EdgeInsets.all(8),
//                 ),
//               );
//               break;
//           }
          
//           return widgets;
//         },
//       ),
//     );
    
//     // Save to temp file
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/${_getReportFileName()}.pdf');
//     await file.writeAsBytes(await pdf.save());
    
//     // Share the file
//     await Share.shareXFiles([XFile(file.path)], subject: _getReportFileName());
//   }
  
//   pw.Widget _pdfSummaryItem(String label, String value) {
//     return pw.Column(
//       children: [
//         pw.Text(
//           value,
//           style: pw.TextStyle(
//             fontSize: 16,
//             fontWeight: pw.FontWeight.bold,
//           ),
//         ),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           label,
//           style: const pw.TextStyle(
//             fontSize: 10,
//           ),
//         ),
//       ],
//     );
//   }
  
//   String _getReportTitle() {
//     switch (_selectedReportType) {
//       case ReportType.mealPlans:
//         return 'Meal Plans Report';
//       case ReportType.mealUsage:
//         return 'Meal Usage Report';
//       case ReportType.customerUsage:
//         return 'Customer Usage Report';
//     }
//   }
  
//   String _getReportFileName() {
//     final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    
//     switch (_selectedReportType) {
//       case ReportType.mealPlans:
//         return 'meal_plans_report_$dateStr';
//       case ReportType.mealUsage:
//         return 'meal_usage_report_$dateStr';
//       case ReportType.customerUsage:
//         return 'customer_usage_report_$dateStr';
//     }
//   }
// }