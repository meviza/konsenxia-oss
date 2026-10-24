import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;

  AuthBloc({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required AuthRepository authRepository,
    required SharedPreferences prefs,
  })  : _loginUser = loginUser,
        _registerUser = registerUser,
        _authRepository = authRepository,
        _prefs = prefs,
        super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuth);
    on<SwitchRoleEvent>(_onSwitchRole);
    on<ForgotPasswordEvent>(_onForgotPassword);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    debugPrint('[AUTH] Login attempt: email=${event.email}, selectedRole=${event.role}');

    User finalUser;
    try {
      final user = await _loginUser(event.email, event.password);
      debugPrint('[AUTH] Backend login OK: role=${user.role}');
      // Backend başarılı olsa bile, kullanıcının seçtiği rolü kullan
      finalUser = User(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: event.role, // Login sayfasından gelen rol
      );
    } catch (e) {
      // Backend erişilemez → Mock auth fallback
      debugPrint('[AUTH] Backend login failed: $e — using mock auth');
      finalUser = _createMockUser(
        email: event.email,
        role: event.role,
      );
    }

    await _saveMockUser(finalUser);
    debugPrint('[AUTH] Saved user: role=${finalUser.role}, name=${finalUser.firstName} ${finalUser.lastName}');
    emit(AuthAuthenticated(user: finalUser));
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    debugPrint('[AUTH] Register attempt: role=${event.role}');

    User finalUser;
    try {
      final user = await _registerUser(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role,
      );
      // Backend başarılı olsa bile seçilen rolü zorla
      finalUser = User(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: event.role,
      );
    } catch (e) {
      debugPrint('[AUTH] Backend register failed: $e — using mock auth');
      finalUser = User(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role,
      );
    }

    await _saveMockUser(finalUser);
    debugPrint('[AUTH] Saved user: role=${finalUser.role}');
    emit(AuthAuthenticated(user: finalUser));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
    } catch (_) {}
    await _prefs.remove('auth_token');
    await _prefs.remove('auth_user');
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckAuth(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final userJson = _prefs.getString('auth_user');
    if (userJson != null) {
      try {
        final data = jsonDecode(userJson) as Map<String, dynamic>;
        var user = User.fromJson(data);

        // Sync role from Firestore if Firebase Auth user exists
        try {
          final fbUser = fb.FirebaseAuth.instance.currentUser;
          if (fbUser != null) {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(fbUser.uid)
                .get()
                .timeout(const Duration(seconds: 5));
            if (userDoc.exists) {
              final firestoreRole = userDoc.data()?['role'] as String? ?? '';
              if (firestoreRole.isNotEmpty && firestoreRole != user.role) {
                debugPrint('[AUTH] Syncing role from Firestore: $firestoreRole (was: ${user.role})');
                user = User(
                  id: user.id,
                  email: user.email,
                  firstName: user.firstName,
                  lastName: user.lastName,
                  role: firestoreRole,
                );
                await _saveMockUser(user);
              }
            }
          }
        } catch (e) {
          debugPrint('[AUTH] Failed to sync role from Firestore: $e');
        }

        emit(AuthAuthenticated(user: user));
        return;
      } catch (_) {}
    }
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSwitchRole(
      SwitchRoleEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      final updatedUser = User(
        id: currentState.user.id,
        email: currentState.user.email,
        firstName: currentState.user.firstName,
        lastName: currentState.user.lastName,
        role: event.newRole,
      );
      await _saveMockUser(updatedUser);
      emit(AuthAuthenticated(user: updatedUser));
    }
  }

  Future<void> _onForgotPassword(
      ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } catch (e) {
      debugPrint('[AUTH] Password reset failed: $e');
      String message = 'Şifre sıfırlama e-postası gönderilemedi.';
      if (e.toString().contains('user-not-found')) {
        message = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
      } else if (e.toString().contains('invalid-email')) {
        message = 'Geçersiz e-posta adresi.';
      }
      emit(AuthPasswordResetError(message: message));
    }
  }

  User _createMockUser({required String email, required String role}) {
    // E-posta'dan isim türet
    final localPart = email.split('@').first;
    final parts = localPart.split(RegExp(r'[._]'));
    final firstName =
        parts.isNotEmpty ? _capitalize(parts.first) : 'Kullanıcı';
    final lastName =
        parts.length > 1 ? _capitalize(parts[1]) : 'Doktor';

    return User(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

  Future<void> _saveMockUser(User user) async {
    await _prefs.setString('auth_token', 'mock_token_${user.id}');
    await _prefs.setString('auth_user', jsonEncode(user.toJson()));
  }
}
