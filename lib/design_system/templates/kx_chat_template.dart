import 'package:flutter/material.dart';
import '../organisms/kx_ai_chat_panel.dart';
import '../tokens/app_colors.dart';

/// KONSENXIA Template — KxChatTemplate
///
/// AI Chat ve doktor-doktor mesajlaşma sayfa iskeleti.
/// Tam ekran sohbet düzeni: başlık + mesaj listesi + input.
///
/// Kullanım:
/// ```dart
/// KxChatTemplate(
///   title: 'AI Asistan',
///   subtitle: 'Medikal soru-cevap',
///   messages: messages,
///   onSend: (text) {},
///   isLoading: state.isLoading,
///   suggestions: ['Tanı öner', 'İlaç dozu nedir?'],
///   onBack: () => context.pop(),
/// )
/// ```
class KxChatTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<KxChatMessage> messages;
  final ValueChanged<String> onSend;
  final bool isLoading;
  final List<String> suggestions;
  final String inputHint;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const KxChatTemplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.messages,
    required this.onSend,
    this.isLoading = false,
    this.suggestions = const [],
    this.inputHint = 'Sorunuzu yazın...',
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      appBar: AppBar(
        backgroundColor: KxColors.bgSurface,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                color: const Color(0xFF8B96B5),
                onPressed: onBack,
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFF0F4FF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  color: Color(0xFF8B96B5),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          ...(actions ?? []),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: KxColors.border),
        ),
      ),
      body: KxAiChatPanel(
        messages: messages,
        onSend: onSend,
        isLoading: isLoading,
        suggestions: suggestions,
        inputHint: inputHint,
        showHeader: false,
      ),
    );
  }
}
