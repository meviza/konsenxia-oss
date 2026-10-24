import 'package:equatable/equatable.dart';

/// KONSENXIA — Vaka Simülasyonu Entity
///
/// AI destekli interaktif hasta simülasyonu.
/// Doktor adım adım tanı koyma sürecini yaşar:
/// Anamnez → Fizik Muayene → Tetkik → Tanı → Tedavi
class SimulationEntity extends Equatable {
  final String id;
  final String scenarioTitle;
  final String scenarioDescription;
  final String specialty;
  final SimulationDifficulty difficulty;
  final SimulationPhase currentPhase;
  final PatientProfile patient;
  final List<SimulationMessage> messages;
  final List<String> orderedTests;
  final List<String> findings;
  final String? userDiagnosis;
  final String? correctDiagnosis;
  final SimulationScore? score;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;

  const SimulationEntity({
    required this.id,
    required this.scenarioTitle,
    required this.scenarioDescription,
    required this.specialty,
    required this.difficulty,
    this.currentPhase = SimulationPhase.anamnesis,
    required this.patient,
    this.messages = const [],
    this.orderedTests = const [],
    this.findings = const [],
    this.userDiagnosis,
    this.correctDiagnosis,
    this.score,
    required this.startedAt,
    this.completedAt,
    this.isCompleted = false,
  });

  SimulationEntity copyWith({
    SimulationPhase? currentPhase,
    List<SimulationMessage>? messages,
    List<String>? orderedTests,
    List<String>? findings,
    String? userDiagnosis,
    String? correctDiagnosis,
    SimulationScore? score,
    DateTime? completedAt,
    bool? isCompleted,
  }) =>
      SimulationEntity(
        id: id,
        scenarioTitle: scenarioTitle,
        scenarioDescription: scenarioDescription,
        specialty: specialty,
        difficulty: difficulty,
        currentPhase: currentPhase ?? this.currentPhase,
        patient: patient,
        messages: messages ?? this.messages,
        orderedTests: orderedTests ?? this.orderedTests,
        findings: findings ?? this.findings,
        userDiagnosis: userDiagnosis ?? this.userDiagnosis,
        correctDiagnosis: correctDiagnosis ?? this.correctDiagnosis,
        score: score ?? this.score,
        startedAt: startedAt,
        completedAt: completedAt ?? this.completedAt,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  List<Object?> get props => [id, currentPhase, messages.length, isCompleted];
}

enum SimulationPhase {
  anamnesis('Anamnez'),
  examination('Fizik Muayene'),
  tests('Tetkik İsteme'),
  diagnosis('Tanı Koyma'),
  treatment('Tedavi Planı'),
  completed('Tamamlandı');

  final String label;
  const SimulationPhase(this.label);

  bool get isLast => this == SimulationPhase.treatment;
}

enum SimulationDifficulty {
  beginner('Başlangıç'),
  intermediate('Orta'),
  advanced('İleri'),
  expert('Uzman');

  final String label;
  const SimulationDifficulty(this.label);
}

class PatientProfile extends Equatable {
  final int age;
  final String gender;
  final String chiefComplaint;
  final List<String> pastHistory;
  final List<String> medications;
  final List<String> allergies;
  final Map<String, String> vitals;

  const PatientProfile({
    required this.age,
    required this.gender,
    required this.chiefComplaint,
    this.pastHistory = const [],
    this.medications = const [],
    this.allergies = const [],
    this.vitals = const {},
  });

  @override
  List<Object?> get props => [age, gender, chiefComplaint];
}

class SimulationMessage extends Equatable {
  final String id;
  final SimulationMessageRole role;
  final String content;
  final SimulationPhase phase;
  final DateTime timestamp;

  const SimulationMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.phase,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, role, content];
}

enum SimulationMessageRole { doctor, patient, system }

class SimulationScore extends Equatable {
  final int totalPoints;
  final int maxPoints;
  final int anamnesisScore;
  final int examinationScore;
  final int testScore;
  final int diagnosisScore;
  final int treatmentScore;
  final int xpEarned;
  final String feedback;

  const SimulationScore({
    required this.totalPoints,
    required this.maxPoints,
    required this.anamnesisScore,
    required this.examinationScore,
    required this.testScore,
    required this.diagnosisScore,
    required this.treatmentScore,
    required this.xpEarned,
    required this.feedback,
  });

  double get percentage => maxPoints > 0 ? totalPoints / maxPoints * 100 : 0;
  String get grade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  @override
  List<Object?> get props => [totalPoints, maxPoints, xpEarned];
}
