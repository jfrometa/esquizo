import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/firebase_auth_repository.dart';

// Models
class UserPreferences {
  final String userId;
  final ThemeMode themeMode;
  final String? phoneNumber;
  final List<SavedLocation> savedLocations;
  final String? defaultLocationId;

  UserPreferences({
    required this.userId,
    this.themeMode = ThemeMode.light,
    this.phoneNumber,
    this.savedLocations = const [],
    this.defaultLocationId,
  });

  UserPreferences copyWith({
    String? userId,
    ThemeMode? themeMode,
    String? phoneNumber,
    List<SavedLocation>? savedLocations,
    String? defaultLocationId,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      savedLocations: savedLocations ?? this.savedLocations,
      defaultLocationId: defaultLocationId ?? this.defaultLocationId,
    );
  }

  factory UserPreferences.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse saved locations
    List<SavedLocation> locations = [];
    if (data['savedLocations'] != null) {
      for (final locationData in data['savedLocations']) {
        locations.add(SavedLocation.fromMap(locationData));
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
    
    return UserPreferences(
      userId: doc.id,
      themeMode: parsedThemeMode,
      phoneNumber: data['phoneNumber'],
      savedLocations: locations,
      defaultLocationId: data['defaultLocationId'],
    );
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
      'savedLocations': savedLocations.map((location) => location.toMap()).toList(),
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

// Repository
class UserPreferencesRepository {
  final FirebaseFirestore _firestore;
  
  UserPreferencesRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  
  // Collection reference
  CollectionReference get _collection => 
      _firestore.collection('userPreferences');
  
  // Get user preferences stream
  Stream<UserPreferences> watchUserPreferences(String userId) {
    return _collection.doc(userId).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          return UserPreferences.fromFirestore(snapshot);
        } else {
          // Return default preferences if document doesn't exist
          return UserPreferences(userId: userId);
        }
      },
    );
  }
  
  // Get user preferences once
  Future<UserPreferences> getUserPreferences(String userId) async {
    final doc = await _collection.doc(userId).get();
    if (doc.exists) {
      return UserPreferences.fromFirestore(doc);
    } else {
      // Return default preferences if document doesn't exist
      return UserPreferences(userId: userId);
    }
  }
  
  // Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _collection.doc(preferences.userId).set(
      preferences.toFirestore(),
      SetOptions(merge: true),
    );
  }
  
  // Update theme mode
  Future<void> updateThemeMode(String userId, ThemeMode themeMode) async {
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
  }
  
  // Update phone number
  Future<void> updatePhoneNumber(String userId, String phoneNumber) async {
    await _collection.doc(userId).set({
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  
  // Add saved location
  Future<String> addSavedLocation(String userId, SavedLocation location) async {
    // Get current preferences
    final preferences = await getUserPreferences(userId);
    
    // Create new location with unique ID if not provided
    final newLocation = location.id.isEmpty
        ? location.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
        : location;
    
    // Add to list
    final updatedLocations = [...preferences.savedLocations, newLocation];
    
    // Update in Firestore
    await _collection.doc(userId).set({
      'savedLocations': updatedLocations.map((loc) => loc.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    return newLocation.id;
  }
  
  // Update saved location
  Future<void> updateSavedLocation(String userId, SavedLocation location) async {
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
}

// Providers
final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository>((ref) {
  return UserPreferencesRepository();
});

final userPreferencesProvider = StreamProvider.family<UserPreferences, String>((ref, userId) {
  final repository = ref.watch(userPreferencesRepositoryProvider);
  return repository.watchUserPreferences(userId);
});

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
  final UserPreferencesRepository repository;
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