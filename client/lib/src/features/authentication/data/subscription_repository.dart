import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart';

final subscriptionsRepositoryProvider =
    Provider<SubscriptionsRepository>((ref) {
  return SubscriptionsRepository();
});

final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user != null) {
    return ref.read(subscriptionsRepositoryProvider).getSubscriptions(user.uid);
  } else {
    return const Stream.empty();
  }
});

class SubscriptionsRepository {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Subscription>> getSubscriptions(String userId) {
    try {
      return _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Subscription.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('Error fetching subscriptions: $e');
      return const Stream.empty();
    }
  }

  Future<void> consumeMeal(String subscriptionId) async {
    final docRef = _firestore.collection('subscriptions').doc(subscriptionId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final currentMeals = snapshot.get('mealsRemaining');
      if (currentMeals > 0) {
        transaction.update(docRef, {'mealsRemaining': currentMeals - 1});
      } else {
        throw Exception('No meals remaining.');
      }
    });
  }
}
