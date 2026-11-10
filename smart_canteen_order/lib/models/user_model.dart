class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final String studentId;
  final String role; // 'student' or 'admin'
  final double walletBalance;
  final int loyaltyPoints;
  final String avatarUrl;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone = '+91 98765 43210',
    this.studentId = 'STU-2024-88',
    this.role = 'student',
    this.walletBalance = 550.0,
    this.loyaltyPoints = 120,
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
  });

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'studentId': studentId,
      'role': role,
      'walletBalance': walletBalance,
      'loyaltyPoints': loyaltyPoints,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, [String? uid]) {
    return UserModel(
      uid: uid ?? map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Campus Diner',
      phone: map['phone'] ?? '+91 98765 43210',
      studentId: map['studentId'] ?? 'STU-2024-88',
      role: map['role'] ?? 'student',
      walletBalance: (map['walletBalance'] as num?)?.toDouble() ?? 550.0,
      loyaltyPoints: (map['loyaltyPoints'] as num?)?.toInt() ?? 120,
      avatarUrl: map['avatarUrl'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    String? studentId,
    String? role,
    double? walletBalance,
    int? loyaltyPoints,
    String? avatarUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      walletBalance: walletBalance ?? this.walletBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

