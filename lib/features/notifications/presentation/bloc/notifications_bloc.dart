import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsInitial()) {
    on<WatchNotificationsEvent>(_onWatch);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
  }

  Future<void> _onWatch(
    WatchNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      await emit.forEach(
        _repository.watchNotifications(),
        onData: (notifications) =>
            NotificationsLoaded(notifications: notifications),
        onError: (e, _) => const NotificationsError(
            'Bildirimler yüklenemedi. Lütfen tekrar deneyin.'),
      );
    } catch (e) {
      emit(const NotificationsError(
          'Bildirimler yüklenemedi. Lütfen tekrar deneyin.'));
    }
  }

  Future<void> _onMarkRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.notificationId);
    } catch (_) {}
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.markAllAsRead();
    } catch (_) {}
  }
}
