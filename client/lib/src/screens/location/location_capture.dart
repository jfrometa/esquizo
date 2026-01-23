import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/delivery_location_provider.dart';

// Web bridge (conditionally imports the web implementation only on web)
import 'location_web_bridge_stub.dart'
    if (dart.library.js_interop) 'location_web_bridge_web.dart';

// Use this ID for consistent view registration
const String mapElementId = 'google-map-view';

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

  // Web interop bridge (no-op on non-web)
  final LocationWebBridge _web = const LocationWebBridge();

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
    if (kIsWeb) _web.dispose();
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
    if (!kIsWeb) return;
    if (!_hasRegisteredFactory) {
      await _web.registerViewFactory(mapElementId);
      _hasRegisteredFactory = true;
    }
    _isViewRegistered = true;
  }

  void _setupWebMapMovedListener() {
    if (!kIsWeb) return;
    try {
      _web.setupMapMovedListener(_updatePositionFromWeb);
    } catch (e) {
      // Failed to set up web map listener
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
      await _web.ensureMapScriptsLoaded();

      // Initialize the maps library via JS interop
      final bool mapsLoaded = await _web.initializeMaps();

      setState(() {
        _isMapInitialized = mapsLoaded;
      });

      if (mapsLoaded) {
        _mapsInitialized.complete(true);
      } else {
        _mapsInitialized.completeError('Failed to initialize maps');
      }
    } catch (e) {
      _mapsInitialized.completeError(e);
      setState(() {
        _isMapInitialized = false;
      });
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
      _showSnackBar('Error al obtener ubicación: $e', isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeWebMapWithPosition() async {
    if (!kIsWeb || !_isViewRegistered || _currentPosition == null) return;

    try {
      // Initialize the map using our JavaScript function
      final bool success = await _web.initializeAdvancedMap(
        mapElementId,
        _latitude,
        _longitude,
        _address ?? 'Su ubicación',
      );

      if (success) {
        // Map success
      } else {
        // Map failure
      }
    } catch (e) {
      // Map error
    }
  }

  // Web-specific location retrieval
  Future<void> _getWebLocation() async {
    if (!kIsWeb) return;

    try {
      final loc = await _web.getCurrentLocation();
      if (loc == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _latitude = loc.latitude.toString();
        _longitude = loc.longitude.toString();
        _currentPosition = LatLng(loc.latitude, loc.longitude);
        _accuracyInMeters = loc.accuracyInMeters;
        _isLowAccuracy = loc.accuracyInMeters > 100; // low accuracy if > 100m
        _isLoading = false;
      });

      // Fetch human-readable address
      await _getHumanReadableAddress(_latitude!, _longitude!);
    } catch (e) {
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
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final data = json.decode(response.body);
          final lat = data['latitude'];
          final lng = data['longitude'];

          if (lat != null && lng != null) {
            setState(() {
              _latitude = lat.toString();
              _longitude = lng.toString();
              _currentPosition = LatLng(lat, lng);
              _isLowAccuracy = true; // IP geolocation is always low accuracy
              _accuracyInMeters =
                  1000; // Assume 1km accuracy for IP geolocation
            });

            // Fetch address for this location
            await _getHumanReadableAddress(_latitude!, _longitude!);
          }
        } catch (e) {
          debugPrint('Error parsing IP location: $e');
        }
      }
    } catch (e) {
      // Fallback error
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
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['results'] != null &&
              (jsonResponse['results'] as List).isNotEmpty) {
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
        } catch (e) {
          debugPrint('Error decoding geocode response: $e');
          setState(() {
            _address = 'Error al procesar dirección';
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
        _web.setMapDragging(_isDraggingMap);
      } catch (e) {
        // Error setting dragging
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
        final pos = await _web.getMarkerPosition();
        if (pos != null) {
          _latitude = pos.latitude.toString();
          _longitude = pos.longitude.toString();
        }
      } catch (e) {
        // Position fetch error
      }
    }

    // Otherwise use map location
    widget.onLocationCaptured(_latitude!, _longitude!, _address!);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 1024;

    // Wrapping in WillPopScope to prevent dismissal by back button.
    // Also note: when showing this bottom sheet, set isDismissible: false and
    // enableDrag: false in showModalBottomSheet().
    return PopScope(
      canPop: false,
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
              color: Colors.black.withValues(alpha: 0.1),
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
              child: SingleChildScrollView(
                child: _isMapView
                    ? _buildMapView(colorScheme, theme)
                    : _buildAddressFormView(colorScheme, theme),
              ),
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
      return HtmlElementView(viewType: mapElementId);
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
      // Map initialization error - show fallback
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
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
