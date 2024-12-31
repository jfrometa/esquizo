import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// Import for web settings
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class LocationCaptureBottomSheet extends StatefulWidget {
  final Function(String latitude, String longitude, String address)
      onLocationCaptured;

  const LocationCaptureBottomSheet(
      {super.key, required this.onLocationCaptured});

  @override
  LocationCaptureBottomSheetState createState() =>
      LocationCaptureBottomSheetState();
}

class LocationCaptureBottomSheetState
    extends State<LocationCaptureBottomSheet> {
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
    return _buildBottomSheetContent();
  }

  Widget _buildBottomSheetContent() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 500, // Adjust height of the BottomSheet
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row with title and switch view button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Confirma tu dirección de envío',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              !_isMapView
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: Icon(Icons.refresh,
                          color: ColorsPaletteRedonda.primary),
                      onPressed: () {
                        _getCurrentLocation(); // Trigger location refresh
                      },
                    ),
              IconButton(
                icon: Icon(_isMapView ? Icons.edit : Icons.map,
                    color: ColorsPaletteRedonda.primary),
                onPressed: () {
                  setState(() {
                    _isMapView = !_isMapView;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Conditional rendering for map view or form view
          if (_isMapView) ...[
            if (_isLoading)
              const Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                    color: ColorsPaletteRedonda.primary,
                  ),
                ),
              )
            else if (_currentPosition != null) ...[
              const SizedBox(height: 10),
              if (_address != null)
                Text(
                  'Dirección: $_address',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: ColorsPaletteRedonda.primary),
                ),
              const SizedBox(height: 10),
              if (_currentPosition != null)
                // Full-Screen Map
                SizedBox(
                  // Make sure the container takes all available space
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 16.0,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: {
                      Marker(
                        markerId: const MarkerId('current_location'),
                        position: _currentPosition!,
                      ),
                    },
                  ),
                ),
            ] else
              const Text('Ubicación no disponible'),
          ] else ...[
            _buildAddressForm(),
          ],
          const SizedBox(height: 16),
          const Spacer(),
          // Row with equal-sized buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded(
              //   child: TextButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.yellow[800],
              //       foregroundColor: Colors.white,
              //     ),
              //     onPressed: () {
              //       if (_isMapView) {
              //         _getCurrentLocation();
              //       } else {
              //         _clearForm();
              //       }
              //     },
              //     child: Text(
              //       _isMapView ? 'Reintentar' : 'Limpiar',
              //       style: Theme.of(context)
              //           .textTheme
              //           .bodyMedium
              //           ?.copyWith(color: ColorsPaletteRedonda.white),
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 10), // Spacing between buttons

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_isMapView) {
                      if (_latitude != null &&
                          _longitude != null &&
                          _address != null) {
                        widget.onLocationCaptured(
                            _latitude!, _longitude!, _address!);
                        Navigator.of(context).pop();
                      }
                    } else {
                      _submitForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPaletteRedonda.deepBrown1,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aceptar'),
                ),
              ),
              const SizedBox(width: 10), // Spacing between buttons
              Expanded(
                child: TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _addressController,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: ColorsPaletteRedonda.primary),
          decoration: InputDecoration(
            labelText: 'Dirección',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.location_on),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: ColorsPaletteRedonda.primary, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: ColorsPaletteRedonda.deepBrown1),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _floorController,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: ColorsPaletteRedonda.primary),
          decoration: InputDecoration(
            labelText: 'Piso',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.layers),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: ColorsPaletteRedonda.primary, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: ColorsPaletteRedonda.deepBrown1),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _cityController,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: ColorsPaletteRedonda.primary),
          decoration: InputDecoration(
            labelText: 'Ciudad',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.location_city),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: ColorsPaletteRedonda.primary, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: ColorsPaletteRedonda.deepBrown1),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _noteController,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: ColorsPaletteRedonda.primary),
          decoration: InputDecoration(
            labelText: 'Nota para la entrega',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.note),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: ColorsPaletteRedonda.primary, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: ColorsPaletteRedonda.deepBrown1),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    final address = _addressController.text;
    final floor = _floorController.text;
    final city = _cityController.text;
    final note = _noteController.text;

    if (address.isNotEmpty && city.isNotEmpty) {
      final fullAddress = '$address, Piso: $floor, $city. Nota: $note';
      widget.onLocationCaptured('0.0', '0.0', fullAddress);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese todos los detalles')),
      );
    }
  }

  void _clearForm() {
    _addressController.clear();
    _floorController.clear();
    _cityController.clear();
    _noteController.clear();
  }
}
