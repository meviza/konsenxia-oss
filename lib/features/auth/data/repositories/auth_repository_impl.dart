import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SharedPreferences _prefs;
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  AuthRepositoryImpl(this._remote, this._prefs);

  @override
  Future<User> login(String email, String password) async {
    final data = await _remote.login(email, password);
    final resData = data['data'] as Map<String, dynamic>;
    final token = resData['token'] ?? resData['tokens']?['accessToken'];
    if (token != null) {
      await _prefs.setString(_tokenKey, token.toString());
    }
    final user = (resData['user'] as Map<String, dynamic>);
    await _prefs.setString(_userKey, jsonEncode(user));
    return User(
      id: user['id'] as String,
      email: user['email'] as String,
      firstName: user['firstName'] as String,
      lastName: user['lastName'] as String,
      role: user['role'] as String,
    );
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    final data = await _remote.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );
    final resData = data['data'] as Map<String, dynamic>;
    final token = resData['token'] ?? resData['tokens']?['accessToken'];
    if (token != null) {
      await _prefs.setString(_tokenKey, token.toString());
    }
    final user = (resData['user'] as Map<String, dynamic>);
    await _prefs.setString(_userKey, jsonEncode(user));
    return User(
      id: user['id'] as String,
      email: user['email'] as String,
      firstName: user['firstName'] as String,
      lastName: user['lastName'] as String,
      role: user['role'] as String,
    );
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
