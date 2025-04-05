import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart'
    as auth_models;

// Common pagination state class
class PaginationState<T> {
  final List<T> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  const PaginationState({
    required this.items,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.lastDocument,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

// Base repository for pagination
abstract class BasePaginatedRepository<T> {
  final FirebaseFirestore _firestore;
  final int pageSize;

  BasePaginatedRepository({
    FirebaseFirestore? firestore,
    this.pageSize = 10,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get collection;
  T fromFirestore(DocumentSnapshot doc);
  Query Function(Query) get queryBuilder;

  Future<PaginationState<T>> fetchPage({
    required String userId,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      var query = queryBuilder(collection
          .where('userId', isEqualTo: userId)
          // .orderBy('orderDate', descending: true)
          .limit(pageSize));

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final items = snapshot.docs.map(fromFirestore).toList();

      return PaginationState<T>(
        items: items,
        hasMore: items.length >= pageSize,
        lastDocument: items.isEmpty ? null : snapshot.docs.last,
      );
    } catch (e) {
      return PaginationState<T>(
        items: [],
        error: 'Error fetching data: ${e.toString()}',
      );
    }
  }
}

// Subscriptions Repository
class SubscriptionsRepository extends BasePaginatedRepository<Subscription> {
  @override
  CollectionReference get collection =>
      FirebaseFirestore.instance.collection('subscriptions');

  @override
  Subscription fromFirestore(DocumentSnapshot doc) =>
      Subscription.fromFirestore(doc);

  @override
  Query Function(Query) get queryBuilder =>
      (Query query) => query.where('status', isEqualTo: 'active');

  Future<void> consumeMeal(String subscriptionId) async {
    final docRef = collection.doc(subscriptionId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final currentMeals = snapshot.get('mealsRemaining') as int;

        if (currentMeals <= 0) {
          throw Exception('No meals remaining');
        }

        transaction.update(docRef, {
          'mealsRemaining': currentMeals - 1,
          'lastUsedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error consuming meal: $e');
      rethrow;
    }
  }
}

// Orders Repository
class OrdersRepository extends BasePaginatedRepository<auth_models.Order> {
  @override
  CollectionReference get collection =>
      FirebaseFirestore.instance.collection('orders');

  @override
  auth_models.Order fromFirestore(DocumentSnapshot doc) =>
      auth_models.Order.fromFirestore(doc);

  @override
  Query Function(Query) get queryBuilder => (Query query) => query;
}

// Providers
final subscriptionsRepositoryProvider =
    Provider<SubscriptionsRepository>((ref) {
  return SubscriptionsRepository();
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository();
});

// Pagination Controllers
class PaginationController<T> extends StateNotifier<PaginationState<T>> {
  final BasePaginatedRepository<T> repository;
  final String userId;

  PaginationController({
    required this.repository,
    required this.userId,
  }) : super(PaginationState<T>(items: []));

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newState = await repository.fetchPage(
        userId: userId,
        lastDocument: state.lastDocument,
      );

      state = state.copyWith(
        items: [...state.items, ...newState.items],
        isLoading: false,
        hasMore: newState.hasMore,
        lastDocument: newState.lastDocument,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = PaginationState(items: []);
    await loadNextPage();
  }
}

// Providers for pagination controllers
final subscriptionsPaginationProvider = StateNotifierProvider.family<
    PaginationController<Subscription>,
    PaginationState<Subscription>,
    String>((ref, userId) {
  final repository = ref.watch(subscriptionsRepositoryProvider);
  return PaginationController<Subscription>(
    repository: repository,
    userId: userId,
  );
});

final ordersPaginationProvider = StateNotifierProvider.family<
    PaginationController<auth_models.Order>,
    PaginationState<auth_models.Order>,
    String>((ref, userId) {
  final repository = ref.watch(ordersRepositoryProvider);
  return PaginationController<auth_models.Order>(
    repository: repository,
    userId: userId,
  );
});
