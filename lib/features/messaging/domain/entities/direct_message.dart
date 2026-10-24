import 'package:equatable/equatable.dart';

/// Doktor-doktor direkt mesajı.
class DirectMessage extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const DirectMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, conversationId, senderId, text, timestamp, isRead];
}
