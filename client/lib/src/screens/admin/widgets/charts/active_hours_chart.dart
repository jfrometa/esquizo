import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/analytics_screen.dart'; 

class ActiveHoursChart extends StatefulWidget {
  final List<HourlyDataPoint> hourlyData;

  const ActiveHoursChart({
    Key? key,
    required this.hourlyData,
  }) : super(key: key);

  @override
  State<ActiveHoursChart> createState() => _ActiveHoursChartState();
}

class _ActiveHoursChartState extends State<ActiveHoursChart> {
  int? _selectedBarIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Find the peak hours for highlight
    final peakHours = _findPeakHours();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: _calculateMaxY() * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData( 
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final hour = group.x;
                    final orders = rod.toY.round();
                    final hourString = _formatHour(hour);
                    return BarTooltipItem(
                      '$hourString\n$orders orders',
                      TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                touchCallback: (event, touchResponse) {
                  setState(() {
                    if (touchResponse == null || touchResponse.spot == null) {
                      _selectedBarIndex = null;
                    } else {
                      _selectedBarIndex = touchResponse.spot!.touchedBarGroupIndex;
                    }
                  });
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      // Only show even hours or when there are few bars
                      if (widget.hourlyData.length <= 12 || value.toInt() % 2 == 0) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _formatHour(value.toInt()),
                            style: TextStyle(
                              fontSize: 10,
                              color: _selectedBarIndex == value.toInt()
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              barGroups: _buildBarGroups(peakHours, theme),
            ),
          ),
        ),
        
        // Legend for peak hours
        if (peakHours.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Peak Hours',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  List<BarChartGroupData> _buildBarGroups(Set<int> peakHours, ThemeData theme) {
    return widget.hourlyData.asMap().map((index, data) {
      final barColor = peakHours.contains(data.hour)
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withOpacity(0.5);
      
      return MapEntry(
        index,
        BarChartGroupData(
          x: data.hour,
          barRods: [
            BarChartRodData(
              toY: data.orders.toDouble(),
              width: 16,
              color: _selectedBarIndex == index ? theme.colorScheme.primary : barColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }).values.toList();
  }
  
  double _calculateMaxY() {
    if (widget.hourlyData.isEmpty) return 10;
    
    return widget.hourlyData
        .map((e) => e.orders)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
  }
  
  Set<int> _findPeakHours() {
    if (widget.hourlyData.isEmpty) return {};
    
    // Calculate the average orders per hour
    final totalOrders = widget.hourlyData.fold(0, (sum, data) => sum + data.orders);
    final averageOrders = totalOrders / widget.hourlyData.length;
    
    // Find hours with orders above 1.5x the average
    final peakThreshold = averageOrders * 1.5;
    
    return widget.hourlyData
        .where((data) => data.orders > peakThreshold)
        .map((data) => data.hour)
        .toSet();
  }
  
  String _formatHour(int hour) {
    final isPM = hour >= 12;
    final displayHour = hour == 0 || hour == 12 ? 12 : hour % 12;
    return '$displayHour${isPM ? 'PM' : 'AM'}';
  }
}