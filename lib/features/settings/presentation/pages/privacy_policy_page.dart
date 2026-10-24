import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Gizlilik Politikası
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
            Text('Gizlilik Politikası', style: KxTypography.headingMd),
            Text('Privacy Policy', style: KxTypography.caption.copyWith(color: KxColors.teal400)),
          ]),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegalBadge('Son Güncelleme: 01 Kasım 2024'),
                const SizedBox(height: 20),

                _Section(
                  title: '1. Giriş',
                  body: 'KONSENXIA ("biz", "uygulama") gizliliğinize saygı duyar. Bu politika, uygulamayı kullandığınızda hangi bilgileri topladığımızı, nasıl kullandığımızı ve nasıl koruduğumuzu açıklar.',
                ),
                _Section(
                  title: '2. Topladığımız Bilgiler',
                  body: 'Hesap bilgileri (e-posta, uzmanlık, çalıştığınız kurum), kullanım verileri (paylaştığınız vakalar, AI sorguları, puan geçmişi), cihaz verileri (cihaz modeli, OS sürümü, IP adresi - analitik amaçlı) ve iletişim kayıtları (destek talepleri).',
                ),
                _Section(
                  title: '3. Bilgilerin Kullanımı',
                  body: 'Toplanan bilgiler; platform hizmetini sunmak, kişiselleştirilmiş içerik göstermek, platform güvenliğini sağlamak, hizmet kalitesini artırmak ve yasal yükümlülükleri yerine getirmek amacıyla kullanılır.',
                ),
                _Section(
                  title: '4. Çerezler ve İzleme',
                  body: 'Uygulama, oturum yönetimi için Firebase Authentication token\'ları kullanır. Üçüncü parti analitik araçları (Firebase Analytics) anonim kullanım istatistikleri toplar. Bu toplamanın kapsamını ayarlardan yönetebilirsiniz.',
                ),
                _Section(
                  title: '5. Veri Güvenliği',
                  body: 'Verileriniz Google Cloud altyapısında, AES-256 şifrelemesiyle saklanır. Aktarımlar TLS 1.3 protokolüyle şifrelenir. Düzenli güvenlik denetimleri ve sızma testleri gerçekleştirilmektedir.',
                ),
                _Section(
                  title: '6. Üçüncü Taraf Paylaşımları',
                  body: 'Kişisel verileriniz; satış/kiralama amacıyla hiçbir üçüncü tarafla paylaşılmaz. Yalnızca hizmet sağlayıcılar (Firebase, Stripe) ve yasal zorunluluk halinde yetkili kurumlarla paylaşılır.',
                ),
                _Section(
                  title: '7. Veri Saklama',
                  body: 'Hesabınız aktif olduğu sürece verileriniz saklanır. Hesap silme talebiniz halinde kişisel verileriniz 30 gün içinde, yasal zorunluluk olmaksızın sistememizden kaldırılır.',
                ),
                _Section(
                  title: '8. Çocukların Gizliliği',
                  body: 'KONSENXIA yalnızca 18 yaş ve üzeri tıp uzmanlarına yönelik bir platformdur. Bilerek 18 yaş altı kişilere ait veri toplanmamaktadır.',
                ),
                _Section(
                  title: '9. İletişim',
                  body: 'Gizlilik politikamızla ilgili sorularınız için: privacy@konsenxia.com',
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
