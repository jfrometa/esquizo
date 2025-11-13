// lib/src/utils/maps_initializer_web.dart

import 'dart:async';
// Core js_interop types
import 'dart:js_interop' as js_interop;
// Annotations like @JS
import 'package:js/js.dart' as js;
// Converters like JSPromise.toDart

// Define the JS function signature using js_interop.
// This assumes 'initMapsWhenNeeded' is a function attached to the global
// window object in your web environment (e.g., defined in index.html)
// and that it returns a JavaScript Promise.
@js.JS('initMapsWhenNeeded')
external js_interop.JSPromise _initMapsWhenNeededJS(); // The external JS function

// Actual web implementation that calls the JavaScript function.
// This file is used ONLY when the application is compiled for the web.
Future<void> initializeMapsIfWeb() async {
  try {
    print('Initializing Google Maps for Web via JS interop...');
    // Convert the JSPromise returned by the JS function to a Dart Future
    // and await its completion.
    await _initMapsWhenNeededJS().toDart;
    print('Google Maps for Web JS initialization successful.');
  } catch (e) {
    // Catch any errors during the JS call or Promise resolution.
    print('Error initializing Google Maps via JS interop: $e');
    // Depending on the app's needs, you might want to:
    // - Log this error to an analytics service.
    // - Show a user-facing error message indicating map features might fail.
    // - Rethrow the error if it's critical.
    // For now, we just print it.
  }
}
