import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  String? _token;
  bool _isLoading = true; // true while restoring session on app start

  AppUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  /// Call once at app startup to restore a saved session.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');
    if (token != null && userJson != null) {
      _token = token;
      _user = AppUser.fromJson(jsonDecode(userJson));
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await ApiService.login(email, password);
    await _persistSession(data);
  }

  Future<void> register(String name, String email, String password) async {
    final data = await ApiService.register(name, email, password);
    await _persistSession(data);
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    _token = data['token'];
    _user = AppUser.fromJson(data['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token!);
    await prefs.setString('auth_user', jsonEncode(_user!.toJson()));

    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    notifyListeners();
  }
}
