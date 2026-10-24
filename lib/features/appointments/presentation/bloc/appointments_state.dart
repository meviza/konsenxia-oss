import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();
  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

class AppointmentsLoading extends AppointmentsState {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentEntity> all;
  final String activeTab;

  const AppointmentsLoaded({
    required this.all,
    this.activeTab = 'Yaklaşan',
  });

  List<AppointmentEntity> get filtered {
    final now = DateTime.now();
    return switch (activeTab) {
      'Yaklaşan' => all
          .where((a) =>
              a.date.isAfter(now) &&
              a.status != AppointmentStatus.cancelled)
          .toList(),
      'Geçmiş' => all.where((a) => a.date.isBefore(now)).toList(),
      _          => all.where((a) => a.status == AppointmentStatus.pending).toList(),
    };
  }

  AppointmentsLoaded copyWith({
    List<AppointmentEntity>? all,
    String? activeTab,
  }) =>
      AppointmentsLoaded(
        all: all ?? this.all,
        activeTab: activeTab ?? this.activeTab,
      );

  @override
  List<Object?> get props => [all, activeTab];
}

class AppointmentsError extends AppointmentsState {
  final String message;
  const AppointmentsError(this.message);
  @override
  List<Object?> get props => [message];
}
