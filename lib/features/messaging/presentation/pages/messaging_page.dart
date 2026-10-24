import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/conversations_bloc.dart';
import '../../domain/entities/conversation.dart';

/// Konuşmalar listesi (giriş sayfası)
class MessagingPage extends StatefulWidget {
  const MessagingPage({super.key});

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  KxNavItem _activeNav = KxNavItem.messages;

  @override
  void initState() {
    super.initState();
    context.read<ConversationsBloc>().add(const WatchConversationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: isWide ? _buildWide() : _buildNarrow(),
    );
  }

  Widget _buildWide() {
    return Row(
      children: [
        KxSidebar(
          activeItem: _activeNav,
          onItemSelected: _onNavChanged,
          userName: 'Dr. Kerem',
          userSpecialty: 'Dahiliye',
          userLevel: 8,
          isOnline: true,
        ),
        Expanded(child: _ConversationsList()),
      ],
    );
  }

  Widget _buildNarrow() {
    return _ConversationsList();
  }

  void _onNavChanged(KxNavItem item) {
    setState(() => _activeNav = item);
    switch (item) {
      case KxNavItem.dashboard:
        context.go('/dashboard');
      case KxNavItem.cases:
        context.go('/cases');
      case KxNavItem.aiChat:
        context.go('/ai-chat');
      case KxNavItem.leaderboard:
        context.go('/leaderboard');
      case KxNavItem.analytics:
        context.go('/analytics');
      case KxNavItem.profile:
        context.go('/profile');
      default:
        break;
    }
  }
}

class _ConversationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Başlık
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Mesajlar', style: KxTypography.headingLg),
              const SizedBox(height: 4),
              Text(
                'Meslektaşlarınızla doğrudan konuşun',
                style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Divider(color: KxColors.border, height: 1),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: BlocBuilder<ConversationsBloc, ConversationsState>(
            builder: (context, state) {
              if (state is ConversationsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: KxColors.teal400),
                );
              }

              if (state is ConversationsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: KxTypography.bodyMd
                        .copyWith(color: KxColors.textSecondary),
                  ),
                );
              }

              if (state is ConversationsLoaded) {
                if (state.conversations.isEmpty) {
                  return _EmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.conversations.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: KxColors.border, height: 1, indent: 72),
                  itemBuilder: (context, i) =>
                      _ConversationTile(conversation: state.conversations[i]),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.hasUnread;

    return InkWell(
      onTap: () => context.push(
        '/messages/${conversation.id}',
        extra: {
          'otherUserId': conversation.otherUserId,
          'otherUserName': conversation.otherUserName,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                KxAvatar(
                  name: conversation.otherUserName,
                  imageUrl: conversation.otherUserPhotoUrl,
                  size: KxAvatarSize.lg,
                ),
                if (conversation.otherUserIsOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: KxColors.jade300,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: KxColors.bgBase, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // İsim + son mesaj
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: KxTypography.labelMd.copyWith(
                            color: hasUnread
                                ? KxColors.textPrimary
                                : KxColors.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: KxTypography.caption.copyWith(
                            color: hasUnread
                                ? KxColors.teal400
                                : KxColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessageText ?? conversation.otherUserSpecialty,
                          style: KxTypography.bodyMd.copyWith(
                            color: hasUnread
                                ? KxColors.textSecondary
                                : KxColors.textMuted,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: KxColors.teal400,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conversation.unreadCount > 9
                                ? '9+'
                                : conversation.unreadCount.toString(),
                            style: KxTypography.caption.copyWith(
                              color: KxColors.bgVoid,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

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
                Icons.chat_bubble_outline_rounded,
                size: 28,
                color: KxColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz konuşma yok',
              style: KxTypography.headingSm,
            ),
            const SizedBox(height: 8),
            Text(
              'Sıralama listesinden veya\nvaka sayfasından meslektaşlarınıza\nmesaj gönderin.',
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
