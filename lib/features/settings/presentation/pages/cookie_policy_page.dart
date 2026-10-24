import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Cerez Politikasi
class CookiePolicyPage extends StatelessWidget {
  const CookiePolicyPage({super.key});

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
            Text('Cerez Politikasi', style: KxTypography.headingMd),
            Text('Cookie Policy', style: KxTypography.caption.copyWith(color: KxColors.teal400)),
          ]),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegalBadge('Son Guncelleme: 01 Kasim 2024'),
                const SizedBox(height: 20),

                _Section(
                  title: '1. Cerezler Hakkinda',
                  body: 'KONSENXIA uygulamasi ve web sitesi, hizmet kalitesini artirmak, kullanici deneyimini iyilestirmek ve guvenlik saglamak amaciyla cerezler ve benzer teknolojiler kullanmaktadir. Bu politika, hangi cerezleri kullandigimizi ve bunlari nasil yonetebileceginizi aciklar.',
                ),
                _Section(
                  title: '2. Zorunlu Cerezler',
                  body: 'Oturum yonetimi ve kimlik dogrulama icin Firebase Authentication token\'lari kullanilmaktadir. Bu cerezler platformun duzgun calismasi icin zorunludur ve devre disi birakilamaz. Oturum cerezleri, uygulamayi kapattiginizda otomatik olarak silinir.',
                ),
                _Section(
                  title: '3. Analitik Cerezler (Firebase Analytics)',
                  body: 'Platformun kullanimini anlamak ve hizmet kalitesini artirmak icin Firebase Analytics kullanmaktayiz. Bu arac asagidaki verileri anonim olarak toplar:\n\n\u2022 Sayfa/ekran goruntulenme sayilari\n\u2022 Oturum suresi ve kullanim sikligi\n\u2022 Cihaz turu ve isletim sistemi\n\u2022 Uygulama performans metrikleri\n\nBu veriler kisisel kimliginizle iliskilendirilmez ve yalnizca toplu istatistiksel analizler icin kullanilir.',
                ),
                _Section(
                  title: '4. Islevsel Cerezler',
                  body: 'Dil tercihinizi (Turkce/Ingilizce), tema ayarlarinizi, bildirim tercihlerinizi ve son gorulen vaka/icerik bilgilerinizi hatirlamak icin islevsel cerezler kullanilmaktadir. Bu cerezler sayesinde platforma her girisinizdeki tercihleri yeniden ayarlamaniza gerek kalmaz.',
                ),
                _Section(
                  title: '5. Ucuncu Taraf Cerezleri',
                  body: 'Platformumuzda asagidaki ucuncu taraf hizmetleri cerez kullanabilir:\n\n\u2022 Firebase Authentication (Google LLC) — oturum yonetimi\n\u2022 Firebase Analytics (Google LLC) — anonim kullanim istatistikleri\n\u2022 Firebase Cloud Messaging — bildirim hizmetleri\n\nBu hizmet saglayicilarin kendi gizlilik politikalari gecerlidir.',
                ),
                _Section(
                  title: '6. Cerezleri Yonetme',
                  body: 'Analitik cerezlerini uygulama ici ayarlardan (Ayarlar > Gizlilik) devre disi birakabilirsiniz. Tarayicinizin cerez ayarlarindan tum cerezleri engelleyebilir veya silebilirsiniz. Ancak zorunlu cerezlerin engellenmesi durumunda platform duzgun calismayabilir.',
                ),
                _Section(
                  title: '7. Veri Saklama Suresi',
                  body: 'Oturum cerezleri: Oturum sonunda silinir.\nAnalitik verileri: 14 ay boyunca saklanir.\nTercih cerezleri: Hesabiniz aktif oldugu surece saklanir.\nHesap silme talebiniz halinde tum cerez verileri 30 gun icinde kaldirilir.',
                ),
                _Section(
                  title: '8. Iletisim',
                  body: 'Cerez politikamizla ilgili sorulariniz icin: privacy@konsenxia.com',
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: KxColors.teal400.withOpacity(0.06),
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(color: KxColors.teal400.withOpacity(0.25)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.cookie_rounded, color: KxColors.teal400, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Cerez tercihlerinizi istediginiz zaman Ayarlar > Gizlilik bolumunden guncelleyebilirsiniz.',
                      style: KxTypography.caption.copyWith(color: KxColors.teal400, height: 1.5),
                    )),
                  ]),
                ),

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
