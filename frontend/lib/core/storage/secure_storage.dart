import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final secureStorageProvider = Provider<AppStorage>((ref) => AppStorage());

class AppStorage {
  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Token
  Future<void> saveToken(String token) async {
    await _secure.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secure.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _secure.delete(key: AppConstants.tokenKey);
  }

  // User data
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _secure.write(key: AppConstants.userKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final data = await _secure.read(key: AppConstants.userKey);
    if (data != null) return jsonDecode(data) as Map<String, dynamic>;
    return null;
  }

  Future<void> clearAll() async {
    await _secure.deleteAll();
  }

  // SharedPreferences for non-sensitive data
  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.themeKey) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, mode);
  }
}
