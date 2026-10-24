/// Profil güncelleme işlemleri için repository arayüzü.
/// Profil verisi okuma işlemleri DashboardRepository üzerinden yapılır.
class ProfileException implements Exception {
  final String message;
  const ProfileException(this.message);
  @override
  String toString() => 'ProfileException: $message';
}

abstract interface class ProfileRepository {
  Future<void> updateProfile({
    String? displayName,
    String? specialty,
    String? bio,
    String? photoUrl,
    String? institution,
    String? title,
  });

  Future<void> updateOnlineStatus(bool isOnline);

  Future<Map<String, dynamic>> getUserProfile(String uid);
}
