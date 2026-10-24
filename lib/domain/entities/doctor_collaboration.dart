import 'package:equatable/equatable.dart';

class DoctorCollaboration extends Equatable {
  final String id;
  final String consultationId;
  final String requestingDoctorId;
  final String requestedDoctorId;
  final CollaborationStatus status;
  final String message;
  final List<String> sharedData;
  final CollaborationType type;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  const DoctorCollaboration({
    required this.id,
    required this.consultationId,
    required this.requestingDoctorId,
    required this.requestedDoctorId,
    required this.status,
    required this.message,
    required this.sharedData,
    required this.type,
    required this.createdAt,
    this.respondedAt,
    this.expiresAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        consultationId,
        requestingDoctorId,
        requestedDoctorId,
        status,
        message,
        sharedData,
        type,
        createdAt,
        respondedAt,
        expiresAt,
        metadata,
      ];
}

enum CollaborationStatus {
  pending,
  accepted,
  declined,
  expired,
  cancelled,
}

enum CollaborationType {
  secondOpinion,
  specialistConsultation,
  caseReview,
  treatmentValidation,
  diagnosisConfirmation,
}

class MedicalInsight extends Equatable {
  final String id;
  final String doctorId;
  final String consultationId;
  final String title;
  final String description;
  final List<String> categories;
  final List<String> tags;
  final int relevanceScore;
  final int validationCount;
  final List<String> references;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;

  const MedicalInsight({
    required this.id,
    required this.doctorId,
    required this.consultationId,
    required this.title,
    required this.description,
    required this.categories,
    required this.tags,
    required this.relevanceScore,
    required this.validationCount,
    required this.references,
    required this.isAnonymous,
    required this.createdAt,
    this.updatedAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        consultationId,
        title,
        description,
        categories,
        tags,
        relevanceScore,
        validationCount,
        references,
        isAnonymous,
        createdAt,
        updatedAt,
        metadata,
      ];
}

class LearningPattern extends Equatable {
  final String id;
  final String doctorId;
  final List<String> specialties;
  final List<String> commonDiagnoses;
  final List<String> treatmentApproaches;
  final double accuracyScore;
  final int caseCount;
  final DateTime lastUpdated;
  final Map<String, dynamic> patterns;

  const LearningPattern({
    required this.id,
    required this.doctorId,
    required this.specialties,
    required this.commonDiagnoses,
    required this.treatmentApproaches,
    required this.accuracyScore,
    required this.caseCount,
    required this.lastUpdated,
    required this.patterns,
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        specialties,
        commonDiagnoses,
        treatmentApproaches,
        accuracyScore,
        caseCount,
        lastUpdated,
        patterns,
      ];
}
