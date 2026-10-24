import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Molecule — KxChatBubble
///
/// AI ve kullanıcı mesaj kabarcıkları.
/// İki tip: kullanıcı (sağ, teal), AI/asistan (sol, koyu).
/// Typing indicator da dahildir.
///
/// Kullanım:
/// ```dart
/// KxChatBubble.user(text: 'Bu vakada ne düşünüyorsun?')
/// KxChatBubble.ai(text: 'Bulgulara göre...')
/// KxChatBubble.typing()
/// ```
enum KxChatRole { user, assistant }

class KxChatBubble extends StatelessWidget {
  final String? text;
  final KxChatRole role;
  final DateTime? timestamp;
  final bool isTyping;
  final bool hasError;
  final List<KxChatAction>? actions;

  const KxChatBubble({
    super.key,
    required this.text,
    required this.role,
    this.timestamp,
    this.isTyping = false,
    this.hasError = false,
    this.actions,
  });

  const KxChatBubble.user({
    Key? key,
    required String text,
    DateTime? timestamp,
  }) : this(
          key: key,
          text: text,
          role: KxChatRole.user,
          timestamp: timestamp,
        );

  const KxChatBubble.ai({
    Key? key,
    required String text,
    DateTime? timestamp,
    List<KxChatAction>? actions,
  }) : this(
          key: key,
          text: text,
          role: KxChatRole.assistant,
          timestamp: timestamp,
          actions: actions,
        );

  const KxChatBubble.typing() : this(
        text: null,
        role: KxChatRole.assistant,
        isTyping: true,
      );

  bool get _isUser => role == KxChatRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // AI avatar (sol)
          if (!_isUser) ...[
            _AiAvatar(),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: _isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildBubble(),
                if (timestamp != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _formatTime(timestamp!),
                    style: KxTypography.caption.copyWith(
                      fontSize: 10,
                      color: KxColors.textMuted,
                    ),
                  ),
                ],

                // Aksiyonlar (AI mesajları için)
                if (!_isUser && actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: actions!
                        .map((a) => _ActionChip(action: a))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // Kullanıcı boşluk (sağ)
          if (_isUser) ...[
            const SizedBox(width: 8),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildBubble() {
    if (isTyping) return _TypingBubble();

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _isUser
            ? KxColors.teal400.withOpacity(0.15)
            : KxColors.bgCard,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(_isUser ? 16 : 4),
          bottomRight: Radius.circular(_isUser ? 4 : 16),
        ),
        border: Border.all(
          color: _isUser
              ? KxColors.teal400.withOpacity(0.3)
              : KxColors.border,
        ),
      ),
      child: Text(
        text ?? '',
        style: KxTypography.bodyMd.copyWith(
          color: _isUser ? KxColors.teal100 : KxColors.textPrimary,
          height: 1.5,
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

/// Yazıyor göstergesi — üç noktalı animasyon
class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(color: KxColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final delay = i * 0.2;
              final phase = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
              final opacity = (phase < 0.5
                  ? phase * 2
                  : (1.0 - phase) * 2).clamp(0.3, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: KxColors.teal400.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: KxColors.teal400.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: KxColors.teal400.withOpacity(0.3)),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 14,
        color: KxColors.teal300,
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: KxColors.bgElevated,
        shape: BoxShape.circle,
        border: Border.all(color: KxColors.border),
      ),
      child: Icon(
        Icons.person_outline_rounded,
        size: 14,
        color: KxColors.textSecondary,
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final KxChatAction action;
  const _ActionChip({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: KxColors.bgElevated,
          borderRadius: KxSpacing.radiusSm,
          border: Border.all(color: KxColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.icon != null) ...[
              Icon(action.icon, size: 12, color: KxColors.teal400),
              const SizedBox(width: 4),
            ],
            Text(
              action.label,
              style: KxTypography.caption.copyWith(
                color: KxColors.teal300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aksiyonlar (örn: "Kaynakları Göster", "Kaydet")
class KxChatAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const KxChatAction({
    required this.label,
    this.icon,
    this.onTap,
  });
}
