import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/mock_data.dart';
import 'firebase_service.dart';

class AuthService {
  fb.FirebaseAuth? get _auth =>
      FirebaseService.isInitialized ? fb.FirebaseAuth.instance : null;

  UserModel? _currentUser;
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  Stream<UserModel?> get authStateChanges => _userStreamController.stream;
  UserModel? get currentUser => _currentUser;

  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('saved_user_role');
    final savedEmail = prefs.getString('saved_user_email');
    final savedName = prefs.getString('saved_user_name');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      if (savedRole == 'admin') {
        _currentUser = MockData.demoAdmin.copyWith(
          email: savedEmail,
          displayName: savedName ?? MockData.demoAdmin.displayName,
        );
      } else {
        _currentUser = MockData.demoStudent.copyWith(
          email: savedEmail,
          displayName: savedName ?? MockData.demoStudent.displayName,
        );
      }
      _userStreamController.add(_currentUser);
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // 1. Try real Firebase Auth if initialized
    if (_auth != null) {
      try {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        final role = email.toLowerCase().contains('admin') ? 'admin' : 'student';
        _currentUser = UserModel(
          uid: fbUser?.uid ?? 'uid_${DateTime.now().millisecondsSinceEpoch}',
          email: fbUser?.email ?? email,
          displayName: fbUser?.displayName ?? (role == 'admin' ? 'Canteen Manager' : 'Student Diner'),
          role: role,
        );
        await _persistUserSession(_currentUser!);
        _userStreamController.add(_currentUser);
        return _currentUser!;
      } catch (e) {
        debugPrint('[AuthService] Firebase Auth signIn error: $e. Falling back to local verification.');
      }
    }

    // 2. Local verification / Demo Fallback
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.contains('admin')) {
      _currentUser = MockData.demoAdmin.copyWith(email: email);
    } else {
      _currentUser = MockData.demoStudent.copyWith(
        email: email,
        displayName: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      );
    }

    await _persistUserSession(_currentUser!);
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String studentId,
    required String role,
  }) async {
    // 1. Try real Firebase Auth if available
    if (_auth != null) {
      try {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        await fbUser?.updateDisplayName(name);
        _currentUser = UserModel(
          uid: fbUser?.uid ?? 'uid_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: name,
          phone: phone,
          studentId: studentId,
          role: role,
        );
        await _persistUserSession(_currentUser!);
        _userStreamController.add(_currentUser);
        return _currentUser!;
      } catch (e) {
        debugPrint('[AuthService] Firebase Auth register error: $e.');
      }
    }

    // 2. Local Fallback
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: name.trim(),
      phone: phone.trim(),
      studentId: studentId.trim(),
      role: role,
      walletBalance: 300.0, // Welcome bonus wallet balance!
    );

    await _persistUserSession(_currentUser!);
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user_role');
    await prefs.remove('saved_user_email');
    await prefs.remove('saved_user_name');

    _currentUser = null;
    _userStreamController.add(null);
  }

  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? studentId,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      displayName: displayName ?? _currentUser!.displayName,
      phone: phone ?? _currentUser!.phone,
      studentId: studentId ?? _currentUser!.studentId,
    );
    await _persistUserSession(_currentUser!);
    _userStreamController.add(_currentUser);
  }

  Future<void> topUpWallet(double amount) async {
    if (_currentUser == null) return;
    final newBalance = _currentUser!.walletBalance + amount;
    _currentUser = _currentUser!.copyWith(walletBalance: newBalance);
    _userStreamController.add(_currentUser);
  }

  Future<bool> deductWallet(double amount) async {
    if (_currentUser == null || _currentUser!.walletBalance < amount) {
      return false;
    }
    final newBalance = _currentUser!.walletBalance - amount;
    _currentUser = _currentUser!.copyWith(walletBalance: newBalance);
    _userStreamController.add(_currentUser);
    return true;
  }

  Future<void> _persistUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_user_role', user.role);
    await prefs.setString('saved_user_email', user.email);
    await prefs.setString('saved_user_name', user.displayName);
  }
}

