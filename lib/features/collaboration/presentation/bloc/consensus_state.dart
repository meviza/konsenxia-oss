import 'package:equatable/equatable.dart';
import '../../domain/entities/poll_entity.dart';

abstract class ConsensusState extends Equatable {
  const ConsensusState();
  @override
  List<Object?> get props => [];
}

class ConsensusInitial extends ConsensusState {
  const ConsensusInitial();
}

class ConsensusLoading extends ConsensusState {
  const ConsensusLoading();
}

class ConsensusLoaded extends ConsensusState {
  final List<PollEntity> polls;
  final PollStatus? activeFilter; // null = tümü
  final String? errorMessage;

  const ConsensusLoaded({
    required this.polls,
    this.activeFilter,
    this.errorMessage,
  });

  ConsensusLoaded copyWith({
    List<PollEntity>? polls,
    PollStatus? activeFilter,
    bool clearFilter = false,
    String? errorMessage,
  }) =>
      ConsensusLoaded(
        polls: polls ?? this.polls,
        activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [polls, activeFilter, errorMessage];
}

class ConsensusError extends ConsensusState {
  final String message;
  const ConsensusError(this.message);
  @override
  List<Object?> get props => [message];
}
