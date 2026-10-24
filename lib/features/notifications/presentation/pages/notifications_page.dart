import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/notifications_bloc.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const WatchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      appBar: AppBar(
        backgroundColor: KxColors.bgSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: KxColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Bildirimler', style: KxTypography.headingSm),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () => context
                      .read<NotificationsBloc>()
                      .add(const MarkAllNotificationsReadEvent()),
                  child: Text(
                    'Tümünü oku',
                    style: KxTypography.labelSm
                        .copyWith(color: KxColors.teal400),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: KxColors.border, height: 1),
        ),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: KxColors.teal400),
            );
          }

          if (state is NotificationsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off_outlined,
                        size: 48, color: KxColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Bildirimler yüklenemedi',
                      style: KxTypography.headingSm,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bağlantınızı kontrol edip tekrar deneyin.',
                      style: KxTypography.bodyMd
                          .copyWith(color: KxColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context
                          .read<NotificationsBloc>()
                          .add(const WatchNotificationsEvent()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: KxColors.teal400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tekrar dene',
                          style: KxTypography.labelSm
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _EmptyState();
            }

            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(color: KxColors.border, height: 1),
              itemBuilder: (context, i) {
                final notif = state.notifications[i];
                return _NotificationTile(
                  notification: notif,
                  onTap: () {
                    if (!notif.isRead) {
                      context
                          .read<NotificationsBloc>()
                          .add(MarkNotificationReadEvent(notif.id));
                    }
                    if (notif.actionRoute != null) {
                      context.push(notif.actionRoute!);
                    }
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : KxColors.teal400.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBgColor(notification.type),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icon(notification.type),
                size: 18,
                color: _iconColor(notification.type),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: KxTypography.labelSm.copyWith(
                            color: notification.isRead
                                ? KxColors.textSecondary
                                : KxColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.timestamp),
                        style: KxTypography.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: KxTypography.bodyMd.copyWith(
                      color: KxColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unread dot
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(
                  color: KxColors.teal400,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _icon(NotificationType type) => switch (type) {
        NotificationType.newComment => Icons.comment_outlined,
        NotificationType.caseAccepted => Icons.check_circle_outline_rounded,
        NotificationType.caseSolved => Icons.emoji_events_outlined,
        NotificationType.caseAssigned => Icons.assignment_ind_outlined,
        NotificationType.newMessage => Icons.chat_bubble_outline_rounded,
        NotificationType.xpGained => Icons.bolt_rounded,
        NotificationType.levelUp => Icons.trending_up_rounded,
        NotificationType.mention => Icons.alternate_email_rounded,
        NotificationType.system => Icons.notifications_outlined,
      };

  Color _iconBgColor(NotificationType type) => switch (type) {
        NotificationType.newComment => KxColors.teal400.withOpacity(0.12),
        NotificationType.caseAccepted => KxColors.jade300.withOpacity(0.12),
        NotificationType.caseSolved => const Color(0xFFF59E0B).withOpacity(0.12),
        NotificationType.caseAssigned => KxColors.amber300.withOpacity(0.12),
        NotificationType.newMessage => const Color(0xFF8B5CF6).withOpacity(0.12),
        NotificationType.xpGained => KxColors.jade300.withOpacity(0.12),
        NotificationType.levelUp => const Color(0xFFF59E0B).withOpacity(0.12),
        NotificationType.mention => KxColors.teal400.withOpacity(0.12),
        NotificationType.system => KxColors.border.withOpacity(0.4),
      };

  Color _iconColor(NotificationType type) => switch (type) {
        NotificationType.newComment => KxColors.teal400,
        NotificationType.caseAccepted => KxColors.jade300,
        NotificationType.caseSolved => const Color(0xFFF59E0B),
        NotificationType.caseAssigned => KxColors.amber300,
        NotificationType.newMessage => const Color(0xFF8B5CF6),
        NotificationType.xpGained => KxColors.jade300,
        NotificationType.levelUp => const Color(0xFFF59E0B),
        NotificationType.mention => KxColors.teal400,
        NotificationType.system => KxColors.textMuted,
      };

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes}d';
    if (diff.inHours < 24) return '${diff.inHours}sa';
    if (diff.inDays == 1) return 'Dün';
    return '${dt.day}/${dt.month}';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: KxColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: KxColors.border),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: KxColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text('Bildirim yok', style: KxTypography.headingSm),
            const SizedBox(height: 8),
            Text(
              'Yeni vaka yorumları, mesajlar\nve XP kazanımları burada görünür.',
              style: KxTypography.bodyMd
                  .copyWith(color: KxColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
