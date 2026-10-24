import 'package:equatable/equatable.dart';

class AIModel extends Equatable {
  final String id;
  final String name;
  final String version;
  final AIModelType type;
  final String description;
  final double accuracy;
  final int trainingDataSize;
  final DateTime trainedAt;
  final DateTime? lastUpdated;
  final List<String> specialties;
  final Map<String, dynamic> performance;
  final bool isActive;
  final Map<String, dynamic> configuration;

  const AIModel({
    required this.id,
    required this.name,
    required this.version,
    required this.type,
    required this.description,
    required this.accuracy,
    required this.trainingDataSize,
    required this.trainedAt,
    this.lastUpdated,
    required this.specialties,
    required this.performance,
    required this.isActive,
    required this.configuration,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        version,
        type,
        description,
        accuracy,
        trainingDataSize,
        trainedAt,
        lastUpdated,
        specialties,
        performance,
        isActive,
        configuration,
      ];
}

enum AIModelType {
  medicalConsultation,
  diagnosisAssistance,
  treatmentRecommendation,
  drugInteraction,
  symptomAnalysis,
  riskAssessment,
}

class AIConsultation extends Equatable {
  final String id;
  final String consultationId;
  final String modelId;
  final String prompt;
  final String response;
  final double confidence;
  final List<String> references;
  final List<AIInsight> insights;
  final Map<String, dynamic> context;
  final DateTime createdAt;
  final Duration responseTime;
  final Map<String, dynamic> metadata;

  const AIConsultation({
    required this.id,
    required this.consultationId,
    required this.modelId,
    required this.prompt,
    required this.response,
    required this.confidence,
    required this.references,
    required this.insights,
    required this.context,
    required this.createdAt,
    required this.responseTime,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        consultationId,
        modelId,
        prompt,
        response,
        confidence,
        references,
        insights,
        context,
        createdAt,
        responseTime,
        metadata,
      ];
}

class AIInsight extends Equatable {
  final String id;
  final String insight;
  final double confidence;
  final List<String> references;
  final InsightType type;
  final String? category;
  final Map<String, dynamic> data;
  final DateTime generatedAt;

  const AIInsight({
    required this.id,
    required this.insight,
    required this.confidence,
    required this.references,
    required this.type,
    this.category,
    required this.data,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        insight,
        confidence,
        references,
        type,
        category,
        data,
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
  warning,
}

class AIFeedback extends Equatable {
  final String id;
  final String consultationId;
  final String doctorId;
  final String modelId;
  final int rating; // 1-5
  final String? comment;
  final List<String> issues;
  final List<String> suggestions;
  final bool wasHelpful;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const AIFeedback({
    required this.id,
    required this.consultationId,
    required this.doctorId,
    required this.modelId,
    required this.rating,
    this.comment,
    required this.issues,
    required this.suggestions,
    required this.wasHelpful,
    required this.createdAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        consultationId,
        doctorId,
        modelId,
        rating,
        comment,
        issues,
        suggestions,
        wasHelpful,
        createdAt,
        metadata,
      ];
}

class TrainingData extends Equatable {
  final String id;
  final String consultationId;
  final List<String> anonymizedData;
  final List<String> features;
  final String? expectedOutcome;
  final String? actualOutcome;
  final bool isUsedForTraining;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const TrainingData({
    required this.id,
    required this.consultationId,
    required this.anonymizedData,
    required this.features,
    this.expectedOutcome,
    this.actualOutcome,
    required this.isUsedForTraining,
    required this.createdAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        consultationId,
        anonymizedData,
        features,
        expectedOutcome,
        actualOutcome,
        isUsedForTraining,
        createdAt,
        metadata,
      ];
}
