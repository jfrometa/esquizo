// lib/src/screens/location/web_map_init.dart
// Web-specific maps initialization using dart:js_interop
// Compatible with both dart2js and WASM builds.

import 'dart:async';
import 'dart:js_interop';

@JS('initMapsWhenNeeded')
external JSPromise _initMapsWhenNeededJS();

/// Actual web implementation that calls the JavaScript function.
/// This file is used ONLY when the application is compiled for the web.
Future<void> initializeMapsIfWeb() async {
  try {
    // Convert the JSPromise returned by the JS function to a Dart Future
    // and await its completion.
    await _initMapsWhenNeededJS().toDart;
  } catch (e) {
    // Silently handle errors - logging should be done via a proper logger
  }
}
