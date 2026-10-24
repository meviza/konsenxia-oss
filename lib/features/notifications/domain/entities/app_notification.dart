import 'package:equatable/equatable.dart';

enum NotificationType {
  newComment,     // Vakana yorum yapıldı
  caseAccepted,   // Cevabın kabul edildi
  caseSolved,     // Takip ettiğin vaka çözüldü
  caseAssigned,   // Sana vaka atandı
  newMessage,     // Yeni direkt mesaj
  xpGained,       // XP kazandın
  levelUp,        // Seviye atladın
  mention,        // Senden bahsedildi
  system,         // Sistem bildirimi
}

class AppNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;   // Navigate target (e.g. '/cases/abc123')
  final Map<String, dynamic>? payload;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.payload,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
      payload: payload,
    );
  }

  @override
  List<Object?> get props => [id, type, isRead, timestamp];
}
