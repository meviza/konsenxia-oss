import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — KVKK Aydınlatma Metni
class KvkkPage extends StatelessWidget {
  const KvkkPage({super.key});

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
            Text('KVKK Aydınlatma Metni', style: KxTypography.headingMd),
            Text('6698 Sayılı Kanun Kapsamında', style: KxTypography.caption.copyWith(color: KxColors.teal400)),
          ]),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegalHeader('Son Güncelleme: 01 Kasım 2024', KxColors.textMuted),
                const SizedBox(height: 20),

                _Section(
                  title: '1. Veri Sorumlusu',
                  body: 'KONSENXIA Sağlık Teknolojileri A.Ş. ("Şirket"), 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") kapsamında veri sorumlusu sıfatıyla hareket etmektedir.',
                ),
                _Section(
                  title: '2. İşlenen Kişisel Veriler',
                  body: 'Kimlik verileri (ad, soyad, diploma numarası), iletişim verileri (e-posta, telefon), mesleki veriler (uzmanlık alanı, çalıştığı kurum), uygulama kullanım verileri (paylaşılan vakalar, XP/puan bilgileri) ve cihaz/teknik veriler işlenmektedir.',
                ),
                _Section(
                  title: '3. Kişisel Verilerin İşlenme Amaçları',
                  body: 'Verileriniz; platform hizmetlerinin sunulması, kimlik doğrulama ve güvenlik, kullanıcı deneyiminin iyileştirilmesi, yasal yükümlülüklerin yerine getirilmesi ve eğitim içeriklerinin geliştirilmesi amaçlarıyla işlenmektedir.',
                ),
                _Section(
                  title: '4. Kişisel Verilerin Aktarılması',
                  body: 'Kişisel verileriniz; sunucu altyapısı (Google Firebase/Cloud), analitik hizmet sağlayıcıları ve yasal zorunluluk halinde kamu kurumları ile paylaşılabilir. Üçüncü ülkelere aktarım KVKK 9. maddesi çerçevesinde gerçekleştirilmektedir.',
                ),
                _Section(
                  title: '5. Kişisel Verilerin Toplanma Yöntemi ve Hukuki Sebebi',
                  body: 'Veriler, uygulama kaydı ve kullanımı sırasında elektronik ortamda toplanmaktadır. İşlemenin hukuki sebepleri: açık rıza, sözleşmenin kurulması/ifası ve veri sorumlusunun meşru menfaatidir.',
                ),
                _Section(
                  title: '6. Kişisel Veri Sahibinin Hakları (Madde 11)',
                  body: 'KVKK 11. maddesi uyarınca aşağıdaki haklara sahipsiniz:\n• Kişisel verilerinizin işlenip işlenmediğini öğrenme\n• İşlenmişse buna ilişkin bilgi talep etme\n• İşlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme\n• Yurt içinde/dışında aktarıldığı üçüncü kişileri öğrenme\n• Eksik/yanlış işlenmişse düzeltilmesini isteme\n• Silinmesini/yok edilmesini isteme\n• Aktarıldığı üçüncü kişilere bildirilmesini isteme\n• İşlenen verilerin otomatik sistemler aracılığıyla aleyhinize sonuç doğurmasına itiraz etme\n• Zarara uğramanız halinde zararın giderilmesini talep etme',
                ),
                _Section(
                  title: '7. Başvuru Yöntemi',
                  body: 'Haklarınızı kullanmak için kvkk@konsenxia.com adresine veya Nişantaşı, İstanbul adresine yazılı başvuruda bulunabilirsiniz. Başvurular 30 gün içinde yanıtlanacaktır.',
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
                    const Icon(Icons.shield_rounded, color: KxColors.teal400, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Verileriniz 256-bit SSL şifrelemesi ve Google Firebase güvenlik altyapısı ile korunmaktadır.',
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

class _LegalHeader extends StatelessWidget {
  final String text;
  final Color color;
  const _LegalHeader(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: KxColors.bgCard,
      borderRadius: KxSpacing.radiusPill,
      border: Border.all(color: KxColors.border),
    ),
    child: Text(text, style: KxTypography.caption.copyWith(color: color)),
  );
}
