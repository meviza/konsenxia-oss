import 'package:equatable/equatable.dart';

abstract class PrescriptionsEvent extends Equatable {
  const PrescriptionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadPrescriptionsEvent extends PrescriptionsEvent {
  const LoadPrescriptionsEvent();
}

class FilterPrescriptionsEvent extends PrescriptionsEvent {
  final String filter; // 'Aktif' | 'Tümü' | 'Süresi Dolmuş'
  const FilterPrescriptionsEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}
