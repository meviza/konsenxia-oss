import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/case_entity.dart';
import '../bloc/cases_bloc.dart';

/// KONSENXIA Vaka Merkezi (Cases Hub)
///
/// Vakaları listeler, filtreler ve yeni vaka oluşturulmasına olanak tanır.
class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  String _selectedFilter = 'Tümü';
  final List<String> _filters = [
    'Tümü', 'Acil', 'Açık', 'Çözüldü', 'Benim Vakalarım'
  ];

  late final CasesBloc _casesBloc;

  // Mock vakalar — backend entegrasyonuna kadar
  // NOT: ID'lerde '#' yok — URL'de fragment sorunu önlenir. Gösterimde '#KX-...' formatı kullanılır.
  static final List<_MockCase> _mockCases = [
    _MockCase(
      id: 'KX-2024-0047',
      title: 'Tekrarlayan ateş ve peteşiyal döküntü: Rocky Mountain benekli ateşi?',
      summary:
          '34 yaşında erkek hasta, 5 gündür süren intermittent ateş (38.8°C) ve bilateral alt ekstremitelerde peteşiyal döküntü ile başvurdu. Yakın zamanda kamp tatili öyküsü mevcut.',
      authorName: 'Dr. Kerem Demir',
      specialty: 'Enfeksiyon Hastalıkları',
      country: 'TR',
      urgency: KxCaseUrgency.urgent,
      tags: ['Riketsiya', 'Peteşi', 'Vektör Kaynaklı'],
      viewCount: 312,
      commentCount: 14,
      likeCount: 28,
      postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isSolved: false,
    ),
    _MockCase(
      id: 'KX-2024-0046',
      title: 'Bilateral pulmoner infiltrat + eozinofili: Löffler sendromu mu?',
      summary:
          '27 yaşında kadın hasta, 3 haftadır öksürük ve nefes darlığı. Akciğer grafisinde bilateral infiltratlar, kanda eozinofili %18. Helmintiyazis ekartasyonu için ne önerirsiniz?',
      authorName: 'Dr. Selin Kaya',
      specialty: 'Göğüs Hastalıkları',
      country: 'TR',
      urgency: KxCaseUrgency.routine,
      tags: ['Eozinofili', 'Pulmoner', 'Parazitoloji'],
      viewCount: 189,
      commentCount: 8,
      likeCount: 15,
      postedAt: DateTime.now().subtract(const Duration(hours: 5)),
      isSolved: true,
    ),
    _MockCase(
      id: 'KX-2024-0045',
      title: 'İleri yaş hasta, ani başlayan unilateral proptoz',
      summary:
          '68 yaşında erkek, 48 saat içinde gelişen sağ göz proptozu, diplopi ve hafif ptoz. Ağrısız. Ateş yok. Orbital selülit mi, kavernöz sinüs trombozu mu?',
      authorName: 'Dr. Ali Çelik',
      specialty: 'Nöroloji',
      country: 'DE',
      urgency: KxCaseUrgency.critical,
      tags: ['Proptoz', 'Orbital', 'Nöroloji'],
      viewCount: 541,
      commentCount: 21,
      likeCount: 47,
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      isSolved: false,
    ),
    _MockCase(
      id: 'KX-2024-0044',
      title: 'Diyabetik hasta — ayak ülseri Wagner Evre 3, kemik tutulumu?',
      summary:
          "Tip 2 DM, 15 yıllık hasta. Sağ ayak 3. parmak tabanında Wagner Evre 3 ülser. MR'da kemik iliği ödemi. Osteomyelit için ampirik tedavi mi, yoksa biyopsi önce mi?",
      authorName: 'Dr. Maya Singh',
      specialty: 'Endokrinoloji',
      country: 'IN',
      urgency: KxCaseUrgency.urgent,
      tags: ['Diyabetik Ayak', 'Osteomyelit', 'Wagner'],
      viewCount: 278,
      commentCount: 32,
      likeCount: 61,
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      isSolved: false,
    ),
    _MockCase(
      id: 'KX-2024-0049',
      title: 'Politravma: 19y erkek, motorlu taşıt kazası — multiple fraktür',
      summary:
          '19 yaşında erkek hasta, yüksek hızlı motorlu taşıt kazası sonrası acile getirildi. GKS 13, bilateral femur fraktürü, dalak laserasyonu şüphesi. Damage control mı, erken total care mı?',
      authorName: 'Dr. Emre Yılmaz',
      specialty: 'Acil Tıp',
      country: 'TR',
      urgency: KxCaseUrgency.emergency,
      tags: ['Politravma', 'Damage Control', 'Ortopedi'],
      viewCount: 421,
      commentCount: 19,
      likeCount: 38,
      postedAt: DateTime.now().subtract(const Duration(hours: 8)),
      isSolved: false,
    ),
    _MockCase(
      id: 'KX-2024-0050',
      title: 'Ani dispne, sağ alt lob PE şüphesi — antikoagülasyon başlanmalı mı?',
      summary:
          '65 yaşında erkek, 3 saattir ani başlayan dispne ve sağ plöritik göğüs ağrısı. Wells skoru 6 (yüksek olasılık). BT anjio beklerken antikoagülasyon başlanmalı mı?',
      authorName: 'Prof. Dr. Aynur Başkaya',
      specialty: 'Göğüs Hastalıkları',
      country: 'TR',
      urgency: KxCaseUrgency.urgent,
      tags: ['Pulmoner Emboli', 'Antikoagülasyon', 'Wells'],
      viewCount: 334,
      commentCount: 24,
      likeCount: 52,
      postedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isSolved: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _casesBloc = GetIt.instance<CasesBloc>();
    _casesBloc.add(const LoadCasesEvent());
  }

  @override
  void dispose() {
    _casesBloc.close();
    super.dispose();
  }

  /// Apply filter via BLoC event dispatch
  void _onFilterSelected(String filter) {
    setState(() => _selectedFilter = filter);

    switch (filter) {
      case 'Tümü':
        _casesBloc.add(const LoadCasesEvent());
      case 'Acil':
        _casesBloc.add(const FilterCasesEvent(urgency: 'urgent'));
      case 'Açık':
        _casesBloc.add(const FilterCasesEvent(status: 'open'));
      case 'Çözüldü':
        _casesBloc.add(const FilterCasesEvent(status: 'solved'));
      case 'Benim Vakalarım':
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          _casesBloc.add(LoadUserCasesEvent(uid));
        } else {
          // Fallback: load all if not logged in
          _casesBloc.add(const LoadCasesEvent());
        }
    }
  }

  /// Map domain CaseUrgency to design system KxCaseUrgency
  static KxCaseUrgency _mapUrgency(CaseUrgency u) => switch (u) {
        CaseUrgency.routine => KxCaseUrgency.routine,
        CaseUrgency.urgent => KxCaseUrgency.urgent,
        CaseUrgency.critical => KxCaseUrgency.critical,
        CaseUrgency.emergency => KxCaseUrgency.emergency,
      };

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return BlocProvider.value(
      value: _casesBloc,
      child: Scaffold(
        backgroundColor: KxColors.bgBase,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/cases/new'),
          backgroundColor: KxColors.teal400,
          foregroundColor: KxColors.bgVoid,
          icon: const Icon(Icons.add_rounded),
          label: Text('Yeni Vaka', style: KxTypography.labelMd),
        ),
        body: isWide ? _buildWide() : _buildNarrow(),
      ),
    );
  }

  // ── Geniş ekran ────────────────────────────────────────────────

  Widget _buildWide() {
    return _buildContent();
  }

  Widget _buildNarrow() => _buildContent();

  // ── İçerik ────────────────────────────────────────────────────

  Widget _buildContent() {
    return BlocBuilder<CasesBloc, CasesState>(
      builder: (context, state) {
        // Determine the case list to display
        final List<CaseEntity> liveCases;
        final bool isLoading;

        if (state is CasesLoaded && state.cases.isNotEmpty) {
          liveCases = state.cases;
          isLoading = false;
        } else if (state is CasesLoading) {
          liveCases = [];
          isLoading = true;
        } else {
          // Fallback to mock data (error state or empty)
          liveCases = [];
          isLoading = false;
        }

        final bool useMock = liveCases.isEmpty && !isLoading;
        final int caseCount = useMock ? _mockCases.length : liveCases.length;

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: KxColors.bgBase,
              floating: true,
              snap: true,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vaka Merkezi', style: KxTypography.headingMd),
                  Text(
                    '$caseCount aktif vaka',
                    style: KxTypography.caption.copyWith(color: KxColors.teal400),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: KxColors.textSecondary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: KxColors.textSecondary),
                  onPressed: () {},
                ),
              ],
            ),

            // Filtre çubuğu
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final f = _filters[i];
                    final isSelected = f == _selectedFilter;
                    return GestureDetector(
                      onTap: () => _onFilterSelected(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? KxColors.teal400.withOpacity(0.12)
                              : KxColors.bgCard,
                          borderRadius: KxSpacing.radiusPill,
                          border: Border.all(
                            color: isSelected
                                ? KxColors.teal400.withOpacity(0.5)
                                : KxColors.border,
                          ),
                        ),
                        child: Text(
                          f,
                          style: KxTypography.labelSm.copyWith(
                            color: isSelected ? KxColors.teal400 : KxColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Loading indicator
            if (isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: KxColors.teal400),
                  ),
                ),
              ),

            // Error message (if any)
            if (state is CasesError)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: KxColors.crimson400.withOpacity(0.08),
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(color: KxColors.crimson400.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: KxColors.crimson400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${state.message} — Mock veriler gosteriliyor.',
                            style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Content: Firestore cases or mock fallback
            if (!isLoading) ...[
              // Öne çıkan vaka (ilk kritik vaka)
              if (useMock) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: KxCaseCard.featured(
                      caseId: _mockCases[2].id,
                      title: _mockCases[2].title,
                      summary: _mockCases[2].summary,
                      authorName: _mockCases[2].authorName,
                      authorSpecialty: _mockCases[2].specialty,
                      authorCountry: _mockCases[2].country,
                      urgency: _mockCases[2].urgency,
                      tags: _mockCases[2].tags,
                      viewCount: _mockCases[2].viewCount,
                      commentCount: _mockCases[2].commentCount,
                      likeCount: _mockCases[2].likeCount,
                      isSolved: _mockCases[2].isSolved,
                      postedAt: _mockCases[2].postedAt,
                      onTap: () => context.go('/cases/${_mockCases[2].id}'),
                      onLike: () {},
                      onBookmark: () {},
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Mock vaka listesi
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = _mockCases[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: KxCaseCard.standard(
                            caseId: c.id,
                            title: c.title,
                            summary: c.summary,
                            authorName: c.authorName,
                            authorSpecialty: c.specialty,
                            authorCountry: c.country,
                            urgency: c.urgency,
                            tags: c.tags,
                            viewCount: c.viewCount,
                            commentCount: c.commentCount,
                            likeCount: c.likeCount,
                            isSolved: c.isSolved,
                            postedAt: c.postedAt,
                            onTap: () => context.go('/cases/${c.id}'),
                            onLike: () {},
                            onBookmark: () {},
                            onShare: () {},
                          ),
                        );
                      },
                      childCount: _mockCases.length,
                    ),
                  ),
                ),
              ] else ...[
                // Featured case from Firestore (first critical/emergency case if available)
                if (_findFeaturedCase(liveCases) != null)
                  _buildFeaturedCaseSliver(_findFeaturedCase(liveCases)!),
                if (_findFeaturedCase(liveCases) != null)
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Firestore vaka listesi
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = liveCases[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: KxCaseCard.standard(
                            caseId: c.id,
                            title: c.title,
                            summary: c.description,
                            authorName: c.authorName,
                            authorSpecialty: c.authorSpecialty,
                            authorCountry: c.authorCountry,
                            urgency: _mapUrgency(c.urgency),
                            tags: c.tags,
                            viewCount: c.viewCount,
                            commentCount: c.comments.length,
                            likeCount: c.likeCount,
                            isSolved: c.isSolved,
                            postedAt: c.createdAt,
                            onTap: () => context.go('/cases/${c.id}'),
                            onLike: () {
                              _casesBloc.add(ToggleLikeCaseEvent(
                                caseId: c.id,
                                isCurrentlyLiked: c.isLikedByCurrentUser,
                              ));
                            },
                            onBookmark: () {
                              _casesBloc.add(ToggleBookmarkCaseEvent(
                                caseId: c.id,
                                isCurrentlyBookmarked: c.isBookmarkedByCurrentUser,
                              ));
                            },
                            onShare: () {},
                          ),
                        );
                      },
                      childCount: liveCases.length,
                    ),
                  ),
                ),
              ],
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  /// Find the first critical/emergency case for featured display
  CaseEntity? _findFeaturedCase(List<CaseEntity> cases) {
    try {
      return cases.firstWhere(
        (c) => c.urgency == CaseUrgency.critical || c.urgency == CaseUrgency.emergency,
      );
    } catch (_) {
      return cases.isNotEmpty ? cases.first : null;
    }
  }

  /// Build a featured case card sliver from a CaseEntity
  Widget _buildFeaturedCaseSliver(CaseEntity c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: KxCaseCard.featured(
          caseId: c.id,
          title: c.title,
          summary: c.description,
          authorName: c.authorName,
          authorSpecialty: c.authorSpecialty,
          authorCountry: c.authorCountry,
          urgency: _mapUrgency(c.urgency),
          tags: c.tags,
          viewCount: c.viewCount,
          commentCount: c.comments.length,
          likeCount: c.likeCount,
          isSolved: c.isSolved,
          postedAt: c.createdAt,
          onTap: () => context.go('/cases/${c.id}'),
          onLike: () {
            _casesBloc.add(ToggleLikeCaseEvent(
              caseId: c.id,
              isCurrentlyLiked: c.isLikedByCurrentUser,
            ));
          },
          onBookmark: () {
            _casesBloc.add(ToggleBookmarkCaseEvent(
              caseId: c.id,
              isCurrentlyBookmarked: c.isBookmarkedByCurrentUser,
            ));
          },
        ),
      ),
    );
  }

}

class _MockCase {
  final String id;
  final String title;
  final String summary;
  final String authorName;
  final String specialty;
  final String? country;
  final KxCaseUrgency urgency;
  final List<String> tags;
  final int viewCount;
  final int commentCount;
  final int likeCount;
  final DateTime postedAt;
  final bool isSolved;

  const _MockCase({
    required this.id,
    required this.title,
    required this.summary,
    required this.authorName,
    required this.specialty,
    this.country,
    required this.urgency,
    required this.tags,
    required this.viewCount,
    required this.commentCount,
    required this.likeCount,
    required this.postedAt,
    required this.isSolved,
  });
}
