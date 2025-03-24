import 'package:cloud_firestore/cloud_firestore.dart' as CloudFireStore;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Initialize Firebase instances
final firebaseFirestoreProvider = Provider<CloudFireStore.FirebaseFirestore>((ref) {
  return CloudFireStore.FirebaseFirestore.instance;
});