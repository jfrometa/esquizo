import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_models.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_providers.dart';

class PaymentTaxesTab extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const PaymentTaxesTab({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  ConsumerState<PaymentTaxesTab> createState() => _PaymentTaxesTabState();
}

class _PaymentTaxesTabState extends ConsumerState<PaymentTaxesTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaxType _selectedType = TaxType.percentage;
  ServiceType? _selectedServiceType;
  bool _isAddingNew = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final taxConfigsAsync = ref.watch(taxConfigurationsProvider);

    return Column(
      children: [
        // Header with add button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax Configurations',
                style: theme.textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isAddingNew = true),
                icon: const Icon(Icons.add),
                label: const Text('Add Tax'),
              ),
            ],
          ),
        ),

        // Tax configurations list or form
        Expanded(
          child: _isAddingNew
              ? _buildTaxForm(context)
              : taxConfigsAsync.when(
                  data: (configs) => _buildTaxList(configs, colorScheme),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
        ),
      ],
    );
  }

  Widget _buildTaxList(
      List<TaxConfiguration> configs, ColorScheme colorScheme) {
    if (configs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tax configurations',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _isAddingNew = true),
              icon: const Icon(Icons.add),
              label: const Text('Add First Tax'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: configs.length,
      itemBuilder: (context, index) =>
          _buildTaxCard(configs[index], colorScheme),
    );
  }

  Widget _buildTaxCard(TaxConfiguration config, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: config.isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calculate,
            color: config.isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          config.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatTaxType(config.type)}: ${config.type == TaxType.percentage ? '${config.rate}%' : '\$${config.rate}'}',
            ),
            if (config.applicableServiceType != null)
              Text(
                'Applies to: ${_formatServiceType(config.applicableServiceType!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (config.description != null)
              Text(
                config.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Switch(
          value: config.isActive,
          onChanged: (value) => _toggleTaxStatus(config),
        ),
        onTap: () => _editTax(config),
      ),
    );
  }

  Widget _buildTaxForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            TextButton.icon(
              onPressed: () => setState(() {
                _isAddingNew = false;
                _clearForm();
              }),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to List'),
            ),
            const SizedBox(height: 16),

            // Form fields
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tax Name',
                hintText: 'e.g., Dine-in Service Tax',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a tax name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaxType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tax Type',
                      border: OutlineInputBorder(),
                    ),
                    items: TaxType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(_formatTaxType(type)),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedType = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    decoration: InputDecoration(
                      labelText: _selectedType == TaxType.percentage
                          ? 'Rate (%)'
                          : 'Amount (\$)',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a rate';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0) {
                        return 'Please enter a valid rate';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<ServiceType?>(
              initialValue: _selectedServiceType,
              decoration: const InputDecoration(
                labelText: 'Applies To Service Type',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('All Service Types')),
                ...ServiceType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_formatServiceType(type)),
                    )),
              ],
              onChanged: (value) =>
                  setState(() => _selectedServiceType = value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() {
                    _isAddingNew = false;
                    _clearForm();
                  }),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveTax,
                  child: const Text('Save Tax'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTax() async {
    if (_formKey.currentState!.validate()) {
      try {
        final paymentService = ref.read(paymentServiceProvider);

        await paymentService.createTaxConfiguration(
          name: _nameController.text,
          rate: double.parse(_rateController.text),
          type: _selectedType,
          applicableServiceType: _selectedServiceType,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );

        setState(() {
          _isAddingNew = false;
          _clearForm();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tax configuration saved')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving tax: $e')),
          );
        }
      }
    }
  }

  void _editTax(TaxConfiguration config) {
    // TODO: Implement edit functionality
    _nameController.text = config.name;
    _rateController.text = config.rate.toString();
    _selectedType = config.type;
    _selectedServiceType = config.applicableServiceType;
    _descriptionController.text = config.description ?? '';
    setState(() => _isAddingNew = true);
  }

  void _toggleTaxStatus(TaxConfiguration config) {
    // TODO: Implement toggle functionality
  }

  void _clearForm() {
    _nameController.clear();
    _rateController.clear();
    _descriptionController.clear();
    _selectedType = TaxType.percentage;
    _selectedServiceType = null;
  }

  String _formatTaxType(TaxType type) {
    switch (type) {
      case TaxType.percentage:
        return 'Percentage';
      case TaxType.fixed:
        return 'Fixed Amount';
      case TaxType.compound:
        return 'Compound';
    }
  }

  String _formatServiceType(ServiceType type) {
    switch (type) {
      case ServiceType.dineIn:
        return 'Dine In';
      case ServiceType.takeout:
        return 'Takeout';
      case ServiceType.delivery:
        return 'Delivery';
      case ServiceType.pickup:
        return 'Pickup';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
