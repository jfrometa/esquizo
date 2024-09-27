import 'package:flutter_riverpod/flutter_riverpod.dart';


class CateringItem {
  final String title;
  final String description;
  final double pricePerPerson;
  final String img;
  final List<String> ingredients;
  int peopleCount;  // Number of people the catering is for
  int quantity;     // Number of catering items

  CateringItem({
    required this.title,
    required this.description,
    required this.pricePerPerson,
    required this.img,
    required this.ingredients,
    this.peopleCount = 10,  // Default to 10 people
    this.quantity = 1,      // Default quantity to 1
  });

  CateringItem copyWith({
    int? peopleCount,
    int? quantity,
  }) {
    return CateringItem(
      title: title,
      description: description,
      pricePerPerson: pricePerPerson,
      img: img,
      ingredients: ingredients,
      peopleCount: peopleCount ?? this.peopleCount,
      quantity: quantity ?? this.quantity,
    );
  }
}
final cateringProvider = Provider<List<CateringItem>>((ref) {
  return [
    CateringItem(
      title: 'Deluxe Sandwich Buffet',
      description: 'A variety of gourmet sandwiches, perfect for large events.',
      pricePerPerson: 1000.00,
      img: 'assets/food4.jpeg',
      ingredients: ['Turkey', 'Cheese', 'Lettuce', 'Bread'],
    ),
    CateringItem(
      title: 'Gourmet Salad Bar',
      description: 'A gourmet salad bar with fresh ingredients.',
      pricePerPerson: 800.00,
      img: 'assets/food5.jpeg',
      ingredients: ['Lettuce', 'Tomatoes', 'Cucumber', 'Dressing'],
    ),
    // Add more catering items here...
  ];
});