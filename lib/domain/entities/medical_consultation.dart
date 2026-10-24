import 'package:equatable/equatable.dart';

class MedicalConsultation extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String? collaboratingDoctorId;
  final ConsultationType type;
  final ConsultationStatus status;
  final String title;
  final String description;
  final List<String> symptoms;
  final String? diagnosis;
  final String? treatmentPlan;
  final List<String> attachments;
  final List<String> tags;
  final double? aiConfidenceScore;
  final List<AIInsight> aiInsights;
  final List<DoctorComment> doctorComments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;

  const MedicalConsultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.collaboratingDoctorId,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.symptoms,
    this.diagnosis,
    this.treatmentPlan,
    required this.attachments,
    required this.tags,
    this.aiConfidenceScore,
    required this.aiInsights,
    required this.doctorComments,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        doctorId,
        collaboratingDoctorId,
        type,
        status,
        title,
        description,
        symptoms,
        diagnosis,
        treatmentPlan,
        attachments,
        tags,
        aiConfidenceScore,
        aiInsights,
        doctorComments,
        createdAt,
        updatedAt,
        completedAt,
        metadata,
      ];
}

enum ConsultationType {
  general,
  emergency,
  secondOpinion,
  followUp,
  specialistReferral,
}

enum ConsultationStatus {
  pending,
  inProgress,
  awaitingCollaboration,
  completed,
  cancelled,
}

class AIInsight extends Equatable {
  final String id;
  final String insight;
  final double confidence;
  final List<String> references;
  final InsightType type;
  final DateTime generatedAt;

  const AIInsight({
    required this.id,
    required this.insight,
    required this.confidence,
    required this.references,
    required this.type,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        insight,
        confidence,
        references,
        type,
        generatedAt,
      ];
}

enum InsightType {
  diagnosis,
  treatment,
  symptomAnalysis,
  drugInteraction,
  riskAssessment,
  recommendation,
}

class DoctorComment extends Equatable {
  final String id;
  final String doctorId;
  final String doctorName;
  final String comment;
  final DateTime createdAt;
  final bool isCollaborationRequest;

  const DoctorComment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.comment,
    required this.createdAt,
    required this.isCollaborationRequest,
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        doctorName,
        comment,
        createdAt,
        isCollaborationRequest,
      ];
}
