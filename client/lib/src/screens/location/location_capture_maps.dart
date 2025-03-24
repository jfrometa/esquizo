
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:js_util' as js_util;
class LocationCaptureWidget extends StatefulWidget {
  const LocationCaptureWidget({super.key});

  @override
  LocationCaptureWidgetState createState() => LocationCaptureWidgetState();
}

class LocationCaptureWidgetState extends State<LocationCaptureWidget> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Automatically get the location when the widget is created
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // Show the loading indicator
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      // Ensure location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }
      await _initGoogleMaps();

      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the current position and remove the loading indicator
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to get location: $e'),
        backgroundColor: Colors.brown[200], // Light brown background color
        duration:
            const Duration(milliseconds: 500), // Display for half a second),
      ));
    }
  }

  Future<void> _initGoogleMaps() async {
    try {
      // Call our optimized maps loading function from index.html
           await js_util.promiseToFuture(
      js_util.callMethod(js_util.globalThis, 'initMapsWhenNeeded', [])
    );
    
      // if (mounted) {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // }
    } catch (e) {
      print('Error initializing Google Maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          )
        : _currentPosition == null
            ? ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Obtener ubicación'),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 15.0,
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Reintentar'),
                  ),
                ],
              );
  }
}
