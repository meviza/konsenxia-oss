part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class WatchNotificationsEvent extends NotificationsEvent {
  const WatchNotificationsEvent();
}

class MarkNotificationReadEvent extends NotificationsEvent {
  final String notificationId;
  const MarkNotificationReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsReadEvent extends NotificationsEvent {
  const MarkAllNotificationsReadEvent();
}
