// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  
  // For testing purposes - allows any login
  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Comment this out for testing
      // _user = await _authService.login(username, password);
      
      // Use this for testing instead
      _user = User(
        id: '1',
        username: username,
        token: 'test-token-123',
      );
      
      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _user!.token);
      await prefs.setString('username', _user!.username);
      await prefs.setString('userId', _user!.id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Rest of the code remains the same...
}