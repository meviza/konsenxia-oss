import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/claude_ai_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/chat_message.dart';

part 'ai_chat_event.dart';
part 'ai_chat_state.dart';

class AIChatBloc extends Bloc<AIChatEvent, AIChatState> {
  final Dio _dio;
  final LocalStorage _storage;
  final ClaudeAIService _claudeAI;
  final FirebaseFirestore _firestore;

  /// Konusma gecmisi — Claude API'ye baglam olarak gonderilir
  final List<Map<String, String>> _conversationHistory = [];

  AIChatBloc({
    required Dio dio,
    required LocalStorage storage,
    required ClaudeAIService claudeAI,
    FirebaseFirestore? firestore,
  })  : _dio = dio,
        _storage = storage,
        _claudeAI = claudeAI,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const AIChatState.initial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SendMessageWithAttachmentsEvent>(_onSendMessageWithAttachments);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<LoadChatFromFirestoreEvent>(_onLoadChatFromFirestore);
    on<ToggleTypingEvent>(_onToggleTyping);
    on<ClearChatEvent>(_onClearChat);
  }

  // ── Firestore helpers ──────────────────────────────────────────────

  String get _userId => _storage.getUserId() ?? 'anonymous';

  CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      _firestore.collection('ai_conversations').doc(_userId).collection('messages');

  Future<void> _saveMessageToFirestore(ChatMessage message) async {
    try {
      await _messagesCollection.doc(message.id).set(message.toFirestore());
    } catch (_) {
      // Silently fail — chat still works without persistence
    }
  }

  // ── Send plain text message ────────────────────────────────────────

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<AIChatState> emit,
  ) async {
    final userId = _userId;

    // 1 — Add user message immediately
    final userMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_u',
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // 2 — Add an empty AI placeholder for streaming
    final aiId = '${DateTime.now().millisecondsSinceEpoch}_ai';
    final placeholder = ChatMessage(
      id: aiId,
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    var messages = [...state.messages, userMessage, placeholder];
    emit(state.copyWith(
      messages: messages,
      isTyping: true,
      streamingMessageId: aiId,
      clearError: true,
    ));

    // Save user message to Firestore
    _saveMessageToFirestore(userMessage);

    // Konusma gecmisine ekle
    _conversationHistory.add({'role': 'user', 'content': event.message});

    // 3 — Try SSE streaming first, fall back to REST, then Claude direct
    final success = await _tryStreaming(
      message: event.message,
      emit: emit,
      userId: userId,
      aiId: aiId,
      messages: messages,
    );

    if (!success) {
      final restSuccess = await _fallbackRest(
        message: event.message,
        emit: emit,
        userId: userId,
        aiId: aiId,
        messages: messages,
      );

      if (!restSuccess) {
        await _fallbackClaude(
          message: event.message,
          emit: emit,
          aiId: aiId,
          messages: messages,
        );
      }
    }
  }

  // ── Send message with file attachments ─────────────────────────────

  Future<void> _onSendMessageWithAttachments(
    SendMessageWithAttachmentsEvent event,
    Emitter<AIChatState> emit,
  ) async {
    final attachmentNames = event.attachments.map((a) => a.fileName).toList();
    final hasImages = event.attachments.any((a) => a.isImage);

    // Build the combined prompt text
    final promptParts = <String>[];

    if (event.message.isNotEmpty) {
      promptParts.add(event.message);
    }

    // Add file descriptions for non-image files
    for (final attachment in event.attachments) {
      if (!attachment.isImage) {
        promptParts.add(
          '\n---\nDosya: ${attachment.fileName} '
          '(${attachment.formattedSize}, ${attachment.extension.toUpperCase()})'
          '${attachment.textContent != null ? '\nIcerik:\n${attachment.textContent}' : ''}',
        );
      }
    }

    final displayText = event.message.isNotEmpty
        ? event.message
        : 'Dosya analizi istegi';
    final attachmentLabel = attachmentNames.length == 1
        ? attachmentNames.first
        : '${attachmentNames.length} dosya';

    // User message shown in chat
    final userMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_u',
      text: '$displayText\n\n[Ek: $attachmentLabel]',
      isUser: true,
      timestamp: DateTime.now(),
      hasAttachments: true,
      attachmentNames: attachmentNames,
    );

    final aiId = '${DateTime.now().millisecondsSinceEpoch}_ai';
    final placeholder = ChatMessage(
      id: aiId,
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    var messages = [...state.messages, userMessage, placeholder];
    emit(state.copyWith(
      messages: messages,
      isTyping: true,
      streamingMessageId: aiId,
      clearError: true,
    ));

    // Save user message to Firestore
    _saveMessageToFirestore(userMessage);

    // Build the full prompt for AI
    final fullPrompt = promptParts.join('\n');

    if (hasImages) {
      // Use vision model for images
      await _sendWithVision(
        textPrompt: fullPrompt,
        attachments: event.attachments,
        emit: emit,
        aiId: aiId,
        messages: messages,
      );
    } else {
      // Text-only (PDF metadata, etc.) — use regular text model
      _conversationHistory.add({'role': 'user', 'content': fullPrompt});

      final success = await _tryStreaming(
        message: fullPrompt,
        emit: emit,
        userId: _userId,
        aiId: aiId,
        messages: messages,
      );

      if (!success) {
        final restSuccess = await _fallbackRest(
          message: fullPrompt,
          emit: emit,
          userId: _userId,
          aiId: aiId,
          messages: messages,
        );

        if (!restSuccess) {
          await _fallbackClaude(
            message: fullPrompt,
            emit: emit,
            aiId: aiId,
            messages: messages,
          );
        }
      }
    }
  }

  /// Send images to the vision model along with text prompt
  Future<void> _sendWithVision({
    required String textPrompt,
    required List<ChatAttachment> attachments,
    required Emitter<AIChatState> emit,
    required String aiId,
    required List<ChatMessage> messages,
  }) async {
    try {
      // Collect all image attachments as base64
      final imageAttachments = attachments.where((a) => a.isImage).toList();
      final nonImageAttachments = attachments.where((a) => !a.isImage).toList();

      // Build prompt including non-image file info
      var prompt = textPrompt;
      if (prompt.isEmpty) {
        prompt = 'Bu tibbi goruntuleri analiz et.';
      }

      // For multiple images, analyze each separately and combine results
      // Each image gets its own vision API call with the user's prompt
      final results = <String>[];

      for (final img in imageAttachments) {
        if (img.base64Content == null) continue;
        final response = await _claudeAI.analyzeImage(
          imageBase64: img.base64Content!,
          mimeType: img.mimeType,
          clinicalContext: prompt,
        );
        if (imageAttachments.length > 1) {
          results.add('**${img.fileName}:**\n${response.text}');
        } else {
          results.add(response.text);
        }
      }

      // Add non-image file descriptions
      for (final file in nonImageAttachments) {
        results.add('**${file.fileName}** (${file.formattedSize}): '
            '${file.textContent ?? "Dosya icerigi okunamadi."}');
      }

      final combinedResult = results.join('\n\n---\n\n');
      final finalText = combinedResult.isEmpty ? 'Dosya analizi yapilamadi.' : combinedResult;

      _conversationHistory.add({'role': 'user', 'content': prompt});
      _conversationHistory.add({'role': 'assistant', 'content': finalText});

      messages = messages
          .map((m) => m.id == aiId
              ? m.copyWith(
                  text: finalText,
                  suggestions: _claudeAI.isConfigured
                      ? ['Daha fazla detay', 'Baska bir goruntu analiz et', 'Diferansiyel tani']
                      : [],
                  confidence: 0.9,
                )
              : m)
          .toList();

      final aiMessage = messages.firstWhere((m) => m.id == aiId);
      _saveMessageToFirestore(aiMessage);

      emit(state.copyWith(
        messages: messages,
        isTyping: false,
        clearStreamingId: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isTyping: false,
        clearStreamingId: true,
        error: 'Dosya analizi sirasinda hata olustu: $e',
      ));
    }
  }

  /// Streams tokens from `/ai/chat/stream` (SSE).
  Future<bool> _tryStreaming({
    required String message,
    required Emitter<AIChatState> emit,
    required String userId,
    required String aiId,
    required List<ChatMessage> messages,
  }) async {
    try {
      final response = await _dio.post<ResponseBody>(
        '/ai/chat/stream',
        data: {
          'message': message,
          'userRole': 'DOCTOR',
          'userId': userId,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data!.stream;
      var accumulated = '';
      List<String>? finalSuggestions;
      final lineBuffer = StringBuffer();

      await for (final chunk in stream) {
        lineBuffer.write(utf8.decode(chunk, allowMalformed: true));
        final raw = lineBuffer.toString();

        final parts = raw.split('\n\n');

        for (var i = 0; i < parts.length - 1; i++) {
          final line = parts[i].trim();
          if (!line.startsWith('data: ')) continue;

          final data = line.substring(6).trim();
          if (data == '[DONE]') continue;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final token = json['token'] as String? ?? '';
            accumulated += token;

            if (json['suggestions'] != null) {
              finalSuggestions =
                  List<String>.from(json['suggestions'] as List);
            }

            messages = messages
                .map((m) => m.id == aiId ? m.copyWith(text: accumulated) : m)
                .toList();
            emit(state.copyWith(messages: messages));
          } catch (_) {}
        }

        lineBuffer.clear();
        lineBuffer.write(parts.last);
      }

      final finalText = accumulated.isEmpty ? 'No response' : accumulated;
      _conversationHistory.add({'role': 'assistant', 'content': finalText});

      messages = messages
          .map((m) => m.id == aiId
              ? m.copyWith(
                  text: finalText,
                  suggestions: finalSuggestions,
                  confidence: 0.9,
                )
              : m)
          .toList();

      final aiMessage = messages.firstWhere((m) => m.id == aiId);
      _saveMessageToFirestore(aiMessage);

      emit(state.copyWith(
        messages: messages,
        isTyping: false,
        clearStreamingId: true,
      ));
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == null || status == 404 || status == 501) return false;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Non-streaming fallback — calls `/ai/chat/send`.
  Future<bool> _fallbackRest({
    required String message,
    required Emitter<AIChatState> emit,
    required String userId,
    required String aiId,
    required List<ChatMessage> messages,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/ai/chat/send',
        data: {
          'message': message,
          'userRole': 'DOCTOR',
          'userId': userId,
        },
      );

      final raw = response.data;
      final data = raw is Map ? raw['data'] ?? raw : raw;
      final text =
          data is Map ? (data['text'] as String?) ?? 'No response' : 'No response';
      final suggestions = data is Map && data['suggestions'] != null
          ? List<String>.from(data['suggestions'] as List)
          : <String>[];

      _conversationHistory.add({'role': 'assistant', 'content': text});

      messages = messages
          .map((m) => m.id == aiId
              ? m.copyWith(text: text, suggestions: suggestions, confidence: 0.9)
              : m)
          .toList();

      final aiMessage = messages.firstWhere((m) => m.id == aiId);
      _saveMessageToFirestore(aiMessage);

      emit(state.copyWith(
        messages: messages,
        isTyping: false,
        clearStreamingId: true,
      ));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Claude API direct fallback — backend tamamen erisilemezken
  Future<void> _fallbackClaude({
    required String message,
    required Emitter<AIChatState> emit,
    required String aiId,
    required List<ChatMessage> messages,
  }) async {
    try {
      final userName = _storage.getUserName() ?? 'Doktor';
      final userRole = _storage.userRole ?? 'Hekim';
      final doctorContext = '$userName — $userRole';

      final response = await _claudeAI.sendMessage(
        message: message,
        conversationHistory:
            _conversationHistory.length > 1
                ? _conversationHistory.sublist(
                    0, _conversationHistory.length - 1)
                : null,
        doctorContext: doctorContext,
      );

      _conversationHistory.add({'role': 'assistant', 'content': response.text});

      messages = messages
          .map((m) => m.id == aiId
              ? m.copyWith(
                  text: response.text,
                  suggestions: response.suggestions,
                  confidence: response.source == 'claude-direct' ? 0.95 : 0.7,
                  metadata: {'source': response.source},
                )
              : m)
          .toList();

      final aiMessage = messages.firstWhere((m) => m.id == aiId);
      _saveMessageToFirestore(aiMessage);

      emit(state.copyWith(
        messages: messages,
        isTyping: false,
        clearStreamingId: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isTyping: false,
        clearStreamingId: true,
        error: 'AI servisine baglanamadi: $e',
      ));
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<AIChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    emit(state.copyWith(isLoading: false));
  }

  /// Load chat history from Firestore
  Future<void> _onLoadChatFromFirestore(
    LoadChatFromFirestoreEvent event,
    Emitter<AIChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final snapshot = await _messagesCollection
          .orderBy('timestamp', descending: false)
          .limit(100)
          .get();

      final loadedMessages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc.id, doc.data()))
          .toList();

      // Rebuild conversation history for AI context
      _conversationHistory.clear();
      for (final msg in loadedMessages) {
        _conversationHistory.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }

      emit(state.copyWith(
        messages: loadedMessages,
        isLoading: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Sohbet gecmisi yuklenemedi: $e',
      ));
    }
  }

  Future<void> _onToggleTyping(
    ToggleTypingEvent event,
    Emitter<AIChatState> emit,
  ) async {
    emit(state.copyWith(isTyping: event.isTyping));
  }

  Future<void> _onClearChat(
    ClearChatEvent event,
    Emitter<AIChatState> emit,
  ) async {
    _conversationHistory.clear();

    // Also clear Firestore history
    try {
      final snapshot = await _messagesCollection.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (_) {
      // Silently fail
    }

    emit(const AIChatState.initial());
  }
}
