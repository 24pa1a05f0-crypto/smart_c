import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _appliedCoupon;
  double _discountAmount = 0.0;
  String _orderNotes = '';

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => _items.isEmpty;
  String? get appliedCoupon => _appliedCoupon;
  double get discountAmount => _discountAmount;
  String get orderNotes => _orderNotes;

  void setOrderNotes(String notes) {
    _orderNotes = notes;
    notifyListeners();
  }

  void addToCart(
    FoodItem foodItem, {
    int quantity = 1,
    List<FoodAddon> selectedAddons = const [],
    String specialInstructions = '',
  }) {
    // Check if item with exact same addons already exists
    final existingIndex = _items.indexWhere((i) {
      if (i.foodItem.id != foodItem.id) return false;
      if (i.selectedAddons.length != selectedAddons.length) return false;
      final existingAddonIds = i.selectedAddons.map((a) => a.id).toSet();
      final newAddonIds = selectedAddons.map((a) => a.id).toSet();
      return existingAddonIds.containsAll(newAddonIds);
    });

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: 'ci_${DateTime.now().millisecondsSinceEpoch}_${_items.length}',
          foodItem: foodItem,
          quantity: quantity,
          selectedAddons: selectedAddons,
          specialInstructions: specialInstructions,
        ),
      );
    }

    _recalculateDiscounts();
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int delta) {
    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index != -1) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      _recalculateDiscounts();
      notifyListeners();
    }
  }

  void removeFromCart(String cartItemId) {
    _items.removeWhere((i) => i.id == cartItemId);
    _recalculateDiscounts();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    _discountAmount = 0.0;
    _orderNotes = '';
    notifyListeners();
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get packagingFee {
    return _items.isEmpty ? 0.0 : AppConstants.packagingFee;
  }

  double get taxAmount {
    return (subtotal - _discountAmount).clamp(0.0, double.infinity) * AppConstants.taxRate;
  }

  double get grandTotal {
    if (_items.isEmpty) return 0.0;
    final total = subtotal - _discountAmount + packagingFee + taxAmount;
    return total.clamp(0.0, double.infinity);
  }

  bool applyCoupon(String code) {
    final upper = code.trim().toUpperCase();
    if (!AppConstants.validCoupons.containsKey(upper)) {
      return false;
    }

    _appliedCoupon = upper;
    _recalculateDiscounts();
    notifyListeners();
    return true;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _discountAmount = 0.0;
    notifyListeners();
  }

  void _recalculateDiscounts() {
    if (_appliedCoupon == null || _items.isEmpty) {
      _discountAmount = 0.0;
      return;
    }

    final discountVal = AppConstants.validCoupons[_appliedCoupon] ?? 0.0;
    if (discountVal < 1.0) {
      // Percentage
      _discountAmount = subtotal * discountVal;
    } else {
      // Flat value
      _discountAmount = discountVal;
    }

    if (_discountAmount > subtotal) {
      _discountAmount = subtotal;
    }
  }
}

