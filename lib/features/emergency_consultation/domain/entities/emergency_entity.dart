import 'package:equatable/equatable.dart';

/// KONSENXIA — Acil Konsültasyon Entity
///
/// Nöbet sırasında hızlı uzman konsültasyonu.
/// Tek tuşla vaka paylaşımı + otomatik uzman bildirimi.
class EmergencyConsultation extends Equatable {
  final String id;
  final String requesterId;
  final String requesterName;
  final String requesterSpecialty;
  final String? requesterImageUrl;
  final EmergencyPriority priority;
  final EmergencyStatus status;
  final String targetSpecialty;
  final String title;
  final String clinicalSummary;
  final PatientBrief patient;
  final List<String> imageUrls;
  final String? voiceNoteUrl;
  final List<ConsultationResponse> responses;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? acceptedResponseId;
  final int viewCount;

  const EmergencyConsultation({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterSpecialty,
    this.requesterImageUrl,
    required this.priority,
    this.status = EmergencyStatus.pending,
    required this.targetSpecialty,
    required this.title,
    required this.clinicalSummary,
    required this.patient,
    this.imageUrls = const [],
    this.voiceNoteUrl,
    this.responses = const [],
    required this.createdAt,
    this.resolvedAt,
    this.acceptedResponseId,
    this.viewCount = 0,
  });

  bool get isResolved => status == EmergencyStatus.resolved;
  Duration get elapsed => DateTime.now().difference(createdAt);
  String get elapsedText {
    final mins = elapsed.inMinutes;
    if (mins < 60) return '$mins dk';
    return '${elapsed.inHours} sa ${mins % 60} dk';
  }

  EmergencyConsultation copyWith({
    EmergencyStatus? status,
    List<ConsultationResponse>? responses,
    DateTime? resolvedAt,
    String? acceptedResponseId,
    int? viewCount,
  }) =>
      EmergencyConsultation(
        id: id,
        requesterId: requesterId,
        requesterName: requesterName,
        requesterSpecialty: requesterSpecialty,
        requesterImageUrl: requesterImageUrl,
        priority: priority,
        targetSpecialty: targetSpecialty,
        title: title,
        clinicalSummary: clinicalSummary,
        patient: patient,
        imageUrls: imageUrls,
        voiceNoteUrl: voiceNoteUrl,
        createdAt: createdAt,
        status: status ?? this.status,
        responses: responses ?? this.responses,
        resolvedAt: resolvedAt ?? this.resolvedAt,
        acceptedResponseId: acceptedResponseId ?? this.acceptedResponseId,
        viewCount: viewCount ?? this.viewCount,
      );

  @override
  List<Object?> get props => [id, status, responses.length, viewCount];
}

enum EmergencyPriority {
  urgent('Acil', 30),
  critical('Kritik', 15),
  lifeThreatening('Hayati Tehlike', 5);

  final String label;
  final int targetResponseMinutes;
  const EmergencyPriority(this.label, this.targetResponseMinutes);
}

enum EmergencyStatus {
  pending('Bekliyor'),
  viewed('Goruldu'),
  inProgress('Yanitlaniyor'),
  resolved('Cozuldu'),
  expired('Sure Doldu');

  final String label;
  const EmergencyStatus(this.label);
}

class PatientBrief extends Equatable {
  final int age;
  final String gender;
  final String chiefComplaint;
  final Map<String, String> vitals;
  final List<String> activeConditions;
  final List<String> currentMedications;

  const PatientBrief({
    required this.age,
    required this.gender,
    required this.chiefComplaint,
    this.vitals = const {},
    this.activeConditions = const [],
    this.currentMedications = const [],
  });

  @override
  List<Object?> get props => [age, gender, chiefComplaint];
}

class ConsultationResponse extends Equatable {
  final String id;
  final String responderId;
  final String responderName;
  final String responderSpecialty;
  final String? responderImageUrl;
  final int responderLevel;
  final String content;
  final String? recommendedAction;
  final List<String> suggestedTests;
  final bool isAccepted;
  final DateTime createdAt;
  final int responseTimeSeconds;
  final int xpEarned;

  const ConsultationResponse({
    required this.id,
    required this.responderId,
    required this.responderName,
    required this.responderSpecialty,
    this.responderImageUrl,
    this.responderLevel = 1,
    required this.content,
    this.recommendedAction,
    this.suggestedTests = const [],
    this.isAccepted = false,
    required this.createdAt,
    this.responseTimeSeconds = 0,
    this.xpEarned = 0,
  });

  @override
  List<Object?> get props => [id, responderId, content];
}

class AvailableExpert extends Equatable {
  final String id;
  final String name;
  final String specialty;
  final String? imageUrl;
  final int level;
  final bool isOnline;
  final int avgResponseMinutes;
  final int totalConsultations;

  const AvailableExpert({
    required this.id,
    required this.name,
    required this.specialty,
    this.imageUrl,
    this.level = 1,
    this.isOnline = false,
    this.avgResponseMinutes = 10,
    this.totalConsultations = 0,
  });

  @override
  List<Object?> get props => [id, name, specialty, isOnline];
}
