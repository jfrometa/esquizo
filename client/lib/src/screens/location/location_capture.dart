import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// Import for web settings
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers/delivery_location_provider.dart';

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
  bool _isMapView = true; // Toggle for switching views
  GoogleMapController? _mapController;
  LatLng? _currentPosition;

  final String _googleGeocodeApiKey =
      'AIzaSyAlk83WpDsAWqaa4RqI4mxa5IYPiuZldek'; // Replace with your Google API key

  // Web settings for Geolocator
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  // Form field controllers for manual address entry
  final _addressController = TextEditingController();
  final _floorController = TextEditingController();
  final _cityController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadSavedLocation();
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

  // Update _submitForm method
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
      widget.onLocationCaptured('0.0', '0.0', fullAddress);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese todos los detalles')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if location services are enabled
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isLocationEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
          backgroundColor: Colors.brown[200], // Light brown background color
          duration:
              const Duration(milliseconds: 500), // Display for half a second),
        ));
        throw Exception("Location services are disabled.");
      }

      // Request permission for location services
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location permission denied. Please enable it.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permissions are permanently denied. Please enable them in your settings.')),
        );
        return;
      }

      // Get the current position using web settings for web-specific configuration
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Fetch human-readable address
      _getHumanReadableAddress(_latitude!, _longitude!);
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
      setState(() {
        _isLoading = false;
      });
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
            _isLoading = false;
          });
        } else {
          setState(() {
            _address = 'Address not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _address = 'Error retrieving address';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 600 && size.width <= 1024;

    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.85,
        maxWidth: isDesktop ? 800 : double.infinity,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
            icon: Icon(Icons.my_location, color: colorScheme.primary),
            onPressed: _getCurrentLocation,
            tooltip: 'Obtener ubicación actual',
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
        if (_address != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _address!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 16.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: _currentPosition!,
                  infoWindow: InfoWindow(title: _address),
                ),
              },
            ),
          ),
        ),
      ],
    );
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
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
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
            onPressed: () {
              if (_isMapView) {
                if (_latitude != null && _longitude != null && _address != null) {
                  widget.onLocationCaptured(_latitude!, _longitude!, _address!);
                  Navigator.of(context).pop();
                }
              } else {
                _submitForm();
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
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
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}
