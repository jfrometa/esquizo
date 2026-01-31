import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/home/provider/recent_search_notifier.dart';

part 'menu_providers.g.dart';

/// Provider for active tab index
@riverpod
class MenuActiveTab extends _$MenuActiveTab {
  @override
  int build() => 0;

  void set(int value) => state = value;
}

/// Provider for current search query
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void set(String value) => state = value;
}

/// Provider for search focus state
@riverpod
class SearchFocus extends _$SearchFocus {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// Provider for scroll state
@riverpod
class ScrollState extends _$ScrollState {
  @override
  double build() => 0.0;

  void set(double value) => state = value;
}

/// Provider to enable/disable tabs
@riverpod
class TabsEnabled extends _$TabsEnabled {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}

// Re-export the recent searches provider
final menuRecentSearchesProvider = recentSearchesNotifierProvider;
