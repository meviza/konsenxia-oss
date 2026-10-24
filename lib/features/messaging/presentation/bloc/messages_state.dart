part of 'messages_bloc.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

class MessagesLoaded extends MessagesState {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final List<DirectMessage> messages;
  final bool isSending;
  final String? sendError;

  const MessagesLoaded({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.messages,
    this.isSending = false,
    this.sendError,
  });

  MessagesLoaded copyWith({
    List<DirectMessage>? messages,
    bool? isSending,
    String? sendError,
    bool clearError = false,
  }) {
    return MessagesLoaded(
      conversationId: conversationId,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      sendError: clearError ? null : (sendError ?? this.sendError),
    );
  }

  @override
  List<Object?> get props => [
        conversationId,
        messages,
        isSending,
        sendError,
      ];
}

class MessagesError extends MessagesState {
  final String message;

  const MessagesError(this.message);

  @override
  List<Object?> get props => [message];
}
