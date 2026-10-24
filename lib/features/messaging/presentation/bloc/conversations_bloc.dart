import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/usecases/watch_conversations_usecase.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final WatchConversationsUseCase _watchConversations;

  ConversationsBloc({required WatchConversationsUseCase watchConversations})
      : _watchConversations = watchConversations,
        super(const ConversationsInitial()) {
    on<WatchConversationsEvent>(_onWatch);
  }

  Future<void> _onWatch(
    WatchConversationsEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(const ConversationsLoading());
    await emit.forEach(
      _watchConversations(),
      onData: (conversations) => ConversationsLoaded(conversations: conversations),
      onError: (e, _) => ConversationsError(e.toString()),
    );
  }
}
