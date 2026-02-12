import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      if (success) {
        _user = await _authService.getCurrentUser();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.register(email, username, password);
      if (success) {
        _user = await _authService.getCurrentUser();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _user = null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserStats({
    required bool won,
    required int ratingChange,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        gamesPlayed: _user!.gamesPlayed + 1,
        gamesWon: won ? _user!.gamesWon + 1 : _user!.gamesWon,
        gamesLost: won ? _user!.gamesLost : _user!.gamesLost + 1,
        rating: _user!.rating + ratingChange,
      );
      await _authService.updateUser(_user!);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
