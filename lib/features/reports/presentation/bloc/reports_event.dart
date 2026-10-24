import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();
  @override
  List<Object?> get props => [];
}

class LoadReportsEvent extends ReportsEvent {
  final int? year;
  const LoadReportsEvent({this.year});
  @override
  List<Object?> get props => [year];
}

class ChangeReportsYearEvent extends ReportsEvent {
  final int year;
  const ChangeReportsYearEvent(this.year);
  @override
  List<Object?> get props => [year];
}
