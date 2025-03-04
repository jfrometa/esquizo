// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'people_quantity_selector.dart';
// import 'allergies_selector.dart'; 

// class EventDetailsCard extends ConsumerWidget {
//   const EventDetailsCard({super.key});

//   @override
//   Widget build(BuildContext context, ref) {
//     return Card(
//       elevation: 4,
//       child: ExpansionTile(
//         title: const Text('Detalles del Evento'),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 PeopleQuantitySelector(quantities: [],),
//                 SizedBox(height: 16),
//                 EventTypeInput(),
//                 SizedBox(height: 16),
//                 AllergiesSelector(),
//                 SizedBox(height: 16),
//                 AdditionalNotes(),
//                 SizedBox(height: 16),
//                 ChefServiceSwitch(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

  
// }