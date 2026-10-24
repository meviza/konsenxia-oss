part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;

  const NotificationsLoaded({required this.notifications});

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  List<AppNotification> get unread =>
      notifications.where((n) => !n.isRead).toList();

  @override
  List<Object?> get props => [notifications];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
