
// import 'package:flutter/material.dart';

// /// Separate component for the inline form to add a new item.
// class NewItemForm extends StatelessWidget {
//   final TextEditingController itemNameController;
//   final TextEditingController itemDescriptionController;
//   final TextEditingController quantityController;
//   final VoidCallback onAddItem;

//   const NewItemForm({
//     super.key,
//     required this.itemNameController,
//     required this.itemDescriptionController,
//     required this.quantityController,
//     required this.onAddItem,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Agregar Nuevo Item',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 16),
//           TextField(
//             controller: itemNameController,
//             decoration: const InputDecoration(
//               labelText: 'Nombre del Item *',
//               border: OutlineInputBorder(),
//               filled: true,
//             ),
//             autofocus: true,
//             textInputAction: TextInputAction.next,
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: itemDescriptionController,
//             decoration: const InputDecoration(
//               labelText: 'Descripción (Opcional)',
//               border: OutlineInputBorder(),
//               filled: true,
//             ),
//             maxLines: 2,
//             textInputAction: TextInputAction.next,
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: quantityController,
//             decoration: const InputDecoration(
//               labelText: 'Cantidad (Opcional)',
//               border: OutlineInputBorder(),
//               filled: true,
//               hintText: 'Dejar vacío para usar cantidad general',
//             ),
//             keyboardType: TextInputType.number,
//             textInputAction: TextInputAction.done,
//             onSubmitted: (_) => onAddItem(),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: onAddItem,
//             child: const Text('Agregar Item'),
//           ),
//         ],
//       ),
//     );
//   }
// }