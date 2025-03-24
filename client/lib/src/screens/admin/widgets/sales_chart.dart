import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/analytics_screen.dart'; 

class SalesChart extends StatefulWidget {
  final List<SalesDataPoint> salesData;
  final DateFormat dateFormat;

  const SalesChart({
    super.key,
    required this.salesData,
    required this.dateFormat,
  });

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> {
  bool _showSales = true;
  bool _showOrders = true;
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legend and toggles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Legend
                Row(
                  children: [
                    _buildLegendItem(
                      color: theme.colorScheme.primary,
                      label: 'Sales (\$)',
                      isActive: _showSales,
                      onTap: () {
                        setState(() {
                          _showSales = !_showSales;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      color: theme.colorScheme.tertiary,
                      label: 'Orders',
                      isActive: _showOrders,
                      onTap: () {
                        setState(() {
                          _showOrders = !_showOrders;
                        });
                      },
                    ),
                  ],
                ),
                
                // Chart type toggle - could expand this to switch between line and bar
                IconButton(
                  icon: const Icon(Icons.auto_graph),
                  onPressed: () {
                    // Toggle chart type if needed
                  },
                  tooltip: 'Change chart type',
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Chart
            Expanded(
              child: _buildChart(theme),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? null : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChart(ThemeData theme) {
    if (widget.salesData.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }
    
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData( 
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final dataIndex = spot.x.toInt();
                if (dataIndex >= 0 && dataIndex < widget.salesData.length) {
                  final data = widget.salesData[dataIndex];
                  
                  String text;
                  if (spot.barIndex == 0) {
                    text = '\$${data.sales.toStringAsFixed(2)}';
                  } else {
                    text = '${data.orders} orders';
                  }
                  
                  return LineTooltipItem(
                    text,
                    TextStyle(
                      color: spot.barIndex == 0 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
          touchCallback: (event, touchResponse) {
            if (touchResponse != null) {
              if (event is FlPanEndEvent || event is FlTapUpEvent) {
                setState(() {
                  _touchedIndex = -1;
                });
              } else if (touchResponse.lineBarSpots != null && 
                  touchResponse.lineBarSpots!.isNotEmpty) {
                setState(() {
                  _touchedIndex = touchResponse.lineBarSpots![0].x.toInt();
                });
              }
            }
          },
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _calculateXAxisInterval(),
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= widget.salesData.length) {
                  return const SizedBox.shrink();
                }
                
                final dataPoint = widget.salesData[value.toInt()];
                final date = widget.dateFormat.format(dataPoint.date);
                
                return SideTitleWidget( 
                  meta: meta,
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: _touchedIndex == value.toInt() 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget( 
                  meta: meta,
                  child: Text(
                    '\$${value.toInt()}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: theme.colorScheme.tertiary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.4),
              width: 1,
            ),
            left: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.4),
              width: 1,
            ),
            right: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.4),
              width: 1,
            ),
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.4),
              width: 1,
            ),
          ),
        ),
        lineBarsData: [
          // Sales line
          if (_showSales)
            LineChartBarData(
              spots: _getSalesSpots(),
              isCurved: true,
              barWidth: 3,
              color: theme.colorScheme.primary,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: _touchedIndex != -1,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: _touchedIndex == index ? 6 : 4,
                    color: theme.colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
          
          // Orders line
          if (_showOrders)
            LineChartBarData(
              spots: _getOrdersSpots(),
              isCurved: true,
              barWidth: 3,
              color: theme.colorScheme.tertiary,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: _touchedIndex != -1,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: _touchedIndex == index ? 6 : 4,
                    color: theme.colorScheme.tertiary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.tertiary.withOpacity(0.1),
              ),
            ),
        ],
        minX: 0,
        maxX: widget.salesData.length.toDouble() - 1,
        minY: 0,
        maxY: _calculateMaxY(),
      ),
      // swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }
  
  List<FlSpot> _getSalesSpots() {
    final maxSales = widget.salesData.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
    
    return widget.salesData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final dataPoint = entry.value;
      return FlSpot(index, dataPoint.sales);
    }).toList();
  }
  
  List<FlSpot> _getOrdersSpots() {
    final maxSales = widget.salesData.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
    final maxOrders = widget.salesData.map((e) => e.orders).reduce((a, b) => a > b ? a : b);
    
    // Scale orders to fit on the same chart as sales
    final scaleFactor = maxSales / maxOrders;
    
    return widget.salesData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final dataPoint = entry.value;
      // Scale orders to match the sales scale
      return FlSpot(index, dataPoint.orders.toDouble() * scaleFactor);
    }).toList();
  }
  
  double _calculateMaxY() {
    if (widget.salesData.isEmpty) return 1000;
    
    final maxSales = widget.salesData.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
    // Add a 10% buffer
    return maxSales * 1.1;
  }
  
  double _calculateXAxisInterval() {
    final length = widget.salesData.length;
    
    if (length <= 7) {
      return 1; // Show every day for a week or less
    } else if (length <= 14) {
      return 2; // Show every other day for two weeks
    } else if (length <= 31) {
      return 7; // Show weekly for a month
    } else if (length <= 90) {
      return 14; // Show bi-weekly for a quarter
    } else {
      return 30; // Show monthly for longer periods
    }
  }
}