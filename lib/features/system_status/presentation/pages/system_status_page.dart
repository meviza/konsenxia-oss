import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';

/// KONSENXIA — Sistem Durumu
class SystemStatusPage extends StatelessWidget {
  const SystemStatusPage({super.key});

  static const _services = [
    _Service('API Sunucusu',      _SStatus.operational,  'Yanıt süresi: 42ms'),
    _Service('Firebase Auth',     _SStatus.operational,  'Kimlik doğrulama aktif'),
    _Service('Firestore DB',      _SStatus.operational,  'Okuma/yazma normal'),
    _Service('AI Chat Servisi',   _SStatus.degraded,     'Akış gecikmesi: ~1.2s'),
    _Service('Bildirim Servisi',  _SStatus.operational,  'FCM bağlantısı aktif'),
    _Service('Medya Depolama',    _SStatus.operational,  'Upload/download normal'),
    _Service('Arama İndeksi',     _SStatus.operational,  'Firestore prefix sorgu'),
    _Service('Analytics Pipeline', _SStatus.maintenance, 'Planlı bakım: 22:00–02:00'),
  ];

  static const _incidents = [
    _Incident(
      date: '07 Kas 2024 — 14:32',
      title: 'AI Chat gecikmeli yanıt',
      description: 'SSE akış gecikmesi GPU kapasitesi artışı ile çözüldü.',
      resolved: true,
    ),
    _Incident(
      date: '01 Kas 2024 — 09:15',
      title: 'Firestore okuma kısıtlaması',
      description: 'Anlık yüksek okuma talebi — 8 dakika içinde ölçeklendi.',
      resolved: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final operational = _services.where((s) => s.status == _SStatus.operational).length;
    final allOk = operational == _services.length;

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
            Text('Sistem Durumu', style: KxTypography.headingMd),
            Text('Canlı izleme', style: KxTypography.caption.copyWith(color: KxColors.teal400)),
          ]),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Genel durum banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (allOk ? KxColors.jade500 : KxColors.amber500).withOpacity(0.08),
                borderRadius: KxSpacing.radiusMd,
                border: Border.all(color: (allOk ? KxColors.jade300 : KxColors.amber300).withOpacity(0.4)),
              ),
              child: Row(children: [
                Icon(allOk ? Icons.check_circle_rounded : Icons.warning_rounded,
                    color: allOk ? KxColors.jade300 : KxColors.amber300, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(allOk ? 'Tüm sistemler çalışıyor' : 'Kısmi kesinti',
                      style: KxTypography.headingSm.copyWith(
                          color: allOk ? KxColors.jade300 : KxColors.amber300)),
                  Text('$operational/${_services.length} servis aktif',
                      style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary)),
                ])),
                Text(_now(), style: KxTypography.monoSm.copyWith(color: KxColors.textMuted)),
              ]),
            ),

            const SizedBox(height: 20),

            // Servis listesi başlık
            Row(children: [
              const Icon(Icons.dns_rounded, size: 14, color: KxColors.teal400),
              const SizedBox(width: 8),
              Text('Servisler', style: KxTypography.labelMd.copyWith(color: KxColors.textSecondary)),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [KxColors.border, KxColors.bgBase])))),
            ]),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: KxColors.bgCard, borderRadius: KxSpacing.radiusMd,
                border: Border.all(color: KxColors.border),
              ),
              child: Column(children: _services.asMap().entries.map((e) {
                final isLast = e.key == _services.length - 1;
                return Column(children: [
                  _ServiceRow(service: e.value),
                  if (!isLast) Container(height: 1, color: KxColors.borderSubtle),
                ]);
              }).toList()),
            ),

            const SizedBox(height: 24),

            Row(children: [
              const Icon(Icons.history_rounded, size: 14, color: KxColors.textMuted),
              const SizedBox(width: 8),
              Text('Son Olaylar', style: KxTypography.labelMd.copyWith(color: KxColors.textSecondary)),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [KxColors.border, KxColors.bgBase])))),
            ]),
            const SizedBox(height: 10),

            ..._incidents.map((inc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: KxColors.bgCard, borderRadius: KxSpacing.radiusMd, border: Border.all(color: KxColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          color: inc.resolved ? KxColors.jade300 : KxColors.crimson300),
                    ),
                    const SizedBox(width: 8),
                    Text(inc.title, style: KxTypography.labelSm),
                    const Spacer(),
                    if (inc.resolved)
                      Text('Çözüldü', style: KxTypography.caption.copyWith(color: KxColors.jade300)),
                  ]),
                  const SizedBox(height: 6),
                  Text(inc.description, style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(inc.date, style: KxTypography.caption.copyWith(color: KxColors.textMuted)),
                ]),
              ),
            )),

            const SizedBox(height: 40),
          ]),
        )),
      ]),
    );
  }

  String _now() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2,'0')}:${n.minute.toString().padLeft(2,'0')}';
  }
}

class _ServiceRow extends StatelessWidget {
  final _Service service;
  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (service.status) {
      _SStatus.operational => (KxColors.jade300,   'Aktif',   Icons.check_circle_rounded),
      _SStatus.degraded    => (KxColors.amber300,  'Yavaş',   Icons.warning_rounded),
      _SStatus.outage      => (KxColors.crimson300,'Kesinti', Icons.cancel_rounded),
      _SStatus.maintenance => (KxColors.blue400,   'Bakım',   Icons.build_rounded),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(service.name, style: KxTypography.labelSm),
          Text(service.detail, style: KxTypography.caption.copyWith(color: KxColors.textMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: KxSpacing.radiusPill),
          child: Text(label, style: KxTypography.caption.copyWith(color: color)),
        ),
      ]),
    );
  }
}

enum _SStatus { operational, degraded, outage, maintenance }

class _Service {
  final String name, detail;
  final _SStatus status;
  const _Service(this.name, this.status, this.detail);
}

class _Incident {
  final String date, title, description;
  final bool resolved;
  const _Incident({required this.date, required this.title, required this.description, required this.resolved});
}
