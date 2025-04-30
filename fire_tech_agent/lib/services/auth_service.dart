import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  // Replace with your server URL
  final String baseUrl = 'http://192.168.1.150/api';
  
  Future<User> login(String username, String password) async {
    try {
      // Comment out the actual API call for testing
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
      */
      
      // Use this for testing instead
      print("Using test user login for: $username");
      return User(
        id: '1',
        username: username,
        token: 'test-token-123',
      );
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
  
  Future<void> logout(String token) async {
    // For testing, just print and return
    print("Logout called with token: $token");
    return;
    
    /*
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    */
  }
  
  Future<bool> verifyToken(String token) async {
    // For testing, always return true
    return true;
    
    /*
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verify-token'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
    */
  }
}