import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  bool isAuthenticated();
  Future<void> setToken(String token);
  Future<String?> getToken();
  Future<void> setUser(Map<String, dynamic> user);
  String? getUserId();
  String? getUserName();
  String? get userRole;
  Future<void> clearToken();
  bool getBool(String key);
  Future<void> setBool(String key, bool value);
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _prefs;
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user'; // Same as AuthRepositoryImpl

  LocalStorageImpl(this._prefs);

  @override
  bool isAuthenticated() {
    final token = _prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> setUser(Map<String, dynamic> user) async {
    await _prefs.setString(_userKey, jsonEncode(user));
  }

  @override
  String? getUserId() {
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    try {
      final user = jsonDecode(json) as Map<String, dynamic>;
      return user['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  String? getUserName() {
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    try {
      final user = jsonDecode(json) as Map<String, dynamic>;
      return user['name'] as String? ?? user['displayName'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  String? get userRole {
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    try {
      final user = jsonDecode(json) as Map<String, dynamic>;
      return user['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  @override
  bool getBool(String key) => _prefs.getBool(key) ?? false;

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
}
