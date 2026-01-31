// Stub (non-web) implementation of the web interop bridge.
// This file is used on all platforms except web via conditional imports.

class WebLocation {
  final double latitude;
  final double longitude;
  final int accuracyInMeters;
  const WebLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyInMeters,
  });
}

class MapPosition {
  final double latitude;
  final double longitude;
  const MapPosition({
    required this.latitude,
    required this.longitude,
  });
}

class LocationWebBridge {
  const LocationWebBridge();

  Future<void> registerViewFactory(String viewType) async {}

  void setupMapMovedListener(void Function(double lat, double lng) onMove) {}

  void dispose() {}

  Future<bool> initializeMaps() async => false;

  Future<bool> initializeAdvancedMap(
    String elementId,
    String? latitude,
    String? longitude,
    String address,
  ) async => false;

  Future<WebLocation?> getCurrentLocation() async => null;

  void setMapDragging(bool dragging) {}

  bool elementExists(String id) => false;

  Future<void> ensureMapScriptsLoaded() async {}

  Future<MapPosition?> getMarkerPosition() async => null;
}
