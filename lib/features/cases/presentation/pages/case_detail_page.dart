import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/claude_ai_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../design_system/design_system.dart';
import '../bloc/case_detail_bloc.dart';
import '../../domain/entities/case_entity.dart';
import '../widgets/assign_case_dialog.dart';
import '../widgets/assigned_doctors_list.dart';
import '../widgets/case_ai_analysis_sheet.dart';
import 'package:get_it/get_it.dart';

/// KONSENXIA Vaka Detay Sayfası
///
/// Vaka açıklaması, vital bulgular, tartışma ve yorum akışı.
/// Geniş ekranda sol: vaka içeriği, sağ: yorumlar paneli.
class CaseDetailPage extends StatefulWidget {
  final String caseId;
  const CaseDetailPage({super.key, required this.caseId});

  @override
  State<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends State<CaseDetailPage> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CaseDetailBloc>().add(LoadCaseDetailEvent(widget.caseId));
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;
    final isMid  = MediaQuery.of(context).size.width >= 860;

    return BlocListener<CaseDetailBloc, CaseDetailState>(
      listenWhen: (prev, curr) =>
          curr is CaseDetailLoaded && curr.offlineCommentAdded,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Cevrimdisi — yorumunuz baglanti kuruldugunda gonderilecek',
            ),
            backgroundColor: KxColors.amber300,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: KxColors.bgBase,
        body: BlocBuilder<CaseDetailBloc, CaseDetailState>(
          builder: (context, state) => switch (state) {
            CaseDetailInitial() || CaseDetailLoading() => const _LoadingView(),
            CaseDetailLoaded s => isWide
                ? _buildWideLayout(s)
                : isMid
                    ? _buildMidLayout(s)
                    : _buildNarrowLayout(s),
            CaseDetailError s  => _ErrorView(message: s.message, caseId: widget.caseId),
            _ => const _LoadingView(),
          },
        ),
      ),
    );
  }

  // ── Geniş: sidebar + içerik + yorumlar ────────────────────────

  Widget _buildWideLayout(CaseDetailLoaded state) {
    return Row(
      children: [
        // Vaka içeriği (geniş)
        Expanded(
          flex: 6,
          child: _CaseContent(
            state: state,
            commentCtrl: _commentCtrl,
            scrollCtrl: _scrollCtrl,
            showCommentsBeside: true,
          ),
        ),
        // Sağ panel: yorumlar
        SizedBox(
          width: 380,
          child: _CommentsPanel(state: state, commentCtrl: _commentCtrl),
        ),
      ],
    );
  }

  // ── Orta: sidebar + içerik (yorumlar aşağıda) ─────────────────

  Widget _buildMidLayout(CaseDetailLoaded state) {
    return _CaseContent(
      state: state,
      commentCtrl: _commentCtrl,
      scrollCtrl: _scrollCtrl,
      showCommentsBeside: false,
    );
  }

  // ── Dar: sadece içerik ──────────────────────────────────────────

  Widget _buildNarrowLayout(CaseDetailLoaded state) {
    return _CaseContent(
      state: state,
      commentCtrl: _commentCtrl,
      scrollCtrl: _scrollCtrl,
      showCommentsBeside: false,
    );
  }

}

// ── Vaka İçeriği ───────────────────────────────────────────────────

class _CaseContent extends StatelessWidget {
  final CaseDetailLoaded state;
  final TextEditingController commentCtrl;
  final ScrollController scrollCtrl;
  final bool showCommentsBeside;

  const _CaseContent({
    required this.state,
    required this.commentCtrl,
    required this.scrollCtrl,
    required this.showCommentsBeside,
  });

  @override
  Widget build(BuildContext context) {
    final kase = state.kase;

    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        // ── App Bar ──────────────────────────────────────────
        SliverAppBar(
          backgroundColor: KxColors.bgBase,
          floating: true,
          snap: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: KxColors.textSecondary, size: 18),
            onPressed: () => context.go('/cases'),
          ),
          actions: [
            // Bookmark
            BlocBuilder<CaseDetailBloc, CaseDetailState>(
              builder: (context, s) {
                if (s is! CaseDetailLoaded) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(
                    s.kase.isBookmarkedByCurrentUser
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: s.kase.isBookmarkedByCurrentUser
                        ? KxColors.amber300 : KxColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => context
                      .read<CaseDetailBloc>()
                      .add(const BookmarkCaseEvent()),
                );
              },
            ),
            // Share
            BlocBuilder<CaseDetailBloc, CaseDetailState>(
              builder: (context, s) {
                return IconButton(
                  icon: const Icon(Icons.share_outlined,
                      color: KxColors.textSecondary, size: 20),
                  onPressed: s is CaseDetailLoaded
                      ? () {
                          final text = '${s.kase.title} — Konsenxia\n'
                              'https://konsenxia.app/cases/${s.kase.id}';
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Link kopyalandı'),
                              backgroundColor: KxColors.bgElevated,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                );
              },
            ),
            // AI Analiz
            BlocBuilder<CaseDetailBloc, CaseDetailState>(
              builder: (context, s) {
                if (s is! CaseDetailLoaded) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: KxButton.secondary(
                    label: '✦ AI',
                    onPressed: () => showCaseAiAnalysisSheet(
                      context: context,
                      caseId: s.kase.id,
                      caseTitle: s.kase.title,
                      caseDescription: s.kase.description,
                    ),
                  ),
                );
              },
            ),
            // Vakayi Al (specialist/resident)
            _TakeCaseButton(caseId: state.kase.id, caseTitle: state.kase.title),
            // Vaka Ata (sadece specialist/professor)
            _AssignButton(caseId: state.kase.id),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Başlık bölgesi ─────────────────────────────
              _CaseHeader(kase: kase)
                  .animate().fadeIn(delay: 50.ms).slideY(begin: 0.05),

              const SizedBox(height: 20),

              // ── Yazar kartı ────────────────────────────────
              _AuthorCard(kase: kase)
                  .animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              // ── Vital bulgular ─────────────────────────────
              if (kase.vitals.isNotEmpty) ...[
                _SectionTitle('Vital Bulgular'),
                const SizedBox(height: 10),
                _VitalsRow(vitals: kase.vitals)
                    .animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 20),
              ],

              // ── Vaka açıklaması ────────────────────────────
              _SectionTitle('Klinik Tablo ve Öykü'),
              const SizedBox(height: 10),
              _CaseDescription(text: kase.description)
                  .animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 20),

              // ── Etiketler / Uzmanlıklar ────────────────────
              if (kase.tags.isNotEmpty || kase.specialties.isNotEmpty) ...[
                _SectionTitle('Etiketler'),
                const SizedBox(height: 10),
                KxTagRow(
                  tags: [...kase.specialties, ...kase.tags],
                ).animate().fadeIn(delay: 230.ms),
                const SizedBox(height: 20),
              ],

              // ── Çözüm (varsa) ──────────────────────────────
              if (kase.isSolved && kase.diagnosisTitle != null) ...[
                _DiagnosisCard(kase: kase)
                    .animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 20),
              ],

              // ── Atanan Doktorlar ──────────────────────────────
              _AssignedDoctorsSection(caseId: kase.id)
                  .animate().fadeIn(delay: 255.ms),

              const SizedBox(height: 20),

              // ── XP ödülü ───────────────────────────────────
              if (kase.xpReward != null) ...[
                _XpRewardCard(reward: kase.xpReward!)
                    .animate().fadeIn(delay: 260.ms),
                const SizedBox(height: 20),
              ],

              // ── Tıbbi Dosyalar butonu ───────────────────────
              KxPressable(
                onTap: () => context.go('/medical-files', extra: {'caseId': kase.id}),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: KxColors.bgCard,
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(color: KxColors.teal400.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: KxColors.teal400.withOpacity(0.1),
                          borderRadius: KxSpacing.radiusSm,
                        ),
                        child: const Icon(Icons.perm_media_rounded,
                            size: 18, color: KxColors.teal400),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tibbi Dosyalar',
                                style: KxTypography.labelMd),
                            Text('Rontgen, BT, MR, kan tahlili...',
                                style: KxTypography.caption
                                    .copyWith(color: KxColors.textMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: KxColors.textMuted, size: 20),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 270.ms),
              const SizedBox(height: 20),

              // ── Yorumlar (geniş değilse burada) ───────────
              if (!showCommentsBeside) ...[
                _SectionTitle('Tartışma (${kase.comments.length})'),
                const SizedBox(height: 12),
                ...kase.comments.asMap().entries.map((e) =>
                  _CommentCard(comment: e.value, index: e.key)
                    .animate().fadeIn(delay: Duration(milliseconds: 280 + e.key * 60))),
                const SizedBox(height: 20),
                _CommentInput(
                  controller: commentCtrl,
                  isSubmitting: state.isSubmittingComment,
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Vaka Başlık Bölgesi ────────────────────────────────────────────

class _CaseHeader extends StatelessWidget {
  final CaseEntity kase;
  const _CaseHeader({required this.kase});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(kase.id, style: KxTypography.caseId),
            const SizedBox(width: 10),
            _urgencyBadge(kase.urgency),
            const SizedBox(width: 6),
            _statusBadge(kase.status),
            const Spacer(),
            _StatChip(icon: Icons.remove_red_eye_outlined, value: '${kase.viewCount}'),
          ],
        ),
        const SizedBox(height: 10),
        Text(kase.title, style: KxTypography.headingMd),
        const SizedBox(height: 6),
        Text(
          kase.patientSummary,
          style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
        ),
        const SizedBox(height: 14),
        // Like / bookmark / comment stats
        BlocBuilder<CaseDetailBloc, CaseDetailState>(
          builder: (ctx, s) {
            final loaded = s as CaseDetailLoaded;
            return Row(
              children: [
                _ActionButton(
                  icon: loaded.kase.isLikedByCurrentUser
                      ? Icons.favorite : Icons.favorite_outline,
                  color: loaded.kase.isLikedByCurrentUser
                      ? KxColors.crimson400 : KxColors.textMuted,
                  label: '${loaded.kase.likeCount}',
                  onTap: () => ctx.read<CaseDetailBloc>()
                      .add(const LikeCaseEvent()),
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: KxColors.textMuted,
                  label: '${loaded.kase.comments.length}',
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.bookmark_outline_rounded,
                  color: KxColors.textMuted,
                  label: '${loaded.kase.bookmarkCount}',
                  onTap: () => ctx.read<CaseDetailBloc>()
                      .add(const BookmarkCaseEvent()),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _urgencyBadge(CaseUrgency u) => switch (u) {
    CaseUrgency.routine   => KxBadge.teal(u.label),
    CaseUrgency.urgent    => KxBadge.amber(u.label),
    CaseUrgency.critical  => KxBadge.crimson(u.label),
    CaseUrgency.emergency => KxBadge.crimson(u.label),
  };

  Widget _statusBadge(CaseStatus s) => switch (s) {
    CaseStatus.open         => KxBadge.blue('Açık'),
    CaseStatus.inDiscussion => KxBadge.teal('Tartışmada', hasDot: true),
    CaseStatus.solved       => KxBadge.jade('Çözüldü'),
    CaseStatus.archived     => KxBadge.neutral('Arşiv'),
  };
}

// ── Yazar Kartı ────────────────────────────────────────────────────

class _AuthorCard extends StatelessWidget {
  final CaseEntity kase;
  const _AuthorCard({required this.kase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Row(
        children: [
          KxAvatar(
            name: kase.authorName,
            imageUrl: kase.authorImageUrl,
            size: KxAvatarSize.md,
            level: kase.authorLevel,
            showLevelRing: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(kase.authorName, style: KxTypography.labelMd),
                    const SizedBox(width: 6),
                    KxBadge.amber('Lvl ${kase.authorLevel}'),
                  ],
                ),
                Text(
                  kase.authorCountry != null
                      ? '${kase.authorSpecialty} · ${kase.authorCountry}'
                      : kase.authorSpecialty,
                  style: KxTypography.caption.copyWith(color: KxColors.teal400),
                ),
              ],
            ),
          ),
          Text(
            _timeAgo(kase.createdAt),
            style: KxTypography.caption,
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24) return '${diff.inHours}sa önce';
    return '${diff.inDays}g önce';
  }
}

// ── Vital Bulgular ─────────────────────────────────────────────────

class _VitalsRow extends StatelessWidget {
  final List<VitalSign> vitals;
  const _VitalsRow({required this.vitals});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: vitals.map((v) => KxVitalChip(
        label: v.label,
        value: v.value,
        unit: v.unit,
        status: switch (v.range) {
          VitalRange.normal   => KxVitalStatus.normal,
          VitalRange.warning  => KxVitalStatus.warning,
          VitalRange.critical => KxVitalStatus.critical,
        },
      )).toList(),
    );
  }
}

// ── Vaka Açıklaması ────────────────────────────────────────────────

class _CaseDescription extends StatefulWidget {
  final String text;
  const _CaseDescription({required this.text});
  @override State<_CaseDescription> createState() => _CaseDescriptionState();
}

class _CaseDescriptionState extends State<_CaseDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Markdown-style bold/italic renderi için basit split
          Text(
            widget.text,
            style: KxTypography.bodyMd.copyWith(
              color: KxColors.textPrimary,
              height: 1.7,
            ),
            maxLines: _expanded ? null : 8,
            overflow: _expanded ? null : TextOverflow.fade,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Daha az göster ↑' : 'Tamamını göster ↓',
              style: KxTypography.labelSm.copyWith(color: KxColors.teal400),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tanı Kartı (çözüldüyse) ────────────────────────────────────────

class _DiagnosisCard extends StatelessWidget {
  final CaseEntity kase;
  const _DiagnosisCard({required this.kase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KxColors.jade500.withOpacity(0.08),
            KxColors.teal400.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.jade500.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: KxColors.jade300, size: 18),
              const SizedBox(width: 8),
              Text('Tanı Konuldu', style: KxTypography.labelMd
                  .copyWith(color: KxColors.jade300)),
            ],
          ),
          const SizedBox(height: 8),
          Text(kase.diagnosisTitle!,
              style: KxTypography.headingSm.copyWith(color: KxColors.textPrimary)),
          if (kase.diagnosisDetails != null) ...[
            const SizedBox(height: 6),
            Text(kase.diagnosisDetails!,
                style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// ── XP Ödülü Kartı ─────────────────────────────────────────────────

class _XpRewardCard extends StatelessWidget {
  final CaseXpReward reward;
  const _XpRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: KxColors.amber300.withOpacity(0.06),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.amber300.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: KxColors.amber300, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('XP Kazanma Fırsatı',
                    style: KxTypography.labelSm.copyWith(color: KxColors.amber300)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  children: [
                    _XpItem('Yorum: +${reward.xpForComment}'),
                    _XpItem('Kabul edilen cevap: +${reward.xpForAcceptedAnswer}'),
                    _XpItem('Vaka oluşturan: +${reward.xpForAuthor}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _XpItem extends StatelessWidget {
  final String text;
  const _XpItem(this.text);
  @override Widget build(BuildContext context) =>
      Text(text, style: KxTypography.caption.copyWith(color: KxColors.textSecondary));
}

// ── Yorumlar Sağ Paneli (geniş ekran) ─────────────────────────────

class _CommentsPanel extends StatelessWidget {
  final CaseDetailLoaded state;
  final TextEditingController commentCtrl;

  const _CommentsPanel({required this.state, required this.commentCtrl});

  @override
  Widget build(BuildContext context) {
    final kase = state.kase;
    return Container(
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(left: BorderSide(color: KxColors.border)),
      ),
      child: Column(
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: KxColors.border)),
            ),
            child: Row(
              children: [
                Text(
                  'Tartışma',
                  style: KxTypography.headingSm,
                ),
                const SizedBox(width: 8),
                KxBadge.teal('${kase.comments.length}'),
                const Spacer(),
                // Sıralama
                Text('En yeni ↓', style: KxTypography.caption
                    .copyWith(color: KxColors.teal400)),
              ],
            ),
          ),

          // Yorum listesi
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: kase.comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _CommentCard(
                comment: kase.comments[i],
                index: i,
              ).animate().fadeIn(
                delay: Duration(milliseconds: 100 + i * 80),
              ),
            ),
          ),

          // Yorum input
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: KxColors.border)),
            ),
            child: _CommentInput(
              controller: commentCtrl,
              isSubmitting: state.isSubmittingComment,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Yorum Kartı ────────────────────────────────────────────────────

class _CommentCard extends StatelessWidget {
  final CaseComment comment;
  final int index;
  const _CommentCard({required this.comment, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: comment.isExpertOpinion
            ? KxColors.teal400.withOpacity(0.05)
            : comment.isAcceptedAnswer
                ? KxColors.jade500.withOpacity(0.06)
                : KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(
          color: comment.isExpertOpinion
              ? KxColors.teal400.withOpacity(0.2)
              : comment.isAcceptedAnswer
                  ? KxColors.jade500.withOpacity(0.3)
                  : KxColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yazar + rozetler
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KxAvatar(
                name: comment.authorName,
                imageUrl: comment.authorImageUrl,
                size: KxAvatarSize.xs,
                level: comment.authorLevel,
                showLevelRing: comment.authorLevel >= 7,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(comment.authorName,
                              style: KxTypography.labelSm,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (comment.isOffline) ...[
                          const SizedBox(width: 4),
                          KxBadge.amber('Cevrimdisi'),
                        ],
                        if (comment.isExpertOpinion) ...[
                          const SizedBox(width: 4),
                          KxBadge.teal('Uzman'),
                        ],
                        if (comment.isAcceptedAnswer) ...[
                          const SizedBox(width: 4),
                          KxBadge.jade('Kabul'),
                        ],
                      ],
                    ),
                    Text(
                      comment.authorSpecialty,
                      style: KxTypography.caption.copyWith(
                        color: KxColors.teal400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _timeAgo(comment.createdAt),
                style: KxTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // İçerik
          Text(
            comment.content,
            style: KxTypography.bodyMd.copyWith(
              color: KxColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),

          // Alt satır: like + yanıtla
          Row(
            children: [
              GestureDetector(
                onTap: () => context.read<CaseDetailBloc>()
                    .add(LikeCommentEvent(comment.id)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      comment.isLikedByCurrentUser
                          ? Icons.favorite : Icons.favorite_outline,
                      size: 14,
                      color: comment.isLikedByCurrentUser
                          ? KxColors.crimson400 : KxColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text('${comment.likeCount}', style: KxTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {},
                child: Text('Yanıtla',
                    style: KxTypography.caption
                        .copyWith(color: KxColors.teal400)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk';
    return '${diff.inHours}sa';
  }
}

// ── Yorum Input ────────────────────────────────────────────────────

class _CommentInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isSubmitting;

  const _CommentInput({
    required this.controller,
    required this.isSubmitting,
  });

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  bool _aiLoading = false;

  bool _aiAvailable = false;

  Future<void> _requestAiSuggestion() async {
    if (!_aiAvailable) return;

    final bloc = context.read<CaseDetailBloc>();
    final s = bloc.state;
    if (s is! CaseDetailLoaded) return;

    setState(() => _aiLoading = true);
    try {
      final claudeAI = GetIt.instance<ClaudeAIService>();
      final response = await claudeAI.suggestComment(
        caseTitle: s.kase.title,
        caseDescription: s.kase.description,
        existingComments: s.kase.comments.map((c) =>
            '${c.authorName} (${c.authorSpecialty}): ${c.content}').toList(),
      ).timeout(const Duration(seconds: 5));
      widget.controller.text = response.text;
    } catch (_) {
      // Offline fallback
      widget.controller.text =
          'Bu vakanin klinik tablosu dikkatli degerlendirme gerektiriyor. '
          'Diferansiyel tanida ek tetkikler ve multidisipliner yaklasim oneriyorum.';
    }
    if (mounted) setState(() => _aiLoading = false);
  }

  @override
  void initState() {
    super.initState();
    // AI servisinin hazir olup olmadigini kontrol et
    try {
      GetIt.instance<ClaudeAIService>();
      _aiAvailable = true;
    } catch (_) {
      _aiAvailable = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI oneri butonu
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: (_aiLoading || !_aiAvailable) ? null : _requestAiSuggestion,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _aiAvailable
                      ? KxColors.teal400.withOpacity(0.08)
                      : KxColors.bgCard,
                  borderRadius: KxSpacing.radiusSm,
                  border: Border.all(
                    color: _aiAvailable
                        ? KxColors.teal400.withOpacity(0.2)
                        : KxColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _aiLoading
                        ? const SizedBox(
                            width: 12, height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: KxColors.teal400),
                          )
                        : Icon(Icons.auto_awesome_rounded,
                            size: 13,
                            color: _aiAvailable
                                ? KxColors.teal400
                                : KxColors.textDisabled),
                    const SizedBox(width: 5),
                    Text(
                      _aiLoading
                          ? 'AI dusunuyor...'
                          : _aiAvailable
                              ? 'AI Yorum Onerisi'
                              : 'AI baglantisi kuruldugunda aktif olacak',
                      style: KxTypography.caption.copyWith(
                        color: _aiAvailable
                            ? KxColors.teal400
                            : KxColors.textDisabled,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: KxColors.bgCard,
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(color: KxColors.border),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    style: KxTypography.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Görüşünüzü paylaşın...',
                      hintStyle: KxTypography.bodyMd
                          .copyWith(color: KxColors.textDisabled),
                      contentPadding: const EdgeInsets.all(12),
                      border: InputBorder.none,
                    ),
                    maxLines: 5,
                    minLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.isSubmitting ? null : () {
                  final text = widget.controller.text.trim();
                  if (text.isEmpty) return;
                  context.read<CaseDetailBloc>()
                      .add(SubmitCommentEvent(text));
                  widget.controller.clear();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: widget.isSubmitting
                        ? null
                        : const LinearGradient(
                            colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                          ),
                    color: widget.isSubmitting ? KxColors.bgCard : null,
                    borderRadius: KxSpacing.radiusMd,
                  ),
                  child: widget.isSubmitting
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: KxColors.teal400,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Yardımcı widgetlar ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: KxColors.teal400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: KxTypography.headingSm),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: KxColors.textDisabled),
      const SizedBox(width: 3),
      Text(value, style: KxTypography.caption),
    ],
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 5),
        Text(label, style: KxTypography.bodyMd.copyWith(color: color)),
      ],
    ),
  );
}

// ── Loading / Error ────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(KxColors.teal400),
      strokeWidth: 2,
    ),
  );
}

// ── Vakayi Al Butonu (specialist/resident) ──────────────────────────

class _TakeCaseButton extends StatelessWidget {
  final String caseId;
  final String caseTitle;
  const _TakeCaseButton({required this.caseId, required this.caseTitle});

  bool get _canTake {
    try {
      final localStorage = GetIt.instance<LocalStorage>();
      final role = localStorage.userRole ?? '';
      return role == 'SPECIALIST' || role == 'RESIDENT';
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canTake) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: KxButton.secondary(
        label: 'Vakayi Al',
        onPressed: () => _showTakeCaseDialog(context),
      ),
    );
  }

  void _showTakeCaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: KxColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: KxColors.teal400.withOpacity(0.1),
                        borderRadius: KxSpacing.radiusMd,
                      ),
                      child: const Icon(Icons.assignment_turned_in_rounded,
                          size: 20, color: KxColors.teal400),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Vakayi Al',
                          style: KxTypography.headingSm),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: KxColors.textMuted, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KxColors.bgBase,
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(color: KxColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open_rounded,
                          size: 16, color: KxColors.teal400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          caseTitle,
                          style: KxTypography.labelSm,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bu vakayi alarak uzerinize atanmasini onayliyor musunuz? '
                  'Vaka durumu "atandi" olarak guncellenecektir.',
                  style: KxTypography.bodyMd
                      .copyWith(color: KxColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: KxColors.bgBase,
                            borderRadius: KxSpacing.radiusMd,
                            border: Border.all(color: KxColors.border),
                          ),
                          child: Center(
                            child: Text('Vazgec',
                                style: KxTypography.labelMd
                                    .copyWith(color: KxColors.textSecondary)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _takeCaseInFirestore(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                            ),
                            borderRadius: KxSpacing.radiusMd,
                          ),
                          child: Center(
                            child: Text('Vakayi Al',
                                style: KxTypography.labelMd
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Write case assignment to Firestore, update case document, and create notification
  Future<void> _takeCaseInFirestore(BuildContext context) async {
    try {
      final localStorage = GetIt.instance<LocalStorage>();
      final userId = localStorage.getUserId() ?? '';
      if (userId.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: KxColors.crimson400,
            content: Text('Kullanici bilgisi bulunamadi. Lutfen tekrar giris yapin.',
                style: KxTypography.bodyMd.copyWith(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
          ),
        );
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final userName = localStorage.getUserName() ?? 'Doktor';

      // Look up the case author (to notify them) and get assigner info
      String? caseAuthorId;
      String assignerTitle = 'Dr.';
      try {
        final caseDoc = await firestore.collection('cases').doc(caseId).get();
        if (caseDoc.exists) {
          caseAuthorId = caseDoc.data()?['authorId'] as String?;
        }
        final userDoc = await firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final role = userDoc.data()?['role'] as String? ?? '';
          assignerTitle = switch (role) {
            'PROFESSOR'  => 'Prof. Dr.',
            'SPECIALIST' => 'Uzm. Dr.',
            'RESIDENT'   => 'Ast. Dr.',
            _            => 'Dr.',
          };
        }
      } catch (_) {}

      final batch = firestore.batch();

      // 1. Write to case_assignments/{caseId}_{userId}
      final assignmentRef = firestore
          .collection('case_assignments')
          .doc('${caseId}_$userId');
      batch.set(assignmentRef, {
        'caseId': caseId,
        'caseTitle': caseTitle,
        'userId': userId,
        'userName': userName,
        'assignedTo': userId,
        'assignedToName': userName,
        'assignedBy': userId,
        'assignedByName': userName,
        'assignedByTitle': assignerTitle,
        'status': 'in_progress',
        'assignedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Add userId to the case document's assignedDoctors array
      final caseRef = firestore.collection('cases').doc(caseId);
      batch.update(caseRef, {
        'assignedDoctors': FieldValue.arrayUnion([userId]),
      });

      // 3. Create notification for the assigned doctor (self-assignment)
      final selfNotifRef = firestore
          .collection('notifications')
          .doc(userId)
          .collection('items')
          .doc();
      batch.set(selfNotifRef, {
        'id': selfNotifRef.id,
        'type': 'case_assigned',
        'title': 'Yeni Vaka Atandi',
        'body': '"$caseTitle" vakasini ustunuze aldiniz.',
        'data': {'caseId': caseId},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'actionRoute': '/cases/$caseId',
      });

      // 4. Notify the case author that someone took the case
      if (caseAuthorId != null && caseAuthorId != userId) {
        final authorNotifRef = firestore
            .collection('notifications')
            .doc(caseAuthorId)
            .collection('items')
            .doc();
        batch.set(authorNotifRef, {
          'id': authorNotifRef.id,
          'type': 'case_assigned',
          'title': 'Vakaniz Alindi',
          'body': '$assignerTitle $userName "$caseTitle" vakasini aldi.',
          'data': {'caseId': caseId},
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'actionRoute': '/cases/$caseId',
        });
      }

      await batch.commit();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: KxColors.bgElevated,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: KxColors.jade300, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vaka basariyla alindi! Durum: Atandi.',
                  style: KxTypography.bodyMd.copyWith(
                      color: KxColors.textPrimary),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: KxSpacing.radiusMd),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: KxColors.crimson400,
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vaka alinamadi: $e',
                  style: KxTypography.bodyMd.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
        ),
      );
    }
  }
}

// ── Vaka Ata Butonu (sadece specialist/professor) ──────────────────

class _AssignButton extends StatelessWidget {
  final String caseId;
  const _AssignButton({required this.caseId});

  bool get _canAssign {
    try {
      final localStorage = GetIt.instance<LocalStorage>();
      final role = localStorage.userRole ?? '';
      return role == 'SPECIALIST' || role == 'PROFESSOR';
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canAssign) return const SizedBox.shrink();

    return BlocBuilder<CaseDetailBloc, CaseDetailState>(
      builder: (context, s) {
        if (s is! CaseDetailLoaded) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: KxButton.primary(
            label: 'Ata',
            onPressed: () => showAssignCaseDialog(
              context: context,
              caseId: s.kase.id,
              caseTitle: s.kase.title,
              caseSpecialty: s.kase.authorSpecialty,
            ),
          ),
        );
      },
    );
  }
}

// ── Atanan Doktorlar Bölümü ────────────────────────────────────────

class _AssignedDoctorsSection extends StatelessWidget {
  final String caseId;
  const _AssignedDoctorsSection({required this.caseId});

  bool get _canView {
    try {
      final localStorage = GetIt.instance<LocalStorage>();
      final role = localStorage.userRole ?? '';
      return role == 'SPECIALIST' || role == 'PROFESSOR';
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canView) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3, height: 16,
              decoration: BoxDecoration(
                color: KxColors.amber300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('Atanan Doktorlar', style: KxTypography.headingSm),
          ],
        ),
        const SizedBox(height: 10),
        AssignedDoctorsList(caseId: caseId),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final String caseId;
  const _ErrorView({required this.message, required this.caseId});

  String get _friendlyMessage {
    final lower = message.toLowerCase();
    if (lower.contains('unavailable') || lower.contains('timeout') ||
        lower.contains('unreachable') || lower.contains('network')) {
      return 'Sunucuya ulaşılamıyor.\nBağlantınızı kontrol edip tekrar deneyin.';
    }
    if (lower.contains('not found') || lower.contains('bulunamadı')) {
      return 'Bu vaka bulunamadı.\nSilinmiş veya taşınmış olabilir.';
    }
    if (lower.contains('permission') || lower.contains('yetki')) {
      return 'Bu vakayı görüntüleme yetkiniz yok.';
    }
    return 'Vaka yüklenirken bir hata oluştu.\nLütfen tekrar deneyin.';
  }

  @override Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: KxColors.crimson400.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.cloud_off_rounded,
                size: 28, color: KxColors.crimson400),
          ),
          const SizedBox(height: 16),
          Text(
            'Bağlantı Hatası',
            style: KxTypography.headingSm,
          ),
          const SizedBox(height: 8),
          Text(
            _friendlyMessage,
            style: KxTypography.bodyMd
                .copyWith(color: KxColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          KxButton.primary(
            label: 'Tekrar Dene',
            onPressed: () => context.read<CaseDetailBloc>()
                .add(LoadCaseDetailEvent(caseId)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.go('/cases'),
            child: Text(
              'Vakalara dön',
              style: KxTypography.labelSm
                  .copyWith(color: KxColors.teal400),
            ),
          ),
        ],
      ),
    ),
  );
}
