import 'package:flutter_test/flutter_test.dart';
import 'package:smart_canteen_order/models/food_item.dart';
import 'package:smart_canteen_order/providers/cart_provider.dart';

void main() {
  group('CartProvider Tests', () {
    late CartProvider cart;
    const testFood = FoodItem(
      id: 'test_1',
      name: 'Paneer Wrap',
      category: 'Snacks',
      description: 'Delicious wrap',
      price: 100.0,
      imageUrl: 'https://example.com/wrap.jpg',
      isVeg: true,
    );

    setUp(() {
      cart = CartProvider();
    });

    test('Initial cart is empty', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, equals(0));
      expect(cart.grandTotal, equals(0.0));
    });

    test('Adding food item updates cart total and count', () {
      cart.addToCart(testFood, quantity: 2);

      expect(cart.isEmpty, isFalse);
      expect(cart.itemCount, equals(2));
      expect(cart.subtotal, equals(200.0));
    });

    test('Applying STUDENT20 discount coupon gives 20% discount', () {
      cart.addToCart(testFood, quantity: 2); // subtotal = 200.0
      final applied = cart.applyCoupon('STUDENT20');

      expect(applied, isTrue);
      expect(cart.discountAmount, equals(40.0)); // 20% of 200
      expect(cart.appliedCoupon, equals('STUDENT20'));
    });

    test('Removing from cart works correctly', () {
      cart.addToCart(testFood, quantity: 1);
      final itemId = cart.items.first.id;

      cart.removeFromCart(itemId);
      expect(cart.isEmpty, isTrue);
    });
  });
}

