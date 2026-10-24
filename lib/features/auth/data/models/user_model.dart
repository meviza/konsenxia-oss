
import '../../../../core/constants/app_constants.dart';




class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? avatar;
  final String? phone;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.avatar,
    this.phone,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.preferences,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      isActive: json['isActive'] as bool?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      isPhoneVerified: json['isPhoneVerified'] as bool?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'avatar': avatar,
    'phone': phone,
    'bio': bio,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isActive': isActive,
    'isEmailVerified': isEmailVerified,
    'isPhoneVerified': isPhoneVerified,
    'preferences': preferences,
    'metadata': metadata,
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? avatar,
    String? phone,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }

  String get fullName => '$firstName $lastName';
  
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0] : '';
    return '$firstInitial$lastInitial'.toUpperCase();
  }

  bool get isPatient => role == AppConstants.patientRole;
  bool get isDoctor => role == AppConstants.doctorRole;
  bool get isAdmin => role == AppConstants.adminRole;

  // ── 4 Seviyeli Rol Helper'ları ─────────────────────────────────
  bool get isIntern => role == 'INTERN';
  bool get isResident => role == 'RESIDENT';
  bool get isSpecialist => role == 'SPECIALIST';
  bool get isProfessor => role == 'PROFESSOR';

  /// Vaka atayabilir mi? (specialist ve professor)
  bool get canAssignCases => isSpecialist || isProfessor;

  /// Öğrenen rolde mi? (intern ve resident)
  bool get isLearner => isIntern || isResident;

  /// Unvan öneki
  String get titlePrefix => switch (role) {
    'INTERN'     => '',
    'RESIDENT'   => 'Dr.',
    'SPECIALIST' => 'Uzm. Dr.',
    'PROFESSOR'  => 'Prof. Dr.',
    'ADMIN'      => '',
    _            => 'Dr.',
  };

  /// Tam ad + unvan
  String get displayTitle =>
      titlePrefix.isEmpty ? fullName : '$titlePrefix $fullName';

  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasPreferences => preferences != null && preferences!.isNotEmpty;
  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;

  bool get isVerified => (isEmailVerified ?? false) && (isPhoneVerified ?? false);
  bool get isEmailVerifiedOnly => isEmailVerified ?? false;
  bool get isPhoneVerifiedOnly => isPhoneVerified ?? false;

  DateTime? get createdAtDate => createdAt;
  DateTime? get updatedAtDate => updatedAt;

  String get createdAtFormatted {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  String get updatedAtFormatted {
    if (updatedAt == null) return '';
    return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}';
  }

  String get roleDisplayName {
    switch (role) {
      case AppConstants.patientRole:
        return 'Patient';
      case AppConstants.doctorRole:
        return 'Doctor';
      case AppConstants.adminRole:
        return 'Administrator';
      default:
        return 'User';
    }
  }

  String get roleDisplayDescription {
    switch (role) {
      case AppConstants.patientRole:
        return 'Healthcare Patient';
      case AppConstants.doctorRole:
        return 'Medical Doctor';
      case AppConstants.adminRole:
        return 'System Administrator';
      default:
        return 'Application User';
    }
  }

  Map<String, dynamic> get toMap => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
    'role': role,
    'roleDisplayName': roleDisplayName,
    'roleDisplayDescription': roleDisplayDescription,
    'avatar': avatar,
    'phone': phone,
    'bio': bio,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isActive': isActive,
    'isEmailVerified': isEmailVerified,
    'isPhoneVerified': isPhoneVerified,
    'isVerified': isVerified,
    'hasAvatar': hasAvatar,
    'hasPhone': hasPhone,
    'hasBio': hasBio,
    'hasPreferences': hasPreferences,
    'hasMetadata': hasMetadata,
    'preferences': preferences,
    'metadata': metadata,
  };

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.role == role &&
        other.avatar == avatar &&
        other.phone == phone &&
        other.bio == bio &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.isEmailVerified == isEmailVerified &&
        other.isPhoneVerified == isPhoneVerified &&
        other.preferences == preferences &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        role.hashCode ^
        avatar.hashCode ^
        phone.hashCode ^
        bio.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isActive.hashCode ^
        isEmailVerified.hashCode ^
        isPhoneVerified.hashCode ^
        preferences.hashCode ^
        metadata.hashCode;
  }

  // Factory constructors
  factory UserModel.patient({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? avatar,
    String? phone,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: AppConstants.patientRole,
      avatar: avatar,
      phone: phone,
      bio: bio,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      preferences: preferences,
      metadata: metadata,
    );
  }

  factory UserModel.doctor({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? avatar,
    String? phone,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: AppConstants.doctorRole,
      avatar: avatar,
      phone: phone,
      bio: bio,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      preferences: preferences,
      metadata: metadata,
    );
  }

  factory UserModel.admin({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? avatar,
    String? phone,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: AppConstants.adminRole,
      avatar: avatar,
      phone: phone,
      bio: bio,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      preferences: preferences,
      metadata: metadata,
    );
  }

  // Static methods
  static UserModel empty() {
    return const UserModel(
      id: '',
      email: '',
      firstName: '',
      lastName: '',
      role: AppConstants.patientRole,
    );
  }

  static UserModel fromJsonString(String jsonString) {
    final json = Map<String, dynamic>.from(
      // This would be implemented based on your JSON parsing library
      // For now, assuming it's already a Map
      {}
    );
    return UserModel.fromJson(json);
  }

  String toJsonString() {
    return toJson().toString();
  }

  // Validation methods
  bool get isValid {
    return id.isNotEmpty && 
           email.isNotEmpty && 
           firstName.isNotEmpty && 
           lastName.isNotEmpty && 
           role.isNotEmpty;
  }

  bool get hasValidEmail {
    return email.contains('@') && email.contains('.');
  }

  bool get hasValidName {
    return firstName.length >= 2 && lastName.length >= 2;
  }

  bool get hasValidRole {
    return [AppConstants.patientRole, AppConstants.doctorRole, AppConstants.adminRole]
        .contains(role);
  }

  // Utility methods
  UserModel updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    String? avatar,
  }) {
    return copyWith(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      bio: bio,
      avatar: avatar,
      updatedAt: DateTime.now(),
    );
  }

  UserModel updatePreferences(Map<String, dynamic> preferences) {
    return copyWith(
      preferences: preferences,
      updatedAt: DateTime.now(),
    );
  }

  UserModel updateMetadata(Map<String, dynamic> metadata) {
    return copyWith(
      metadata: metadata,
      updatedAt: DateTime.now(),
    );
  }

  UserModel verifyEmail() {
    return copyWith(
      isEmailVerified: true,
      updatedAt: DateTime.now(),
    );
  }

  UserModel verifyPhone() {
    return copyWith(
      isPhoneVerified: true,
      updatedAt: DateTime.now(),
    );
  }

  UserModel activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  UserModel deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  UserModel changeRole(String newRole) {
    return copyWith(
      role: newRole,
      updatedAt: DateTime.now(),
    );
  }
}
