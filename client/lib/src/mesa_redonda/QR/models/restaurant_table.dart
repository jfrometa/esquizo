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
