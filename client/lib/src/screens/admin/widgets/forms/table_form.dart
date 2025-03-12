import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart' as restairant_table;
import 'package:uuid/uuid.dart'; 

class TableForm extends ConsumerStatefulWidget {
  final restairant_table.RestaurantTable? table;
  final Function(restairant_table.RestaurantTable) onSave;
  final VoidCallback onCancel;

  const TableForm({
    Key? key,
    this.table,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<TableForm> createState() => _TableFormState();
}

class _TableFormState extends ConsumerState<TableForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form state
  int _tableNumber = 1;
  int _capacity = 4;
  restairant_table.TableStatus _status = restairant_table.TableStatusEnum.available;
  Map<String, double> _position = {'x': 0, 'y': 0};
  String? _currentOrderId;

  bool _isEditMode = false;
  String _businessId = 'default';

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.table != null;
    
    if (_isEditMode) {
      // Populate form with existing table data
      _tableNumber = widget.table!.number;
      _capacity = widget.table!.capacity;
      _status = widget.table!.status;
      _position = widget.table!.position;
      _currentOrderId = widget.table!.currentOrderId;
      _businessId = widget.table!.businessId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? 'Edit Table' : 'Add New Table',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Table number
            TextFormField(
              initialValue: _tableNumber.toString(),
              decoration: const InputDecoration(
                labelText: 'Table Number',
                hintText: 'Enter table number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a table number';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _tableNumber = int.tryParse(value) ?? 1;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Capacity
            Row(
              children: [
                const Text('Capacity:'),
                Expanded(
                  child: Slider(
                    value: _capacity.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: _capacity.toString(),
                    onChanged: (value) {
                      setState(() {
                        _capacity = value.toInt();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextFormField(
                    initialValue: _capacity.toString(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      final capacity = int.tryParse(value);
                      if (capacity != null && capacity > 0 && capacity <= 20) {
                        setState(() {
                          _capacity = capacity;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status dropdown
            DropdownButtonFormField<restairant_table.TableStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: restairant_table.TableStatusEnum.values.map((status) {
                return DropdownMenuItem<restairant_table.TableStatus>(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Position in floor plan
            ExpansionTile(
              title: const Text('Floor Plan Position'),
              subtitle: Text('x: ${_position['x']!.toStringAsFixed(1)}, y: ${_position['y']!.toStringAsFixed(1)}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('X Position:'),
                          Expanded(
                            child: Slider(
                              value: _position['x']!,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: _position['x']!.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  _position['x'] = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: _position['x']!.toStringAsFixed(1),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                              ],
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                final x = double.tryParse(value);
                                if (x != null && x >= 0 && x <= 100) {
                                  setState(() {
                                    _position['x'] = x;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Y Position:'),
                          Expanded(
                            child: Slider(
                              value: _position['y']!,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: _position['y']!.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  _position['y'] = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: _position['y']!.toStringAsFixed(1),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                              ],
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                final y = double.tryParse(value);
                                if (y != null && y >= 0 && y <= 100) {
                                  setState(() {
                                    _position['y'] = y;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Preview
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Table $_tableNumber',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.table_restaurant,
                      size: 48,
                      color: _getStatusColor(_status),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text('Capacity: $_capacity'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor(_status),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(_getStatusText(_status)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Form actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(_isEditMode ? 'Update Table' : 'Add Table'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(restairant_table.TableStatus status) {
    switch (status) {
      case restairant_table.TableStatusEnum.available:
        return Colors.green;
      case restairant_table.TableStatusEnum.occupied:
        return Colors.red;
      case restairant_table.TableStatusEnum.reserved:
        return Colors.orange;
      case restairant_table.TableStatusEnum.maintenance:
        return Colors.blue;
      case restairant_table.TableStatusEnum.cleaning:
        // TODO: Handle this case.
       return Colors.yellow;
    }
  }
  
  String _getStatusText(restairant_table.TableStatus status) {
    switch (status) {
      case restairant_table.TableStatusEnum.available:
        return 'Available';
      case restairant_table.TableStatusEnum.occupied:
        return 'Occupied';
      case restairant_table.TableStatusEnum.reserved:
        return 'Reserved';
      case restairant_table.TableStatusEnum.maintenance:
        return 'Maintenance';
      case restairant_table.TableStatusEnum.cleaning:
        // TODO: Handle this case.
        return 'Cleaning';
    }
  }
  
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Create table object
    final table = restairant_table.RestaurantTable(
      id: _isEditMode ? widget.table!.id : const Uuid().v4(),
      businessId: _businessId,
      number: _tableNumber,
      capacity: _capacity,
      status: _status,
      position: _position,
      currentOrderId: _currentOrderId,
    );
    
    widget.onSave(table);
  }
}