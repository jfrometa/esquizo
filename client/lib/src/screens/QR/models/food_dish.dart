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
