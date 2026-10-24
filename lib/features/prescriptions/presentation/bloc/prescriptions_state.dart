import 'package:equatable/equatable.dart';
import '../../domain/entities/prescription_entity.dart';

abstract class PrescriptionsState extends Equatable {
  const PrescriptionsState();
  @override
  List<Object?> get props => [];
}

class PrescriptionsInitial extends PrescriptionsState {
  const PrescriptionsInitial();
}

class PrescriptionsLoading extends PrescriptionsState {
  const PrescriptionsLoading();
}

class PrescriptionsLoaded extends PrescriptionsState {
  final List<PrescriptionEntity> all;
  final String activeFilter;

  const PrescriptionsLoaded({
    required this.all,
    this.activeFilter = 'Aktif',
  });

  List<PrescriptionEntity> get filtered => switch (activeFilter) {
        'Aktif'         => all.where((p) => p.isActive && !p.isExpired).toList(),
        'Süresi Dolmuş' => all.where((p) => p.isExpired).toList(),
        _               => all,
      };

  PrescriptionsLoaded copyWith({
    List<PrescriptionEntity>? all,
    String? activeFilter,
  }) =>
      PrescriptionsLoaded(
        all: all ?? this.all,
        activeFilter: activeFilter ?? this.activeFilter,
      );

  @override
  List<Object?> get props => [all, activeFilter];
}

class PrescriptionsError extends PrescriptionsState {
  final String message;
  const PrescriptionsError(this.message);
  @override
  List<Object?> get props => [message];
}
