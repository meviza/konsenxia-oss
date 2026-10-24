/// KONSENXIA — UserRole
///
/// 4 seviyeli hiyerarşik kullanıcı rolü sistemi.
/// intern → resident → specialist → professor
enum UserRole {
  /// İntern — Tıp fakültesi 5-6. sınıf / intern
  intern('INTERN', 'İntern / Tıp Öğrencisi', '🎓'),

  /// Asistan Doktor — Uzmanlık eğitimi alan hekim
  resident('RESIDENT', 'Asistan Doktor', '🩺'),

  /// Uzman Hekim — Uzmanlık almış hekim
  specialist('SPECIALIST', 'Uzman Hekim', '👨‍⚕️'),

  /// Profesör — Akademisyen / öğretim üyesi
  professor('PROFESSOR', 'Profesör / Doçent', '🏛️'),

  /// Admin — Platform yöneticisi
  admin('ADMIN', 'Platform Yöneticisi', '🔧');

  const UserRole(this.apiValue, this.displayName, this.emoji);

  /// Backend'e gönderilen string değer
  final String apiValue;

  /// Kullanıcıya gösterilen isim
  final String displayName;

  /// Emoji sembolü
  final String emoji;

  /// Unvan öneki (Prof. Dr. / Uzm. Dr. / Dr. / )
  String get titlePrefix => switch (this) {
        UserRole.intern    => '',
        UserRole.resident  => 'Dr.',
        UserRole.specialist => 'Uzm. Dr.',
        UserRole.professor => 'Prof. Dr.',
        UserRole.admin     => '',
      };

  /// Vaka atayabilir mi? (specialist ve professor)
  bool get canAssignCases =>
      this == UserRole.specialist || this == UserRole.professor;

  /// Mesleki belge yükleme gerektirir mi?
  bool get requiresDocument =>
      this == UserRole.specialist || this == UserRole.professor;

  /// Öğrenme modunda mı? (intern ve resident)
  bool get isLearner =>
      this == UserRole.intern || this == UserRole.resident;

  /// API değerinden enum'a çevirme
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.apiValue == value.toUpperCase(),
      orElse: () => UserRole.resident,
    );
  }
}
