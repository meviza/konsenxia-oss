part of 'conversations_bloc.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  final List<Conversation> conversations;

  const ConversationsLoaded({required this.conversations});

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  List<Object?> get props => [conversations];
}

class ConversationsError extends ConversationsState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}
