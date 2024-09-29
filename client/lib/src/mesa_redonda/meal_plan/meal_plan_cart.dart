// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
// import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/plans/plans.dart'; // Import the cartProvider

// class MealPlanCard extends ConsumerWidget {
//   final MealPlan mealPlan;

//   const MealPlanCard({super.key, required this.mealPlan});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);

//     return ConstrainedBox(
//       constraints: const BoxConstraints(
//         minWidth: 300,
//         maxWidth: 450,
//         maxHeight: 550, // Maximum height for the card
//       ),
//       child: Card(
//         elevation: 6,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15.0),
//           side: BorderSide(
//             color: mealPlan.isBestValue ? Colors.green : Colors.grey.shade300,
//             width: mealPlan.isBestValue ? 3 : 1.5,
//           ),
//         ),
//         color: mealPlan.isBestValue ? Colors.green.shade50 : Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (mealPlan.isBestValue)
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade600,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'Best Value',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.star,
//                     color:
//                         mealPlan.isBestValue ? Colors.green : Colors.blueAccent,
//                     size: 30,
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       mealPlan.title,
//                       style: theme.textTheme.headlineMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                         fontSize: 28, // Increased font size for title
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.monetization_on,
//                     color: Colors.blueAccent,
//                     size: 25,
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     mealPlan.price,
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 22,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               const Divider(),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.featured_play_list,
//                     color: Colors.blueAccent,
//                     size: 25,
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     'Features:',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: mealPlan.features.map((feature) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.check_circle,
//                           color: Colors.green.shade700,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           feature,
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const Spacer(),
//               // Delivery Info
//               Row(
//                 children: [
//                   const Icon(Icons.local_shipping, color: Colors.redAccent),
//                   const SizedBox(width: 10),
//                   Text(
//                     'Delivery expenses will be added',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: Colors.redAccent,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Add meal plan to the cart
//                     ref.read(cartProvider.notifier).addToCart({
//                       'img': '', // Meal plans may not have an image
//                       'title': mealPlan.title,
//                       'description': 'Meal Plan Subscription',
//                       'pricing': mealPlan.price,
//                       'offertPricing': null, // No offer for meal plans
//                       'ingredients': [],
//                       'isSpicy': false,
//                       'foodType': 'Meal Plan'
//                     }, 1,
//                     isMealSubscription: true,
//                     totalMeals: mealPlan.features.contains('5 meals per day') ? 150 : 60 // Example logic for total meals.
//                     );
                    
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('${mealPlan.title} añadido al carrito'),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: mealPlan.isBestValue
//                         ? Colors.green.shade700
//                         : Colors.blueAccent,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   child: const Text(
//                     'Comprar Plan',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }