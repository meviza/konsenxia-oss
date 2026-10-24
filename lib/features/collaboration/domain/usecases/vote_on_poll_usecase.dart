import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/consensus_repository.dart';

class VoteOnPollUseCase implements UseCase<void, VoteOnPollParams> {
  final ConsensusRepository repository;
  const VoteOnPollUseCase(this.repository);

  @override
  Future<void> call(VoteOnPollParams params) => repository.voteOnPoll(
        pollId: params.pollId,
        optionIndex: params.optionIndex,
      );
}

class VoteOnPollParams extends Equatable {
  final String pollId;
  final int optionIndex;
  const VoteOnPollParams({required this.pollId, required this.optionIndex});

  @override
  List<Object?> get props => [pollId, optionIndex];
}
