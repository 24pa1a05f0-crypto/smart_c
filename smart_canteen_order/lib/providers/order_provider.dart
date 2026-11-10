import 'dart:math';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/pickup_slot.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final DatabaseService _dbService;

  List<OrderModel> _orders = [];
  List<PickupSlot> _slots = [];
  PickupSlot? _selectedSlot;
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  List<PickupSlot> get slots => _slots;
  PickupSlot? get selectedSlot => _selectedSlot;
  bool get isLoading => _isLoading;

  OrderProvider({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService() {
    _init();
  }

  void _init() {
    _orders = _dbService.getCachedOrders();
    _slots = _dbService.getCachedSlots();
    if (_slots.isNotEmpty) {
      _selectedSlot = _slots.firstWhere((s) => s.isAvailable, orElse: () => _slots.first);
    }
    notifyListeners();

    _dbService.ordersStream.listen((orders) {
      _orders = orders;
      notifyListeners();
    });

    _dbService.slotsStream.listen((slots) {
      _slots = slots;
      notifyListeners();
    });
  }

  void selectSlot(PickupSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  List<OrderModel> getActiveOrdersForUser(String userId) {
    return _orders.where((o) {
      return o.userId == userId &&
          (o.status == OrderStatus.placed ||
              o.status == OrderStatus.preparing ||
              o.status == OrderStatus.ready);
    }).toList();
  }

  List<OrderModel> getPastOrdersForUser(String userId) {
    return _orders.where((o) {
      return o.userId == userId &&
          (o.status == OrderStatus.completed || o.status == OrderStatus.cancelled);
    }).toList();
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel> placeOrder({
    required UserModel user,
    required CartProvider cart,
    required PickupSlot slot,
    required String paymentMethod,
    String? specialNotes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final tokenNumber = 100 + Random().nextInt(899);
    final orderToken = '#CT-$tokenNumber';
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

    final order = OrderModel(
      id: orderId,
      orderToken: orderToken,
      userId: user.uid,
      userName: user.displayName,
      userPhone: user.phone,
      items: List.from(cart.items),
      subtotal: cart.subtotal,
      packagingFee: cart.packagingFee,
      taxAmount: cart.taxAmount,
      discountAmount: cart.discountAmount,
      totalAmount: cart.grandTotal,
      pickupSlot: slot,
      pickupDate: DateTime.now(),
      pickupCounter: 'Counter ${(Random().nextInt(2) + 1)} (Express Pickup)',
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod.contains('Counter') ? 'Pay at Pickup' : 'Paid',
      status: OrderStatus.placed,
      specialNotes: specialNotes ?? cart.orderNotes,
      createdAt: DateTime.now(),
      estimatedReadyMinutes: 15,
    );

    await _dbService.placeOrder(order);
    cart.clearCart();

    _isLoading = false;
    notifyListeners();

    return order;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _dbService.updateOrderStatus(orderId, newStatus);
  }

  // --- Staff / Admin Order Filters ---
  List<OrderModel> get incomingOrders =>
      _orders.where((o) => o.status == OrderStatus.placed).toList();

  List<OrderModel> get preparingOrders =>
      _orders.where((o) => o.status == OrderStatus.preparing).toList();

  List<OrderModel> get readyOrders =>
      _orders.where((o) => o.status == OrderStatus.ready).toList();

  List<OrderModel> get completedOrders =>
      _orders.where((o) => o.status == OrderStatus.completed).toList();

  double get todayRevenue {
    return _orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }
}

