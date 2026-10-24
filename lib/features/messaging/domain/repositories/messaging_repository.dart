import '../entities/conversation.dart';
import '../entities/direct_message.dart';

abstract class MessagingRepository {
  /// Giriş yapan doktorun konuşma listesini gerçek zamanlı izler.
  Stream<List<Conversation>> watchConversations();

  /// Belirli bir konuşmanın mesajlarını gerçek zamanlı izler.
  Stream<List<DirectMessage>> watchMessages(String conversationId);

  /// Mesaj gönderir; konuşma yoksa otomatik oluşturur.
  Future<void> sendMessage({
    required String toUserId,
    required String text,
  });

  /// Konuşmadaki okunmamış mesajları okundu olarak işaretler.
  Future<void> markAsRead(String conversationId);

  /// Konuşmayı başlatmak için gereken kullanıcı bilgisini arar
  /// (Leaderboard/Cases'dan seçilen doktoru mesajlamak için).
  Future<String> getOrCreateConversationId(String otherUserId);
}
