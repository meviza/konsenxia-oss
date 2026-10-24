import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Asistanlarim (My Assistants) Page
///
/// Professor/Specialist'lerin asistanlarini yonettigi sayfa.
/// Genis ekranda sidebar + icerik.
class AssistantsPage extends StatefulWidget {
  const AssistantsPage({super.key});

  @override
  State<AssistantsPage> createState() => _AssistantsPageState();
}

class _AssistantsPageState extends State<AssistantsPage> {
  final KxNavItem _activeNav = KxNavItem.leaderboard;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Mock Asistan Verileri ─────────────────────────────────────

  static final List<_MockAssistant> _allAssistants = [
    _MockAssistant(
      id: 'ast_001',
      name: 'Dr. Elif Yilmaz',
      specialty: 'Dahiliye',
      level: 4,
      xpCurrent: 1800,
      xpTotal: 3000,
      casesCompleted: 12,
      casesAssigned: 3,
      isOnline: true,
      role: 'RESIDENT',
    ),
    _MockAssistant(
      id: 'ast_002',
      name: 'Dr. Burak Ozdemir',
      specialty: 'Kardiyoloji',
      level: 3,
      xpCurrent: 1200,
      xpTotal: 3000,
      casesCompleted: 8,
      casesAssigned: 2,
      isOnline: true,
      role: 'RESIDENT',
    ),
    _MockAssistant(
      id: 'ast_003',
      name: 'Dr. Zeynep Kara',
      specialty: 'Noroloji',
      level: 5,
      xpCurrent: 2400,
      xpTotal: 3000,
      casesCompleted: 18,
      casesAssigned: 1,
      isOnline: false,
      role: 'RESIDENT',
    ),
    _MockAssistant(
      id: 'ast_004',
      name: 'Selin Aksoy',
      specialty: 'Genel Cerrahi',
      level: 2,
      xpCurrent: 650,
      xpTotal: 1500,
      casesCompleted: 4,
      casesAssigned: 2,
      isOnline: true,
      role: 'INTERN',
    ),
    _MockAssistant(
      id: 'ast_005',
      name: 'Mert Celik',
      specialty: 'Gogus Hastaliklari',
      level: 1,
      xpCurrent: 320,
      xpTotal: 1500,
      casesCompleted: 2,
      casesAssigned: 1,
      isOnline: false,
      role: 'INTERN',
    ),
    _MockAssistant(
      id: 'ast_006',
      name: 'Dr. Ayse Demir',
      specialty: 'Endokrinoloji',
      level: 6,
      xpCurrent: 2800,
      xpTotal: 3000,
      casesCompleted: 22,
      casesAssigned: 0,
      isOnline: true,
      role: 'RESIDENT',
    ),
  ];

  List<_MockAssistant> get _filteredAssistants {
    if (_searchQuery.isEmpty) return _allAssistants;
    final q = _searchQuery.toLowerCase();
    return _allAssistants.where((a) =>
        a.name.toLowerCase().contains(q) ||
        a.specialty.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAssistantDialog(context),
        backgroundColor: KxColors.teal400,
        foregroundColor: KxColors.bgVoid,
        icon: const Icon(Icons.person_add_rounded),
        label: Text('Asistan Ekle', style: KxTypography.labelMd),
      ),
      body: isWide ? _buildWide() : _buildNarrow(),
    );
  }

  Widget _buildWide() {
    return Row(
      children: [
        KxSidebar(
          activeItem: _activeNav,
          onItemSelected: _onNavChanged,
          userName: 'Prof. Dr. Kerem',
          userSpecialty: 'Dahiliye',
          userLevel: 12,
          userLevelTitle: 'Akademisyen',
          xpCurrent: 15000,
          xpTotal: 20000,
          isOnline: true,
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildNarrow() => _buildContent();

  Widget _buildContent() {
    final assistants = _filteredAssistants;

    return CustomScrollView(
      slivers: [
        // ── App Bar ────────────────────────────────────────
        SliverAppBar(
          backgroundColor: KxColors.bgBase,
          floating: true,
          snap: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: KxColors.textSecondary, size: 18),
            onPressed: () => context.go('/dashboard'),
          ),
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Asistanlarim', style: KxTypography.headingMd),
                  Text(
                    '${_allAssistants.length} asistan',
                    style: KxTypography.caption.copyWith(color: KxColors.teal400),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              KxBadge.teal('${_allAssistants.length}'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sort_rounded,
                  color: KxColors.textSecondary),
              onPressed: () {},
            ),
          ],
        ),

        // ── Arama ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: KxColors.bgCard,
                borderRadius: KxSpacing.radiusMd,
                border: Border.all(color: KxColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: KxTypography.bodyMd,
                decoration: InputDecoration(
                  hintText: 'Asistan ara (isim, uzmanlik)...',
                  hintStyle: KxTypography.bodyMd
                      .copyWith(color: KxColors.textDisabled),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: KxColors.textMuted, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: KxColors.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),

        // ── Ozet istatistikler ─────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.people_alt_rounded,
                    label: 'Toplam',
                    value: '${_allAssistants.length}',
                    color: KxColors.teal400,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.circle,
                    label: 'Cevrimici',
                    value:
                        '${_allAssistants.where((a) => a.isOnline).length}',
                    color: KxColors.jade300,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.assignment_turned_in_rounded,
                    label: 'Tamamlanan',
                    value:
                        '${_allAssistants.fold<int>(0, (s, a) => s + a.casesCompleted)}',
                    color: KxColors.amber300,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Asistan listesi veya bos durum ───────────────
        if (assistants.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(hasSearch: _searchQuery.isNotEmpty),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final assistant = assistants[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AssistantCard(
                      assistant: assistant,
                      onAssignCase: () =>
                          _showAssignCaseSnackbar(context, assistant),
                      onSendMessage: () =>
                          _showSendMessageSnackbar(context, assistant),
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: 50 + index * 60),
                        ),
                  );
                },
                childCount: assistants.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  void _onNavChanged(KxNavItem item) {
    switch (item) {
      case KxNavItem.dashboard:
        context.go('/dashboard');
      case KxNavItem.cases:
        context.go('/cases');
      case KxNavItem.aiChat:
        context.go('/ai-chat');
      case KxNavItem.messages:
        context.go('/messages');
      case KxNavItem.leaderboard:
        context.go('/leaderboard');
      case KxNavItem.analytics:
        context.go('/analytics');
      case KxNavItem.profile:
        context.go('/profile');
    }
  }

  void _showAssignCaseSnackbar(BuildContext context, _MockAssistant assistant) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: KxColors.bgElevated,
        content: Text(
          '${assistant.name} icin vaka atama sayfasina yonlendiriliyorsunuz...',
          style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
        ),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: KxColors.teal400,
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
      ),
    );
  }

  void _showSendMessageSnackbar(
      BuildContext context, _MockAssistant assistant) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: KxColors.bgElevated,
        content: Text(
          '${assistant.name} ile mesajlasma baslatiliyor...',
          style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
        ),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: KxColors.teal400,
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
      ),
    );
  }

  void _showAddAssistantDialog(BuildContext context) {
    final searchCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: KxColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_add_rounded,
                        color: KxColors.teal400, size: 22),
                    const SizedBox(width: 10),
                    Text('Asistan Ekle', style: KxTypography.headingSm),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: KxColors.textMuted, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: KxColors.bgBase,
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(color: KxColors.border),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    style: KxTypography.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Doktor adi ile arayiniz...',
                      hintStyle: KxTypography.bodyMd
                          .copyWith(color: KxColors.textDisabled),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: KxColors.textMuted, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Onerilen Doktorlar',
                  style: KxTypography.labelSm
                      .copyWith(color: KxColors.textSecondary),
                ),
                const SizedBox(height: 10),
                // Mock oneriler
                _SuggestedDoctorRow(
                  name: 'Dr. Can Yildiz',
                  specialty: 'Ortopedi',
                  role: 'RESIDENT',
                  onAdd: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: KxColors.bgElevated,
                        content: Text(
                          'Dr. Can Yildiz asistan listenize eklendi.',
                          style: KxTypography.bodyMd
                              .copyWith(color: KxColors.textPrimary),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: KxSpacing.radiusMd),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _SuggestedDoctorRow(
                  name: 'Deniz Korkmaz',
                  specialty: 'Radyoloji',
                  role: 'INTERN',
                  onAdd: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: KxColors.bgElevated,
                        content: Text(
                          'Deniz Korkmaz asistan listenize eklendi.',
                          style: KxTypography.bodyMd
                              .copyWith(color: KxColors.textPrimary),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: KxSpacing.radiusMd),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Asistan Karti ─────────────────────────────────────────────────

class _AssistantCard extends StatelessWidget {
  final _MockAssistant assistant;
  final VoidCallback onAssignCase;
  final VoidCallback onSendMessage;

  const _AssistantCard({
    required this.assistant,
    required this.onAssignCase,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = assistant.role == 'RESIDENT'
        ? KxColors.blue400
        : KxColors.amber300;
    final roleLabel =
        assistant.role == 'RESIDENT' ? 'Asistan' : 'Intern';

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
          // Ust satir: avatar + isim + durum
          Row(
            children: [
              Stack(
                children: [
                  KxAvatar(
                    name: assistant.name,
                    size: KxAvatarSize.md,
                    level: assistant.level,
                    showLevelRing: true,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: assistant.isOnline
                            ? KxColors.jade300
                            : KxColors.textMuted,
                        shape: BoxShape.circle,
                        border: Border.all(color: KxColors.bgCard, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            assistant.name,
                            style: KxTypography.labelMd,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        KxBadge(roleLabel, variant: KxBadgeVariant.teal),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      assistant.specialty,
                      style: KxTypography.caption
                          .copyWith(color: KxColors.teal400),
                    ),
                  ],
                ),
              ),
              // Online/Offline text
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: assistant.isOnline
                      ? KxColors.jade300.withOpacity(0.1)
                      : KxColors.textMuted.withOpacity(0.1),
                  borderRadius: KxSpacing.radiusPill,
                ),
                child: Text(
                  assistant.isOnline ? 'Online' : 'Offline',
                  style: KxTypography.caption.copyWith(
                    color: assistant.isOnline
                        ? KxColors.jade300
                        : KxColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // XP ilerleme cubugu
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 14, color: KxColors.amber300),
              const SizedBox(width: 4),
              Text(
                '${assistant.xpCurrent} / ${assistant.xpTotal} XP',
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Lvl ${assistant.level}',
                style: KxTypography.caption
                    .copyWith(color: roleColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: KxSpacing.radiusPill,
            child: LinearProgressIndicator(
              value: assistant.xpCurrent / assistant.xpTotal,
              backgroundColor: KxColors.border,
              valueColor:
                  AlwaysStoppedAnimation<Color>(KxColors.teal400),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 12),

          // Vaka istatistikleri
          Row(
            children: [
              _CaseStatChip(
                icon: Icons.check_circle_outline_rounded,
                label: 'Tamamlanan',
                value: '${assistant.casesCompleted}',
                color: KxColors.jade300,
              ),
              const SizedBox(width: 14),
              _CaseStatChip(
                icon: Icons.assignment_outlined,
                label: 'Atanan',
                value: '${assistant.casesAssigned}',
                color: KxColors.amber300,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Aksiyon butonlari
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onAssignCase,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: KxColors.teal400.withOpacity(0.08),
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(
                          color: KxColors.teal400.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_ind_rounded,
                            size: 16, color: KxColors.teal400),
                        const SizedBox(width: 6),
                        Text(
                          'Vaka Ata',
                          style: KxTypography.labelSm
                              .copyWith(color: KxColors.teal400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onSendMessage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: KxColors.blue400.withOpacity(0.08),
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(
                          color: KxColors.blue400.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded,
                            size: 16, color: KxColors.blue400),
                        const SizedBox(width: 6),
                        Text(
                          'Mesaj Gonder',
                          style: KxTypography.labelSm
                              .copyWith(color: KxColors.blue400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Karti ──────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: KxTypography.monoMd.copyWith(
              color: KxColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(label, style: KxTypography.caption),
        ],
      ),
    );
  }
}

// ── Vaka Stat Chip ───────────────────────────────────────────────

class _CaseStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CaseStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: KxTypography.caption.copyWith(color: KxColors.textSecondary),
        ),
        Text(
          value,
          style: KxTypography.monoSm.copyWith(
            color: KxColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Bos Durum ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

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
                color: KxColors.teal400.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 28,
                color: KxColors.teal400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'Sonuc bulunamadi' : 'Henuz asistan yok',
              style: KxTypography.headingSm,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Farkli bir arama terimi deneyin.'
                  : 'Asistan ekleyerek ekibinizi olusturun.',
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

// ── Onerilen Doktor Satiri (Dialog icinde) ───────────────────────

class _SuggestedDoctorRow extends StatelessWidget {
  final String name;
  final String specialty;
  final String role;
  final VoidCallback onAdd;

  const _SuggestedDoctorRow({
    required this.name,
    required this.specialty,
    required this.role,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: KxColors.bgBase,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Row(
        children: [
          KxAvatar(name: name, size: KxAvatarSize.sm),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: KxTypography.labelSm),
                Text(
                  '$specialty${role == "INTERN" ? " (Intern)" : " (Asistan)"}',
                  style: KxTypography.caption
                      .copyWith(color: KxColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: KxColors.teal400.withOpacity(0.1),
                borderRadius: KxSpacing.radiusPill,
                border:
                    Border.all(color: KxColors.teal400.withOpacity(0.3)),
              ),
              child: Text(
                'Ekle',
                style: KxTypography.labelSm
                    .copyWith(color: KxColors.teal400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mock Veri Modeli ─────────────────────────────────────────────

class _MockAssistant {
  final String id;
  final String name;
  final String specialty;
  final int level;
  final int xpCurrent;
  final int xpTotal;
  final int casesCompleted;
  final int casesAssigned;
  final bool isOnline;
  final String role; // 'RESIDENT' or 'INTERN'

  const _MockAssistant({
    required this.id,
    required this.name,
    required this.specialty,
    required this.level,
    required this.xpCurrent,
    required this.xpTotal,
    required this.casesCompleted,
    required this.casesAssigned,
    required this.isOnline,
    required this.role,
  });
}
