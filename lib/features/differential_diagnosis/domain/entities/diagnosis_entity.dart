import 'package:equatable/equatable.dart';

/// KONSENXIA — Ayirici Tani (Differential Diagnosis) Entity
///
/// Yapilandirilmis semptom girisi → AI destekli DD listesi → Tetkik onerileri
class DiagnosisSession extends Equatable {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DiagnosisInput input;
  final DiagnosisResult? result;
  final bool isLoading;

  const DiagnosisSession({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.input,
    this.result,
    this.isLoading = false,
  });

  bool get hasResult => result != null;

  DiagnosisSession copyWith({
    DiagnosisInput? input,
    DiagnosisResult? result,
    bool? isLoading,
  }) =>
      DiagnosisSession(
        id: id,
        userId: userId,
        createdAt: createdAt,
        input: input ?? this.input,
        result: result ?? this.result,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [id, input, result, isLoading];
}

class DiagnosisInput extends Equatable {
  final int patientAge;
  final String patientGender;
  final String chiefComplaint;
  final List<String> symptoms;
  final List<String> negativeFindings;
  final String symptomDuration;
  final String symptomOnset;
  final List<String> pastHistory;
  final List<String> medications;
  final List<String> familyHistory;
  final Map<String, String> vitals;
  final String? additionalNotes;
  final String? targetSpecialty;

  const DiagnosisInput({
    required this.patientAge,
    required this.patientGender,
    required this.chiefComplaint,
    this.symptoms = const [],
    this.negativeFindings = const [],
    this.symptomDuration = '',
    this.symptomOnset = '',
    this.pastHistory = const [],
    this.medications = const [],
    this.familyHistory = const [],
    this.vitals = const {},
    this.additionalNotes,
    this.targetSpecialty,
  });

  DiagnosisInput copyWith({
    int? patientAge,
    String? patientGender,
    String? chiefComplaint,
    List<String>? symptoms,
    List<String>? negativeFindings,
    String? symptomDuration,
    String? symptomOnset,
    List<String>? pastHistory,
    List<String>? medications,
    List<String>? familyHistory,
    Map<String, String>? vitals,
    String? additionalNotes,
    String? targetSpecialty,
  }) =>
      DiagnosisInput(
        patientAge: patientAge ?? this.patientAge,
        patientGender: patientGender ?? this.patientGender,
        chiefComplaint: chiefComplaint ?? this.chiefComplaint,
        symptoms: symptoms ?? this.symptoms,
        negativeFindings: negativeFindings ?? this.negativeFindings,
        symptomDuration: symptomDuration ?? this.symptomDuration,
        symptomOnset: symptomOnset ?? this.symptomOnset,
        pastHistory: pastHistory ?? this.pastHistory,
        medications: medications ?? this.medications,
        familyHistory: familyHistory ?? this.familyHistory,
        vitals: vitals ?? this.vitals,
        additionalNotes: additionalNotes ?? this.additionalNotes,
        targetSpecialty: targetSpecialty ?? this.targetSpecialty,
      );

  @override
  List<Object?> get props =>
      [patientAge, patientGender, chiefComplaint, symptoms];
}

class DiagnosisResult extends Equatable {
  final List<DifferentialItem> differentials;
  final List<RecommendedTest> recommendedTests;
  final List<RiskFactor> riskFactors;
  final String clinicalComment;
  final List<String> redFlags;
  final String aiSource;
  final int processingMs;
  final double confidenceScore;

  const DiagnosisResult({
    required this.differentials,
    required this.recommendedTests,
    required this.riskFactors,
    required this.clinicalComment,
    this.redFlags = const [],
    required this.aiSource,
    required this.processingMs,
    this.confidenceScore = 0.0,
  });

  @override
  List<Object?> get props => [differentials, recommendedTests, confidenceScore];
}

class DifferentialItem extends Equatable {
  final int rank;
  final String diagnosis;
  final double probability;
  final String reasoning;
  final List<String> supportingFindings;
  final List<String> againstFindings;
  final String icdCode;

  const DifferentialItem({
    required this.rank,
    required this.diagnosis,
    required this.probability,
    required this.reasoning,
    this.supportingFindings = const [],
    this.againstFindings = const [],
    this.icdCode = '',
  });

  String get probabilityText =>
      '${(probability * 100).toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [rank, diagnosis, probability];
}

class RecommendedTest extends Equatable {
  final String name;
  final TestPriority priority;
  final String rationale;
  final String expectedFinding;
  final String category;

  const RecommendedTest({
    required this.name,
    required this.priority,
    required this.rationale,
    required this.expectedFinding,
    this.category = 'Laboratuvar',
  });

  @override
  List<Object?> get props => [name, priority];
}

enum TestPriority {
  stat('STAT - Hemen'),
  urgent('Acil'),
  routine('Rutin');

  final String label;
  const TestPriority(this.label);
}

class RiskFactor extends Equatable {
  final String factor;
  final RiskLevel level;
  final String explanation;

  const RiskFactor({
    required this.factor,
    required this.level,
    required this.explanation,
  });

  @override
  List<Object?> get props => [factor, level];
}

enum RiskLevel {
  low('Dusuk'),
  moderate('Orta'),
  high('Yuksek'),
  critical('Kritik');

  final String label;
  const RiskLevel(this.label);
}
