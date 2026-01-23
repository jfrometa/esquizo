// lib/src/screens/location/mobile_map_init.dart
// Default implementation for mobile (does nothing)
// This file is used when the application is NOT compiled for the web.

/// No-op implementation for mobile platforms.
/// The google_maps_flutter package handles native map initialization.
Future<void> initializeMapsIfWeb() async {
  // No specific JS initialization needed for mobile platforms using
  // the standard google_maps_flutter package.
  return Future.value();
}
