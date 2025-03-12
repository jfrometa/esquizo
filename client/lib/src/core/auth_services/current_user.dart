import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/auth_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';

final currentUserProvider = FutureProvider<UserProfile?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return UserProfile(email: authService.currentUser?.email ?? "", displayName: authService.currentUser?.displayName ?? "", uid: authService.currentUser?.uid ?? "") ;
});

final isCurrentUserProvider = FutureProvider.family<bool, String>((ref, email) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  return currentUser?.email == email;
});