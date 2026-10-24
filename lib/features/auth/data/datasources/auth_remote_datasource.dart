import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  });
}

/// Firebase-only implementation (no separate backend server needed).
/// Authenticates via Firebase Auth and returns a normalized user map.
/// The [Dio] parameter is kept for DI compatibility but not used.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // ignore: unused_field
  final Dio _dio;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _buildResponse(credential.user, email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_authError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      final credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Persist display name in Firebase profile
      await credential.user
          ?.updateDisplayName('$firstName $lastName'.trim());

      return _buildResponse(
        credential.user,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_authError(e));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Map<String, dynamic> _buildResponse(
    firebase_auth.User? user, {
    required String email,
    String? firstName,
    String? lastName,
  }) {
    final displayName = user?.displayName ?? '';
    final parts = displayName.split(' ');

    final resolvedFirst = firstName ??
        (parts.isNotEmpty && parts.first.isNotEmpty
            ? parts.first
            : email.split('@').first);
    final resolvedLast = lastName ??
        (parts.length > 1 ? parts.sublist(1).join(' ') : '');

    return {
      'data': {
        'token': user?.uid ?? '', // Firebase UID used as session token
        'user': {
          'id': user?.uid ?? '',
          'email': user?.email ?? email,
          'firstName': resolvedFirst,
          'lastName': resolvedLast,
          'role': 'doctor',
        },
      },
    };
  }

  String _authError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı. Lütfen tekrar deneyin.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter kullanın.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi formatı.';
      case 'too-many-requests':
        return 'Çok fazla başarısız giriş. Lütfen daha sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
      default:
        return e.message ?? 'Kimlik doğrulama başarısız oldu.';
    }
  }
}
