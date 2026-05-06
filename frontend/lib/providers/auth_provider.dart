import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../core/storage/secure_storage.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  AuthService get _service => _ref.read(authServiceProvider);
  AppStorage get _storage => _ref.read(secureStorageProvider);

  Future<void> checkAuth() async {
    final token = await _storage.getToken();
    if (token != null) {
      try {
        final user = await _service.getProfile();
        state = AuthState(user: user, isAuthenticated: true);
      } catch (_) {
        await _storage.clearAll();
        state = const AuthState();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _service.login(email, password);
      if (user.token != null) {
        await _storage.saveToken(user.token!);
        await _storage.saveUser(user.toJson());
      }
      state = AuthState(user: user, isAuthenticated: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.firstError);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan');
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _service.register(data);
      if (user.token != null) {
        await _storage.saveToken(user.token!);
        await _storage.saveUser(user.toJson());
      }
      state = AuthState(user: user, isAuthenticated: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.firstError);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {}
    await _storage.clearAll();
    state = const AuthState();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _service.updateProfile(data);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.firstError);
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

// Theme
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final mode = await _ref.read(secureStorageProvider).getThemeMode();
    state = _fromString(mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _ref.read(secureStorageProvider).setThemeMode(mode.name);
  }

  ThemeMode _fromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
