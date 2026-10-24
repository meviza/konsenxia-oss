import 'package:equatable/equatable.dart';

/// KONSENXIA — Sealed Failure Hiyerarşisi
///
/// Repository katmanı bu sınıfları kullanarak domain katmanına
/// anlamlı hata bilgisi iletir.
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Ağ bağlantısı yok veya zaman aşımı
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.']);
}

/// Sunucu hatası (4xx, 5xx)
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Yerel depolama okuma/yazma hatası
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Yerel veri okunamadı.']);
}

/// Kimlik doğrulama gerekli veya oturum süresi dolmuş
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Oturum süresi dolmuş. Lütfen tekrar giriş yapın.']);
}

/// İstenen kaynak bulunamadı
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'İstenen kaynak bulunamadı.']);
}

/// İzin hatası (Firestore security rules)
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Bu işlem için yetkiniz yok.']);
}

/// Geçersiz girdi
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
