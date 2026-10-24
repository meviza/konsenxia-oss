part of 'messages_bloc.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

class WatchMessagesEvent extends MessagesEvent {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;

  const WatchMessagesEvent({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  List<Object?> get props => [conversationId, otherUserId];
}

class SendDirectMessageEvent extends MessagesEvent {
  final String toUserId;
  final String text;

  const SendDirectMessageEvent({required this.toUserId, required this.text});

  @override
  List<Object?> get props => [toUserId, text];
}

class MarkConversationReadEvent extends MessagesEvent {
  final String conversationId;

  const MarkConversationReadEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}
