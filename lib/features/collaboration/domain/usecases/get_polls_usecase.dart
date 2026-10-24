import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/poll_entity.dart';
import '../repositories/consensus_repository.dart';

class GetPollsUseCase implements UseCase<List<PollEntity>, GetPollsParams> {
  final ConsensusRepository repository;
  const GetPollsUseCase(this.repository);

  @override
  Future<List<PollEntity>> call(GetPollsParams params) =>
      repository.getPolls(status: params.status);
}

class GetPollsParams extends Equatable {
  final PollStatus? status;
  const GetPollsParams({this.status});

  @override
  List<Object?> get props => [status];
}
