// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/dishes/dish_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: RestaurantApp()));
}

// Theme configuration with Material 3
class RestaurantApp extends StatelessWidget {
  const RestaurantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant QR System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E3200),
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Montserrat'),
          displayMedium: TextStyle(fontFamily: 'Montserrat'),
          displaySmall: TextStyle(fontFamily: 'Montserrat'),
          headlineMedium: TextStyle(fontFamily: 'Montserrat'),
          headlineSmall: TextStyle(fontFamily: 'Montserrat'),
          titleLarge: TextStyle(fontFamily: 'Montserrat'),
          titleMedium: TextStyle(fontFamily: 'Montserrat'),
          titleSmall: TextStyle(fontFamily: 'Montserrat'),
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
          bodySmall: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E3200),
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Montserrat'),
          displayMedium: TextStyle(fontFamily: 'Montserrat'),
          displaySmall: TextStyle(fontFamily: 'Montserrat'),
          headlineMedium: TextStyle(fontFamily: 'Montserrat'),
          headlineSmall: TextStyle(fontFamily: 'Montserrat'),
          titleLarge: TextStyle(fontFamily: 'Montserrat'),
          titleMedium: TextStyle(fontFamily: 'Montserrat'),
          titleSmall: TextStyle(fontFamily: 'Montserrat'),
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
          bodySmall: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const QRCodeScreen(),
    );
  }
}

// Home screen with navigation options
class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar with logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'La Redonda',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      child: IconButton(
                        icon: const Icon(Icons.person_outline),
                        onPressed: () {
                          // Navigate to profile or show login
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile feature coming soon'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Welcome section
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to La Redonda',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Experience our cuisine both at the restaurant and online',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Main options
                Text(
                  'What would you like to do?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Options Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    // Scan QR option
                    _buildOptionCard(
                      context: context,
                      icon: Icons.qr_code_scanner,
                      title: 'Scan QR Code',
                      description: 'Scan table QR to place order',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRScannerScreen(),
                        ),
                      ),
                    ),
                    
                    // View Menu option
                    _buildOptionCard(
                      context: context,
                      icon: Icons.restaurant_menu,
                      title: 'View Menu',
                      description: 'Browse our delicious options',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MenuScreen(),
                        ),
                      ),
                    ),
                    
                    // Table Reservation option
                    _buildOptionCard(
                      context: context,
                      icon: Icons.event_seat,
                      title: 'Reserve Table',
                      description: 'Book your visit in advance',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReservationScreen(),
                        ),
                      ),
                    ),
                    
                    // Restaurant Info option
                    _buildOptionCard(
                      context: context,
                      icon: Icons.info_outline,
                      title: 'Restaurant Info',
                      description: 'About us, hours, location',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RestaurantInfoScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Admin Section (would be shown only to staff in a real app)
                Text(
                  'Restaurant Staff',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Generate QR Option
                _buildAdminCard(
                  context: context,
                  icon: Icons.qr_code,
                  title: 'Generate Table QR',
                  description: 'Create QR codes for tables',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRGeneratorScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAdminCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------ DATA MODELS ------

// Table model
class RestaurantTable {
  final int id;
  final String name;
  final int capacity;
  final bool isAvailable;

  RestaurantTable({
    required this.id,
    required this.name,
    required this.capacity,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'isAvailable': isAvailable,
    };
  }

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

// Menu category model
class Category {
  final int id;
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

// Dish model
class Dish {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String? imageUrl;
  final int categoryId;
  final List<String> ingredients;
  final bool isAvailable;

  Dish({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.rating = 0.0,
    this.imageUrl,
    required this.categoryId,
    this.ingredients = const [],
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'rating': rating,
      'image': imageUrl,
      'categoryId': categoryId,
      'ingredients': ingredients,
      'isAvailable': isAvailable,
    };
  }

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      rating: json['rating']?.toDouble() ?? 0.0,
      imageUrl: json['image'],
      categoryId: json['categoryId'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

// QR Code data model
class QRCodeData {
  final int tableId;
  final String tableName;
  final String restaurantId;
  final DateTime generatedAt;

  QRCodeData({
    required this.tableId,
    required this.tableName,
    required this.restaurantId,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'tableName': tableName,
      'restaurantId': restaurantId,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    return QRCodeData(
      tableId: json['tableId'],
      tableName: json['tableName'],
      restaurantId: json['restaurantId'],
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  String toQRString() {
    return jsonEncode(toJson());
  }

  static QRCodeData? fromQRString(String qrString) {
    try {
      final Map<String, dynamic> json = jsonDecode(qrString);
      return QRCodeData.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}

// ------ PROVIDERS ------

// Tables provider
final tablesProvider = FutureProvider<List<RestaurantTable>>((ref) async {
  // In a real app, fetch from an API
  await Future.delayed(const Duration(milliseconds: 800));
  
  return [
    RestaurantTable(id: 1, name: 'Table 1', capacity: 2),
    RestaurantTable(id: 2, name: 'Table 2', capacity: 4),
    RestaurantTable(id: 3, name: 'Table 3', capacity: 6),
    RestaurantTable(id: 4, name: 'Table 4', capacity: 2),
    RestaurantTable(id: 5, name: 'Table 5', capacity: 8),
  ];
});

// Selected table provider
final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  // In a real app, fetch from an API
  await Future.delayed(const Duration(milliseconds: 800));
  
  return [
    Category(id: 1, name: 'Starters', imageUrl: 'assets/images/starters.jpg'),
    Category(id: 2, name: 'Main Courses', imageUrl: 'assets/images/main.jpg'),
    Category(id: 3, name: 'Desserts', imageUrl: 'assets/images/desserts.jpg'),
    Category(id: 4, name: 'Drinks', imageUrl: 'assets/images/drinks.jpg'),
  ];
});

// Dishes provider
final dishesProvider = FutureProvider<List<Dish>>((ref) async {
  // In a real app, fetch from an API
  await Future.delayed(const Duration(milliseconds: 1000));
  
  return [
    Dish(
      id: 1, 
      title: 'Caesar Salad', 
      description: 'Fresh romaine lettuce, parmesan cheese, and our homemade dressing',
      price: 12.99,
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1',
      categoryId: 1,
      ingredients: ['Romaine lettuce', 'Parmesan', 'Croutons', 'Caesar dressing'],
    ),
    Dish(
      id: 2, 
      title: 'Grilled Salmon', 
      description: 'Atlantic salmon served with seasonal vegetables',
      price: 24.99,
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288',
      categoryId: 2,
      ingredients: ['Salmon fillet', 'Lemon', 'Herbs', 'Seasonal vegetables'],
    ),
    Dish(
      id: 3, 
      title: 'Chocolate Lava Cake', 
      description: 'Warm chocolate cake with a molten center, served with vanilla ice cream',
      price: 9.99,
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1602351447937-745cb720612f',
      categoryId: 3,
      ingredients: ['Dark chocolate', 'Flour', 'Eggs', 'Vanilla ice cream'],
    ),
    // Add more dishes as needed
  ];
});

// Filtered dishes by category provider
final filteredDishesProvider = FutureProvider.family<List<Dish>, int?>((ref, categoryId) async {
  final dishesAsync = ref.watch(dishesProvider);
  
  return dishesAsync.when(
    data: (dishes) {
      if (categoryId == null) return dishes;
      return dishes.where((dish) => dish.categoryId == categoryId).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ------ SCREENS ------

// QR Scanner Screen
class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;
  String? scanError;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Table QR Code'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Scanner
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && isScanning) {
                      setState(() {
                        isScanning = false;
                      });
                      
                      final String code = barcodes.first.rawValue ?? '';
                      _processQRCode(code);
                    }
                  },
                ),
                
                // Overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Point camera at table QR code',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Error message if any
                if (scanError != null)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          scanError!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Bottom panel
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Having trouble?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Reset scanner
                      setState(() {
                        isScanning = true;
                        scanError = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Again'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processQRCode(String data) {
    try {
      final qrData = QRCodeData.fromQRString(data);
      
      if (qrData == null) {
        setState(() {
          scanError = 'Invalid QR code format';
          isScanning = true;
        });
        return;
      }
      
      // Find the table in our database
      final tablesAsync = ref.read(tablesProvider);
      
      tablesAsync.whenData((tables) {
        final table = tables.firstWhere(
          (t) => t.id == qrData.tableId,
          orElse: () => throw Exception('Table not found'),
        );
        
        // Set the selected table
        ref.read(selectedTableProvider.notifier).state = table;
        
        // Navigate to the menu screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TableMenuScreen(
              tableData: qrData,
            ),
          ),
        );
      });
    } catch (e) {
      setState(() {
        scanError = 'Error processing QR code: ${e.toString()}';
        isScanning = true;
      });
    }
  }
}

// Table Menu Screen (after scanning)
class TableMenuScreen extends ConsumerWidget {
  final QRCodeData tableData;
  
  const TableMenuScreen({
    Key? key,
    required this.tableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu - ${tableData.tableName}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are at ${tableData.tableName}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse our menu and place your order',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Categories
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Categories list
          SizedBox(
            height: 120,
            child: Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoriesProvider);
                
                return categoriesAsync.when(
                  data: (categories) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDishesScreen(
                                    categoryId: category.id,
                                    categoryName: category.name,
                                    tableData: tableData,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(category.id),
                                    size: 32,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text('Error loading categories: $error'),
                  ),
                );
              },
            ),
          ),
          
          // Popular dishes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Popular Dishes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Popular dishes list
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final dishesAsync = ref.watch(dishesProvider);
                
                return dishesAsync.when(
                  data: (dishes) {
                    // Sort dishes by rating
                    final popularDishes = List<Dish>.from(dishes)
                      ..sort((a, b) => b.rating.compareTo(a.rating));
                    
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: popularDishes.length,
                      itemBuilder: (context, index) {
                        final dish = popularDishes[index];
                        return DishCard(
                          dish: dish.toJson(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DishDetailScreen(
                                  dish: dish,
                                  tableData: tableData,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text('Error loading dishes: $error'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Order button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderScreen(tableData: tableData),
            ),
          );
        },
        label: const Text('View Order'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }
  
  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.lunch_dining;
      case 2:
        return Icons.dinner_dining;
      case 3:
        return Icons.cake;
      case 4:
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }
}

// Category Dishes Screen
class CategoryDishesScreen extends ConsumerWidget {
  final int categoryId;
  final String categoryName;
  final QRCodeData tableData;
  
  const CategoryDishesScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.tableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filteredDishesAsync = ref.watch(filteredDishesProvider(categoryId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        elevation: 0,
      ),
      body: filteredDishesAsync.when(
        data: (dishes) {
          if (dishes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.no_food,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No dishes available in this category',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              final dish = dishes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DishCard(
                  dish: dish.toJson(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DishDetailScreen(
                          dish: dish,
                          tableData: tableData,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading dishes',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dish Detail Screen
class DishDetailScreen extends StatelessWidget {
  final Dish dish;
  final QRCodeData tableData;
  
  const DishDetailScreen({
    Key? key,
    required this.dish,
    required this.tableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: dish.imageUrl != null
                  ? Image.network(
                      dish.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.restaurant,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          
          // Dish details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          dish.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dish.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Price
                  const SizedBox(height: 16),
                  Text(
                    'S/ ${dish.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Description
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dish.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  
                  // Ingredients
                  if (dish.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Ingredients',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dish.ingredients.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Quantity selector
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Text(
                        'Quantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {},
                              iconSize: 20,
                            ),
                            const SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  '1',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {},
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${dish.title} added to order'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to Order'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// QR Generator Screen (for restaurant staff)
class QRGeneratorScreen extends ConsumerStatefulWidget {
  const QRGeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends ConsumerState<QRGeneratorScreen> {
  RestaurantTable? selectedTable;
  QRCodeData? generatedQRData;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tablesAsync = ref.watch(tablesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Table QR'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Staff Instructions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate a unique QR code for each table in your restaurant. Customers will scan these codes to place orders directly from their table.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Table selection
            Text(
              'Select a Table',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            tablesAsync.when(
              data: (tables) {
                return Column(
                  children: [
                    // Table grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: tables.length,
                      itemBuilder: (context, index) {
                        final table = tables[index];
                        final isSelected = selectedTable?.id == table.id;
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedTable = table;
                              generatedQRData = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withOpacity(0.5),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.table_restaurant,
                                  size: 32,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  table.name,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${table.capacity} seats',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary.withOpacity(0.8)
                                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Generate button
                    ElevatedButton.icon(
                      onPressed: selectedTable == null
                          ? null
                          : () {
                              _generateQRCode();
                            },
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Generate QR Code'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error loading tables: $error'),
              ),
            ),
            
            if (generatedQRData != null) ...[
              const SizedBox(height: 40),
              
              // QR Code section
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'QR Code for ${generatedQRData!.tableName}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // QR Code
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          QrImageView(
                            data: generatedQRData!.toQRString(),
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                            embeddedImage: AssetImage('assets/images/logo.png'),
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              size: const Size(40, 40),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Table ${generatedQRData!.tableName}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scan to access digital menu',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // In a real app, this would save the QR code image
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('QR Code saved to gallery'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Save'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          // In a real app, this would print the QR code
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Printing QR Code...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Print'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _generateQRCode() {
    if (selectedTable == null) return;
    
    setState(() {
      generatedQRData = QRCodeData(
        tableId: selectedTable!.id,
        tableName: selectedTable!.name,
        restaurantId: 'la-redonda-123', // In a real app, this would come from your restaurant's unique ID
        generatedAt: DateTime.now(),
      );
    });
  }
}

// Menu Screen
class MenuScreen extends ConsumerWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Menu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Our Menu',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Delicious dishes crafted with love',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDishesScreen(
                                categoryId: category.id,
                                categoryName: category.name,
                                tableData: QRCodeData(
                                  tableId: 0,
                                  tableName: 'Takeaway',
                                  restaurantId: 'la-redonda-123',
                                  generatedAt: DateTime.now(),
                                ),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getCategoryIcon(category.id),
                                  size: 32,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getCategoryDescription(category.id),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error loading categories: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.lunch_dining;
      case 2:
        return Icons.dinner_dining;
      case 3:
        return Icons.cake;
      case 4:
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }
  
  String _getCategoryDescription(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'Light bites to start your meal';
      case 2:
        return 'Hearty and satisfying main dishes';
      case 3:
        return 'Sweet treats to end your meal';
      case 4:
        return 'Refreshing beverages and cocktails';
      default:
        return 'Explore our delicious options';
    }
  }
}

// Order Screen
class OrderScreen extends StatelessWidget {
  final QRCodeData tableData;
  
  const OrderScreen({
    Key? key,
    required this.tableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock order data
    final orderItems = [
      {'dish': 'Caesar Salad', 'price': 12.99, 'quantity': 1},
      {'dish': 'Grilled Salmon', 'price': 24.99, 'quantity': 2},
    ];
    
    // Calculate total
    double total = 0;
    for (var item in orderItems) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Order - ${tableData.tableName}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Your Order',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Order items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: orderItems.length,
              separatorBuilder: (context, index) => Divider(
                color: theme.colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final item = orderItems[index];
                final itemTotal = (item['price'] as double) * (item['quantity'] as int);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        '${item['quantity']}x',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['dish'] as String,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'S/ ${(item['price'] as double).toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'S/ ${itemTotal.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Total and checkout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        'S/ ${total.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Service charge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service Charge (10%)',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        'S/ ${(total * 0.1).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'S/ ${(total * 1.1).toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Checkout button
                  ElevatedButton.icon(
                    onPressed: () {
                      // In a real app, this would place the order
                      _showOrderConfirmation(context);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showOrderConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Order Placed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been sent to the kitchen. A waiter will bring your food to ${tableData.tableName} shortly.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Reservation Screen
class ReservationScreen extends StatelessWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Reservation'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserve Your Table',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book in advance to ensure your spot at La Redonda',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date selection
            Text(
              'Select Date',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Date picker placeholder
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Friday, March 1, 2025',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Time selection
            Text(
              'Select Time',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Time slots
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTimeSlot(context, '6:00 PM', true),
                _buildTimeSlot(context, '6:30 PM', true),
                _buildTimeSlot(context, '7:00 PM', false),
                _buildTimeSlot(context, '7:30 PM', true),
                _buildTimeSlot(context, '8:00 PM', true),
                _buildTimeSlot(context, '8:30 PM', true),
                _buildTimeSlot(context, '9:00 PM', false),
                _buildTimeSlot(context, '9:30 PM', true),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Party size
            Text(
              'Number of Guests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Guest counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '4 Guests',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {},
                    iconSize: 20,
                  ),
                  const SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        '4',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Special requests
            Text(
              'Special Requests (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Text field
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requirements or preferences...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Reserve button
            ElevatedButton.icon(
              onPressed: () {
                _showReservationConfirmation(context);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Reserve Table'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeSlot(BuildContext context, String time, bool isAvailable) {
    final theme = Theme.of(context);
    
    return ChoiceChip(
      label: Text(time),
      selected: time == '7:30 PM',
      onSelected: isAvailable
          ? (selected) {
              // In a real app, this would update the selected time
            }
          : null,
      backgroundColor: theme.colorScheme.surfaceVariant,
      selectedColor: theme.colorScheme.primaryContainer,
      disabledColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      labelStyle: TextStyle(
        color: isAvailable
            ? time == '7:30 PM'
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
  
  void _showReservationConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Reservation Confirmed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your table has been reserved for 4 guests on Friday, March 1, 2025 at 7:30 PM.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Reservation code: RED24031',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Restaurant Info Screen
class RestaurantInfoScreen extends StatelessWidget {
  const RestaurantInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with restaurant image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          
          // Restaurant info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    'La Redonda',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Restaurant description
                  Text(
                    'A cozy restaurant offering the finest dishes with a modern twist on traditional cuisine.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Hours section
                  _buildInfoSection(
                    context,
                    'Opening Hours',
                    Icons.access_time,
                    [
                      _buildInfoItem('Monday - Thursday', '11:00 AM - 10:00 PM'),
                      _buildInfoItem('Friday - Saturday', '11:00 AM - 11:00 PM'),
                      _buildInfoItem('Sunday', '12:00 PM - 9:00 PM'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Location section
                  _buildInfoSection(
                    context,
                    'Location',
                    Icons.location_on,
                    [
                      _buildInfoItem('Address', '123 Main Street, Miraflores, Lima'),
                      _buildInfoItem('Neighborhood', 'Miraflores'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Contact section
                  _buildInfoSection(
                    context,
                    'Contact',
                    Icons.phone,
                    [
                      _buildInfoItem('Phone', '+51 1 234 5678'),
                      _buildInfoItem('Email', 'info@laredonda.com'),
                      _buildInfoItem('Website', 'www.laredonda.com'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Amenities section
                  _buildInfoSection(
                    context,
                    'Amenities',
                    Icons.star,
                    [
                      _buildInfoItem('Parking', 'Available'),
                      _buildInfoItem('Outdoor Seating', 'Yes'),
                      _buildInfoItem('Takeout', 'Available'),
                      _buildInfoItem('Delivery', 'Available'),
                      _buildInfoItem('Accessibility', 'Wheelchair accessible'),
                      _buildInfoItem('WiFi', 'Free'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // CTA buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // In a real app, this would open maps
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening in Maps...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // In a real app, this would make a call
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Calling restaurant...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}