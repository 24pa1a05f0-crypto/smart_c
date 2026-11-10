class FoodItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String imageUrl;
  final bool isVeg;
  final bool isAvailable;
  final double rating;
  final int reviewsCount;
  final int prepTimeMinutes;
  final int calories;
  final List<String> allergens;
  final List<String> tags;
  final List<FoodAddon> availableAddons;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isVeg,
    this.isAvailable = true,
    this.rating = 4.5,
    this.reviewsCount = 42,
    this.prepTimeMinutes = 10,
    this.calories = 350,
    this.allergens = const [],
    this.tags = const [],
    this.availableAddons = const [],
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    String? imageUrl,
    bool? isVeg,
    bool? isAvailable,
    double? rating,
    int? reviewsCount,
    int? prepTimeMinutes,
    int? calories,
    List<String>? allergens,
    List<String>? tags,
    List<FoodAddon>? availableAddons,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isVeg: isVeg ?? this.isVeg,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      calories: calories ?? this.calories,
      allergens: allergens ?? this.allergens,
      tags: tags ?? this.tags,
      availableAddons: availableAddons ?? this.availableAddons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'prepTimeMinutes': prepTimeMinutes,
      'calories': calories,
      'allergens': allergens,
      'tags': tags,
      'availableAddons': availableAddons.map((x) => x.toMap()).toList(),
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return FoodItem(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Snacks',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
      isVeg: map['isVeg'] ?? true,
      isAvailable: map['isAvailable'] ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 10,
      prepTimeMinutes: (map['prepTimeMinutes'] as num?)?.toInt() ?? 10,
      calories: (map['calories'] as num?)?.toInt() ?? 300,
      allergens: List<String>.from(map['allergens'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      availableAddons: (map['availableAddons'] as List<dynamic>?)
              ?.map((x) => FoodAddon.fromMap(x as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class FoodAddon {
  final String id;
  final String name;
  final double price;

  const FoodAddon({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price};

  factory FoodAddon.fromMap(Map<String, dynamic> map) {
    return FoodAddon(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

