import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/home/provider/recent_search_notifier.dart';

/// Provider for recent searches
final menuRecentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});

/// Provider for active tab index
final menuActiveTabProvider = StateProvider<int>((ref) => 0);

/// Provider for current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for search focus state
final searchFocusProvider = StateProvider<bool>((ref) => false);

/// Provider for scroll state
final scrollStateProvider = StateProvider<double>((ref) => 0.0);

/// Provider to enable/disable tabs
final tabsEnabledProvider = StateProvider<bool>((ref) => true);