part of 'ai_chat_bloc.dart';

abstract class AIChatEvent extends Equatable {
  const AIChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends AIChatEvent {
  final String message;

  const SendMessageEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Send a message with file attachments (images, PDFs, etc.)
class SendMessageWithAttachmentsEvent extends AIChatEvent {
  final String message;
  final List<ChatAttachment> attachments;

  const SendMessageWithAttachmentsEvent({
    required this.message,
    required this.attachments,
  });

  @override
  List<Object?> get props => [message, attachments];
}

class LoadChatHistoryEvent extends AIChatEvent {}

/// Load chat history from Firestore for the current user
class LoadChatFromFirestoreEvent extends AIChatEvent {}

class ToggleTypingEvent extends AIChatEvent {
  final bool isTyping;

  const ToggleTypingEvent({required this.isTyping});

  @override
  List<Object?> get props => [isTyping];
}

class ClearChatEvent extends AIChatEvent {}
