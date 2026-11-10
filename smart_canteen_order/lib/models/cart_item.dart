import 'food_item.dart';

class CartItem {
  final String id;
  final FoodItem foodItem;
  int quantity;
  final List<FoodAddon> selectedAddons;
  String specialInstructions;

  CartItem({
    required this.id,
    required this.foodItem,
    this.quantity = 1,
    this.selectedAddons = const [],
    this.specialInstructions = '',
  });

  double get unitPrice {
    final addonsTotal = selectedAddons.fold<double>(0.0, (sum, item) => sum + item.price);
    return foodItem.price + addonsTotal;
  }

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodItem': foodItem.toMap(),
      'quantity': quantity,
      'selectedAddons': selectedAddons.map((x) => x.toMap()).toList(),
      'specialInstructions': specialInstructions,
      'totalPrice': totalPrice,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      foodItem: FoodItem.fromMap(map['foodItem'] ?? {}),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      selectedAddons: (map['selectedAddons'] as List<dynamic>?)
              ?.map((x) => FoodAddon.fromMap(x as Map<String, dynamic>))
              .toList() ??
          const [],
      specialInstructions: map['specialInstructions'] ?? '',
    );
  }

  CartItem copyWith({
    String? id,
    FoodItem? foodItem,
    int? quantity,
    List<FoodAddon>? selectedAddons,
    String? specialInstructions,
  }) {
    return CartItem(
      id: id ?? this.id,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

