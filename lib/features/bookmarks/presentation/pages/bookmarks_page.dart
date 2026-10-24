import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Yer İmleri (Bookmarks) Sayfası
///
/// Koleksiyon sidebar'ı + kayıtlı vakalar listesi.
class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  String _activeCollection = 'all';

  final List<_BookmarkCollection> _collections = [
    const _BookmarkCollection(
      id: 'all',
      name: 'Tüm Kayıtlılar',
      icon: Icons.bookmarks_rounded,
      count: 24,
      color: KxColors.teal400,
    ),
    const _BookmarkCollection(
      id: 'cardiology',
      name: 'Kardiyoloji',
      icon: Icons.favorite_rounded,
      count: 8,
      color: KxColors.crimson400,
    ),
    const _BookmarkCollection(
      id: 'emergency',
      name: 'Acil',
      icon: Icons.local_hospital_rounded,
      count: 5,
      color: KxColors.amber300,
    ),
    const _BookmarkCollection(
      id: 'education',
      name: 'Eğitim',
      icon: Icons.school_rounded,
      count: 11,
      color: KxColors.blue400,
    ),
  ];

  final List<_BookmarkedCase> _mockCases = [
    _BookmarkedCase(
      id: 'KNX-1042',
      title: 'Akut ST-Elevasyonlu Miyokard İnfarktüsü',
      specialty: 'Kardiyoloji',
      savedAt: DateTime.now().subtract(const Duration(hours: 2)),
      urgency: 'Kritik',
      commentCount: 14,
      collection: 'cardiology',
    ),
    _BookmarkedCase(
      id: 'KNX-1038',
      title: 'Pediatrik Febril Konvülziyon Yönetimi',
      specialty: 'Pediatri',
      savedAt: DateTime.now().subtract(const Duration(hours: 8)),
      urgency: 'Acil',
      commentCount: 9,
      collection: 'emergency',
    ),
    _BookmarkedCase(
      id: 'KNX-1035',
      title: 'Tip 2 DM — İnsulin Direnci ve Yeni Tedavi Protokolü',
      specialty: 'Endokrinoloji',
      savedAt: DateTime.now().subtract(const Duration(days: 1)),
      urgency: 'Rutin',
      commentCount: 22,
      collection: 'education',
    ),
    _BookmarkedCase(
      id: 'KNX-1029',
      title: 'Atriyal Fibrilasyon — Antikoagülan Seçimi',
      specialty: 'Kardiyoloji',
      savedAt: DateTime.now().subtract(const Duration(days: 2)),
      urgency: 'Acil',
      commentCount: 18,
      collection: 'cardiology',
    ),
    _BookmarkedCase(
      id: 'KNX-1024',
      title: 'İskemik İnme Sonrası Rehabilitasyon Planlaması',
      specialty: 'Nöroloji',
      savedAt: DateTime.now().subtract(const Duration(days: 3)),
      urgency: 'Rutin',
      commentCount: 7,
      collection: 'education',
    ),
    _BookmarkedCase(
      id: 'KNX-1020',
      title: 'Septik Şok — Erken Tanı ve Sıvı Resüsitasyonu',
      specialty: 'Acil Tıp',
      savedAt: DateTime.now().subtract(const Duration(days: 4)),
      urgency: 'Kritik',
      commentCount: 31,
      collection: 'emergency',
    ),
  ];

  List<_BookmarkedCase> get _filteredCases {
    if (_activeCollection == 'all') return _mockCases;
    return _mockCases
        .where((c) => c.collection == _activeCollection)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: isWide ? _buildWide() : _buildNarrow(),
    );
  }

  // ── Geniş ekran: sidebar + koleksiyonlar + vakalar ──────────────

  Widget _buildWide() {
    return Row(
      children: [
        KxSidebar(
          activeItem: KxNavItem.cases,
          onItemSelected: (item) => _onNav(context, item),
          userName: 'Dr. Kerem',
          userSpecialty: 'Dahiliye',
          userLevel: 8,
          isOnline: true,
        ),
        // Koleksiyon paneli
        SizedBox(
          width: 260,
          child: _CollectionsPanel(),
        ),
        // Ana içerik
        Expanded(child: _BookmarksList()),
      ],
    );
  }

  // ── Dar ekran ───────────────────────────────────────────────────

  Widget _buildNarrow() {
    return Column(
      children: [
        // Üst bar
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: KxColors.textSecondary, size: 18),
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/dashboard'),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yer İmleri', style: KxTypography.headingMd),
                      Text(
                        '${_mockCases.length} kayıtlı vaka',
                        style: KxTypography.caption
                            .copyWith(color: KxColors.teal400),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined,
                      color: KxColors.teal400, size: 20),
                  onPressed: () => _showCreateCollectionDialog(context),
                ),
              ],
            ),
          ),
        ),

        // Yatay koleksiyon çipleri
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _collections.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = _collections[i];
              final isActive = _activeCollection == c.id;
              return GestureDetector(
                onTap: () => setState(() => _activeCollection = c.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? c.color.withOpacity(0.15)
                        : KxColors.bgCard,
                    borderRadius: KxSpacing.radiusPill,
                    border: Border.all(
                      color: isActive
                          ? c.color.withOpacity(0.4)
                          : KxColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon,
                          size: 14,
                          color: isActive ? c.color : KxColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        '${c.name} (${c.count})',
                        style: KxTypography.labelSm.copyWith(
                          color:
                              isActive ? c.color : KxColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Vakalar
        Expanded(child: _BookmarksList()),
      ],
    );
  }

  // ── Koleksiyon Paneli (geniş ekran) ─────────────────────────────

  Widget _CollectionsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(right: BorderSide(color: KxColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              children: [
                const Icon(Icons.bookmarks_rounded,
                    color: KxColors.teal400, size: 20),
                const SizedBox(width: 8),
                Text('Koleksiyonlar', style: KxTypography.headingSm),
              ],
            ),
          ),

          // Koleksiyon öğeleri
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _collections.length,
              itemBuilder: (_, i) {
                final c = _collections[i];
                final isActive = _activeCollection == c.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: KxSpacing.radiusMd,
                      onTap: () =>
                          setState(() => _activeCollection = c.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? c.color.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: KxSpacing.radiusMd,
                          border: isActive
                              ? Border.all(
                                  color: c.color.withOpacity(0.2))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: c.color.withOpacity(0.12),
                                borderRadius: KxSpacing.radiusSm,
                              ),
                              child:
                                  Icon(c.icon, size: 16, color: c.color),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: KxTypography.labelSm.copyWith(
                                      color: isActive
                                          ? c.color
                                          : KxColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${c.count} vaka',
                                    style: KxTypography.caption.copyWith(
                                        color: KxColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: c.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Koleksiyon oluştur butonu
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => _showCreateCollectionDialog(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: KxColors.teal400.withOpacity(0.06),
                  borderRadius: KxSpacing.radiusMd,
                  border:
                      Border.all(color: KxColors.teal400.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 16, color: KxColors.teal400),
                    const SizedBox(width: 6),
                    Text(
                      'Yeni Koleksiyon',
                      style: KxTypography.labelSm
                          .copyWith(color: KxColors.teal400),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kayıtlı Vakalar Listesi ─────────────────────────────────────

  Widget _BookmarksList() {
    final cases = _filteredCases;
    final collectionName = _collections
        .firstWhere((c) => c.id == _activeCollection)
        .name;

    return CustomScrollView(
      slivers: [
        // Başlık (geniş ekranda)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(collectionName,
                          style: KxTypography.headingMd),
                      const SizedBox(height: 4),
                      Text(
                        '${cases.length} kayıtlı vaka',
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Sıralama
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: KxColors.bgCard,
                    borderRadius: KxSpacing.radiusSm,
                    border: Border.all(color: KxColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort_rounded,
                          size: 14, color: KxColors.textMuted),
                      const SizedBox(width: 4),
                      Text('En Yeni',
                          style: KxTypography.caption
                              .copyWith(color: KxColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Liste
        cases.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: KxColors.teal400.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.bookmark_outline_rounded,
                            size: 28, color: KxColors.teal400),
                      ),
                      const SizedBox(height: 16),
                      Text('Bu koleksiyonda vaka yok',
                          style: KxTypography.labelMd),
                      const SizedBox(height: 4),
                      Text(
                        'Vakalardan yer imi ekleyin',
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BookmarkCaseCard(kase: cases[i]),
                    ),
                    childCount: cases.length,
                  ),
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // ── Koleksiyon Oluştur Dialogu ───────────────────────────────────

  void _showCreateCollectionDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
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
                      child: const Icon(Icons.create_new_folder_rounded,
                          size: 20, color: KxColors.teal400),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Yeni Koleksiyon',
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
                Text(
                  'Koleksiyonlar, kayıtlı vakalarınızı düzenlemenize yardımcı olur.',
                  style: KxTypography.bodyMd
                      .copyWith(color: KxColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 16),
                KxTextField(
                  controller: nameCtrl,
                  hint: 'Koleksiyon adı (Ör. Nöroloji)',
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
                            child: Text('Vazgeç',
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
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          setState(() {
                            _collections.add(_BookmarkCollection(
                              id: name.toLowerCase().replaceAll(' ', '_'),
                              name: name,
                              icon: Icons.folder_rounded,
                              count: 0,
                              color: KxColors.jade300,
                            ));
                          });
                          Navigator.of(ctx).pop();
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
                                      '"$name" koleksiyonu oluşturuldu',
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
                            child: Text('Oluştur',
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

  void _onNav(BuildContext context, KxNavItem item) {
    switch (item) {
      case KxNavItem.dashboard:
        context.go('/dashboard');
      case KxNavItem.cases:
        context.go('/cases');
      case KxNavItem.aiChat:
        context.go('/ai-chat');
      case KxNavItem.profile:
        context.go('/profile');
      default:
        break;
    }
  }
}

// ── Bookmark Kart Widget'ı ──────────────────────────────────────────

class _BookmarkCaseCard extends StatelessWidget {
  final _BookmarkedCase kase;
  const _BookmarkCaseCard({required this.kase});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/cases/${kase.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(kase.id, style: KxTypography.caseId),
                const SizedBox(width: 8),
                _urgencyBadge(kase.urgency),
                const Spacer(),
                Icon(Icons.bookmark_rounded,
                    size: 16, color: KxColors.amber300),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kase.title,
              style: KxTypography.labelMd,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                KxBadge.teal(kase.specialty),
                const SizedBox(width: 8),
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 12, color: KxColors.textMuted),
                const SizedBox(width: 3),
                Text('${kase.commentCount}',
                    style: KxTypography.caption),
                const Spacer(),
                Text(
                  _timeAgo(kase.savedAt),
                  style: KxTypography.caption
                      .copyWith(color: KxColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _urgencyBadge(String urgency) => switch (urgency) {
        'Kritik' => KxBadge.crimson(urgency),
        'Acil' => KxBadge.amber(urgency),
        _ => KxBadge.teal(urgency),
      };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24) return '${diff.inHours}sa önce';
    return '${diff.inDays}g önce';
  }
}

// ── Veri Modelleri ──────────────────────────────────────────────────

class _BookmarkCollection {
  final String id;
  final String name;
  final IconData icon;
  final int count;
  final Color color;

  const _BookmarkCollection({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
    required this.color,
  });
}

class _BookmarkedCase {
  final String id;
  final String title;
  final String specialty;
  final DateTime savedAt;
  final String urgency;
  final int commentCount;
  final String collection;

  const _BookmarkedCase({
    required this.id,
    required this.title,
    required this.specialty,
    required this.savedAt,
    required this.urgency,
    required this.commentCount,
    required this.collection,
  });
}
