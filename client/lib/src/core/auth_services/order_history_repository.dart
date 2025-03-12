// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
// import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart'
//     as auth_models;


// final orderHistoryProvider = StreamProvider<List<auth_models.Order>>((ref) {
//   final user = ref.watch(firebaseAuthProvider).currentUser;
//   if (user != null) {
//     return FirebaseFirestore.instance
//         .collection('orders')
//         .where('userId', isEqualTo: user.uid)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => auth_models.Order.fromFirestore(doc))
//             .toList());
//   } else {
//     return const Stream.empty();
//   }
// });
