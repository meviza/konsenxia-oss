/// KONSENXIA — Failure Classes
///
/// Domain katmanında hataları temsil eden sealed class hiyerarşisi.
/// dartz kütüphanesi kullanılmadığından Either yerine exception pattern kullanılır.

sealed class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Sunucu / API hatası
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Ağ bağlantısı yok
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'İnternet bağlantısı bulunamadı'])
      : super(message, code: 'network_error');
}

/// Kimlik doğrulama hatası
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Yetkilendirme hatası
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Bulunamadı
class NotFoundFailure extends Failure {
  const NotFoundFailure(String resource)
      : super('$resource bulunamadı', code: 'not_found');
}

/// Doğrulama hatası
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors});
}

/// Cache / yerel depolama hatası
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Yerel veri yüklenemedi'])
      : super(message, code: 'cache_error');
}

/// Bilinmeyen hata
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Beklenmeyen bir hata oluştu'])
      : super(message, code: 'unknown');
}
