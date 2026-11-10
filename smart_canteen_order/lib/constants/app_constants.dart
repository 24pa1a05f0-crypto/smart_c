class AppConstants {
  static const String appName = 'Smart Canteen';
  static const String appTagline = 'Fast, Fresh & Queue-Free Campus Dining';
  static const String currencySymbol = '₹';

  // Demo Credentials
  static const String demoStudentEmail = 'student@campus.edu';
  static const String demoStudentPassword = 'password123';
  static const String demoAdminEmail = 'admin@canteen.edu';
  static const String demoAdminPassword = 'adminpassword123';

  // Fee & Tax
  static const double taxRate = 0.05; // 5% GST
  static const double packagingFee = 10.0; // ₹10 flat packaging/tray fee

  // Promo Coupons
  static const Map<String, double> validCoupons = {
    'HUNGRY10': 0.10, // 10% discount
    'STUDENT20': 0.20, // 20% discount
    'FREEDRINK': 25.0, // ₹25 flat discount
  };

  // Categories
  static const List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Snacks',
    'Beverages',
    'Desserts',
    'Daily Specials',
  ];

  // Default Pickup Slots (Morning, Lunch, Afternoon, Evening)
  static const List<Map<String, dynamic>> defaultSlots = [
    {'id': 'slot_1', 'label': '09:00 AM - 09:30 AM', 'period': 'Morning'},
    {'id': 'slot_2', 'label': '09:30 AM - 10:00 AM', 'period': 'Morning'},
    {'id': 'slot_3', 'label': '10:00 AM - 10:30 AM', 'period': 'Morning'},
    {'id': 'slot_4', 'label': '12:00 PM - 12:30 PM', 'period': 'Lunch'},
    {'id': 'slot_5', 'label': '12:30 PM - 01:00 PM', 'period': 'Lunch'},
    {'id': 'slot_6', 'label': '01:00 PM - 01:30 PM', 'period': 'Lunch'},
    {'id': 'slot_7', 'label': '01:30 PM - 02:00 PM', 'period': 'Lunch'},
    {'id': 'slot_8', 'label': '03:30 PM - 04:00 PM', 'period': 'Evening Snacks'},
    {'id': 'slot_9', 'label': '04:00 PM - 04:30 PM', 'period': 'Evening Snacks'},
    {'id': 'slot_10', 'label': '05:00 PM - 05:30 PM', 'period': 'Evening Snacks'},
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Campus Wallet',
    'UPI (GooglePay / PhonePe / Paytm)',
    'Credit / Debit Card',
    'Pay Cash at Pickup Counter',
  ];
}

