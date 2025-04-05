import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_services/providers/delivery_location_provider.dart';

// For web platform only
import 'dart:js_util' as js_util;
import 'dart:html' as html;
import 'package:flutter/services.dart';
// Import platformViewRegistry from the correct location
import 'dart:ui_web' as ui;

// Use this ID for consistent view registration
const String MAP_ELEMENT_ID = 'google-map-view';

class LocationCaptureBottomSheet extends ConsumerStatefulWidget {
  final Function(String latitude, String longitude, String address)
      onLocationCaptured;

  const LocationCaptureBottomSheet(
      {super.key, required this.onLocationCaptured});

  @override
  LocationCaptureBottomSheetState createState() =>
      LocationCaptureBottomSheetState();
}

class LocationCaptureBottomSheetState
    extends ConsumerState<LocationCaptureBottomSheet> {
  String? _latitude;
  String? _longitude;
  String? _address;
  bool _isLoading = false;
  bool _isMapView = true;
  bool _isDraggingMap = false;
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isMapInitialized = false;
  bool _isViewRegistered = false;

  // For accuracy feedback
  int? _accuracyInMeters;
  bool _isLowAccuracy = false;

  final String _googleGeocodeApiKey = 'AIzaSyAlk83WpDsAWqaa4RqI4mxa5IYPiuZldek';

  // Web elements
  StreamSubscription<html.MessageEvent>? _webMapMovedSubscription;

  // Location settings
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  // Form field controllers for manual address entry
  final _addressController = TextEditingController();
  final _floorController = TextEditingController();
  final _cityController = TextEditingController();
  final _noteController = TextEditingController();

  // Completer to track map initialization
  final Completer<bool> _mapsInitialized = Completer<bool>();

  // Register view factory once for the entire app
  static bool _hasRegisteredFactory = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _initializePlatform();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _floorController.dispose();
    _cityController.dispose();
    _noteController.dispose();
    _webMapMovedSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlatform() async {
    if (kIsWeb) {
      // Step 1: Register the web view factory first
      await _registerWebViewFactory();

      // Step 2: Initialize the maps JavaScript
      await _initializeWebMaps();

      // Step 3: Set up communication channels
      _setupWebMapMovedListener();
    }

    // Step 4: Get user location
    _getCurrentLocation();
  }

  // Critical step: Register the view factory before we try to use it
  Future<void> _registerWebViewFactory() async {
    if (kIsWeb && !_hasRegisteredFactory) {
      // This needs to be registered only once for the entire app
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(MAP_ELEMENT_ID, (int viewId) {
        print('Creating map element with viewId: $viewId');
        final mapElement = html.DivElement()
          ..id = MAP_ELEMENT_ID
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none';

        return mapElement;
      });

      _hasRegisteredFactory = true;
      _isViewRegistered = true;
      print('Web view factory registered successfully for $MAP_ELEMENT_ID');

      // Wait for the DOM to update
      await Future.delayed(const Duration(milliseconds: 100));
    } else if (kIsWeb) {
      _isViewRegistered = true;
      print('Using previously registered view factory for $MAP_ELEMENT_ID');
    }
  }

  void _setupWebMapMovedListener() {
    if (kIsWeb) {
      try {
        // Create a communication channel between JavaScript and Dart
        // Use a properly wrapped callback with allowInterop
        final void Function(dynamic) wrappedCallback =
            js_util.allowInterop((dynamic data) {
          if (data is Map) {
            final lat = data['latitude'];
            final lng = data['longitude'];
            if (lat != null && lng != null) {
              _updatePositionFromWeb(lat as double, lng as double);
            }
          }
        });

        // Set up the message listener on the window
        _webMapMovedSubscription =
            html.window.onMessage.listen((html.MessageEvent event) {
          if (event.data is Map && event.data['type'] == 'mapMoved') {
            final lat = event.data['latitude'];
            final lng = event.data['longitude'];
            if (lat != null && lng != null) {
              _updatePositionFromWeb(lat as double, lng as double);
            }
          }
        });

        // Register the callback for direct JS calls
        js_util.setProperty(
            html.window, 'onMapPositionChanged', wrappedCallback);

        print('Web map listener set up successfully');
      } catch (e) {
        print('Error setting up web map listener: $e');
      }
    }
  }

  void _updatePositionFromWeb(double latitude, double longitude) {
    if (_isDraggingMap) {
      setState(() {
        _latitude = latitude.toString();
        _longitude = longitude.toString();
      });

      // Get address for the new position with debouncing
      _debounceGetAddress();
    }
  }

  // Debouncer for address lookup
  Timer? _debounceTimer;
  void _debounceGetAddress() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_latitude != null && _longitude != null) {
        _getHumanReadableAddress(_latitude!, _longitude!);
      }
    });
  }

  // Web-specific maps initialization
  Future<void> _initializeWebMaps() async {
    try {
      if (!kIsWeb) return;

      // Ensure map scripts are loaded
      await _ensureMapScriptsLoaded();

      // Initialize the maps library
      final bool mapsLoaded = await js_util.promiseToFuture<bool>(
          js_util.callMethod(html.window, 'initMapsWhenNeeded', []));

      setState(() {
        _isMapInitialized = mapsLoaded;
      });

      if (mapsLoaded) {
        _mapsInitialized.complete(true);
        print('Web maps initialized successfully');
      } else {
        _mapsInitialized.completeError('Failed to initialize maps');
      }
    } catch (e) {
      print('Error initializing Google Maps for web: $e');
      _mapsInitialized.completeError(e);
      setState(() {
        _isMapInitialized = false;
      });
    }
  }

  Future<void> _ensureMapScriptsLoaded() async {
    // Check if we need to inject the map scripts code
    if (kIsWeb) {
      final String mapScripts = '''
// Track if maps have been initialized
let mapsInitialized = false;
let mapInstance = null;
let advancedMarker = null;
let currentPosition = null;
let isDraggingMap = false;

// Map ID for advanced markers - Replace with your actual map ID when in production
const MAP_ID = 'DEMO_MAP_ID'; // For testing only, get an actual Map ID for production

// Initialize maps library with required components
window.initMapsWhenNeeded = async function() {
  if (mapsInitialized) {
    return true;
  }
  
  try {
    // Load the Maps JavaScript API if not already loaded
    if (typeof google === 'undefined' || typeof google.maps === 'undefined') {
      console.log("Google Maps API not found, waiting for it to load...");
      return new Promise((resolve) => {
        const checkGoogleMaps = setInterval(() => {
          if (typeof google !== 'undefined' && typeof google.maps !== 'undefined') {
            clearInterval(checkGoogleMaps);
            console.log("Google Maps API loaded");
            mapsInitialized = true;
            resolve(true);
          }
        }, 100);
        
        // Timeout after 10 seconds
        setTimeout(() => {
          clearInterval(checkGoogleMaps);
          console.error("Timeout waiting for Google Maps API");
          resolve(false);
        }, 10000);
      });
    }
    
    // Load required libraries
    try {
      const { Map } = await google.maps.importLibrary("maps");
      const { AdvancedMarkerElement } = await google.maps.importLibrary("marker");
      
      mapsInitialized = true;
      console.log("Google Maps libraries initialized successfully");
      return true;
    } catch (error) {
      console.error("Error loading Google Maps libraries:", error);
      return false;
    }
  } catch (error) {
    console.error("Error initializing Google Maps:", error);
    return false;
  }
};

// Initialize Google Maps with Advanced Marker
window.initializeAdvancedMap = async function(elementId, latitude, longitude, address) {
  console.log("Initializing advanced map with:", { elementId, latitude, longitude, address });
  
  if (!mapsInitialized) {
    const initialized = await window.initMapsWhenNeeded();
    if (!initialized) {
      console.error("Failed to initialize maps");
      return false;
    }
  }
  
  try {
    const mapElement = document.getElementById(elementId);
    if (!mapElement) {
      console.error("Map element not found:", elementId);
      return false;
    }
    
    currentPosition = { 
      lat: parseFloat(latitude), 
      lng: parseFloat(longitude) 
    };
    
    // Get map component
    const { Map } = await google.maps.importLibrary("maps");
    
    // Get marker component
    const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");
    
    console.log("Creating map in element:", elementId);
    
    // Create new map
    mapInstance = new Map(mapElement, {
      zoom: 16,
      center: currentPosition,
      mapId: MAP_ID,
      mapTypeControl: false,
      fullscreenControl: false,
      streetViewControl: false,
      zoomControl: true,
    });
    
    // Create a pin element
    const pinElement = new PinElement({
      scale: 1.2,
      background: "#FF5252",
      glyphColor: "#FFFFFF",
      borderColor: "#D32F2F",
    });
    
    // Create advanced marker
    advancedMarker = new AdvancedMarkerElement({
      map: mapInstance,
      position: currentPosition,
      title: address || "Selected Location",
      content: pinElement.element,
      gmpClickable: true,
    });
    
    // Set up map move event to reposition the marker
    mapInstance.addListener('center_changed', () => {
      if (!mapInstance) return;
      
      const center = mapInstance.getCenter();
      if (advancedMarker && center && isDraggingMap) {
        advancedMarker.position = center;
      }
      
      // Send message to Dart
      window.postMessage({
        type: 'mapMoved',
        latitude: center.lat(),
        longitude: center.lng()
      }, '*');
      
      // Also call the function directly if it exists
      if (typeof window.onMapPositionChanged === 'function') {
        window.onMapPositionChanged({
          latitude: center.lat(),
          longitude: center.lng()
        });
      }
    });
    
    console.log("Advanced map initialized successfully");
    return true;
  } catch (error) {
    console.error("Error initializing advanced map:", error);
    return false;
  }
};

// Update marker position
window.updateMarkerPosition = function(latitude, longitude) {
  if (!mapInstance || !advancedMarker) {
    console.error("Map or marker not initialized");
    return false;
  }
  
  try {
    const position = { 
      lat: parseFloat(latitude), 
      lng: parseFloat(longitude) 
    };
    
    advancedMarker.position = position;
    mapInstance.panTo(position);
    
    return true;
  } catch (error) {
    console.error("Error updating marker position:", error);
    return false;
  }
};

// Get current marker position
window.getMarkerPosition = function() {
  if (!advancedMarker) {
    console.error("Marker not initialized");
    return null;
  }
  
  try {
    const position = advancedMarker.position;
    return {
      latitude: position.lat(),
      longitude: position.lng()
    };
  } catch (error) {
    console.error("Error getting marker position:", error);
    return null;
  }
};

// Function to recenter the map on the current location
window.recenterMap = function() {
  if (!mapInstance || !currentPosition) {
    console.error("Map not initialized or position unknown");
    return false;
  }
  
  try {
    mapInstance.panTo(currentPosition);
    if (advancedMarker) {
      advancedMarker.position = currentPosition;
    }
    
    return true;
  } catch (error) {
    console.error("Error recentering map:", error);
    return false;
  }
};

// Set map dragging mode
window.setMapDragging = function(dragging) {
  if (!mapInstance) {
    console.error("Map not initialized");
    return false;
  }
  
  try {
    isDraggingMap = dragging;
    
    // Toggle dragging mode visual changes
    if (dragging) {
      // Show a center crosshair or indicator when in dragging mode
      const mapDiv = mapInstance.getDiv();
      let centerPin = document.getElementById('map-center-pin');
      
      if (!centerPin) {
        centerPin = document.createElement('div');
        centerPin.id = 'map-center-pin';
        centerPin.style.position = 'absolute';
        centerPin.style.top = '50%';
        centerPin.style.left = '50%';
        centerPin.style.transform = 'translate(-50%, -50%)';
        centerPin.style.width = '20px';
        centerPin.style.height = '20px';
        centerPin.style.backgroundImage = 'url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'24\\' height=\\'24\\' viewBox=\\'0 0 24 24\\' fill=\\'none\\' stroke=\\'%23D32F2F\\' stroke-width=\\'2\\' stroke-linecap=\\'round\\' stroke-linejoin=\\'round\\'%3e%3cpath d=\\'M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z\\'%3e%3c/path%3e%3ccircle cx=\\'12\\' cy=\\'10\\' r=\\'3\\'%3e%3c/circle%3e%3c/svg%3e")';
        centerPin.style.backgroundRepeat = 'no-repeat';
        centerPin.style.backgroundPosition = 'center';
        centerPin.style.zIndex = '1000';
        centerPin.style.pointerEvents = 'none'; // Allow clicks to pass through
        centerPin.style.animation = 'bounce 1s infinite alternate';
        
        // Add animation style
        const style = document.createElement('style');
        style.textContent = `
          @keyframes bounce {
            from { transform: translate(-50%, -50%) scale(1); }
            to { transform: translate(-50%, -50%) scale(1.2); }
          }
        `;
        document.head.appendChild(style);
        
        mapDiv.appendChild(centerPin);
      } else {
        centerPin.style.display = 'block';
      }
      
      // Hide the advanced marker
      if (advancedMarker) {
        advancedMarker.map = null;
      }
    } else {
      // Hide the center pin
      const centerPin = document.getElementById('map-center-pin');
      if (centerPin) {
        centerPin.style.display = 'none';
      }
      
      // Restore the advanced marker at the current center position
      if (advancedMarker) {
        const center = mapInstance.getCenter();
        advancedMarker.position = center;
        advancedMarker.map = mapInstance;
      }
    }
    
    return true;
  } catch (error) {
    console.error("Error setting map dragging mode:", error);
    return false;
  }
};

// Geolocation service
window.getCurrentLocation = function() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation is not supported by this browser'));
      return;
    }
    
    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy
        });
      },
      (error) => {
        console.error('Geolocation error:', error.message);
        
        // Try IP-based fallback
        fetch('https://ipapi.co/json/')
          .then(response => response.json())
          .then(data => {
            if (data.latitude && data.longitude) {
              resolve({
                latitude: data.latitude,
                longitude: data.longitude,
                accuracy: 1000 // Assume 1km accuracy for IP geolocation
              });
            } else {
              reject(new Error('Could not determine location'));
            }
          })
          .catch(err => {
            reject(error);
          });
      },
      { 
        enableHighAccuracy: true, 
        timeout: 10000, 
        maximumAge: 60000 
      }
    );
  });
};
      ''';

      final scriptElement = html.ScriptElement()
        ..type = 'text/javascript'
        ..innerHtml = mapScripts;

      html.document.head!.append(scriptElement);

      // Wait a moment to ensure script execution
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void _loadSavedLocation() {
    final savedLocation = ref.read(deliveryLocationProvider);
    if (savedLocation != null) {
      _addressController.text = savedLocation.address;
      _floorController.text = savedLocation.floor;
      _cityController.text = savedLocation.city;
      _noteController.text = savedLocation.note;
    }
  }

  void _submitForm() {
    final address = _addressController.text;
    final floor = _floorController.text;
    final city = _cityController.text;
    final note = _noteController.text;

    if (address.isNotEmpty && city.isNotEmpty) {
      // Save to provider
      ref.read(deliveryLocationProvider.notifier).updateLocation(
            address: address,
            floor: floor,
            city: city,
            note: note,
          );

      final fullAddress = '$address, Piso: $floor, $city. Nota: $note';

      // Use current map position if available, otherwise use zeros
      final lat = _latitude ?? '0.0';
      final lng = _longitude ?? '0.0';

      widget.onLocationCaptured(lat, lng, fullAddress);
      Navigator.of(context).pop();
    } else {
      _showSnackBar('Por favor ingrese todos los detalles requeridos');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _isLowAccuracy = false;
    });

    try {
      // Different location retrieval based on platform
      if (kIsWeb) {
        await _getWebLocation();
      } else {
        await _getNativeLocation();
      }

      // Initialize map with the current position
      if (_currentPosition != null &&
          kIsWeb &&
          _isMapInitialized &&
          _isViewRegistered) {
        await _initializeWebMapWithPosition();
      }
    } catch (e) {
      print('Error getting location: $e');
      _showSnackBar('Error al obtener ubicación: $e', isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeWebMapWithPosition() async {
    if (!kIsWeb || !_isViewRegistered || _currentPosition == null) return;

    try {
      // Make sure the element exists before initializing the map
      final mapElement = html.document.getElementById(MAP_ELEMENT_ID);
      if (mapElement == null) {
        print('Map element not found in DOM: $MAP_ELEMENT_ID');
        return;
      }

      print('Initializing map with element ID: $MAP_ELEMENT_ID');

      // Initialize the map using our JavaScript function
      final bool success = await js_util.promiseToFuture<bool>(js_util
          .callMethod(html.window, 'initializeAdvancedMap', [
        MAP_ELEMENT_ID,
        _latitude,
        _longitude,
        _address ?? 'Su ubicación'
      ]));

      if (success) {
        print('Web map initialized successfully with position');
      } else {
        print('Failed to initialize web map with position');
      }
    } catch (e) {
      print('Error initializing web map with position: $e');
    }
  }

  // Web-specific location retrieval
  Future<void> _getWebLocation() async {
    if (!kIsWeb) return;

    try {
      // Use JavaScript bridge for geolocation
      final locationData = await js_util.promiseToFuture(
          js_util.callMethod(html.window, 'getCurrentLocation', []));

      final latitude = js_util.getProperty(locationData, 'latitude');
      final longitude = js_util.getProperty(locationData, 'longitude');
      final accuracy = js_util.getProperty(locationData, 'accuracy');

      setState(() {
        _latitude = latitude.toString();
        _longitude = longitude.toString();
        _currentPosition = LatLng(latitude, longitude);
        _accuracyInMeters = accuracy.toInt();
        _isLowAccuracy =
            accuracy > 100; // Consider low accuracy if > 100 meters
        _isLoading = false;
      });

      // Fetch human-readable address
      await _getHumanReadableAddress(_latitude!, _longitude!);
    } catch (e) {
      print('Web geolocation error: $e');

      // Fall back to IP-based geolocation if permission is denied
      if (e.toString().contains('permission') ||
          e.toString().contains('denied')) {
        await _getFallbackLocation();
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fallback to IP-based geolocation
  Future<void> _getFallbackLocation() async {
    try {
      // Use a free geolocation API
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lat = data['latitude'];
        final lng = data['longitude'];

        if (lat != null && lng != null) {
          setState(() {
            _latitude = lat.toString();
            _longitude = lng.toString();
            _currentPosition = LatLng(lat, lng);
            _isLowAccuracy = true; // IP geolocation is always low accuracy
            _accuracyInMeters = 1000; // Assume 1km accuracy for IP geolocation
          });

          // Fetch address for this location
          await _getHumanReadableAddress(_latitude!, _longitude!);
        }
      }
    } catch (e) {
      print('Fallback geolocation error: $e');
    }
  }

  // Native location retrieval (Android/iOS)
  Future<void> _getNativeLocation() async {
    if (kIsWeb) return;

    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      _showSnackBar('Servicios de ubicación desactivados.', isError: true);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Request permission for location services
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Permiso de ubicación denegado.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
          'Permisos de ubicación denegados permanentemente. Por favor habilítalos en la configuración de tu dispositivo.',
          isError: true);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
      _currentPosition = LatLng(position.latitude, position.longitude);
      _accuracyInMeters = position.accuracy.toInt();
      _isLowAccuracy =
          position.accuracy > 100; // Consider low accuracy if > 100 meters
      _isLoading = false;
    });

    // Fetch human-readable address
    await _getHumanReadableAddress(_latitude!, _longitude!);

    // If native map controller is available, move camera to position
    if (_mapController != null) {
      _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 16));
    }
  }

  Future<void> _getHumanReadableAddress(
      String latitude, String longitude) async {
    final String geocodeUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_googleGeocodeApiKey';

    try {
      final response = await http.get(Uri.parse(geocodeUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['results'].isNotEmpty) {
          setState(() {
            _address = jsonResponse['results'][0]['formatted_address'];
          });

          // Populate the address field for manual editing too
          _addressController.text = _address ?? '';
        } else {
          setState(() {
            _address = 'Dirección no encontrada';
          });
        }
      } else {
        setState(() {
          _address = 'Error al obtener dirección';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Error: $e';
      });
    }
  }

  void _toggleMapDragging() {
    setState(() {
      _isDraggingMap = !_isDraggingMap;
    });

    // Show guidance message when entering drag mode
    if (_isDraggingMap) {
      _showSnackBar(
          'Mueve el mapa para ajustar la ubicación. El marcador se moverá con el centro del mapa.');
    }

    // Update the marker for web
    if (kIsWeb) {
      _updateWebMapDragging();
    }
  }

  void _updateWebMapDragging() {
    if (kIsWeb) {
      try {
        js_util.callMethod(html.window, 'setMapDragging', [_isDraggingMap]);
      } catch (e) {
        print('Error setting map dragging mode: $e');
      }
    }
  }

  void _onCameraMoveStarted() {
    if (_isDraggingMap) {
      setState(() {
        // Show visual indicator that map is being moved
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    if (_isDraggingMap) {
      setState(() {
        _latitude = position.target.latitude.toString();
        _longitude = position.target.longitude.toString();
      });
    }
  }

  void _onCameraIdle() {
    if (_isDraggingMap && _latitude != null && _longitude != null) {
      // Update the address when camera stops moving
      _getHumanReadableAddress(_latitude!, _longitude!);
    }
  }

  Future<void> _confirmLocation() async {
    if (_latitude == null || _longitude == null || _address == null) {
      _showSnackBar('No se pudo determinar la ubicación.', isError: true);
      return;
    }

    // If in manual entry mode, submit form
    if (!_isMapView) {
      _submitForm();
      return;
    }

    // For web platform, get the current position from JavaScript
    if (kIsWeb) {
      try {
        final positionData =
            js_util.callMethod(html.window, 'getMarkerPosition', []);
        if (positionData != null) {
          final lat = js_util.getProperty(positionData, 'latitude').toString();
          final lng = js_util.getProperty(positionData, 'longitude').toString();
          if (lat != null && lng != null) {
            _latitude = lat;
            _longitude = lng;
          }
        }
      } catch (e) {
        print('Error getting marker position: $e');
      }
    }

    // Otherwise use map location
    widget.onLocationCaptured(_latitude!, _longitude!, _address!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 600 && size.width <= 1024;

    // Wrapping in WillPopScope to prevent dismissal by back button.
    // Also note: when showing this bottom sheet, set isDismissible: false and
    // enableDrag: false in showModalBottomSheet().
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        // Occupy the full screen height
        height: size.height,
        constraints: BoxConstraints(
          maxHeight: size.height,
          maxWidth: isDesktop ? 800 : double.infinity,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 16,
          vertical: 24,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(colorScheme, theme),
            const SizedBox(height: 24),
            Expanded(
              child: _isMapView
                  ? _buildMapView(colorScheme, theme)
                  : _buildAddressFormView(colorScheme, theme),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(colorScheme, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Confirma tu dirección de envío',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (_isMapView)
          IconButton(
            icon: const Icon(Icons.my_location),
            color: colorScheme.primary,
            onPressed: _getCurrentLocation,
            tooltip: 'Obtener ubicación actual',
          ),
        if (_isMapView)
          IconButton(
            icon: Icon(
              _isDraggingMap ? Icons.location_on : Icons.edit_location_alt,
            ),
            color: _isDraggingMap ? colorScheme.tertiary : colorScheme.primary,
            onPressed: _toggleMapDragging,
            tooltip: _isDraggingMap
                ? 'Ajustando ubicación (clic para finalizar)'
                : 'Ajustar ubicación manualmente',
          ),
        IconButton(
          icon: Icon(
            _isMapView ? Icons.edit : Icons.map,
            color: colorScheme.primary,
          ),
          onPressed: () => setState(() => _isMapView = !_isMapView),
          tooltip: _isMapView ? 'Editar manualmente' : 'Ver mapa',
        ),
      ],
    );
  }

  Widget _buildMapView(ColorScheme colorScheme, ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Obteniendo ubicación...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentPosition == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Ubicación no disponible',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isLowAccuracy)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'La precisión de la ubicación es baja (±${_accuracyInMeters}m). '
                      'Puedes ajustar manualmente la posición tocando el ícono de edición.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_address != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isDraggingMap
                  ? colorScheme.tertiaryContainer
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: _isDraggingMap
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isDraggingMap
                        ? 'Ajustando ubicación: $_address'
                        : _address!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _isDraggingMap
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildPlatformMap(),
              ),
              if (_isDraggingMap && !kIsWeb)
                const Center(
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Platform-aware map widget
  Widget _buildPlatformMap() {
    if (_currentPosition == null) {
      return const Center(
        child: Text('Ubicación no disponible'),
      );
    }

    // Check if we're on web and using special handling
    if (kIsWeb) {
      if (!_isMapInitialized) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Inicializando mapa...'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _initializeWebMaps,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        );
      }

      // Return HtmlElementView for web - using the static ID
      return HtmlElementView(viewType: MAP_ELEMENT_ID);
    }

    // Native platforms - use GoogleMap widget
    try {
      return GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 16.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: true,
        mapToolbarEnabled: false,
        onCameraMoveStarted: _onCameraMoveStarted,
        onCameraMove: _onCameraMove,
        onCameraIdle: _onCameraIdle,
        markers: !_isDraggingMap
            ? {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: _currentPosition!,
                  infoWindow: InfoWindow(title: _address),
                ),
              }
            : {},
      );
    } catch (e) {
      print('Map initialization error: $e');
      // Fallback widget
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('No se pudo cargar el mapa: $e'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  if (kIsWeb) {
                    _initializeWebMaps();
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildAddressFormView(ColorScheme colorScheme, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _addressController,
            label: 'Dirección',
            icon: Icons.location_on,
            colorScheme: colorScheme,
            theme: theme,
            required: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _floorController,
            label: 'Piso / Apartamento',
            icon: Icons.layers,
            colorScheme: colorScheme,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cityController,
            label: 'Ciudad',
            icon: Icons.location_city,
            colorScheme: colorScheme,
            theme: theme,
            required: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _noteController,
            label: 'Instrucciones de entrega',
            icon: Icons.note,
            colorScheme: colorScheme,
            theme: theme,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required ThemeData theme,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _confirmLocation,
            icon: const Icon(Icons.check),
            label: const Text('Confirmar'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
