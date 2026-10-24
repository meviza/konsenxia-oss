import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/direct_message.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/watch_messages_usecase.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final WatchMessagesUseCase _watchMessages;
  final SendMessageUseCase _sendMessage;
  final MarkAsReadUseCase _markAsRead;

  MessagesBloc({
    required WatchMessagesUseCase watchMessages,
    required SendMessageUseCase sendMessage,
    required MarkAsReadUseCase markAsRead,
  })  : _watchMessages = watchMessages,
        _sendMessage = sendMessage,
        _markAsRead = markAsRead,
        super(const MessagesInitial()) {
    on<WatchMessagesEvent>(_onWatch);
    on<SendDirectMessageEvent>(_onSend);
    on<MarkConversationReadEvent>(_onMarkRead);
  }

  Future<void> _onWatch(
    WatchMessagesEvent event,
    Emitter<MessagesState> emit,
  ) async {
    emit(const MessagesLoading());
    await emit.forEach(
      _watchMessages(event.conversationId),
      onData: (messages) => MessagesLoaded(
        conversationId: event.conversationId,
        otherUserId: event.otherUserId,
        otherUserName: event.otherUserName,
        messages: messages,
      ),
      onError: (e, _) => MessagesError(e.toString()),
    );
  }

  Future<void> _onSend(
    SendDirectMessageEvent event,
    Emitter<MessagesState> emit,
  ) async {
    if (state is! MessagesLoaded) return;
    final current = state as MessagesLoaded;
    emit(current.copyWith(isSending: true));

    try {
      await _sendMessage(toUserId: event.toUserId, text: event.text);
      emit(current.copyWith(isSending: false));
    } catch (e) {
      emit(current.copyWith(
        isSending: false,
        sendError: e.toString(),
      ));
    }
  }

  Future<void> _onMarkRead(
    MarkConversationReadEvent event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      await _markAsRead(event.conversationId);
    } catch (_) {
      // Sessizce yoksay — kritik değil
    }
  }
}
