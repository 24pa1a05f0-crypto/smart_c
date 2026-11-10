class PickupSlot {
  final String id;
  final String label;
  final String period; // Morning, Lunch, Evening Snacks
  final int maxCapacity;
  final int bookedOrders;
  final bool isActive;

  const PickupSlot({
    required this.id,
    required this.label,
    required this.period,
    this.maxCapacity = 20,
    this.bookedOrders = 0,
    this.isActive = true,
  });

  bool get isAvailable => isActive && (bookedOrders < maxCapacity);

  int get availableSlots => (maxCapacity - bookedOrders).clamp(0, maxCapacity);

  double get occupancyRatio => maxCapacity == 0 ? 0 : bookedOrders / maxCapacity;

  String get availabilityStatus {
    if (!isActive) return 'Closed';
    if (bookedOrders >= maxCapacity) return 'Full';
    if (availableSlots <= 3) return 'Filling Fast ($availableSlots left)';
    return 'Available ($availableSlots slots)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'period': period,
      'maxCapacity': maxCapacity,
      'bookedOrders': bookedOrders,
      'isActive': isActive,
    };
  }

  factory PickupSlot.fromMap(Map<String, dynamic> map, [String? docId]) {
    return PickupSlot(
      id: docId ?? map['id'] ?? '',
      label: map['label'] ?? '',
      period: map['period'] ?? 'Lunch',
      maxCapacity: (map['maxCapacity'] as num?)?.toInt() ?? 20,
      bookedOrders: (map['bookedOrders'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  PickupSlot copyWith({
    String? id,
    String? label,
    String? period,
    int? maxCapacity,
    int? bookedOrders,
    bool? isActive,
  }) {
    return PickupSlot(
      id: id ?? this.id,
      label: label ?? this.label,
      period: period ?? this.period,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      bookedOrders: bookedOrders ?? this.bookedOrders,
      isActive: isActive ?? this.isActive,
    );
  }
}

