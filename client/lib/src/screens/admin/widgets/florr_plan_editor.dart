import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

class FloorPlanEditor extends StatefulWidget {
  final List<RestaurantTable> tables;
  final Function(RestaurantTable, Map<String, double>) onTableMoved;
  final Function(RestaurantTable) onTableTapped;

  const FloorPlanEditor({
    Key? key,
    required this.tables,
    required this.onTableMoved,
    required this.onTableTapped,
  }) : super(key: key);

  @override
  State<FloorPlanEditor> createState() => _FloorPlanEditorState();
}

class _FloorPlanEditorState extends State<FloorPlanEditor> {
  RestaurantTable? _selectedTable;
  bool _isEditing = false;
  bool _showGrid = true;
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: GestureDetector(
            onScaleStart: (details) {
              // Deselect table when starting a new gesture
              setState(() {
                _selectedTable = null;
              });
            },
            onScaleUpdate: (details) {
              // Pan the view
              setState(() {
                if (details.scale == 1.0) {
                  _panOffset += details.focalPointDelta;
                } else {
                  // Zoom the view
                  final newZoom = (_zoom * details.scale).clamp(0.5, 2.0);
                  _zoom = newZoom;
                }
              });
            },
            child: Container(
              color: Colors.grey[200],
              child: Stack(
                children: [
                  // Background grid
                  if (_showGrid) _buildGrid(),
                  
                  // Tables
                  ..._buildTables(),
                  
                  // Info panel
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: _buildInfoPanel(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Edit mode toggle
          ToggleButtons(
            isSelected: [!_isEditing, _isEditing],
            onPressed: (index) {
              setState(() {
                _isEditing = index == 1;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('View Mode'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Edit Mode'),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Show grid toggle
          IconButton(
            icon: Icon(
              _showGrid ? Icons.grid_on : Icons.grid_off,
              color: _showGrid ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
            tooltip: _showGrid ? 'Hide Grid' : 'Show Grid',
          ),
          
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _zoom = (_zoom + 0.1).clamp(0.5, 2.0);
              });
            },
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _zoom = (_zoom - 0.1).clamp(0.5, 2.0);
              });
            },
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () {
              setState(() {
                _zoom = 1.0;
                _panOffset = Offset.zero;
              });
            },
            tooltip: 'Reset View',
          ),
          
          const Spacer(),
          
          // Selection info
          if (_selectedTable != null)
            Text(
              'Selected: Table ${_selectedTable!.number}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
  
  Widget _buildGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(
        gridSize: 20.0 * _zoom,
        offset: _panOffset,
      ),
    );
  }
  
  List<Widget> _buildTables() {
    return widget.tables.map((table) {
      // Convert percentage positions to pixel positions
      final size = MediaQuery.of(context).size;
      final x = size.width * (table.position['x']! / 100) + _panOffset.dx;
      final y = size.height * (table.position['y']! / 100) + _panOffset.dy;
      
      final isSelected = _selectedTable?.id == table.id;
      
      return Positioned(
        left: x,
        top: y,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedTable = table;
            });
            widget.onTableTapped(table);
          },
          onPanUpdate: _isEditing ? (details) {
            // Only allow dragging if in edit mode
            // Convert pixel movement to percentage movement
            final dx = details.delta.dx / size.width * 100;
            final dy = details.delta.dy / size.height * 100;
            
            // Calculate new position
            final newX = (table.position['x']! + dx).clamp(0.0, 100.0);
            final newY = (table.position['y']! + dy).clamp(0.0, 100.0);
            
            // Update table position
            final newPosition = {
              'x': newX,
              'y': newY,
            };
            
            // Update the table in the parent widget
            widget.onTableMoved(table, newPosition);
            
            // Update the selected table
            setState(() {
              _selectedTable = RestaurantTable(
                id: table.id,
                businessId: table.businessId,
                number: table.number,
                capacity: table.capacity,
                status: table.status,
                position: newPosition,
                currentOrderId: table.currentOrderId,
              );
            });
          } : null,
          child: _buildTableWidget(table, isSelected),
        ),
      );
    }).toList();
  }
  
  Widget _buildTableWidget(RestaurantTable table, bool isSelected) {
    // Determine table size based on capacity and zoom
    final baseSize = 60.0;
    final tableSize = baseSize * _zoom;
    
    final tableWidth = tableSize * (1 + (table.capacity / 10));
    final tableHeight = tableSize;
    
    // Table colors based on status
    final statusColor = _getStatusColor(table.status);
    
    return Container(
      width: tableWidth,
      height: tableHeight,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.white : statusColor,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Table ${table.number}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Cap: ${table.capacity}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Floor Plan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              if (_isEditing)
                const Chip(
                  label: Text('Edit Mode'),
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.zero,
                  labelStyle: TextStyle(fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusIndicator(TableStatusEnum.available),
              const SizedBox(width: 16),
              _buildStatusIndicator(TableStatusEnum.occupied),
              const SizedBox(width: 16),
              _buildStatusIndicator(TableStatusEnum.reserved),
              const SizedBox(width: 16),
              _buildStatusIndicator(TableStatusEnum.maintenance),
            ],
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            const Text(
              '• Drag tables to reposition',
              style: TextStyle(fontSize: 12),
            ),
          const Text(
            '• Tap a table for details',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusIndicator(TableStatusEnum status) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _getStatusText(status),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  Color _getStatusColor(TableStatusEnum status) {
    switch (status) {
      case TableStatusEnum.available:
        return Colors.green;
      case TableStatusEnum.occupied:
        return Colors.red;
      case TableStatusEnum.reserved:
        return Colors.orange;
      case TableStatusEnum.maintenance:
        return Colors.blue;
      case TableStatusEnum.cleaning:
        // TODO: Handle this case.
        return Colors.yellow;
    }
  }
  
  String _getStatusText(TableStatusEnum status) {
    switch (status) {
      case TableStatusEnum.available:
        return 'Available';
      case TableStatusEnum.occupied:
        return 'Occupied';
      case TableStatusEnum.reserved:
        return 'Reserved';
      case TableStatusEnum.maintenance:
        return 'Maintenance';
      case TableStatusEnum.cleaning:
        // TODO: Handle this case.
        return 'Cleaning';
    }
  }
}

// Grid painter for the background
class GridPainter extends CustomPainter {
  final double gridSize;
  final Offset offset;

  GridPainter({
    required this.gridSize,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Calculate grid lines with offset
    final xOffset = offset.dx % gridSize;
    final yOffset = offset.dy % gridSize;

    // Draw vertical lines
    for (double x = xOffset; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = yOffset; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}