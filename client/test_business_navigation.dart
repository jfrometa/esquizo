// Test script to verify business navigation behavior
// Run with: dart run test_business_navigation.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 Testing Business Navigation Routing');
  print('=====================================');

  // Test routes
  final testRoutes = [
    'http://localhost:3000/',
    'http://localhost:3000/g3',
    'http://localhost:3000/g3/menu',
    'http://localhost:3000/g3/carrito',
    'http://localhost:3000/g3/cuenta',
    'http://localhost:3000/menu',
    'http://localhost:3000/carrito',
    'http://localhost:3000/cuenta',
  ];

  print('\n📋 Testing Routes:');
  for (final route in testRoutes) {
    await testRoute(route);
    await Future.delayed(Duration(milliseconds: 500));
  }

  print('\n✅ Navigation test completed');
}

Future<void> testRoute(String url) async {
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    print('🔗 $url -> Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('   ✅ Route accessible');
    } else {
      print('   ❌ Route returned ${response.statusCode}');
    }

    client.close();
  } catch (e) {
    print('   ❌ Error accessing route: $e');
  }
}
