import 'package:equatable/equatable.dart';
import '../../domain/entities/hub_case_entity.dart';

abstract class HubCaseDetailState extends Equatable {
  const HubCaseDetailState();
  @override
  List<Object?> get props => [];
}

class HubCaseDetailInitial extends HubCaseDetailState { const HubCaseDetailInitial(); }
class HubCaseDetailLoading extends HubCaseDetailState { const HubCaseDetailLoading(); }

class HubCaseDetailLoaded extends HubCaseDetailState {
  final HubCaseEntity hubCase;
  const HubCaseDetailLoaded(this.hubCase);
  @override
  List<Object?> get props => [hubCase];
}

class HubCaseDetailError extends HubCaseDetailState {
  final String message;
  const HubCaseDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
