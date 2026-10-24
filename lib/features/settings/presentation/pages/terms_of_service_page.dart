import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Kullanım Koşulları
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: KxColors.bgBase,
          floating: true, snap: true, elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: KxColors.textPrimary, size: 18),
            onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
          ),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Kullanım Koşulları', style: KxTypography.headingMd),
            Text('Terms of Service', style: KxTypography.caption.copyWith(color: KxColors.teal400)),
          ]),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegalBadge('Yürürlük Tarihi: 01 Kasım 2024'),
                const SizedBox(height: 20),

                _WarningBox(
                  'KONSENXIA sağlık profesyonellerine yönelik mesleki bir platformdur. Platform içeriği, yapay zeka yanıtları dahil, doğrudan tıbbi tavsiye veya tanı niteliği taşımaz.',
                ),
                const SizedBox(height: 20),

                _Section(
                  title: '1. Hizmet Tanımı ve Kabul',
                  body: 'KONSENXIA, lisanslı hekimlerin klinik vakaları paylaşabileceği, mesleki gelişim içeriklerine erişebileceği ve yapay zeka destekli karar destek araçları kullanabileceği dijital bir platformdur. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.',
                ),
                _Section(
                  title: '2. Üyelik Gereksinimleri',
                  body: 'Platforma üyelik; Türkiye Cumhuriyeti sınırları dahilinde geçerli hekimlik lisansına sahip, T.C. Tabip Odası veya Sağlık Bakanlığı kayıtlı hekimlere açıktır. Yanlış bilgi sağlanması hesabın kalıcı olarak kapatılmasına yol açar.',
                ),
                _Section(
                  title: '3. Vaka Paylaşım Kuralları',
                  body: 'Paylaşılan vakalar KVKK ve Sağlık Bakanlığı hasta gizliliği yönetmelikleri uyarınca anonimleştirilmiş olmalıdır. Ad, soyadı, TC kimlik numarası, dosya numarası, görüntü veya diğer tanımlayıcı bilgiler paylaşılamaz. Bu kurallara aykırı içerik yayınlanmaz.',
                ),
                _Section(
                  title: '4. Fikri Mülkiyet',
                  body: 'Platforma yüklediğiniz içerikler size aittir; ancak KONSENXIA\'ya söz konusu içeriği platforma yayınlama, görüntüleme ve hizmet geliştirme amaçlarıyla kullanma lisansı vermiş olursunuz. Platform tasarımı, kodu ve markası KONSENXIA\'nın tescilli mülkiyetidir.',
                ),
                _Section(
                  title: '5. Yapay Zeka Araçları Sorumluluk Reddi',
                  body: 'KONSENXIA AI araçları karar destek sistemleridir. Sağlanan yanıtlar; kesinlikle teşhis, tedavi veya ilaç reçetesi anlamına gelmez. Kullanıcı, klinik kararlarının tüm sorumluluğunu bizzat taşır.',
                ),
                _Section(
                  title: '6. Yasaklı İçerik ve Davranışlar',
                  body: 'Hasta kimliğini açığa çıkaran içerik, yanıltıcı tıbbi bilgi, reklam ve ticari içerik, diğer kullanıcılara yönelik taciz ve hakaret, platform güvenliğini tehdit eden eylemler kesinlikle yasaktır.',
                ),
                _Section(
                  title: '7. Hizmetin Askıya Alınması ve Sonlandırılması',
                  body: 'Koşul ihlali durumunda KONSENXIA, önceden bildirim yapmaksızın hesabınızı geçici olarak askıya alabilir veya kalıcı olarak kapatabilir.',
                ),
                _Section(
                  title: '8. Uygulanacak Hukuk',
                  body: 'Bu sözleşme Türkiye Cumhuriyeti hukukuna tabidir. Uyuşmazlıklarda İstanbul mahkemeleri yetkilidir.',
                ),
                _Section(
                  title: '9. Değişiklikler',
                  body: 'KONSENXIA, kullanım koşullarını önceden bildirim yaparak değiştirme hakkını saklı tutar. Değişiklikler uygulama içi bildirim ve e-posta ile duyurulur.',
                ),

                const SizedBox(height: 16),
                Center(child: Text(
                  'Sorularınız için: legal@konsenxia.com',
                  style: KxTypography.caption.copyWith(color: KxColors.textMuted),
                )),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: KxTypography.labelMd.copyWith(color: KxColors.textPrimary)),
      const SizedBox(height: 6),
      Text(body, style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary, height: 1.6)),
    ]),
  );
}

class _WarningBox extends StatelessWidget {
  final String text;
  const _WarningBox(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: KxColors.amber300.withOpacity(0.08),
      borderRadius: KxSpacing.radiusMd,
      border: Border.all(color: KxColors.amber300.withOpacity(0.3)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.warning_rounded, color: KxColors.amber300, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(text,
          style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary, height: 1.5))),
    ]),
  );
}

class _LegalBadge extends StatelessWidget {
  final String text;
  const _LegalBadge(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: KxColors.bgCard,
      borderRadius: KxSpacing.radiusPill,
      border: Border.all(color: KxColors.border),
    ),
    child: Text(text, style: KxTypography.caption.copyWith(color: KxColors.textMuted)),
  );
}
