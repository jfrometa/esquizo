
class CateringCategory {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final String imageUrl;
  final List<String> tags;
  final int displayOrder;
  final String? iconName;

  const CateringCategory({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = false,
    this.imageUrl = '',
    this.tags = const [],
    this.displayOrder = 0,
    this.iconName,
  });

  // Empty constructor
  factory CateringCategory.empty() => const CateringCategory(
    id: '',
    name: '',
    description: '',
  );

  // From JSON constructor
  factory CateringCategory.fromJson(Map<String, dynamic> json) {
    return CateringCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      displayOrder: json['displayOrder'] as int? ?? 0,
      iconName: json['iconName'] as String?,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'tags': tags,
      'displayOrder': displayOrder,
      if (iconName != null) 'iconName': iconName,
    };
  }

  // Copy with method
  CateringCategory copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    String? imageUrl,
    List<String>? tags,
    int? displayOrder,
    String? iconName,
    bool clearIconName = false,
  }) {
    return CateringCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      displayOrder: displayOrder ?? this.displayOrder,
      iconName: clearIconName ? null : (iconName ?? this.iconName),
    );
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CateringCategory &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.isActive == isActive &&
      other.imageUrl == imageUrl &&
      _listEquals(other.tags, tags) &&
      other.displayOrder == displayOrder &&
      other.iconName == iconName;
  }

  // Hash code
  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      isActive.hashCode ^
      imageUrl.hashCode ^
      tags.hashCode ^
      displayOrder.hashCode ^
      iconName.hashCode;
  }

  // Helper for list equality
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // String representation
  @override
  String toString() {
    return 'CateringCategory(id: $id, name: $name, description: $description, isActive: $isActive, displayOrder: $displayOrder)';
  }
}