import 'package:equatable/equatable.dart';

/// İki doktor arasındaki direkt mesajlaşma konuşması.
class Conversation extends Equatable {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String otherUserSpecialty;
  final bool otherUserIsOnline;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.otherUserSpecialty,
    this.otherUserIsOnline = false,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [
        id,
        otherUserId,
        lastMessageText,
        lastMessageAt,
        unreadCount,
      ];
}
