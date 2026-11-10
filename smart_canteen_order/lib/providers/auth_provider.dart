import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStudent => _user?.isStudent ?? true;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _init();
  }

  Future<void> _init() async {
    await _authService.initSession();
    _user = _authService.currentUser;
    // Default to demo student if no session saved for instant frictionless preview
    _user ??= MockData.demoStudent;
    notifyListeners();

    _authService.authStateChanges.listen((updatedUser) {
      _user = updatedUser;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String studentId,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        studentId: studentId,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> topUpWallet(double amount) async {
    await _authService.topUpWallet(amount);
    _user = _authService.currentUser;
    notifyListeners();
  }

  Future<bool> deductWallet(double amount) async {
    final success = await _authService.deductWallet(amount);
    if (success) {
      _user = _authService.currentUser;
      notifyListeners();
    }
    return success;
  }

  /// Instant role switch for evaluator convenience
  void switchDemoRole() {
    if (isAdmin) {
      _user = MockData.demoStudent;
    } else {
      _user = MockData.demoAdmin;
    }
    notifyListeners();
  }

  void loginAsDemoStudent() {
    _user = MockData.demoStudent;
    notifyListeners();
  }

  void loginAsDemoAdmin() {
    _user = MockData.demoAdmin;
    notifyListeners();
  }
}

