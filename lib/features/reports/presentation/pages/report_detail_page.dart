import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Rapor Detayı
class ReportDetailPage extends StatelessWidget {
  final String reportId;
  const ReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: KxColors.bgSurface,
            floating: false,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: KxColors.textPrimary, size: 18),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/reports'),
            ),
            title: Text('Rapor Detayı', style: KxTypography.headingSm),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded,
                    color: KxColors.textSecondary),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded,
                    color: KxColors.textSecondary),
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rapor tipi & tarih
                  Row(
                    children: [
                      _TypeBadge(
                          label: 'Laboratuvar',
                          color: KxColors.blue400,
                          icon: Icons.biotech_rounded),
                      const Spacer(),
                      Text('08.11.2024',
                          style: KxTypography.monoSm.copyWith(
                              color: KxColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text('Tam Kan Sayımı + Biyokimya',
                      style: KxTypography.headingLg),
                  const SizedBox(height: 4),
                  Text('Üsküdar Tıp Merkezi — Dr. Aylin Çelik',
                      style: KxTypography.bodyMd.copyWith(
                          color: KxColors.textSecondary)),

                  const SizedBox(height: 20),
                  const _Divider(),
                  const SizedBox(height: 20),

                  // Kritik değerler
                  _SectionTitle('Dikkat Gerektiren Değerler',
                      icon: Icons.warning_rounded,
                      color: KxColors.amber300),
                  const SizedBox(height: 10),
                  ...[
                    const _LabRow(
                        param: 'HbA1c',
                        value: '7.2%',
                        ref: '< 5.7%',
                        status: _LabStatus.high),
                    const _LabRow(
                        param: 'LDL Kolesterol',
                        value: '142 mg/dL',
                        ref: '< 100 mg/dL',
                        status: _LabStatus.high),
                    const _LabRow(
                        param: 'CRP',
                        value: '4.1 mg/L',
                        ref: '< 5.0 mg/L',
                        status: _LabStatus.borderline),
                  ].map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: w,
                      )),

                  const SizedBox(height: 20),

                  // Normal değerler
                  _SectionTitle('Normal Değerler',
                      icon: Icons.check_circle_rounded,
                      color: KxColors.jade300),
                  const SizedBox(height: 10),
                  ...[
                    const _LabRow(
                        param: 'Hemoglobin',
                        value: '14.2 g/dL',
                        ref: '13.5–17.5 g/dL',
                        status: _LabStatus.normal),
                    const _LabRow(
                        param: 'Trombositler',
                        value: '248K/µL',
                        ref: '150–400K/µL',
                        status: _LabStatus.normal),
                    const _LabRow(
                        param: 'Kreatinin',
                        value: '0.9 mg/dL',
                        ref: '0.7–1.2 mg/dL',
                        status: _LabStatus.normal),
                    const _LabRow(
                        param: 'ALT',
                        value: '28 U/L',
                        ref: '7–40 U/L',
                        status: _LabStatus.normal),
                    const _LabRow(
                        param: 'TSH',
                        value: '2.4 mIU/L',
                        ref: '0.4–4.0 mIU/L',
                        status: _LabStatus.normal),
                    const _LabRow(
                        param: 'Sodyum',
                        value: '139 mEq/L',
                        ref: '136–145 mEq/L',
                        status: _LabStatus.normal),
                  ].map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: w,
                      )),

                  const SizedBox(height: 20),
                  const _Divider(),
                  const SizedBox(height: 16),

                  // Doktor notu
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: KxColors.bgSurface,
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(color: KxColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                size: 14, color: KxColors.teal400),
                            const SizedBox(width: 6),
                            Text('Doktor Notu',
                                style: KxTypography.labelSm.copyWith(
                                    color: KxColors.teal400)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'HbA1c değeriniz hedef aralığın biraz üzerinde. LDL kolesterol kontrolü için diyet ve egzersiz öneriyorum. 3 ay sonra tekrar değerlendirelim.',
                          style: KxTypography.bodyMd.copyWith(
                              color: KxColors.textSecondary, height: 1.6),
                        ),
                        const SizedBox(height: 6),
                        Text('— Dr. Aylin Çelik',
                            style: KxTypography.caption.copyWith(
                                color: KxColors.textMuted)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: KxButton(
                      label: 'Vakaya Ekle',
                      onPressed: () {},
                      variant: KxButtonVariant.secondary,
                      icon: Icons.add_rounded,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: KxColors.border);
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _TypeBadge(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: KxSpacing.radiusPill,
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: KxTypography.caption.copyWith(color: color)),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionTitle(this.title,
      {required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(title,
              style: KxTypography.labelMd.copyWith(color: color)),
        ],
      );
}

enum _LabStatus { normal, high, low, borderline }

class _LabRow extends StatelessWidget {
  final String param;
  final String value;
  final String ref;
  final _LabStatus status;
  const _LabRow({
    required this.param,
    required this.value,
    required this.ref,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      _LabStatus.normal     => (KxColors.jade300,   Icons.check_rounded),
      _LabStatus.high       => (KxColors.crimson300, Icons.arrow_upward_rounded),
      _LabStatus.low        => (KxColors.blue300,    Icons.arrow_downward_rounded),
      _LabStatus.borderline => (KxColors.amber300,   Icons.remove_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(
          color: status == _LabStatus.normal
              ? KxColors.border
              : color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(param, style: KxTypography.labelSm),
          ),
          Expanded(
            flex: 2,
            child: Text(value,
                textAlign: TextAlign.center,
                style: KxTypography.monoSm.copyWith(
                  color: color,
                  fontWeight: status != _LabStatus.normal
                      ? FontWeight.bold
                      : FontWeight.normal,
                )),
          ),
          Expanded(
            flex: 3,
            child: Text(ref,
                textAlign: TextAlign.right,
                style: KxTypography.caption.copyWith(
                    color: KxColors.textMuted)),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: color),
        ],
      ),
    );
  }
}
