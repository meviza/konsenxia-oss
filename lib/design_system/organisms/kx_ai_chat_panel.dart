import 'package:flutter/material.dart';
import '../molecules/kx_chat_bubble.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Organism — KxAiChatPanel
///
/// Tam AI sohbet paneli. Mesaj listesi + input çubuğu + suggestion chip'leri.
/// Sayfa içine embed edilebilir veya tam sayfa olarak kullanılabilir.
///
/// Kullanım:
/// ```dart
/// KxAiChatPanel(
///   messages: messages,
///   onSend: (text) => bloc.add(SendMessage(text)),
///   isLoading: state.isTyping,
///   suggestions: ['Tanı ne olabilir?', 'Tedavi öner'],
/// )
/// ```

class KxChatMessage {
  final String id;
  final String text;
  final KxChatRole role;
  final DateTime time;
  final List<KxChatAction>? actions;

  const KxChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.time,
    this.actions,
  });
}

class KxAiChatPanel extends StatefulWidget {
  final List<KxChatMessage> messages;
  final ValueChanged<String> onSend;
  final bool isLoading;
  final List<String> suggestions;
  final String inputHint;
  final Widget? header;
  final bool showHeader;

  const KxAiChatPanel({
    super.key,
    required this.messages,
    required this.onSend,
    this.isLoading = false,
    this.suggestions = const [],
    this.inputHint = 'Sorunuzu yazın...',
    this.header,
    this.showHeader = true,
  });

  @override
  State<KxAiChatPanel> createState() => _KxAiChatPanelState();
}

class _KxAiChatPanelState extends State<KxAiChatPanel> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(() {
      final has = _inputCtrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void didUpdateWidget(KxAiChatPanel old) {
    super.didUpdateWidget(old);
    if (old.messages.length != widget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header (opsiyonel)
        if (widget.showHeader) _buildHeader(),

        // Mesaj listesi
        Expanded(
          child: _buildMessageList(),
        ),

        // Suggestion chip'leri
        if (widget.suggestions.isNotEmpty && widget.messages.isEmpty)
          _buildSuggestions(),

        // Input alanı
        _buildInput(),
      ],
    );
  }

  Widget _buildHeader() {
    if (widget.header != null) return widget.header!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        border: Border(bottom: BorderSide(color: KxColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: KxColors.teal400.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: KxColors.teal400.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: KxColors.teal300,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KONSENXIA AI',
                style: KxTypography.labelMd.copyWith(
                  color: KxColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: KxColors.jade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Medikal AI Asistanı · Çevrimiçi',
                    style: KxTypography.caption.copyWith(
                      color: KxColors.jade300,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: KxColors.textMuted,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: widget.messages.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (widget.isLoading && i == widget.messages.length) {
          return const KxChatBubble.typing();
        }
        final msg = widget.messages[i];
        return msg.role == KxChatRole.user
            ? KxChatBubble.user(text: msg.text, timestamp: msg.time)
            : KxChatBubble.ai(
                text: msg.text,
                timestamp: msg.time,
                actions: msg.actions,
              );
      },
    );
  }

  Widget _buildSuggestions() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: KxColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: widget.suggestions
              .map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SuggestionChip(
                      text: s,
                      onTap: () => widget.onSend(s),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        border: Border(top: BorderSide(color: KxColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: KxColors.bgSurface,
                borderRadius: KxSpacing.radiusMd,
                border: Border.all(color: KxColors.border),
              ),
              child: TextField(
                controller: _inputCtrl,
                maxLines: null,
                style: KxTypography.bodyMd.copyWith(
                  color: KxColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.inputHint,
                  hintStyle: KxTypography.bodyMd.copyWith(
                    color: KxColors.textMuted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Gönder butonu
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _hasText
                  ? KxColors.teal400
                  : KxColors.bgElevated,
              borderRadius: KxSpacing.radiusMd,
              border: Border.all(
                color: _hasText ? KxColors.teal400 : KxColors.border,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                size: 18,
                color: _hasText
                    ? KxColors.bgVoid
                    : KxColors.textDisabled,
              ),
              onPressed: _hasText ? _send : null,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: KxColors.teal400.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KxColors.teal400.withOpacity(0.25)),
        ),
        child: Text(
          text,
          style: KxTypography.labelSm.copyWith(
            color: KxColors.teal300,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
