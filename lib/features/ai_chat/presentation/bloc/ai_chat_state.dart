part of 'ai_chat_bloc.dart';

class AIChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;
  /// ID of the AI message currently being streamed (null when not streaming).
  final String? streamingMessageId;

  const AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.error,
    this.streamingMessageId,
  });

  const AIChatState.initial() : this();

  bool get isStreaming => streamingMessageId != null;

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
    String? streamingMessageId,
    bool clearStreamingId = false,
    bool clearError = false,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: clearError ? null : (error ?? this.error),
      streamingMessageId:
          clearStreamingId ? null : (streamingMessageId ?? this.streamingMessageId),
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, isTyping, error, streamingMessageId];
}
