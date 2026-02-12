import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'registered_users';

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson != null) {
      final users = jsonDecode(usersJson) as Map<String, dynamic>;
      if (users.containsKey(email)) {
        final userData = users[email] as Map<String, dynamic>;
        if (userData['password'] == password) {
          final user = UserModel.fromJson(userData['user']);
          await prefs.setString(_userKey, jsonEncode(user.toJson()));
          return true;
        }
      }
    }
    
    if (email == 'demo@chessplus.com' && password == 'demo123') {
      final user = UserModel(
        id: 'demo_user_001',
        email: email,
        username: 'ChessMaster',
        gamesPlayed: 42,
        gamesWon: 28,
        gamesLost: 14,
        rating: 1450,
      );
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return true;
    }
    
    return false;
  }

  Future<bool> register(String email, String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    Map<String, dynamic> users = {};
    
    if (usersJson != null) {
      users = jsonDecode(usersJson) as Map<String, dynamic>;
      if (users.containsKey(email)) {
        return false;
      }
    }
    
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      username: username,
    );
    
    users[email] = {
      'password': password,
      'user': user.toJson(),
    };
    
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final users = jsonDecode(usersJson) as Map<String, dynamic>;
      if (users.containsKey(user.email)) {
        users[user.email]['user'] = user.toJson();
        await prefs.setString(_usersKey, jsonEncode(users));
      }
    }
  }
}
