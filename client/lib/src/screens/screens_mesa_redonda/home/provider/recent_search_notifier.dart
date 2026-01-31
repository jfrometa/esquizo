import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'recent_search_notifier.g.dart';

@riverpod
class RecentSearchesNotifier extends _$RecentSearchesNotifier {
  @override
  List<String> build() {
    _loadSearches();
    return [];
  }

  static const String _key = 'recent_searches';
  static const int _maxSearches = 10;

  Future<void> _loadSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_key) ?? [];
    state = searches;
  }

  Future<void> _saveSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  void addSearch(String search) {
    if (search.trim().isEmpty) return;

    // If search already exists, remove it (to add it at the beginning)
    state =
        state.where((s) => s.toLowerCase() != search.toLowerCase()).toList();

    // Add new search at the beginning
    state = [search, ...state];

    // Limit the number of searches
    if (state.length > _maxSearches) {
      state = state.sublist(0, _maxSearches);
    }

    _saveSearches();
  }

  void clearSearches() {
    state = [];
    _saveSearches();
  }

  void removeSearch(String search) {
    state = state.where((s) => s != search).toList();
    _saveSearches();
  }
}
