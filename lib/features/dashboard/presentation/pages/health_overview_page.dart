import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';

/// KONSENXIA — Sağlık Genel Bakış
class HealthOverviewPage extends StatelessWidget {
  const HealthOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: KxColors.bgBase, floating: true, snap: true, elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: KxColors.textPrimary, size: 18),
            onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
          ),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sağlık Genel Bakış', style: KxTypography.headingMd),
            Text('Son güncelleme: 08.11.2024',
                style: KxTypography.caption.copyWith(color: KxColors.teal400)),
          ]),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Kimlik kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [KxColors.teal700.withOpacity(0.8), KxColors.bgCard],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: KxSpacing.radiusMd,
                  border: Border.all(color: KxColors.teal500.withOpacity(0.3)),
                ),
                child: Row(children: [
                  KxAvatar(name: 'Kerem Çelik', size: KxAvatarSize.lg),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Kerem Çelik', style: KxTypography.headingMd),
                    Text('32 yaş — Erkek — Kan Grubu: A+',
                        style: KxTypography.bodyMd.copyWith(color: KxColors.teal100)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, children: [
                      _Chip('DM Tip 2'), _Chip('HT'), _Chip('Hiperlipidemi'),
                    ]),
                  ])),
                ]),
              ),

              const SizedBox(height: 20),
              _Label('Vital Parametreler', Icons.favorite_rounded, KxColors.crimson300),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
                children: const [
                  _VCard(label: 'Kan Basıncı', value: '128/82', unit: 'mmHg', isHigh: true, icon: Icons.favorite_rounded),
                  _VCard(label: 'Nabız', value: '74', unit: 'bpm', isHigh: false, icon: Icons.monitor_heart_rounded),
                  _VCard(label: 'HbA1c', value: '7.2', unit: '%', isHigh: true, icon: Icons.water_drop_rounded),
                  _VCard(label: 'LDL', value: '142', unit: 'mg/dL', isHigh: true, icon: Icons.bloodtype_rounded),
                  _VCard(label: 'BMI', value: '26.4', unit: 'kg/m²', isHigh: false, icon: Icons.person_rounded),
                  _VCard(label: 'Ağırlık', value: '83', unit: 'kg', isHigh: false, icon: Icons.scale_rounded),
                ],
              ),

              const SizedBox(height: 20),
              _Label('Aktif Tanılar', Icons.local_hospital_rounded, KxColors.blue400),
              const SizedBox(height: 10),
              _DiagRow('E11.9', 'Tip 2 Diyabetes Mellitus', 'Set 2024', KxColors.amber300),
              const SizedBox(height: 8),
              _DiagRow('I10',   'Esansiyel Hipertansiyon',   'Kas 2022', KxColors.crimson300),
              const SizedBox(height: 8),
              _DiagRow('E78.5', 'Hiperlipidemi',              'Eki 2024', KxColors.blue400),

              const SizedBox(height: 20),
              _Label('Alerjiler', Icons.warning_rounded, KxColors.crimson300),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KxColors.crimson500.withOpacity(0.06),
                  borderRadius: KxSpacing.radiusMd,
                  border: Border.all(color: KxColors.crimson500.withOpacity(0.25)),
                ),
                child: Row(children: [
                  const Icon(Icons.block_rounded, color: KxColors.crimson300, size: 20),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Penisilin ailesi', style: KxTypography.labelMd),
                    Text('Anafilaksi — ciddi reaksiyon',
                        style: KxTypography.caption.copyWith(color: KxColors.crimson300)),
                  ]),
                ]),
              ),

              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _QBtn(icon: Icons.description_rounded, label: 'Raporlar',
                    color: KxColors.teal400, onTap: () => context.go('/reports'))),
                const SizedBox(width: 10),
                Expanded(child: _QBtn(icon: Icons.medication_rounded, label: 'Reçeteler',
                    color: KxColors.blue400, onTap: () => context.go('/prescriptions'))),
                const SizedBox(width: 10),
                Expanded(child: _QBtn(icon: Icons.calendar_today_rounded, label: 'Randevular',
                    color: KxColors.amber300, onTap: () => context.go('/appointments'))),
              ]),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text; final IconData icon; final Color color;
  const _Label(this.text, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: color), const SizedBox(width: 8),
    Text(text, style: KxTypography.labelMd.copyWith(color: KxColors.textSecondary)),
    const SizedBox(width: 8),
    Expanded(child: Container(height: 1,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [KxColors.border, KxColors.bgBase])))),
  ]);
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: KxColors.bgVoid.withOpacity(0.5), borderRadius: KxSpacing.radiusPill),
    child: Text(label, style: KxTypography.caption.copyWith(color: KxColors.teal100, fontSize: 10)),
  );
}

Widget _DiagRow(String code, String name, String date, Color color) => Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(color: KxColors.bgCard, borderRadius: KxSpacing.radiusMd, border: Border.all(color: KxColors.border)),
  child: Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: KxSpacing.radiusSm, border: Border.all(color: color.withOpacity(0.3))),
      child: Text(code, style: KxTypography.monoSm.copyWith(color: color)),
    ),
    const SizedBox(width: 10),
    Expanded(child: Text(name, style: KxTypography.labelSm)),
    Text(date, style: KxTypography.caption.copyWith(color: KxColors.textMuted)),
  ]),
);

class _VCard extends StatelessWidget {
  final String label, value, unit; final bool isHigh; final IconData icon;
  const _VCard({required this.label, required this.value, required this.unit, required this.isHigh, required this.icon});
  @override
  Widget build(BuildContext context) {
    final color = isHigh ? KxColors.amber300 : KxColors.jade300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: KxColors.bgCard, borderRadius: KxSpacing.radiusMd, border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 18), const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: KxTypography.caption.copyWith(color: KxColors.textMuted, fontSize: 10)),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(value, style: KxTypography.monoSm.copyWith(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(width: 3),
            Text(unit, style: KxTypography.caption.copyWith(color: KxColors.textMuted, fontSize: 9)),
          ]),
        ])),
      ]),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: KxSpacing.radiusMd, border: Border.all(color: color.withOpacity(0.3))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 22), const SizedBox(height: 4),
        Text(label, style: KxTypography.caption.copyWith(color: color)),
      ]),
    ),
  );
}
