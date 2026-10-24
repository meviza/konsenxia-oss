import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Destek Merkezi
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  int? _openFaq;
  final _contactCtrl = TextEditingController();
  bool _submitted = false;

  static const _faqs = [
    _Faq(
      q: "KONSENXIA'ya nasıl üye olabilirim?",
      a: "Üyelik yalnızca tıp fakültesi mezunu doktorlara açıktır. Kayıt ekranında diploma numaranız ve uzmanlık bilginizle başvurun; ekibimiz 1-3 iş günü içinde onaylayacaktır.",
    ),
    _Faq(
      q: "Vaka paylaşımında gizlilik nasıl sağlanır?",
      a: "KONSENXIA'da paylaşılan tüm vakalar KVKK ve GDPR gerekliliklerine uygun şekilde anonimleştirilmelidir. Hasta kimliğine dair hiçbir bilgi paylaşılamaz.",
    ),
    _Faq(
      q: "XP puanları nasıl kazanılır?",
      a: "Vaka açma (+50 XP), katkı/yorum (+10 XP), doğru yanıt (+25 XP), vaka onaylanma (+100 XP) işlemleri ile XP kazanırsınız.",
    ),
    _Faq(
      q: "AI asistan hangi kaynaklara dayanır?",
      a: "KONSENXIA AI, PubMed ve güncel klinik kılavuzlara (ESC, ADA, NICE vb.) göre çalışır. Yanıtlar karar destek amaçlıdır, tanı koyamaz.",
    ),
    _Faq(
      q: "Şifremi unuttum, ne yapmalıyım?",
      a: "Giriş ekranında 'Şifremi Unuttum' seçeneğine tıklayın. Kayıtlı e-posta adresinize sıfırlama bağlantısı gönderilecektir.",
    ),
    _Faq(
      q: "Uygulamada hata bildirmek istiyorum.",
      a: "Aşağıdaki formu kullanabilir ya da support@konsenxia.com adresine e-posta gönderebilirsiniz. Ekran görüntüsü eklerseniz daha hızlı çözüm sağlayabiliriz.",
    ),
  ];

  @override
  void dispose() {
    _contactCtrl.dispose();
    super.dispose();
  }

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
            Text('Destek Merkezi', style: KxTypography.headingMd),
            Text('Yardım & İletişim', style: KxTypography.caption.copyWith(color: KxColors.teal400)),
          ]),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Hızlı iletişim
                Row(children: [
                  _QuickCard(icon: Icons.email_rounded, label: 'E-posta', sub: 'support@konsenxia.com', color: KxColors.blue400, onTap: () {}),
                  const SizedBox(width: 10),
                  _QuickCard(icon: Icons.chat_bubble_rounded, label: 'Canlı Destek', sub: 'Pzt-Cum 09-18', color: KxColors.jade300, onTap: () {}),
                  const SizedBox(width: 10),
                  _QuickCard(icon: Icons.video_call_rounded, label: 'Eğitim Video', sub: 'Nasıl kullanılır?', color: KxColors.amber300, onTap: () {}),
                ]),

                const SizedBox(height: 24),

                Text('Sıkça Sorulan Sorular',
                    style: KxTypography.labelMd.copyWith(color: KxColors.textSecondary)),
                const SizedBox(height: 10),

                ...List.generate(_faqs.length, (i) {
                  final faq = _faqs[i];
                  final isOpen = _openFaq == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _openFaq = isOpen ? null : i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: KxColors.bgCard,
                          borderRadius: KxSpacing.radiusMd,
                          border: Border.all(color: isOpen ? KxColors.teal400.withOpacity(0.4) : KxColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(children: [
                                Expanded(child: Text(faq.q, style: KxTypography.labelSm)),
                                Icon(isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                    color: KxColors.textMuted, size: 18),
                              ]),
                            ),
                            if (isOpen)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                child: Text(faq.a,
                                    style: KxTypography.bodyMd.copyWith(
                                        color: KxColors.textSecondary, height: 1.6)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                Text('Bize Yazın', style: KxTypography.labelMd.copyWith(color: KxColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Sorunuzu veya geri bildiriminizi iletin.',
                    style: KxTypography.caption.copyWith(color: KxColors.textMuted)),
                const SizedBox(height: 10),

                if (_submitted)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KxColors.jade300.withOpacity(0.1),
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(color: KxColors.jade300.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded, color: KxColors.jade300, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Mesajınız alındı!', style: KxTypography.labelMd),
                        Text('En kısa sürede dönüş yapacağız.',
                            style: KxTypography.caption.copyWith(color: KxColors.textSecondary)),
                      ])),
                    ]),
                  )
                else ...[
                  KxTextField(
                    controller: _contactCtrl,
                    hint: 'Sorunuzu veya yaşadığınız problemi açıklayın...',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: KxButton(
                      label: 'Gönder',
                      onPressed: () {
                        if (_contactCtrl.text.trim().isNotEmpty) {
                          setState(() => _submitted = true);
                        }
                      },
                      variant: KxButtonVariant.primary,
                      icon: Icons.send_rounded,
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                Center(child: Text('KONSENXIA v1.0.0 — © 2024',
                    style: KxTypography.caption.copyWith(color: KxColors.textMuted))),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({required this.icon, required this.label, required this.sub, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 5),
          Text(label, style: KxTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(sub, style: KxTypography.caption.copyWith(color: KxColors.textMuted, fontSize: 10), textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

class _Faq {
  final String q, a;
  const _Faq({required this.q, required this.a});
}
