import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/analytics_screen.dart'; 

class CategoryBreakdownChart extends StatefulWidget {
  final List<CategoryDataPoint> categoryData;
  
  const CategoryBreakdownChart({
    Key? key,
    required this.categoryData,
  }) : super(key: key);

  @override
  State<CategoryBreakdownChart> createState() => _CategoryBreakdownChartState();
}

class _CategoryBreakdownChartState extends State<CategoryBreakdownChart> {
  int _touchedIndex = -1;
  bool _showRevenue = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Revenue/Orders toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Revenue'),
                  icon: Icon(Icons.attach_money),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Orders'),
                  icon: Icon(Icons.shopping_cart),
                ),
              ],
              selected: {_showRevenue},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showRevenue = selection.first;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Chart and legend
        Expanded(
          child: Row(
            children: [
              // Pie chart
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _showRevenue
                        ? _generateRevenueSections()
                        : _generateOrdersSections(),
                  ),
                ),
              ),
              
              // Legend
              Expanded(
                flex: 2,
                child: _buildLegend(),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  List<PieChartSectionData> _generateRevenueSections() {
    double total = widget.categoryData.fold(0, (sum, item) => sum + item.sales);
    
    return widget.categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;
      final percentage = (data.sales / total * 100).roundToDouble();
      
      return PieChartSectionData(
        color: data.color,
        value: data.sales,
        title: '$percentage%',
        radius: isTouched ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched
            ? const Icon(
                Icons.attach_money,
                color: Colors.white,
                size: 18,
              )
            : null,
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();
  }
  
  List<PieChartSectionData> _generateOrdersSections() {
    int total = widget.categoryData.fold(0, (sum, item) => sum + item.orders);
    
    return widget.categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;
      final percentage = (data.orders / total * 100).roundToDouble();
      
      return PieChartSectionData(
        color: data.color,
        value: data.orders.toDouble(),
        title: '$percentage%',
        radius: isTouched ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched
            ? const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 18,
              )
            : null,
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();
  }
  
  Widget _buildLegend() {
    if (widget.categoryData.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    // Sort data by sales or orders, depending on what's showing
    final sortedData = List<CategoryDataPoint>.from(widget.categoryData);
    if (_showRevenue) {
      sortedData.sort((a, b) => b.sales.compareTo(a.sales));
    } else {
      sortedData.sort((a, b) => b.orders.compareTo(a.orders));
    }
    
    // Calculate totals for percentages
    double totalSales = widget.categoryData.fold(0, (sum, item) => sum + item.sales);
    int totalOrders = widget.categoryData.fold(0, (sum, item) => sum + item.orders);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedData.map((data) {
          final isTouched = sortedData.indexOf(data) == _touchedIndex;
          final percentage = _showRevenue
              ? (data.sales / totalSales * 100).toStringAsFixed(1)
              : (data.orders / totalOrders * 100).toStringAsFixed(1);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: isTouched
                    ? data.color.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: data.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.category,
                      style: TextStyle(
                        fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _showRevenue
                        ? '\$${data.sales.toStringAsFixed(0)}'
                        : '${data.orders}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($percentage%)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}