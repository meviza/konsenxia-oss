import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final AppointmentType type;
  final String? location;
  final String? notes;
  final AppointmentStatus status;
  final String? meetingUrl; // video randevular için
  final DateTime createdAt;

  const AppointmentEntity({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.type,
    this.location,
    this.notes,
    required this.status,
    this.meetingUrl,
    required this.createdAt,
  });

  AppointmentEntity copyWith({AppointmentStatus? status}) => AppointmentEntity(
        id: id,
        doctorId: doctorId,
        doctorName: doctorName,
        specialty: specialty,
        date: date,
        type: type,
        location: location,
        notes: notes,
        status: status ?? this.status,
        meetingUrl: meetingUrl,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id, doctorId, doctorName, specialty, date,
        type, location, notes, status, meetingUrl, createdAt,
      ];
}

enum AppointmentType {
  inPerson,
  video,
  phone;

  String get label => switch (this) {
        AppointmentType.inPerson => 'Yüz Yüze',
        AppointmentType.video    => 'Video',
        AppointmentType.phone    => 'Telefon',
      };

  static AppointmentType fromValue(String v) => switch (v) {
        'video' => AppointmentType.video,
        'phone' => AppointmentType.phone,
        _       => AppointmentType.inPerson,
      };
}

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  static AppointmentStatus fromValue(String v) => switch (v) {
        'confirmed' => AppointmentStatus.confirmed,
        'completed' => AppointmentStatus.completed,
        'cancelled' => AppointmentStatus.cancelled,
        _           => AppointmentStatus.pending,
      };
}
