import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/local_storange/local_storage_service.dart';
// JSON encoding/decoding imports
import 'dart:convert';

/// Optimized user preferences system with local caching and
/// efficient Firebase operations.

// Models
class UserPreferences {
  final String userId;
  final ThemeMode themeMode;
  final String? phoneNumber;
  final List<SavedLocation> savedLocations;
  final String? defaultLocationId;
  final DateTime? lastUpdated;

  UserPreferences({
    required this.userId,
    this.themeMode = ThemeMode.light,
    this.phoneNumber,
    this.savedLocations = const [],
    this.defaultLocationId,
    this.lastUpdated,
  });

  UserPreferences copyWith({
    String? userId,
    ThemeMode? themeMode,
    String? phoneNumber,
    List<SavedLocation>? savedLocations,
    String? defaultLocationId,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      savedLocations: savedLocations ?? this.savedLocations,
      defaultLocationId: defaultLocationId ?? this.defaultLocationId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory UserPreferences.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // Parse saved locations
      List<SavedLocation> locations = [];
      if (data['savedLocations'] != null) {
        for (final locationData in data['savedLocations']) {
          try {
            locations.add(SavedLocation.fromMap(locationData));
          } catch (e) {
            debugPrint('Error parsing location: $e');
          }
        }
      }

      // Parse theme mode
      ThemeMode parsedThemeMode = ThemeMode.system;
      if (data['themeMode'] != null) {
        switch (data['themeMode']) {
          case 'light':
            parsedThemeMode = ThemeMode.light;
            break;
          case 'dark':
            parsedThemeMode = ThemeMode.dark;
            break;
          default:
            parsedThemeMode = ThemeMode.system;
        }
      }

      // Parse last updated timestamp
      DateTime? lastUpdated;
      if (data['updatedAt'] != null) {
        lastUpdated = (data['updatedAt'] as Timestamp).toDate();
      }

      return UserPreferences(
        userId: doc.id,
        themeMode: parsedThemeMode,
        phoneNumber: data['phoneNumber'],
        savedLocations: locations,
        defaultLocationId: data['defaultLocationId'],
        lastUpdated: lastUpdated,
      );
    } catch (e) {
      debugPrint('Error parsing user preferences: $e');
      return UserPreferences(userId: doc.id);
    }
  }

  Map<String, dynamic> toFirestore() {
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }

    return {
      'userId': userId,
      'themeMode': themeModeString,
      'phoneNumber': phoneNumber,
      'savedLocations':
          savedLocations.map((location) => location.toMap()).toList(),
      'defaultLocationId': defaultLocationId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper to get default location if it exists
  SavedLocation? get defaultLocation {
    if (defaultLocationId == null) return null;
    try {
      return savedLocations.firstWhere((loc) => loc.id == defaultLocationId);
    } catch (_) {
      return null;
    }
  }

  // Serialize to JSON for local caching
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'themeMode': themeMode.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'savedLocations':
          savedLocations.map((location) => location.toMap()).toList(),
      'defaultLocationId': defaultLocationId,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  // Deserialize from JSON for local caching
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    // Parse theme mode
    ThemeMode parsedThemeMode = ThemeMode.system;
    if (json['themeMode'] != null) {
      switch (json['themeMode']) {
        case 'light':
          parsedThemeMode = ThemeMode.light;
          break;
        case 'dark':
          parsedThemeMode = ThemeMode.dark;
          break;
        default:
          parsedThemeMode = ThemeMode.system;
      }
    }

    // Parse saved locations
    List<SavedLocation> locations = [];
    if (json['savedLocations'] != null) {
      for (final locationData in json['savedLocations']) {
        try {
          locations.add(SavedLocation.fromMap(locationData));
        } catch (e) {
          debugPrint('Error parsing cached location: $e');
        }
      }
    }

    // Parse last updated
    DateTime? lastUpdated;
    if (json['lastUpdated'] != null) {
      lastUpdated = DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']);
    }

    return UserPreferences(
      userId: json['userId'],
      themeMode: parsedThemeMode,
      phoneNumber: json['phoneNumber'],
      savedLocations: locations,
      defaultLocationId: json['defaultLocationId'],
      lastUpdated: lastUpdated,
    );
  }
}

class SavedLocation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? notes;

  SavedLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  SavedLocation copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
    );
  }

  factory SavedLocation.fromMap(Map<String, dynamic> map) {
    return SavedLocation(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    };
  }
}

// Optimized repository with local caching
class OptimizedUserPreferencesRepository {
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;

  OptimizedUserPreferencesRepository({
    required FirebaseFirestore firestore,
    required LocalStorageService localStorage,
  })  : _firestore = firestore,
        _localStorage = localStorage;

  // Collection reference
  CollectionReference get _collection =>
      _firestore.collection('userPreferences');

  // Local cache keys
  String _userPrefsKey(String userId) => 'user_prefs_$userId';
  String _themeModeKey(String userId) => 'theme_mode_$userId';

  // Get user preferences stream with local cache fallback
  Stream<UserPreferences> watchUserPreferences(String userId) {
    // Load from cache first
    _loadFromCache(userId);

    // Then listen to Firestore changes
    return _collection.doc(userId).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          final prefs = UserPreferences.fromFirestore(snapshot);
          // Update cache whenever we get new data
          _saveToCache(prefs);
          return prefs;
        } else {
          // Return default preferences if document doesn't exist
          final defaultPrefs = UserPreferences(userId: userId);
          // Cache default preferences
          _saveToCache(defaultPrefs);
          return defaultPrefs;
        }
      },
    );
  }

  // Update phone number
  Future<void> updatePhoneNumber(String userId, String phoneNumber) async {
    await _collection.doc(userId).set({
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Update saved location
  Future<void> updateSavedLocation(
      String userId, SavedLocation location) async {
    // Get current preferences
    final preferences = await getUserPreferences(userId);

    // Find and replace location
    final updatedLocations = preferences.savedLocations.map((loc) {
      if (loc.id == location.id) {
        return location;
      }
      return loc;
    }).toList();

    // Update in Firestore
    await _collection.doc(userId).set({
      'savedLocations': updatedLocations.map((loc) => loc.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Delete saved location
  Future<void> deleteSavedLocation(String userId, String locationId) async {
    // Get current preferences
    final preferences = await getUserPreferences(userId);

    // Remove location
    final updatedLocations = preferences.savedLocations
        .where((loc) => loc.id != locationId)
        .toList();

    // If default location is being deleted, update defaultLocationId
    String? updatedDefaultLocationId = preferences.defaultLocationId;
    if (preferences.defaultLocationId == locationId) {
      updatedDefaultLocationId = null;
    }

    // Update in Firestore
    await _collection.doc(userId).set({
      'savedLocations': updatedLocations.map((loc) => loc.toMap()).toList(),
      'defaultLocationId': updatedDefaultLocationId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Set default location
  Future<void> setDefaultLocation(String userId, String locationId) async {
    await _collection.doc(userId).set({
      'defaultLocationId': locationId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Load from cache to update providers immediately
  Future<UserPreferences?> _loadFromCache(String userId) async {
    try {
      final jsonString = await _localStorage.getString(_userPrefsKey(userId));
      if (jsonString != null) {
        final jsonMap =
            Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
        return UserPreferences.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint('Error loading preferences from cache: $e');
    }
    return null;
  }

  // Save to cache for offline access
  Future<void> _saveToCache(UserPreferences preferences) async {
    try {
      final jsonString = jsonEncode(preferences.toJson());
      await _localStorage.setString(
          _userPrefsKey(preferences.userId), jsonString);

      // Also cache theme mode separately for quick access
      await _localStorage.setString(_themeModeKey(preferences.userId),
          preferences.themeMode.toString().split('.').last);
    } catch (e) {
      debugPrint('Error saving preferences to cache: $e');
    }
  }

  // Get user preferences once with cache fallback
  Future<UserPreferences> getUserPreferences(String userId) async {
    try {
      // Try to get from cache first
      final cachedPrefs = await _loadFromCache(userId);
      if (cachedPrefs != null) {
        return cachedPrefs;
      }

      // If not in cache, get from Firestore
      final docSnapshot = await _collection
          .doc(userId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (docSnapshot.exists) {
        final prefs = UserPreferences.fromFirestore(docSnapshot);
        _saveToCache(prefs);
        return prefs;
      }
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
    }

    // Return default preferences if all else fails
    return UserPreferences(userId: userId);
  }

  // Save user preferences with efficient merging
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      await _collection.doc(preferences.userId).set(
            preferences.toFirestore(),
            SetOptions(merge: true),
          );

      // Update local cache
      await _saveToCache(preferences);
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      rethrow;
    }
  }

  // Update theme mode with optimized approach
  Future<void> updateThemeMode(String userId, ThemeMode themeMode) async {
    try {
      // Get current preferences to avoid overwriting
      final currentPrefs = await getUserPreferences(userId);

      // Update to new preferences
      final updatedPrefs = currentPrefs.copyWith(
        themeMode: themeMode,
        lastUpdated: DateTime.now(),
      );

      // Update cache immediately for responsive UI
      await _saveToCache(updatedPrefs);

      // Then update Firestore
      String themeModeString;
      switch (themeMode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        default:
          themeModeString = 'system';
      }

      await _collection.doc(userId).set({
        'themeMode': themeModeString,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating theme mode: $e');
      rethrow;
    }
  }

  // Add saved location with optimized transaction
  Future<String> addSavedLocation(String userId, SavedLocation location) async {
    try {
      // Generate unique ID if not provided
      final newLocation = location.id.isEmpty
          ? location.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString())
          : location;

      // Use transaction for consistency
      final newLocationId =
          await _firestore.runTransaction<String>((transaction) async {
        // Get current doc
        final docRef = _collection.doc(userId);
        final docSnapshot = await transaction.get(docRef);

        // Parse current locations or use empty list
        List<dynamic> currentLocations = [];
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>?;
          currentLocations = data?['savedLocations'] ?? [];
        }

        // Add new location
        final updatedLocations = [...currentLocations, newLocation.toMap()];

        // Update in transaction
        transaction.set(
            docRef,
            {
              'savedLocations': updatedLocations,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));

        return newLocation.id;
      });

      // Update cache with new location
      final currentPrefs = await getUserPreferences(userId);
      final updatedLocations = [...currentPrefs.savedLocations, newLocation];
      await _saveToCache(currentPrefs.copyWith(
        savedLocations: updatedLocations,
        lastUpdated: DateTime.now(),
      ));

      return newLocationId;
    } catch (e) {
      debugPrint('Error adding saved location: $e');
      rethrow;
    }
  }
}

// Optimized providers
final userPreferencesRepositoryProvider =
    Provider<OptimizedUserPreferencesRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return OptimizedUserPreferencesRepository(
    firestore: firestore,
    localStorage: localStorage,
  );
});

// User preferences provider with proper caching
final userPreferencesProvider =
    StreamProvider.family<UserPreferences, String>((ref, userId) {
  final repository = ref.watch(userPreferencesRepositoryProvider);
  return repository.watchUserPreferences(userId);
});

// // Optimized theme provider with local caching
// final themeProvider =
//     StateNotifierProvider<OptimizedThemeNotifier, AsyncValue<ThemeMode>>((ref) {
//   final user = ref.watch(currentUserProvider).valueOrNull;
//   final userPrefsRepo = ref.watch(userPreferencesRepositoryProvider);
//   final localStorage = ref.watch(localStorageServiceProvider);

//   return OptimizedThemeNotifier(
//     ref: ref,
//     repository: userPrefsRepo,
//     localStorage: localStorage,
//     userId: user?.uid,
//   );
// });

// // Optimized theme notifier with local caching
// class OptimizedThemeNotifier extends StateNotifier<AsyncValue<ThemeMode>> {
//   final Ref ref;
//   final OptimizedUserPreferencesRepository repository;
//   final LocalStorageService localStorage;
//   final String? userId;

//   OptimizedThemeNotifier({
//     required this.ref,
//     required this.repository,
//     required this.localStorage,
//     this.userId,
//   }) : super(const AsyncValue.loading()) {
//     _init();
//   }

//   Future<void> _init() async {
//     if (userId == null) {
//       state = const AsyncValue.data(ThemeMode.system);
//       return;
//     }

//     try {
//       // Try to get cached theme first for immediate response
//       final cachedThemeStr = await localStorage.getString('theme_mode_$userId');
//       if (cachedThemeStr != null) {
//         final cachedTheme = _parseThemeMode(cachedThemeStr);
//         state = AsyncValue.data(cachedTheme);
//       }

//       // Then get full preferences to ensure we have latest
//       final prefs = await repository.getUserPreferences(userId!);
//       state = AsyncValue.data(prefs.themeMode);
//     } catch (e) {
//       debugPrint('Error initializing theme: $e');
//       state = AsyncValue.error(e, StackTrace.current);
//     }
//   }

//   ThemeMode _parseThemeMode(String value) {
//     switch (value.toLowerCase()) {
//       case 'light':
//         return ThemeMode.light;
//       case 'dark':
//         return ThemeMode.dark;
//       default:
//         return ThemeMode.system;
//     }
//   }

//   Future<void> setThemeMode(ThemeMode mode) async {
//     if (userId == null) return;

//     try {
//       // Update state immediately for responsive UI
//       state = AsyncValue.data(mode);

//       // Save to cache immediately
//       await localStorage.setString(
//           'theme_mode_$userId', mode.toString().split('.').last);

//       // Then update in Firestore
//       await repository.updateThemeMode(userId!, mode);
//     } catch (e) {
//       debugPrint('Error setting theme mode: $e');
//       // Revert to previous state if there's an error
//       _init();
//     }
//   }
// }

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  final userPreferencesRepo = ref.watch(userPreferencesRepositoryProvider);

  return ThemeNotifier(
    ref: ref,
    repository: userPreferencesRepo,
    userId: user?.uid,
  );
});

// Theme notifier to handle theme changes
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;
  final OptimizedUserPreferencesRepository repository;
  final String? userId;

  ThemeNotifier({
    required this.ref,
    required this.repository,
    this.userId,
  }) : super(ThemeMode.light) {
    _init();
  }

  Future<void> _init() async {
    if (userId != null) {
      final prefs = await repository.getUserPreferences(userId!);
      state = prefs.themeMode;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (userId == null) return;

    state = mode;
    await repository.updateThemeMode(userId!, mode);
  }
}
