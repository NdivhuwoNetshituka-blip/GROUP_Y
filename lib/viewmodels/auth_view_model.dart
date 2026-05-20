/**
 * GROUP Y - TPG316C Student Assistant Application System
 *
 * Student Numbers and Names:
 *   215135458 - LE Lipali
 *   223013773 - NM Netshituka
 *   224004294 - B Linda
 *   221050663 - GR Kgwele
 *   222066543 - RG Madi
 *   224007421 - Y Mazamani
 *   224099468 - LE Letsie
 *   219002738 - LTBG Pule
 *   223060226 - NC Pali
 *   223007074 - T Zitha
 *
 * File: auth_view_model.dart
 * Description: ViewModel for authentication state and operations.
 */
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> signUp(String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(email, password, role);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(email, password);
      _errorMessage = null;
    } catch (e) {
      // Better error handling
      if (e.toString().contains('invalid_credentials')) {
        _errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.toString().contains('email_not_confirmed')) {
        _errorMessage = 'Please verify your email address before logging in.';
      } else {
        _errorMessage =
            'Login failed. Please check your connection and try again.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      return _currentUser;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }
}
