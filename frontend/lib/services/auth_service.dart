import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    if (response['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['data']['token']);
      await prefs.setString('user_role', response['data']['user']['role']);
      await prefs.setString('user_name', response['data']['user']['name']);
      await prefs.setString('user_email', response['data']['user']['email']);
      await prefs.setInt('user_id', response['data']['user']['id']);
    }
    return response;
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('/auth/profile');
  }
}
