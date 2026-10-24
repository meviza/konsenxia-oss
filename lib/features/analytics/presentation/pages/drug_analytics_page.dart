import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA İlaç Analitikleri
class DrugAnalyticsPage extends StatefulWidget {
  const DrugAnalyticsPage({super.key});

  @override
  State<DrugAnalyticsPage> createState() => _DrugAnalyticsPageState();
}

class _DrugAnalyticsPageState extends State<DrugAnalyticsPage> {
  String _tab = 'Trend';
  static const _tabs = ['Trend', 'Uzmanlığa Göre', 'Etkileşimler'];

  static final _trending = [
    _DrugEntry(name: 'Semaglutid', category: 'GLP-1 Agonisti', mentions: 847, trend: 42, trendUp: true, topSpecialty: 'Endokrinoloji', note: 'Obezite endikasyonu sonrası artış'),
    _DrugEntry(name: 'Empagliflozin', category: 'SGLT2 İnhibitörü', mentions: 613, trend: 28, trendUp: true, topSpecialty: 'Kardiyoloji', note: 'Kardiyoprotektif etki vakaları'),
    _DrugEntry(name: 'Amiodaron', category: 'Antiaritmik', mentions: 389, trend: -12, trendUp: false, topSpecialty: 'Kardiyoloji', note: 'Tiroid yan etki sorguları'),
    _DrugEntry(name: 'Prednizolon', category: 'Kortikosteroid', mentions: 521, trend: 5, trendUp: true, topSpecialty: 'Romatoloji', note: 'Otoimmün alevlenme vakaları'),
    _DrugEntry(name: 'Metotreksat', category: 'DMARD', mentions: 302, trend: 8, trendUp: true, topSpecialty: 'Romatoloji', note: 'RA kombine protokol soruları'),
    _DrugEntry(name: 'Vankomisın', category: 'Antibiyotik', mentions: 267, trend: -3, trendUp: false, topSpecialty: 'Enfeksiyon H.', note: 'MRSA vakalarında standart'),
  ];

  static final _bySpecialty = <String, List<String>>{
    'Kardiyoloji': ['Metoprolol', 'Empagliflozin', 'Apixaban', 'Atorvastatin'],
    'Endokrinoloji': ['Semaglutid', 'Metformin', 'Tirozin', 'Dapagliflozin'],
    'Romatoloji': ['Metotreksat', 'Prednizolon', 'Adalimumab', 'Leflunomid'],
    'Nöroloji': ['Levetiracetam', 'Fingolimod', 'Topiramat', 'Natalizumab'],
    'Enfeksiyon': ['Vankomisın', 'Meropenem', 'Pip-Taz', 'Linezolid'],
  };

  static final _interactions = [
    _Interaction(drug1: 'Warfarin', drug2: 'Flukonazol', severity: _Severity.major, mechanism: 'CYP2C9 inhibisyonu → INR artışı → kanama riski'),
    _Interaction(drug1: 'Amiodaron', drug2: 'Digoksin', severity: _Severity.major, mechanism: 'P-glikoprotein inhibisyonu → digoksin toksisitesi'),
    _Interaction(drug1: 'Metotreksat', drug2: 'NSAII', severity: _Severity.moderate, mechanism: 'Renal tübüler sekresyon inhibisyonu → MTX birikimi'),
    _Interaction(drug1: 'Sildenafil', drug2: 'Nitrat', severity: _Severity.contraindicated, mechanism: 'cGMP artışı → şiddetli hipotansiyon'),
    _Interaction(drug1: 'Lityum', drug2: 'Tiazid', severity: _Severity.major, mechanism: 'Sodyum kaybı → lityum reabsorpsiyonu → toksik seviye'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: KxColors.bgBase,
            floating: true, snap: true, elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: KxColors.textPrimary, size: 18),
              onPressed: () => context.canPop() ? context.pop() : context.go('/analytics'),
            ),
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('İlaç Analitikleri', style: KxTypography.headingMd),
              Text('Topluluk verisi', style: KxTypography.caption.copyWith(color: KxColors.teal400)),
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _tabs.map((t) {
                  final sel = t == _tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: sel ? KxColors.teal400.withOpacity(0.12) : KxColors.bgCard,
                          borderRadius: KxSpacing.radiusMd,
                          border: Border.all(color: sel ? KxColors.teal400.withOpacity(0.5) : KxColors.border),
                        ),
                        child: Text(t, textAlign: TextAlign.center,
                            style: KxTypography.labelSm.copyWith(
                                color: sel ? KxColors.teal400 : KxColors.textSecondary)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (_tab == 'Trend') _TrendSliver(drugs: _trending)
          else if (_tab == 'Uzmanlığa Göre') _SpecialtySliver(data: _bySpecialty)
          else _InteractionSliver(items: _interactions),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _TrendSliver extends StatelessWidget {
  final List<_DrugEntry> drugs;
  const _TrendSliver({required this.drugs});
  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    sliver: SliverList(delegate: SliverChildBuilderDelegate(
      (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10),
        child: _DrugTile(drug: drugs[i], rank: i + 1)),
      childCount: drugs.length,
    )),
  );
}

class _DrugTile extends StatelessWidget {
  final _DrugEntry drug; final int rank;
  const _DrugTile({required this.drug, required this.rank});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: KxColors.bgCard, borderRadius: KxSpacing.radiusMd, border: Border.all(color: KxColors.border)),
    child: Row(children: [
      Container(width: 32, height: 32,
        decoration: BoxDecoration(color: KxColors.bgSurface, borderRadius: KxSpacing.radiusSm),
        child: Center(child: Text('#$rank', style: KxTypography.monoSm.copyWith(color: KxColors.textMuted)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(drug.name, style: KxTypography.headingSm),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(color: KxColors.bgSurface, borderRadius: KxSpacing.radiusPill),
            child: Text(drug.category, style: KxTypography.caption.copyWith(color: KxColors.textMuted, fontSize: 10))),
        ]),
        const SizedBox(height: 3),
        Text(drug.note, style: KxTypography.caption.copyWith(color: KxColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: KxColors.textMuted),
          const SizedBox(width: 4),
          Text('${drug.mentions} söz', style: KxTypography.caption.copyWith(color: KxColors.textMuted)),
          const SizedBox(width: 8),
          KxTag(drug.topSpecialty),
        ]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Icon(drug.trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: drug.trendUp ? KxColors.jade300 : KxColors.crimson300, size: 20),
        Text('${drug.trendUp ? "+" : ""}${drug.trend}%',
          style: KxTypography.monoSm.copyWith(color: drug.trendUp ? KxColors.jade300 : KxColors.crimson300)),
      ]),
    ]),
  );
}

class _SpecialtySliver extends StatelessWidget {
  final Map<String, List<String>> data;
  const _SpecialtySliver({required this.data});
  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    sliver: SliverList(delegate: SliverChildBuilderDelegate(
      (_, i) {
        final entry = data.entries.toList()[i];
        return Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: KxColors.bgCard, borderRadius: KxSpacing.radiusMd, border: Border.all(color: KxColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.key, style: KxTypography.headingSm),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: entry.value.map((d) => KxTag(d)).toList()),
            ])));
      },
      childCount: data.length,
    )),
  );
}

class _InteractionSliver extends StatelessWidget {
  final List<_Interaction> items;
  const _InteractionSliver({required this.items});
  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    sliver: SliverList(delegate: SliverChildBuilderDelegate(
      (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _InteractionTile(item: items[i])),
      childCount: items.length,
    )),
  );
}

class _InteractionTile extends StatelessWidget {
  final _Interaction item;
  const _InteractionTile({required this.item});
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (item.severity) {
      _Severity.contraindicated => ('Kontrendike', KxColors.crimson400),
      _Severity.major           => ('Majör',       KxColors.crimson300),
      _Severity.moderate        => ('Orta',        KxColors.amber300),
      _Severity.minor           => ('Minör',       KxColors.jade300),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: KxColors.bgCard, borderRadius: KxSpacing.radiusMd, border: Border.all(color: color.withOpacity(0.35))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: KxSpacing.radiusPill, border: Border.all(color: color.withOpacity(0.4))),
          child: Text(label, style: KxTypography.caption.copyWith(color: color))),
        const SizedBox(height: 10),
        Row(children: [
          _Pill(item.drug1),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.add_rounded, color: KxColors.textMuted, size: 14)),
          _Pill(item.drug2),
        ]),
        const SizedBox(height: 8),
        Text(item.mechanism, style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary)),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String name;
  const _Pill(this.name);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: KxColors.bgSurface, borderRadius: KxSpacing.radiusPill, border: Border.all(color: KxColors.border)),
    child: Text(name, style: KxTypography.labelSm),
  );
}

class _DrugEntry {
  final String name, category, topSpecialty, note;
  final int mentions, trend;
  final bool trendUp;
  const _DrugEntry({required this.name, required this.category, required this.mentions, required this.trend, required this.trendUp, required this.topSpecialty, required this.note});
}

enum _Severity { contraindicated, major, moderate, minor }

class _Interaction {
  final String drug1, drug2, mechanism;
  final _Severity severity;
  const _Interaction({required this.drug1, required this.drug2, required this.severity, required this.mechanism});
}
