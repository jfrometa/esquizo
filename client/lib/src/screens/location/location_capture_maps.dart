// lib/src/screens/location/location_capture.dart

// Used for checks if needed, though conditional import handles the primary case
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Conditional Import:
// Imports the default stub first.
// If 'dart:js_interop' library is available (i.e., compiling for web),
// it replaces the import with the web-specific implementation.
import './mobile_map_init.dart' // Default (mobile) implementation
    if (dart.library.js_interop) './web_map_init.dart'; // Web implementation

class LocationCaptureWidget extends StatefulWidget {
  const LocationCaptureWidget({super.key});

  @override
  LocationCaptureWidgetState createState() => LocationCaptureWidgetState();
}

class LocationCaptureWidgetState extends State<LocationCaptureWidget> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage; // To store and display potential error messages

  @override
  void initState() {
    super.initState();
    // Initiate the process to get location and set up the map when the widget first loads.
    _fetchLocationAndInitializeMap();
  }

  // Central function to handle map initialization and location fetching.
  Future<void> _fetchLocationAndInitializeMap() async {
    // Ensure the widget is still mounted before proceeding with async operations.
    if (!mounted) return;

    setState(() {
      _isLoading = true; // Show loading indicator
      _errorMessage = null; // Clear any previous errors
    });

    try {
      // Step 1: Initialize Google Maps (conditionally runs JS on web).
      // This calls the function imported via the conditional import mechanism.
      await initializeMapsIfWeb();

      // Step 2: Check and request location permissions.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        // Handle cases where permission is still denied or permanently denied.
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception(
              'Location permission denied. Please enable it in app settings.');
        }
      }

      // Step 3: Check if location services (GPS) are enabled on the device.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
            'Location services are disabled. Please enable GPS/Location.');
      }

      // Step 4: Get the current geographical position.
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Request high accuracy
      );

      // Step 5: Update the state with the obtained location if the widget is still mounted.
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false; // Hide loading indicator, show map
        });
      }
    } catch (e) {
      // Catch errors from any step (initialization, permissions, service check, position fetch).
      print('Error during location/map setup: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading indicator
          // Store a user-friendly error message.
          _errorMessage = 'Failed to get location: ${e.toString()}';
        });
        // Show a snackbar to inform the user about the error.
        _showErrorSnackBar(_errorMessage!);
      }
    }
  }

  // Helper function to display error messages in a SnackBar.
  void _showErrorSnackBar(String message) {
    // Ensure context is available and widget is mounted.
    if (!mounted || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent, // Use a distinct color for errors
      duration: const Duration(seconds: 4), // Give user time to read
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Use a Scaffold as the base for pages, providing structure for AppBar, Body, SnackBar etc.
    return Scaffold(
      // appBar: AppBar( // Optional: Add an AppBar if needed
      //   title: const Text('Select Location'),
      // ),
      body: _buildBodyContent(), // Delegate body building to a separate method
    );
  }

  // Builds the main content based on the current state (_isLoading, _errorMessage, _currentPosition).
  Widget _buildBodyContent() {
    // State 1: Loading
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }

    // State 2: Error occurred before getting a position
    if (_errorMessage != null && _currentPosition == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed:
                    _fetchLocationAndInitializeMap, // Allow user to retry
              ),
            ],
          ),
        ),
      );
    }

    // State 3: Position successfully obtained
    if (_currentPosition != null) {
      return GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          // Store the controller for potential future use (e.g., programmatically moving the camera).
          _mapController = controller;
        },
        // Set the initial camera view to the user's current location.
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15.0, // Adjust zoom level as needed
        ),
        // Add a marker at the user's current location.
        markers: {
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(
              title: 'Your Current Location',
              // snippet: 'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}' // Optional snippet
            ),
          ),
        },
        myLocationEnabled:
            true, // Show the blue dot indicating user's location.
        myLocationButtonEnabled:
            true, // Show the button to center the map on the user's location.
        zoomControlsEnabled: true, // Show zoom controls (+/-)
        mapToolbarEnabled: true, // Show toolbar (directions, open in maps app)
      );
    }

    // Fallback State: Should not typically be reached if logic is correct,
    // but provides a button if position is null without an error.
    return Center(
      child: ElevatedButton(
        onPressed: _fetchLocationAndInitializeMap,
        child: const Text('Get Location'),
      ),
    );
  }
}
