import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  /// Kullanıcının bildirimlerini gerçek zamanlı izler.
  Stream<List<AppNotification>> watchNotifications();

  /// Belirli bir bildirimi okundu olarak işaretler.
  Future<void> markAsRead(String notificationId);

  /// Tüm bildirimleri okundu olarak işaretler.
  Future<void> markAllAsRead();

  /// Okunmamış bildirim sayısını döner.
  Stream<int> watchUnreadCount();
}
