import 'package:equatable/equatable.dart';
import '../../domain/entities/poll_entity.dart';

abstract class ConsensusEvent extends Equatable {
  const ConsensusEvent();
  @override
  List<Object?> get props => [];
}

class LoadPollsEvent extends ConsensusEvent {
  final PollStatus? status;
  const LoadPollsEvent({this.status});
  @override
  List<Object?> get props => [status];
}

class FilterPollsEvent extends ConsensusEvent {
  final PollStatus? status; // null = tümü
  const FilterPollsEvent(this.status);
  @override
  List<Object?> get props => [status];
}

class VoteOnPollEvent extends ConsensusEvent {
  final String pollId;
  final int optionIndex;
  final bool isCurrentlyVoted; // aynı seçenek = geri al
  const VoteOnPollEvent({
    required this.pollId,
    required this.optionIndex,
    required this.isCurrentlyVoted,
  });
  @override
  List<Object?> get props => [pollId, optionIndex, isCurrentlyVoted];
}

class RefreshPollsEvent extends ConsensusEvent {
  const RefreshPollsEvent();
}
