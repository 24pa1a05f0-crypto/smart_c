import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';
import '../models/order_model.dart';
import '../models/pickup_slot.dart';
import '../utils/mock_data.dart';
import 'firebase_service.dart';

class DatabaseService {
  FirebaseFirestore? get _db =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  // In-Memory store for fast, reactive, guaranteed-working offline & demo operations
  final List<FoodItem> _menuItems = List.from(MockData.initialFoodItems);
  final List<PickupSlot> _slots = List.from(MockData.initialSlots);
  final List<OrderModel> _orders = [];

  final StreamController<List<FoodItem>> _menuStreamController =
      StreamController<List<FoodItem>>.broadcast();
  final StreamController<List<OrderModel>> _ordersStreamController =
      StreamController<List<OrderModel>>.broadcast();
  final StreamController<List<PickupSlot>> _slotsStreamController =
      StreamController<List<PickupSlot>>.broadcast();

  Stream<List<FoodItem>> get menuStream => _menuStreamController.stream;
  Stream<List<OrderModel>> get ordersStream => _ordersStreamController.stream;
  Stream<List<PickupSlot>> get slotsStream => _slotsStreamController.stream;

  DatabaseService() {
    _seedInitialOrders();
    _notifyStreams();
  }

  void _seedInitialOrders() {
    final now = DateTime.now();
    _orders.add(
      OrderModel(
        id: 'ord_demo_1',
        orderToken: '#CT-101',
        userId: MockData.demoStudent.uid,
        userName: MockData.demoStudent.displayName,
        userPhone: MockData.demoStudent.phone,
        items: [
          // Item 1
          CartItem.fromMap({
            'id': 'ci_1',
            'foodItem': MockData.initialFoodItems[0].toMap(),
            'quantity': 1,
            'specialInstructions': 'Extra crispy please',
          }),
          // Item 2
          CartItem.fromMap({
            'id': 'ci_2',
            'foodItem': MockData.initialFoodItems[10].toMap(),
            'quantity': 1,
            'specialInstructions': '',
          }),
        ],
        subtotal: 200.0,
        packagingFee: 10.0,
        taxAmount: 10.0,
        discountAmount: 20.0,
        totalAmount: 200.0,
        pickupSlot: MockData.initialSlots[3], // 12:00 PM - 12:30 PM
        pickupDate: now,
        pickupCounter: 'Counter 2 (Express Lane)',
        paymentMethod: 'Campus Wallet',
        paymentStatus: 'Paid',
        status: OrderStatus.ready,
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
    );

    _orders.add(
      OrderModel(
        id: 'ord_demo_2',
        orderToken: '#CT-102',
        userId: MockData.demoStudent.uid,
        userName: MockData.demoStudent.displayName,
        userPhone: MockData.demoStudent.phone,
        items: [
          CartItem.fromMap({
            'id': 'ci_3',
            'foodItem': MockData.initialFoodItems[3].toMap(), // Biryani
            'quantity': 2,
            'specialInstructions': 'Medium spicy',
          }),
        ],
        subtotal: 420.0,
        packagingFee: 10.0,
        taxAmount: 21.0,
        discountAmount: 0.0,
        totalAmount: 451.0,
        pickupSlot: MockData.initialSlots[4], // 12:30 PM - 01:00 PM
        pickupDate: now,
        pickupCounter: 'Counter 1 (Main Hall)',
        paymentMethod: 'UPI (GooglePay)',
        paymentStatus: 'Paid',
        status: OrderStatus.preparing,
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
    );
  }

  void _notifyStreams() {
    _menuStreamController.add(List.unmodifiable(_menuItems));
    _ordersStreamController.add(List.unmodifiable(_orders));
    _slotsStreamController.add(List.unmodifiable(_slots));
  }

  // --- MENU MANAGEMENT ---
  List<FoodItem> getCachedMenu() => List.unmodifiable(_menuItems);

  Future<List<FoodItem>> fetchMenuItems() async {
    if (_db != null) {
      try {
        final snapshot = await _db!.collection('menu_items').get();
        if (snapshot.docs.isNotEmpty) {
          final items = snapshot.docs
              .map((doc) => FoodItem.fromMap(doc.data(), doc.id))
              .toList();
          _menuItems.clear();
          _menuItems.addAll(items);
          _notifyStreams();
          return items;
        }
      } catch (e) {
        debugPrint('[DatabaseService] Firestore fetchMenuItems error: $e');
      }
    }
    return List.unmodifiable(_menuItems);
  }

  Future<void> addMenuItem(FoodItem item) async {
    _menuItems.insert(0, item);
    _notifyStreams();

    if (_db != null) {
      try {
        await _db!.collection('menu_items').doc(item.id).set(item.toMap());
      } catch (e) {
        debugPrint('[DatabaseService] Firestore addMenuItem error: $e');
      }
    }
  }

  Future<void> updateMenuItem(FoodItem item) async {
    final index = _menuItems.indexWhere((x) => x.id == item.id);
    if (index != -1) {
      _menuItems[index] = item;
      _notifyStreams();
    }

    if (_db != null) {
      try {
        await _db!.collection('menu_items').doc(item.id).update(item.toMap());
      } catch (e) {
        debugPrint('[DatabaseService] Firestore updateMenuItem error: $e');
      }
    }
  }

  Future<void> deleteMenuItem(String id) async {
    _menuItems.removeWhere((x) => x.id == id);
    _notifyStreams();

    if (_db != null) {
      try {
        await _db!.collection('menu_items').doc(id).delete();
      } catch (e) {
        debugPrint('[DatabaseService] Firestore deleteMenuItem error: $e');
      }
    }
  }

  Future<void> toggleItemAvailability(String id, bool isAvailable) async {
    final index = _menuItems.indexWhere((x) => x.id == id);
    if (index != -1) {
      _menuItems[index] = _menuItems[index].copyWith(isAvailable: isAvailable);
      _notifyStreams();
    }

    if (_db != null) {
      try {
        await _db!.collection('menu_items').doc(id).update({'isAvailable': isAvailable});
      } catch (e) {
        debugPrint('[DatabaseService] Firestore toggleItemAvailability error: $e');
      }
    }
  }

  // --- PICKUP SLOTS ---
  List<PickupSlot> getCachedSlots() => List.unmodifiable(_slots);

  Future<void> incrementSlotBooking(String slotId) async {
    final index = _slots.indexWhere((s) => s.id == slotId);
    if (index != -1) {
      final slot = _slots[index];
      _slots[index] = slot.copyWith(bookedOrders: slot.bookedOrders + 1);
      _slotsStreamController.add(List.unmodifiable(_slots));
    }
  }

  // --- ORDERS ---
  List<OrderModel> getCachedOrders() => List.unmodifiable(_orders);

  Future<void> placeOrder(OrderModel order) async {
    _orders.insert(0, order);
    await incrementSlotBooking(order.pickupSlot.id);
    _notifyStreams();

    if (_db != null) {
      try {
        await _db!.collection('orders').doc(order.id).set(order.toMap());
      } catch (e) {
        debugPrint('[DatabaseService] Firestore placeOrder error: $e');
      }
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      _ordersStreamController.add(List.unmodifiable(_orders));
    }

    if (_db != null) {
      try {
        await _db!.collection('orders').doc(orderId).update({'status': newStatus.name});
      } catch (e) {
        debugPrint('[DatabaseService] Firestore updateOrderStatus error: $e');
      }
    }
  }

  List<OrderModel> getUserOrders(String userId) {
    return _orders.where((o) => o.userId == userId).toList();
  }
}

