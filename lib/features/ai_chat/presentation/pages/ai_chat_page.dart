import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/claude_ai_service.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/ai_chat_bloc.dart';

/// KONSENXIA AI Asistani
///
/// Medikal AI chat arayuzu. Sol: konusma listesi. Sag: chat alani.
/// Dar ekranda tek panel.
class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  KxNavItem _activeNav = KxNavItem.aiChat;
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  /// Pending files waiting to be sent with the next message
  final List<PlatformFile> _pendingFiles = [];

  @override
  void initState() {
    super.initState();
    // Load chat history from Firestore on page load
    context.read<AIChatBloc>().add(LoadChatFromFirestoreEvent());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addPendingFiles(List<PlatformFile> files) {
    setState(() {
      _pendingFiles.addAll(files);
    });
  }

  void _removePendingFile(int index) {
    setState(() {
      _pendingFiles.removeAt(index);
    });
  }

  void _clearPendingFiles() {
    setState(() {
      _pendingFiles.clear();
    });
  }

  /// Send the current message (with or without attachments)
  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty && _pendingFiles.isEmpty) return;

    if (_pendingFiles.isNotEmpty) {
      // Build attachments from pending files
      final attachments = <ChatAttachment>[];

      for (final file in _pendingFiles) {
        if (file.path == null) continue;

        final ext = file.extension?.toLowerCase() ?? '';
        String? base64Content;
        String? textContent;

        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
          // Read image as base64
          final bytes = await File(file.path!).readAsBytes();
          base64Content = base64Encode(bytes);
        } else if (ext == 'pdf') {
          // For PDF, include file metadata (full text extraction would need a PDF library)
          textContent = 'PDF dosyasi: ${file.name}, '
              'Boyut: ${(file.size / 1024).toStringAsFixed(1)} KB. '
              'Bu PDF dosyasinin icerigini analiz etmem isteniyor.';
        } else {
          // Try to read as text
          try {
            textContent = await File(file.path!).readAsString();
          } catch (_) {
            textContent = 'Dosya icerigi okunamadi (${file.name})';
          }
        }

        attachments.add(ChatAttachment(
          fileName: file.name,
          filePath: file.path!,
          fileSize: file.size,
          extension: ext,
          base64Content: base64Content,
          textContent: textContent,
        ));
      }

      if (!mounted) return;
      context.read<AIChatBloc>().add(SendMessageWithAttachmentsEvent(
        message: text,
        attachments: attachments,
      ));
    } else {
      context.read<AIChatBloc>().add(SendMessageEvent(message: text));
    }

    _inputCtrl.clear();
    _clearPendingFiles();

    // Scroll to bottom after a brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        // Konusma listesi (sidebar MainShell'den geliyor, burada tekrarlamiyoruz)
        Container(
          width: 260,
          decoration: BoxDecoration(
            color: KxColors.bgSurface,
            border: Border(right: BorderSide(color: KxColors.border)),
          ),
          child: _ConversationList(),
        ),
        // Chat alani
        Expanded(child: _ChatPanel(
          inputCtrl: _inputCtrl,
          scrollCtrl: _scrollCtrl,
          pendingFiles: _pendingFiles,
          onRemovePendingFile: _removePendingFile,
          onAddPendingFiles: _addPendingFiles,
          onSend: _sendMessage,
        )),
      ],
    );
  }

  Widget _buildNarrow() {
    return _ChatPanel(
      inputCtrl: _inputCtrl,
      scrollCtrl: _scrollCtrl,
      pendingFiles: _pendingFiles,
      onRemovePendingFile: _removePendingFile,
      onAddPendingFiles: _addPendingFiles,
      onSend: _sendMessage,
    );
  }

  void _onNavChanged(KxNavItem item) {
    setState(() => _activeNav = item);
    switch (item) {
      case KxNavItem.dashboard:
        context.go('/dashboard');
      case KxNavItem.cases:
        context.go('/cases');
      case KxNavItem.messages:
        context.go('/messages');
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

// ── Dosya Ekleme Fonksiyonlari ──────────────────────────────────────

void _showAttachOptions(BuildContext context, void Function(List<PlatformFile>) onFilesSelected) {
  showModalBottomSheet(
    context: context,
    backgroundColor: KxColors.bgElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosya Ekle', style: KxTypography.headingSm),
            const SizedBox(height: 4),
            Text('Tibbi goruntu veya belge gonderin',
                style: KxTypography.caption.copyWith(color: KxColors.textMuted)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AttachOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    color: KxColors.teal400,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImageToQueue(context, ImageSource.gallery, onFilesSelected);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AttachOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    color: KxColors.blue400,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImageToQueue(context, ImageSource.camera, onFilesSelected);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AttachOption(
                    icon: Icons.description_rounded,
                    label: 'Dosya',
                    color: KxColors.amber300,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickFilesToQueue(context, onFilesSelected);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Pick image from gallery/camera and add to pending queue (do NOT send)
Future<void> _pickImageToQueue(
  BuildContext context,
  ImageSource source,
  void Function(List<PlatformFile>) onFilesSelected,
) async {
  try {
    final picker = ImagePicker();

    if (source == ImageSource.gallery) {
      // Allow multiple image selection from gallery
      final picked = await picker.pickMultiImage(maxWidth: 1024, imageQuality: 85);
      if (picked.isEmpty) return;

      final platformFiles = <PlatformFile>[];
      for (final xfile in picked) {
        final file = File(xfile.path);
        final bytes = await file.readAsBytes();
        final ext = xfile.path.split('.').last.toLowerCase();
        platformFiles.add(PlatformFile(
          name: xfile.name,
          path: xfile.path,
          size: bytes.length,
          bytes: bytes,
        ));
      }
      onFilesSelected(platformFiles);
    } else {
      // Camera — single image
      final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (picked == null) return;
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      onFilesSelected([
        PlatformFile(
          name: picked.name,
          path: picked.path,
          size: bytes.length,
          bytes: bytes,
        ),
      ]);
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goruntu secilemedi: $e'),
        backgroundColor: KxColors.crimson400,
      ),
    );
  }
}

/// Pick multiple files and add to pending queue (do NOT send)
Future<void> _pickFilesToQueue(
  BuildContext context,
  void Function(List<PlatformFile>) onFilesSelected,
) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'dcm', 'txt', 'csv'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    // Filter out files without paths
    final validFiles = result.files.where((f) => f.path != null).toList();
    if (validFiles.isNotEmpty) {
      onFilesSelected(validFiles);
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dosya secilemedi: $e'), backgroundColor: KxColors.crimson400),
    );
  }
}

// ── Konusma Listesi ─────────────────────────────────────────────────

class _ConversationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Baslik
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Text('Asistan', style: KxTypography.headingSm),
              const Spacer(),
              Icon(Icons.edit_outlined, size: 18, color: KxColors.textMuted),
            ],
          ),
        ),
        // Yeni sohbet butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: KxButton.secondary(
            label: '+ Yeni Sohbet',
            onPressed: () {},
            isFullWidth: true,
          ),
        ),
        const SizedBox(height: 12),
        // Gecmis
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _ConvTile(
                title: 'Rocky Mountain atesi ayirici tanisi',
                time: '2sa',
                isActive: true,
              ),
              _ConvTile(
                title: 'Eozinofili — tedavi protokolu',
                time: 'Dun',
              ),
              _ConvTile(
                title: 'Orbital selulit MR yorumu',
                time: '2g',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConvTile extends StatelessWidget {
  final String title;
  final String time;
  final bool isActive;

  const _ConvTile({
    required this.title,
    required this.time,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? KxColors.teal400.withOpacity(0.1) : Colors.transparent,
        borderRadius: KxSpacing.radiusMd,
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
          style: KxTypography.bodyMd.copyWith(
            color: isActive ? KxColors.teal400 : KxColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(time, style: KxTypography.caption),
        onTap: () {},
      ),
    );
  }
}

// ── Chat Paneli ─────────────────────────────────────────────────────

class _ChatPanel extends StatelessWidget {
  final TextEditingController inputCtrl;
  final ScrollController scrollCtrl;
  final List<PlatformFile> pendingFiles;
  final void Function(int) onRemovePendingFile;
  final void Function(List<PlatformFile>) onAddPendingFiles;
  final VoidCallback onSend;

  const _ChatPanel({
    required this.inputCtrl,
    required this.scrollCtrl,
    required this.pendingFiles,
    required this.onRemovePendingFile,
    required this.onAddPendingFiles,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Baslik
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: KxColors.bgBase,
            border: Border(bottom: BorderSide(color: KxColors.border)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Builder(
                builder: (context) {
                  final isOnline = GetIt.instance<ClaudeAIService>().isConfigured;
                  final statusColor = isOnline ? KxColors.jade300 : KxColors.amber500;
                  final statusText = isOnline ? 'Cevrimici' : 'Cevrimdisi — API anahtari gerekli';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KX Medikal Asistan', style: KxTypography.labelMd),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: KxTypography.caption.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded,
                    color: KxColors.textMuted),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Mesajlar
        Expanded(
          child: BlocBuilder<AIChatBloc, AIChatState>(
            builder: (context, state) {
              if (state.messages.isEmpty) {
                return _WelcomeView();
              }
              return ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                itemCount: state.messages.length +
                    (state.isTyping && !state.isStreaming ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == state.messages.length) {
                    return const _TypingIndicator();
                  }
                  final msg = state.messages[i];
                  final isStreaming = msg.id == state.streamingMessageId;
                  return _MessageBubble(
                    text: msg.text,
                    isUser: msg.isUser,
                    time: msg.timestamp,
                    isStreaming: isStreaming,
                    hasAttachments: msg.hasAttachments,
                    attachmentNames: msg.attachmentNames,
                  );
                },
              );
            },
          ),
        ),

        // Pending files preview + Input
        _ChatInputArea(
          controller: inputCtrl,
          pendingFiles: pendingFiles,
          onRemovePendingFile: onRemovePendingFile,
          onAttach: () => _showAttachOptions(context, onAddPendingFiles),
          onSend: onSend,
        ),
      ],
    );
  }
}

// ── Karsilama ekrani ────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  static const _examplePrompts = [
    'Gogus agrisi olan 55 yas erkek hasta icin ayirici tani listesi olustur',
    'STEMI tedavi protokolunu ozetle',
    'Tiroid fonksiyon testlerini yorumla: TSH 8.5, T4 0.6',
    'Pediatride ates yonetimi kilavuzu',
  ];

  static const _promptIcons = [
    Icons.monitor_heart_outlined,
    Icons.medication_outlined,
    Icons.science_outlined,
    Icons.child_care_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: KxSpacing.xl2,
        vertical: KxSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // ── Hero icon ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: KxColors.teal400.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // ── Title ──
              Text(
                'KONSENXIA AI',
                style: KxTypography.displaySm.copyWith(
                  color: KxColors.teal400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: KxSpacing.sm),

              // ── Subtitle ──
              Text(
                'Tibbi yapay zeka asistani',
                style: KxTypography.headingSm.copyWith(
                  color: KxColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: KxSpacing.lg),

              // ── Description ──
              Text(
                'Klinik sorularinizi sorun, diferansiyel tani destegi alin, tibbi literatur tarayin.',
                style: KxTypography.bodyLg.copyWith(
                  color: KxColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: KxSpacing.xl2),

              // ── Example prompts header ──
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ORNEK SORULAR',
                  style: KxTypography.overline.copyWith(
                    color: KxColors.teal300,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(height: KxSpacing.md),

              // ── Tappable prompt cards ──
              ...List.generate(_examplePrompts.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(bottom: KxSpacing.sm),
                  child: _PromptCard(
                    text: _examplePrompts[i],
                    icon: _promptIcons[i],
                    onTap: () {
                      context
                          .read<AIChatBloc>()
                          .add(SendMessageEvent(message: _examplePrompts[i]));
                    },
                  ),
                );
              }),

              SizedBox(height: KxSpacing.xl),

              // ── Disclaimer ──
              Container(
                padding: EdgeInsets.all(KxSpacing.lg),
                decoration: BoxDecoration(
                  color: KxColors.amber500.withOpacity(0.08),
                  borderRadius: KxSpacing.radiusLg,
                  border: Border.all(
                    color: KxColors.amber500.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: KxColors.amber500,
                    ),
                    SizedBox(width: KxSpacing.sm),
                    Expanded(
                      child: Text(
                        'AI onerileri klinik karar destegi amaclidir. Kesin tani ve tedavi kararlari icin klinik degerlendirme gereklidir.',
                        style: KxTypography.labelSm.copyWith(
                          color: KxColors.amber500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PromptCard({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: KxSpacing.radiusLg,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: KxSpacing.lg,
            vertical: KxSpacing.md,
          ),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius: KxSpacing.radiusLg,
            border: Border.all(
              color: KxColors.teal400.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: KxColors.teal400.withOpacity(0.1),
                  borderRadius: KxSpacing.radiusMd,
                ),
                child: Icon(icon, size: 18, color: KxColors.teal400),
              ),
              SizedBox(width: KxSpacing.md),
              Expanded(
                child: Text(
                  text,
                  style: KxTypography.bodyMd.copyWith(
                    color: KxColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: KxSpacing.sm),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: KxColors.teal400.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mesaj balonu ────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isStreaming;
  final bool hasAttachments;
  final List<String> attachmentNames;

  const _MessageBubble({
    required this.text,
    required this.isUser,
    required this.time,
    this.isStreaming = false,
    this.hasAttachments = false,
    this.attachmentNames = const [],
  });

  @override
  Widget build(BuildContext context) {
    final showDots = isStreaming && text.isEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Show attachment badges if present
            if (hasAttachments && attachmentNames.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: attachmentNames.map((name) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: KxColors.teal400.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getFileIcon(name),
                        size: 12,
                        color: KxColors.teal400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        name.length > 20 ? '${name.substring(0, 17)}...' : name,
                        style: KxTypography.caption.copyWith(
                          color: KxColors.teal400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 4),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? KxColors.teal400 : KxColors.bgCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: KxColors.border),
              ),
              child: showDots
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) => _Dot(delay: i * 200)),
                    )
                  : isStreaming
                      ? _StreamingText(text: text)
                      : Text(
                          text,
                          style: KxTypography.bodyMd.copyWith(
                            color: isUser
                                ? KxColors.bgVoid
                                : KxColors.textPrimary,
                          ),
                        ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: KxTypography.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      case 'dcm':
        return Icons.medical_information_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Streaming text with a blinking cursor at the end.
class _StreamingText extends StatefulWidget {
  final String text;
  const _StreamingText({required this.text});

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: widget.text,
            style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
          ),
          WidgetSpan(
            child: FadeTransition(
              opacity: _opacity,
              child: Container(
                width: 2,
                height: 14,
                margin: const EdgeInsets.only(left: 1),
                decoration: const BoxDecoration(
                  color: KxColors.teal400,
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Yaziyor gostergesi ──────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          children: List.generate(3, (i) => _Dot(delay: i * 200)),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: KxColors.teal400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Chat Input Area (with pending file chips) ───────────────────────

class _ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final List<PlatformFile> pendingFiles;
  final void Function(int) onRemovePendingFile;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const _ChatInputArea({
    required this.controller,
    required this.pendingFiles,
    required this.onRemovePendingFile,
    required this.onAttach,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KxColors.bgBase,
        border: Border(top: BorderSide(color: KxColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Pending files preview ──
          if (pendingFiles.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with count
                  Row(
                    children: [
                      Icon(Icons.attach_file_rounded, size: 14, color: KxColors.teal400),
                      const SizedBox(width: 4),
                      Text(
                        '${pendingFiles.length} dosya secildi',
                        style: KxTypography.caption.copyWith(color: KxColors.teal400),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // Remove all pending files
                          for (var i = pendingFiles.length - 1; i >= 0; i--) {
                            onRemovePendingFile(i);
                          }
                        },
                        child: Text(
                          'Tumunu kaldir',
                          style: KxTypography.caption.copyWith(
                            color: KxColors.crimson400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // File chips — horizontal scroll
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: pendingFiles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final file = pendingFiles[index];
                        return _PendingFileChip(
                          file: file,
                          onRemove: () => onRemovePendingFile(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

          // ── Text input + buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: KxColors.bgCard,
                      borderRadius: KxSpacing.radiusPill,
                      border: Border.all(color: KxColors.border),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: KxTypography.bodyMd
                                .copyWith(color: KxColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: pendingFiles.isNotEmpty
                                  ? 'Dosyalarla birlikte sorunuzu yazin...'
                                  : 'Sorunuzu yazin...',
                              hintStyle: KxTypography.bodyMd
                                  .copyWith(color: KxColors.textDisabled),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            maxLines: 3,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.attach_file_rounded,
                            size: 18,
                            color: pendingFiles.isNotEmpty
                                ? KxColors.teal400
                                : KxColors.textMuted,
                          ),
                          onPressed: onAttach,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pending File Chip ───────────────────────────────────────────────

class _PendingFileChip extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;

  const _PendingFileChip({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final ext = file.extension?.toLowerCase() ?? '';
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
    final isPdf = ext == 'pdf';

    final sizeStr = file.size < 1024
        ? '${file.size} B'
        : file.size < 1024 * 1024
            ? '${(file.size / 1024).toStringAsFixed(1)} KB'
            : '${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB';

    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KxColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon / thumbnail
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isImage
                  ? KxColors.teal400.withOpacity(0.1)
                  : isPdf
                      ? KxColors.crimson400.withOpacity(0.1)
                      : KxColors.amber300.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isImage && file.path != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(file.path!),
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_rounded,
                        size: 16,
                        color: KxColors.teal400,
                      ),
                    ),
                  )
                : Icon(
                    isPdf
                        ? Icons.picture_as_pdf_rounded
                        : Icons.insert_drive_file_rounded,
                    size: 16,
                    color: isPdf ? KxColors.crimson400 : KxColors.amber300,
                  ),
          ),
          const SizedBox(width: 8),
          // File name + size
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  file.name,
                  style: KxTypography.caption.copyWith(
                    color: KxColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sizeStr,
                  style: KxTypography.caption.copyWith(
                    color: KxColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: KxColors.crimson400.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 12,
                color: KxColors.crimson400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dosya Ekleme Secenk Karti ───────────────────────────────────────

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: KxTypography.labelSm.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
