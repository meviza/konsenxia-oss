import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatar;
  final String role;
  final List<String> specialties;
  final String? licenseNumber;
  final String? institution;
  final int experience;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPreferences preferences;
  final UserStats stats;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    required this.role,
    required this.specialties,
    this.licenseNumber,
    this.institution,
    required this.experience,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.preferences,
    required this.stats,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatar,
        role,
        specialties,
        licenseNumber,
        institution,
        experience,
        isVerified,
        isActive,
        createdAt,
        updatedAt,
        preferences,
        stats,
      ];

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatar,
    String? role,
    List<String>? specialties,
    String? licenseNumber,
    String? institution,
    int? experience,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      specialties: specialties ?? this.specialties,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      institution: institution ?? this.institution,
      experience: experience ?? this.experience,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}

class UserPreferences extends Equatable {
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool autoTranslationEnabled;
  final List<String> preferredSpecialties;
  final Map<String, dynamic> settings;

  const UserPreferences({
    required this.language,
    required this.theme,
    required this.notificationsEnabled,
    required this.biometricEnabled,
    required this.autoTranslationEnabled,
    required this.preferredSpecialties,
    required this.settings,
  });

  @override
  List<Object?> get props => [
        language,
        theme,
        notificationsEnabled,
        biometricEnabled,
        autoTranslationEnabled,
        preferredSpecialties,
        settings,
      ];
}

class UserStats extends Equatable {
  final int consultationsCount;
  final int collaborationsCount;
  final int insightsShared;
  final double aiAccuracyScore;
  final int reputationPoints;
  final List<String> achievements;

  const UserStats({
    required this.consultationsCount,
    required this.collaborationsCount,
    required this.insightsShared,
    required this.aiAccuracyScore,
    required this.reputationPoints,
    required this.achievements,
  });

  @override
  List<Object?> get props => [
        consultationsCount,
        collaborationsCount,
        insightsShared,
        aiAccuracyScore,
        reputationPoints,
        achievements,
      ];
}
