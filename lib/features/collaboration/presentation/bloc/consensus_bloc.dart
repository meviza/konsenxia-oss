import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/repositories/consensus_repository.dart';
import '../../domain/usecases/get_polls_usecase.dart';
import '../../domain/usecases/vote_on_poll_usecase.dart';
import 'consensus_event.dart';
import 'consensus_state.dart';

class ConsensusBloc extends Bloc<ConsensusEvent, ConsensusState> {
  final GetPollsUseCase _getPolls;
  final VoteOnPollUseCase _vote;

  ConsensusBloc({
    required GetPollsUseCase getPolls,
    required VoteOnPollUseCase vote,
  })  : _getPolls = getPolls,
        _vote = vote,
        super(const ConsensusInitial()) {
    on<LoadPollsEvent>(_onLoad);
    on<FilterPollsEvent>(_onFilter);
    on<VoteOnPollEvent>(_onVote);
    on<RefreshPollsEvent>(_onRefresh);
  }

  Future<void> _onLoad(
      LoadPollsEvent event, Emitter<ConsensusState> emit) async {
    emit(const ConsensusLoading());
    try {
      final polls = await _getPolls(GetPollsParams(status: event.status));
      emit(ConsensusLoaded(polls: polls, activeFilter: event.status));
    } on ConsensusException catch (e) {
      emit(ConsensusError(e.message));
    }
  }

  Future<void> _onFilter(
      FilterPollsEvent event, Emitter<ConsensusState> emit) async {
    emit(const ConsensusLoading());
    try {
      final polls = await _getPolls(GetPollsParams(status: event.status));
      emit(ConsensusLoaded(polls: polls, activeFilter: event.status));
    } on ConsensusException catch (e) {
      emit(ConsensusError(e.message));
    }
  }

  Future<void> _onRefresh(
      RefreshPollsEvent event, Emitter<ConsensusState> emit) async {
    final filter = state is ConsensusLoaded
        ? (state as ConsensusLoaded).activeFilter
        : null;
    add(LoadPollsEvent(status: filter));
  }

  Future<void> _onVote(
      VoteOnPollEvent event, Emitter<ConsensusState> emit) async {
    final current = state;
    if (current is! ConsensusLoaded) return;

    // Optimistic update
    final updatedPolls = current.polls.map((poll) {
      if (poll.id != event.pollId) return poll;
      final opts = poll.options.toList();
      var totalVotes = poll.totalVotes;

      // Önceki oy varsa geri al
      if (poll.myVoteIndex != null && poll.myVoteIndex! < opts.length) {
        opts[poll.myVoteIndex!] = opts[poll.myVoteIndex!]
            .copyWith(voteCount: opts[poll.myVoteIndex!].voteCount - 1);
        totalVotes = (totalVotes - 1).clamp(0, totalVotes);
      }

      // Aynı seçeneğe tekrar → iptal
      if (poll.myVoteIndex == event.optionIndex) {
        return poll.copyWith(
          options: opts,
          totalVotes: totalVotes,
          myVoteIndex: -1, // -1 = oy yok ama null olmayan gösterim
        );
      }

      // Yeni oy
      if (event.optionIndex < opts.length) {
        opts[event.optionIndex] = opts[event.optionIndex]
            .copyWith(voteCount: opts[event.optionIndex].voteCount + 1);
        totalVotes++;
      }

      return poll.copyWith(
        options: opts,
        totalVotes: totalVotes,
        myVoteIndex: event.optionIndex,
      );
    }).toList();

    emit(current.copyWith(polls: updatedPolls));

    try {
      await _vote(VoteOnPollParams(
        pollId: event.pollId,
        optionIndex: event.optionIndex,
      ));
    } on ConsensusException {
      emit(current); // rollback
    }
  }
}
