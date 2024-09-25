import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui_web' as ui_web;

import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class LocationCaptureBottomSheet extends StatefulWidget {
  final Function(String latitude, String longitude, String address)
      onLocationCaptured;

  const LocationCaptureBottomSheet({Key? key, required this.onLocationCaptured})
      : super(key: key);

  @override
  _LocationCaptureBottomSheetState createState() =>
      _LocationCaptureBottomSheetState();
}

class _LocationCaptureBottomSheetState
    extends State<LocationCaptureBottomSheet> {
  String? _latitude;
  String? _longitude;
  String? _address;
  bool _isLoading = false;
  final String _googleGeocodeApiKey =
      'AIzaSyAlk83WpDsAWqaa4RqI4mxa5IYPiuZldek'; // Replace with your actual Google API key

  @override
  void initState() {
    super.initState();

    // Fetch location as soon as the widget is initialized
    _getCurrentLocation();

    // Register the iframe element for Google Maps
    ui_web.platformViewRegistry.registerViewFactory('google-map', (int viewId) {
      final mapIframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.height = '100%' // Set height explicitly
        ..style.width = '100%' // Set width explicitly
        ..src = _latitude != null && _longitude != null
            ? _getMapUrl(_latitude!, _longitude!)
            : ''; // Empty if the location isn't ready
      return mapIframe;
    });
  }

  void _getCurrentLocation() {
    setState(() {
      _isLoading = true;
    });

    html.window.navigator.geolocation.getCurrentPosition().then((position) {
      setState(() {
        _latitude = position.coords?.latitude.toString();
        _longitude = position.coords?.longitude.toString();
        _getHumanReadableAddress(_latitude!, _longitude!);
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get location')),
        );
      }
    });
  }

  Future<void> _getHumanReadableAddress(
      String latitude, String longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_googleGeocodeApiKey';

    try {
      final response = await http.get(Uri.parse(url));
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

  String _getMapUrl(String latitude, String longitude) {
    return 'https://www.google.com/maps/embed/v1/view?key=$_googleGeocodeApiKey&center=$latitude,$longitude&zoom=15';
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
          const Text(
            'Confirma tu dirección de envío',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 16),
          if (_latitude == null || _longitude == null)
            _isLoading
                ? const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0, // Adjust stroke width if necessary
                        color: ColorsPaletteRedonda
                            .primary, // Primary color from theme
                      ),
                    ),
                  )
                : const Text('Ubicación actual')
          else ...[
            // Text('Latitud: $_latitude, Longitud: $_longitude'),
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
            const Expanded(
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: HtmlElementView(
                  viewType: 'google-map', // Must match the registered view type
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Action buttons: Accept, Retry, Cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800],
                    foregroundColor: Colors.white),
                onPressed: () {
                  // Retry - Get location again
                  _getCurrentLocation();
                },
                child: const Text(
                  'Reintentar',
                  // style: TextStyle(color: Colors.deepOrange),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Accept the location
                  if (_latitude != null && _longitude != null) {
                    widget.onLocationCaptured(
                        _latitude!, _longitude!, _address!);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPaletteRedonda.lightBrown,
                    foregroundColor: Colors.white),
                child: const Text('Aceptar'),
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white),
                onPressed: () {
                  // Cancel operation
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
