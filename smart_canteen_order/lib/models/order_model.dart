import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'cart_item.dart';
import 'pickup_slot.dart';

enum OrderStatus {
  placed,
  preparing,
  ready,
  completed,
  cancelled,
}

class OrderModel {
  final String id;
  final String orderToken; // e.g. #CT-204
  final String userId;
  final String userName;
  final String userPhone;
  final List<CartItem> items;
  final double subtotal;
  final double packagingFee;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final PickupSlot pickupSlot;
  final DateTime pickupDate;
  final String pickupCounter;
  final String paymentMethod;
  final String paymentStatus; // 'Paid', 'Pay on Pickup'
  final OrderStatus status;
  final String specialNotes;
  final DateTime createdAt;
  final int estimatedReadyMinutes;

  const OrderModel({
    required this.id,
    required this.orderToken,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.items,
    required this.subtotal,
    this.packagingFee = 10.0,
    required this.taxAmount,
    this.discountAmount = 0.0,
    required this.totalAmount,
    required this.pickupSlot,
    required this.pickupDate,
    this.pickupCounter = 'Counter 1 (Main Hall)',
    required this.paymentMethod,
    this.paymentStatus = 'Paid',
    this.status = OrderStatus.placed,
    this.specialNotes = '',
    required this.createdAt,
    this.estimatedReadyMinutes = 15,
  });

  String get statusDisplay {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.preparing:
        return 'In Kitchen Prep';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get statusDescription {
    switch (status) {
      case OrderStatus.placed:
        return 'Your order is received and queued in the canteen kitchen.';
      case OrderStatus.preparing:
        return 'Chefs are preparing your meal fresh right now.';
      case OrderStatus.ready:
        return 'Hot & ready! Please head to $pickupCounter and present your token.';
      case OrderStatus.completed:
        return 'Order collected. Enjoy your meal!';
      case OrderStatus.cancelled:
        return 'This order has been cancelled.';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.placed:
        return AppColors.statusPlaced;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.ready:
        return AppColors.statusReady;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  int get statusStepIndex {
    switch (status) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.ready:
        return 2;
      case OrderStatus.completed:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderToken': orderToken,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'packagingFee': packagingFee,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'pickupSlot': pickupSlot.toMap(),
      'pickupDate': pickupDate.toIso8601String(),
      'pickupCounter': pickupCounter,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status.name,
      'specialNotes': specialNotes,
      'createdAt': createdAt.toIso8601String(),
      'estimatedReadyMinutes': estimatedReadyMinutes,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    OrderStatus parseStatus(String? name) {
      return OrderStatus.values.firstWhere(
        (e) => e.name == name,
        orElse: () => OrderStatus.placed,
      );
    }

    return OrderModel(
      id: docId ?? map['id'] ?? '',
      orderToken: map['orderToken'] ?? '#CT-101',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Student',
      userPhone: map['userPhone'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((x) => CartItem.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      packagingFee: (map['packagingFee'] as num?)?.toDouble() ?? 10.0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      pickupSlot: PickupSlot.fromMap(map['pickupSlot'] ?? {}),
      pickupDate: DateTime.tryParse(map['pickupDate'] ?? '') ?? DateTime.now(),
      pickupCounter: map['pickupCounter'] ?? 'Counter 1',
      paymentMethod: map['paymentMethod'] ?? 'Campus Wallet',
      paymentStatus: map['paymentStatus'] ?? 'Paid',
      status: parseStatus(map['status']),
      specialNotes: map['specialNotes'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      estimatedReadyMinutes: (map['estimatedReadyMinutes'] as num?)?.toInt() ?? 15,
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderToken,
    String? userId,
    String? userName,
    String? userPhone,
    List<CartItem>? items,
    double? subtotal,
    double? packagingFee,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    PickupSlot? pickupSlot,
    DateTime? pickupDate,
    String? pickupCounter,
    String? paymentMethod,
    String? paymentStatus,
    OrderStatus? status,
    String? specialNotes,
    DateTime? createdAt,
    int? estimatedReadyMinutes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderToken: orderToken ?? this.orderToken,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      packagingFee: packagingFee ?? this.packagingFee,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      pickupSlot: pickupSlot ?? this.pickupSlot,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupCounter: pickupCounter ?? this.pickupCounter,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      specialNotes: specialNotes ?? this.specialNotes,
      createdAt: createdAt ?? this.createdAt,
      estimatedReadyMinutes: estimatedReadyMinutes ?? this.estimatedReadyMinutes,
    );
  }
}

