// // Web implementation of the interop bridge using dart:js_interop and package:js.
// // This file is only imported on web builds via conditional imports.

// import 'dart:async';
// import 'dart:html' as html;
// import 'dart:ui_web' as ui;

// // Core js_interop types
// import 'dart:js_interop' as js_interop;
// // @JS annotations and allowInterop
// import 'package:js/js.dart' as js;


// class WebLocation {
//   final double latitude;
//   final double longitude;
//   final int accuracyInMeters;
//   const WebLocation({
//     required this.latitude,
//     required this.longitude,
//     required this.accuracyInMeters,
//   });
// }

// class MapPosition {
//   final double latitude;
//   final double longitude;
//   const MapPosition({
//     required this.latitude,
//     required this.longitude,
//   });
// }

// class LocationWebBridge {
//   const LocationWebBridge();

//   StreamSubscription<html.MessageEvent>? _messageSub;

//   Future<void> registerViewFactory(String viewType) async {
//     // ignore: undefined_prefixed_name
//     ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
//       final mapElement = html.DivElement()
//         ..id = viewType
//         ..style.width = '100%'
//         ..style.height = '100%'
//         ..style.border = 'none';
//       return mapElement;
//     });
//     // Allow a short delay for DOM to update
//     await Future.delayed(const Duration(milliseconds: 100));
//   }

//   void setupMapMovedListener(void Function(double lat, double lng) onMove) {
//     // Listen to window.postMessage events from JS
//     _messageSub = html.window.onMessage.listen((html.MessageEvent event) {
//       final data = event.data;
//       if (data is Map && data['type'] == 'mapMoved') {
//         final lat = data['latitude'];
//         final lng = data['longitude'];
//         if (lat != null && lng != null) {
//           onMove((lat as num).toDouble(), (lng as num).toDouble());
//         }
//       }
//     });
//   }

//   void dispose() {
//     _messageSub?.cancel();
//     _messageSub = null;
//   }

//   // Externals to JS globals provided by the injected script below
//   @js.JS('initMapsWhenNeeded')
//   external js_interop.JSPromise _initMapsWhenNeededJS();

//   @js.JS('initializeAdvancedMap')
//   external js_interop.JSPromise _initializeAdvancedMapJS(
//     String elementId,
//     Object? latitude,
//     Object? longitude,
//     String address,
//   );

//   @js.JS('setMapDragging')
//   external void _setMapDraggingJS(bool dragging);

//   @js.JS('getMarkerPosition')
//   external Object? _getMarkerPositionJS();

//   @js.JS('getCurrentLocation')
//   external js_interop.JSPromise _getCurrentLocationJS();

//   Future<bool> initializeMaps() async {
//     final result = await _initMapsWhenNeededJS().toDart;
//     // If JS returned a boolean, use it. Otherwise, assume success if no error.
//     return result is bool ? result : true;
//   }

//   Future<bool> initializeAdvancedMap(
//     String elementId,
//     String? latitude,
//     String? longitude,
//     String address,
//   ) async {
//     final result = await _initializeAdvancedMapJS(
//       elementId,
//       latitude,
//       longitude,
//       address,
//     ).toDart;
//     return result is bool ? result : true;
//   }

//   Future<WebLocation?> getCurrentLocation() async {
//     try {
//       final jsResult = await _getCurrentLocationJS().toDart; // JS object
//       final lat = js_unsafe.getProperty(jsResult, 'latitude') as num?;
//       final lng = js_unsafe.getProperty(jsResult, 'longitude') as num?;
//       final acc = js_unsafe.getProperty(jsResult, 'accuracy') as num?;
//       if (lat == null || lng == null) return null;
//       return WebLocation(
//         latitude: lat.toDouble(),
//         longitude: lng.toDouble(),
//         accuracyInMeters: (acc ?? 0).toInt(),
//       );
//     } catch (_) {
//       return null;
//     }
//   }

//   void setMapDragging(bool dragging) {
//     _setMapDraggingJS(dragging);
//   }

//   bool elementExists(String id) {
//     return html.document.getElementById(id) != null;
//   }

//   Future<void> ensureMapScriptsLoaded() async {
//     // Inject the script only once
//     if (html.document.getElementById('__mapsInteropScript__') != null) {
//       return;
//     }

//     const String mapScripts = '''
// // Track if maps have been initialized
// let mapsInitialized = false;
// let mapInstance = null;
// let advancedMarker = null;
// let currentPosition = null;
// let isDraggingMap = false;

// // Map ID for advanced markers - Replace with your actual map ID when in production
// const MAP_ID = 'DEMO_MAP_ID'; // For testing only, get an actual Map ID for production

// // Initialize maps library with required components
// window.initMapsWhenNeeded = async function() {
//   if (mapsInitialized) {
//     return true;
//   }
  
//   try {
//     // Load the Maps JavaScript API if not already loaded
//     if (typeof google === 'undefined' || typeof google.maps === 'undefined') {
//       console.log("Google Maps API not found, waiting for it to load...");
//       return new Promise((resolve) => {
//         const checkGoogleMaps = setInterval(() => {
//           if (typeof google !== 'undefined' && typeof google.maps !== 'undefined') {
//             clearInterval(checkGoogleMaps);
//             console.log("Google Maps API loaded");
//             mapsInitialized = true;
//             resolve(true);
//           }
//         }, 100);
        
//         // Timeout after 10 seconds
//         setTimeout(() => {
//           clearInterval(checkGoogleMaps);
//           console.error("Timeout waiting for Google Maps API");
//           resolve(false);
//         }, 10000);
//       });
//     }
    
//     // Load required libraries
//     try {
//       const { Map } = await google.maps.importLibrary("maps");
//       const { AdvancedMarkerElement } = await google.maps.importLibrary("marker");
      
//       mapsInitialized = true;
//       console.log("Google Maps libraries initialized successfully");
//       return true;
//     } catch (error) {
//       console.error("Error loading Google Maps libraries:", error);
//       return false;
//     }
//   } catch (error) {
//     console.error("Error initializing Google Maps:", error);
//     return false;
//   }
// };

// // Initialize Google Maps with Advanced Marker
// window.initializeAdvancedMap = async function(elementId, latitude, longitude, address) {
//   console.log("Initializing advanced map with:", { elementId, latitude, longitude, address });
  
//   if (!mapsInitialized) {
//     const initialized = await window.initMapsWhenNeeded();
//     if (!initialized) {
//       console.error("Failed to initialize maps");
//       return false;
//     }
//   }
  
//   try {
//     const mapElement = document.getElementById(elementId);
//     if (!mapElement) {
//       console.error("Map element not found:", elementId);
//       return false;
//     }
    
//     currentPosition = { 
//       lat: parseFloat(latitude), 
//       lng: parseFloat(longitude) 
//     };
    
//     // Get map component
//     const { Map } = await google.maps.importLibrary("maps");
    
//     // Get marker component
//     const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");
    
//     console.log("Creating map in element:", elementId);
    
//     // Create new map
//     mapInstance = new Map(mapElement, {
//       zoom: 16,
//       center: currentPosition,
//       mapId: MAP_ID,
//       mapTypeControl: false,
//       fullscreenControl: false,
//       streetViewControl: false,
//       zoomControl: true,
//     });
    
//     // Create a pin element
//     const pinElement = new PinElement({
//       scale: 1.2,
//       background: "#FF5252",
//       glyphColor: "#FFFFFF",
//       borderColor: "#D32F2F",
//     });
    
//     // Create advanced marker
//     advancedMarker = new AdvancedMarkerElement({
//       map: mapInstance,
//       position: currentPosition,
//       title: address || "Selected Location",
//       content: pinElement.element,
//       gmpClickable: true,
//     });
    
//     // Set up map move event to reposition the marker
//     mapInstance.addListener('center_changed', () => {
//       if (!mapInstance) return;
      
//       const center = mapInstance.getCenter();
//       if (advancedMarker && center && isDraggingMap) {
//         advancedMarker.position = center;
//       }
      
//       // Send message to Dart
//       window.postMessage({
//         type: 'mapMoved',
//         latitude: center.lat(),
//         longitude: center.lng()
//       }, '*');
//     });
    
//     console.log("Advanced map initialized successfully");
//     return true;
//   } catch (error) {
//     console.error("Error initializing advanced map:", error);
//     return false;
//   }
// };

// // Update marker position
// window.updateMarkerPosition = function(latitude, longitude) {
//   if (!mapInstance || !advancedMarker) {
//     console.error("Map or marker not initialized");
//     return false;
//   }
  
//   try {
//     const position = { 
//       lat: parseFloat(latitude), 
//       lng: parseFloat(longitude) 
//     };
    
//     advancedMarker.position = position;
//     mapInstance.panTo(position);
    
//     return true;
//   } catch (error) {
//     console.error("Error updating marker position:", error);
//     return false;
//   }
// };

// // Get current marker position
// window.getMarkerPosition = function() {
//   if (!advancedMarker) {
//     console.error("Marker not initialized");
//     return null;
//   }
  
//   try {
//     const position = advancedMarker.position;
//     return {
//       latitude: position.lat(),
//       longitude: position.lng()
//     };
//   } catch (error) {
//     console.error("Error getting marker position:", error);
//     return null;
//   }
// };

// // Function to recenter the map on the current location
// window.recenterMap = function() {
//   if (!mapInstance || !currentPosition) {
//     console.error("Map not initialized or position unknown");
//     return false;
//   }
  
//   try {
//     mapInstance.panTo(currentPosition);
//     if (advancedMarker) {
//       advancedMarker.position = currentPosition;
//     }
    
//     return true;
//   } catch (error) {
//     console.error("Error recentering map:", error);
//     return false;
//   }
// };

// // Set map dragging mode
// window.setMapDragging = function(dragging) {
//   if (!mapInstance) {
//     console.error("Map not initialized");
//     return false;
//   }
  
//   try {
//     isDraggingMap = dragging;
    
//     // Toggle dragging mode visual changes
//     if (dragging) {
//       // Show a center crosshair or indicator when in dragging mode
//       const mapDiv = mapInstance.getDiv();
//       let centerPin = document.getElementById('map-center-pin');
      
//       if (!centerPin) {
//         centerPin = document.createElement('div');
//         centerPin.id = 'map-center-pin';
//         centerPin.style.position = 'absolute';
//         centerPin.style.top = '50%';
//         centerPin.style.left = '50%';
//         centerPin.style.transform = 'translate(-50%, -50%)';
//         centerPin.style.width = '20px';
//         centerPin.style.height = '20px';
//         centerPin.style.backgroundImage = 'url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns=\\'http://www.w3.org/2000/svg\\' width=\\'24\\' height=\\'24\\' viewBox=\\'0 0 24 24\\' fill=\\'none\\' stroke=\\'%23D32F2F\\' stroke-width=\\'2\\' stroke-linecap=\\'round\\' stroke-linejoin=\\'round\\'%3e%3cpath d=\\'M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z\\'%3e%3c/path%3e%3ccircle cx=\\'12\\' cy=\\'10\\' r=\\'3\\'%3e%3c/circle%3e%3c/svg%3e")';
//         centerPin.style.backgroundRepeat = 'no-repeat';
//         centerPin.style.backgroundPosition = 'center';
//         centerPin.style.zIndex = '1000';
//         centerPin.style.pointerEvents = 'none'; // Allow clicks to pass through
//         centerPin.style.animation = 'bounce 1s infinite alternate';
        
//         // Add animation style
//         const style = document.createElement('style');
//         style.textContent = `
//           @keyframes bounce {
//             from { transform: translate(-50%, -50%) scale(1); }
//             to { transform: translate(-50%, -50%) scale(1.2); }
//           }
//         `;
//         document.head.appendChild(style);
        
//         mapDiv.appendChild(centerPin);
//       } else {
//         centerPin.style.display = 'block';
//       }
      
//       // Hide the advanced marker
//       if (advancedMarker) {
//         advancedMarker.map = null;
//       }
//     } else {
//       // Hide the center pin
//       const centerPin = document.getElementById('map-center-pin');
//       if (centerPin) {
//         centerPin.style.display = 'none';
//       }
      
//       // Restore the advanced marker at the current center position
//       if (advancedMarker) {
//         const center = mapInstance.getCenter();
//         advancedMarker.position = center;
//         advancedMarker.map = mapInstance;
//       }
//     }
    
//     return true;
//   } catch (error) {
//     console.error("Error setting map dragging mode:", error);
//     return false;
//   }
// };

// // Geolocation service
// window.getCurrentLocation = function() {
//   return new Promise((resolve, reject) => {
//     if (!navigator.geolocation) {
//       reject(new Error('Geolocation is not supported by this browser'));
//       return;
//     }
    
//     navigator.geolocation.getCurrentPosition(
//       (position) => {
//         resolve({
//           latitude: position.coords.latitude,
//           longitude: position.coords.longitude,
//           accuracy: position.coords.accuracy
//         });
//       },
//       (error) => {
//         console.error('Geolocation error:', error.message);
        
//         // Try IP-based fallback
//         fetch('https://ipapi.co/json/')
//           .then(response => response.json())
//           .then(data => {
//             if (data.latitude && data.longitude) {
//               resolve({
//                 latitude: data.latitude,
//                 longitude: data.longitude,
//                 accuracy: 1000 // Assume 1km accuracy for IP geolocation
//               });
//             } else {
//               reject(new Error('Could not determine location'));
//             }
//           })
//           .catch(err => {
//             reject(error);
//           });
//       },
//       { 
//         enableHighAccuracy: true, 
//         timeout: 10000, 
//         maximumAge: 60000 
//       }
//     );
//   });
// };
// ''';

//     final scriptElement = html.ScriptElement()
//       ..id = '__mapsInteropScript__'
//       ..type = 'text/javascript'
//       ..innerHtml = mapScripts;

//     html.document.head!.append(scriptElement);
//     await Future.delayed(const Duration(milliseconds: 300));
//   }

//   Future<MapPosition?> getMarkerPosition() async {
//     try {
//       final result = _getMarkerPositionJS();
//       if (result == null) return null;
//       final lat = js_unsafe.getProperty(result, 'latitude') as num?;
//       final lng = js_unsafe.getProperty(result, 'longitude') as num?;
//       if (lat == null || lng == null) return null;
//       return MapPosition(latitude: lat.toDouble(), longitude: lng.toDouble());
//     } catch (_) {
//       return null;
//     }
//   }
// }
