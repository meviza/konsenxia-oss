import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/messages_bloc.dart';
import '../../domain/entities/direct_message.dart';

/// Tek konuşma — mesaj thread'i
class ConversationDetailPage extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;

  const ConversationDetailPage({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ConversationDetailPage> createState() =>
      _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<MessagesBloc>();
    bloc.add(WatchMessagesEvent(
      conversationId: widget.conversationId,
      otherUserId: widget.otherUserId,
      otherUserName: widget.otherUserName,
    ));
    bloc.add(MarkConversationReadEvent(widget.conversationId));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String myUid) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    context.read<MessagesBloc>().add(
          SendDirectMessageEvent(toUserId: widget.otherUserId, text: text),
        );
    _ctrl.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _MessageList(scroll: _scroll)),
          _InputBar(ctrl: _ctrl, onSend: _sendMessage),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: KxColors.bgSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: KxColors.textSecondary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          KxAvatar(name: widget.otherUserName, size: KxAvatarSize.sm),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUserName, style: KxTypography.labelMd),
              Text('Doktor', style: KxTypography.caption),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(color: KxColors.border, height: 1),
      ),
    );
  }
}

// ── Mesaj listesi ───────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final ScrollController scroll;

  const _MessageList({required this.scroll});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessagesBloc, MessagesState>(
      listenWhen: (prev, curr) =>
          curr is MessagesLoaded &&
          (prev is! MessagesLoaded ||
              curr.messages.length != (prev as MessagesLoaded).messages.length),
      listener: (context, state) {
        // Yeni mesaj geldiğinde aşağı kaydır
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scroll.hasClients) {
            scroll.animateTo(
              scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      },
      builder: (context, state) {
        if (state is MessagesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: KxColors.teal400),
          );
        }

        if (state is MessagesError) {
          return Center(
            child: Text(state.message,
                style: KxTypography.bodyMd
                    .copyWith(color: KxColors.textSecondary)),
          );
        }

        if (state is MessagesLoaded) {
          if (state.messages.isEmpty) {
            return Center(
              child: Text(
                'Konuşmayı başlatın',
                style:
                    KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
              ),
            );
          }

          // myUid — mesajları kendimizinkilerden ayırt etmek için
          // State'ten bilgi almak yerine direkt senderId'ye bakıyoruz
          final messages = state.messages;
          final myUid = _guessMyUid(messages, state.otherUserId);

          return ListView.builder(
            controller: scroll,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final msg = messages[i];
              final isMe = msg.senderId == myUid;
              final showDate = i == 0 ||
                  !_sameDay(messages[i - 1].timestamp, msg.timestamp);

              return Column(
                children: [
                  if (showDate)
                    _DateDivider(date: msg.timestamp),
                  _MessageBubble(message: msg, isMe: isMe),
                ],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Kendi uid'imizi bulmak için: otherUserId ile eşleşmeyen sender = biz
  String _guessMyUid(List<DirectMessage> messages, String otherUserId) {
    for (final m in messages) {
      if (m.senderId != otherUserId) return m.senderId;
    }
    return '';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Tarih bölücü ─────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    final label = diff == 0
        ? 'Bugün'
        : diff == 1
            ? 'Dün'
            : '${date.day}/${date.month}/${date.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: KxColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: KxTypography.caption),
          ),
          Expanded(child: Divider(color: KxColors.border)),
        ],
      ),
    );
  }
}

// ── Mesaj balonu ──────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final DirectMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? KxColors.teal400 : KxColors.bgCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: KxColors.border),
              ),
              child: Text(
                message.text,
                style: KxTypography.bodyMd.copyWith(
                  color: isMe ? KxColors.bgVoid : KxColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: KxTypography.caption.copyWith(fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 12,
                    color: message.isRead
                        ? KxColors.teal400
                        : KxColors.textMuted,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Input bar ──────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final void Function(String myUid) onSend;

  const _InputBar({required this.ctrl, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: BoxDecoration(
        color: KxColors.bgBase,
        border: Border(top: BorderSide(color: KxColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: KxColors.bgCard,
                borderRadius: KxSpacing.radiusPill,
                border: Border.all(color: KxColors.border),
              ),
              child: TextField(
                controller: ctrl,
                style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Mesaj yazın...',
                  hintStyle:
                      KxTypography.bodyMd.copyWith(color: KxColors.textDisabled),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<MessagesBloc, MessagesState>(
            builder: (context, state) {
              final isSending =
                  state is MessagesLoaded && state.isSending;
              return GestureDetector(
                onTap: isSending ? null : () => onSend(''),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isSending
                        ? null
                        : const LinearGradient(
                            colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                          ),
                    color: isSending ? KxColors.bgCard : null,
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: KxColors.teal400,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
