import 'package:flutter/material.dart';

class AddressInputDialog extends StatefulWidget {
  const AddressInputDialog({super.key});

  @override
  _AddressInputDialogState createState() => _AddressInputDialogState();
}

class _AddressInputDialogState extends State<AddressInputDialog> {
  final _formKey = GlobalKey<FormState>();
  String _street = '';
  String _city = '';
  String _state = '';
  String _postalCode = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Delivery Address'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Street Address'),
              onChanged: (value) {
                setState(() {
                  _street = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid street address';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'City'),
              onChanged: (value) {
                setState(() {
                  _city = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a city';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'State'),
              onChanged: (value) {
                setState(() {
                  _state = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a state';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Postal Code'),
              onChanged: (value) {
                setState(() {
                  _postalCode = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a postal code';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'street': _street,
                'city': _city,
                'state': _state,
                'postalCode': _postalCode,
              });
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
