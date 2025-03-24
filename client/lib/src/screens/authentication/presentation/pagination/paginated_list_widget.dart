import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/subscription_repository.dart';


class PaginatedListView<T> extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationController<T>, PaginationState<T>>
      provider;
  final Widget Function(BuildContext, T) itemBuilder;
  final Widget? emptyWidget;
  final double? itemExtent;

  const PaginatedListView({
    super.key,
    required this.provider,
    required this.itemBuilder,
    this.emptyWidget,
    this.itemExtent,
  });

  @override
  ConsumerState<PaginatedListView<T>> createState() =>
      _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends ConsumerState<PaginatedListView<T>> {
  final _scrollController = ScrollController();
  static const _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(widget.provider.notifier).loadNextPage();
    });
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= _scrollThreshold) {
      ref.read(widget.provider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    if (state.error != null) {
      return _buildError(state.error!);
    }

    if (state.items.isEmpty) {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return widget.emptyWidget ?? const SizedBox();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(widget.provider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        itemExtent: widget.itemExtent,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return _buildLoader();
          }
          return widget.itemBuilder(context, state.items[index]);
        },
      ),
    );
  }

  Widget _buildLoader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(widget.provider.notifier).refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// // Usage in SubscriptionsList widget
// class SubscriptionsList extends ConsumerWidget {
//   const SubscriptionsList({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(firebaseAuthProvider).currentUser;
//     if (user == null) return const SizedBox();

//     return PaginatedListView<Subscription>(
//       provider: subscriptionsPaginationProvider(user.uid),
//       itemBuilder: (context, subscription) => SubscriptionCard(
//         subscription: subscription,
//       ),
//       emptyWidget: const Center(
//         child: Text('No tienes suscripciones activas'),
//       ),
//     );
//   }
// }

// // Usage in OrderHistoryList widget
// class OrderHistoryList extends ConsumerWidget {
//   const OrderHistoryList({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(firebaseAuthProvider).currentUser;
//     if (user == null) return const SizedBox();

//     return PaginatedListView<Order>(
//       provider: ordersPaginationProvider(user.uid),
//       itemBuilder: (context, order) => OrderHistoryCard(
//         order: order,
//       ),
//       emptyWidget: const Center(
//         child: Text('No tienes órdenes previas'),
//       ),
//     );
//   }
// }
