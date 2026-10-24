import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Gelişmiş AI Modu
///
/// Diferansiyel tanı asistanı, kanıta dayalı sorgu, ilaç analizi modları.
class AdvancedAiChatPage extends StatefulWidget {
  const AdvancedAiChatPage({super.key});

  @override
  State<AdvancedAiChatPage> createState() => _AdvancedAiChatPageState();
}

class _AdvancedAiChatPageState extends State<AdvancedAiChatPage> {
  _AiMode _mode = _AiMode.differential;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isThinking = false;

  final List<_Message> _messages = [];

  static const _modeLabels = {
    _AiMode.differential: 'Diferansiyel Tanı',
    _AiMode.evidenceBased: 'Kanıta Dayalı',
    _AiMode.drugAnalysis: 'İlaç Analizi',
    _AiMode.caseReview:   'Vaka İnceleme',
  };

  static const _modeIcons = {
    _AiMode.differential: Icons.account_tree_rounded,
    _AiMode.evidenceBased: Icons.science_rounded,
    _AiMode.drugAnalysis: Icons.medication_rounded,
    _AiMode.caseReview:   Icons.folder_open_rounded,
  };

  static const _modeColors = {
    _AiMode.differential: KxColors.teal400,
    _AiMode.evidenceBased: KxColors.blue400,
    _AiMode.drugAnalysis: KxColors.jade300,
    _AiMode.caseReview:   KxColors.amber300,
  };

  static const _modeSuggestions = {
    _AiMode.differential: [
      '45 yaş, ani başlangıçlı göğüs ağrısı, sol kola yayılım',
      'Genç kadın, sabah tutukluğu, küçük eklem tutulumu',
      'Çocuk, ateş + döküntü + boyun sertliği',
    ],
    _AiMode.evidenceBased: [
      'Tip 2 DM yönetiminde SGLT2i vs GLP-1a ilk seçenek mi?',
      'AF\'de antikoagülasyon başlama kriteri nedir?',
      'Statin tedavisinde LDL hedefi ne olmalı?',
    ],
    _AiMode.drugAnalysis: [
      'Warfarin + Flukonazol etkileşimi nasıl yönetilir?',
      'Metformin kronik böbrek hastalığında kullanılır mı?',
      'Semaglutid ile ağırlık kaybı beklentisi nedir?',
    ],
    _AiMode.caseReview: [
      '63 yaşında hipertansiyon + EKG anormalliği olan hastayı incele',
      'Diyabetik nefropati izlem protokolü nedir?',
      'Post-MI hasta taburculuk kriterlerini özetle',
    ],
  };

  // Mock AI responses per mode
  static const _mockResponses = {
    _AiMode.differential: '''**Diferansiyel Tanı Analizi**

Verilen klinik tabloya göre olası tanılar, olasılık sıralamasıyla:

**1. Akut Miyokard İnfarktüsü (STEMI/NSTEMI)** — %38
İskemik ağrı karakteri (sol kola yayılım), risk faktörleri varlığı

**2. Kararsız Anjina** — %22
Efor/istirahat anginal ağrısı, hemodinamik stabilite

**3. Aort Diseksiyonu** — %14
Ani başlangıç, yırtılır nitelikte ağrı — ekarte edilmeli

**4. Pulmoner Emboli** — %10
Dispne, hipoksi, SVT eşlik ediyorsa düşünülmeli

**5. Özofagus Spazmı** — %8
Nitrat yanıtı, yemekle ilişki

---
📋 **Önerilen İlk Adımlar:**
• 12-derivasyon EKG (ilk 10 dk)
• Troponin I/T seri ölçüm (0h, 1h, 3h)
• Göğüs grafisi, D-Dimer gerekirse
• Acil kardiyoloji konsültasyonu''',

    _AiMode.evidenceBased: '''**Kanıta Dayalı Tıp Analizi**

**Güncel Kılavuz Özeti (2024)**

ADA/ESC kılavuzlarına göre Tip 2 DM'de ilk basamak tedavi seçimi:

**SGLT2 İnhibitörü Üstünlükleri:**
✅ KV riski yüksek hastalarda mortalite azaltımı (EMPA-REG, CANVAS)
✅ Kalp yetersizliği hospitalizasyonunu %35 azaltır
✅ Renal koruyucu etki (CREDENCE, DAPA-CKD)

**GLP-1 Agonisti Üstünlükleri:**
✅ Aterosklerotik KV hastalıkta MACE azaltımı (LEADER, SUSTAIN-6)
✅ Kilo kaybı (ortalama −4.5 kg)
✅ HbA1c düşürme kapasitesi yüksek

**Sonuç:** KY veya KBH varsa → SGLT2i öncelikli. Aterosklerotik KVH varsa → GLP-1a veya SGLT2i. Obezite baskın ise → GLP-1a.

📚 *NEJM 2023, Lancet 2024, ADA Standards of Care 2024*''',

    _AiMode.drugAnalysis: '''**İlaç Etkileşim Analizi**

## Warfarin ↔ Flukonazol

**Etkileşim Düzeyi:** 🔴 Majör — Yakın Takip Gerektirir

**Mekanizma:**
Flukonazol güçlü CYP2C9 inhibitörüdür. Warfarin'in S-enantiomeri bu enzim ile metabolize edilir. İnhibisyon sonucu warfarin klerensi ↓, biyoyararlanım ↑, INR yükselir.

**Klinik Sonuç:**
Kombine kullanımda INR değerleri genellikle 2-4 kat artar. Ciddi kanama riski (GI, intrakraniyal).

**Yönetim Önerileri:**
1. Mümkünse alternatif antifungal seç (topikal veya farklı mekanizmalı)
2. Kaçınılmazsa: warfarin dozunu %25-50 azalt
3. INR takibi: başlangıç, 3. gün, 7. gün, tedavi bitiminde
4. Kanama belirtileri konusunda hasta eğitimi

⚠️ *Flukonazol kesildikten sonra da 1-2 hafta INR takibi sürdür.*''',

    _AiMode.caseReview: '''**Vaka İnceleme Özeti**

**Hasta Profili:** 63Y/E — HT, DM Tip 2
**Başvuru:** EKG anormalliği eşlik eden semptom

**Değerlendirme Çerçevesi:**

**1. Aciliyet Triajı**
• Vital bulgular stabil mi? → Hemodinami kontrol
• Aktif semptom (ağrı, dispne)? → Acil müdahale protokolü

**2. EKG İnterpretasyon Rehberi**
• ST elevasyonu ≥1mm ≥2 komşu derivasyon → STEMI protokolü
• LBBB yeni başlangıç → eşdeğer kabul et
• Q dalgaları + T inversiyonu → geçirilmiş MI?

**3. Risk Stratifikasyonu**
HEART skoru hesapla:
H: EKG ● E: Yaş ● A: Risk faktörleri ● R: Troponin ● T: Klinik

**4. İleri Değerlendirme**
• Ekokardiyografi (EF, duvar hareket bozukluğu)
• Stres testi veya koroner anjiyografi endikasyonu?
• Nefroloji konsüle edilmesi gerekiyor mu? (HT + DM → böbrek)''',
  };

  @override
  void initState() {
    super.initState();
    _addSystemMessage();
  }

  void _addSystemMessage() {
    setState(() {
      _messages.add(_Message(
        text: _getModeWelcome(_mode),
        isUser: false,
        mode: _mode,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _getModeWelcome(_AiMode mode) {
    return switch (mode) {
      _AiMode.differential => 'Diferansiyel Tanı Modu etkin. Semptomları, demografiyi ve klinik bulguları paylaşın — olası tanıları olasılık sırasıyla listelerim.',
      _AiMode.evidenceBased => 'Kanıta Dayalı Tıp Modu etkin. Klinik sorunuzu sorun — güncel kılavuzlar ve meta-analizlere dayalı yanıt veririm.',
      _AiMode.drugAnalysis => 'İlaç Analiz Modu etkin. Etkileşim kontrolü, doz optimizasyonu veya farmakoloji soruları için hazırım.',
      _AiMode.caseReview => 'Vaka İnceleme Modu etkin. Hasta vakasını özetleyin — sistematik bir değerlendirme çerçevesi sunayım.',
    };
  }

  void _switchMode(_AiMode newMode) {
    setState(() {
      _mode = newMode;
      _messages.clear();
    });
    _addSystemMessage();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();

    setState(() {
      _messages.add(_Message(text: text, isUser: true, mode: _mode, timestamp: DateTime.now()));
      _isThinking = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    setState(() {
      _isThinking = false;
      _messages.add(_Message(
        text: _mockResponses[_mode] ?? 'Analiz tamamlandı.',
        isUser: false,
        mode: _mode,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _modeColors[_mode]!;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: Column(children: [
        // AppBar
        SafeArea(
          bottom: false,
          child: Container(
            color: KxColors.bgSurface,
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: KxColors.textPrimary, size: 18),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/settings'),
              ),
              Icon(_modeIcons[_mode]!, color: activeColor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Gelişmiş AI', style: KxTypography.headingSm),
                Text(_modeLabels[_mode]!,
                    style: KxTypography.caption.copyWith(color: activeColor)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: KxColors.teal400.withOpacity(0.1),
                  borderRadius: KxSpacing.radiusPill,
                  border: Border.all(color: KxColors.teal400.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: KxColors.teal400, size: 12),
                  const SizedBox(width: 4),
                  Text('AI Pro', style: KxTypography.caption.copyWith(color: KxColors.teal400)),
                ]),
              ),
            ]),
          ),
        ),

        // Mode selector
        Container(
          color: KxColors.bgSurface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: _AiMode.values.map((m) {
              final sel = m == _mode;
              final color = _modeColors[m]!;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _switchMode(m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? color.withOpacity(0.12) : KxColors.bgCard,
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(
                          color: sel ? color.withOpacity(0.5) : KxColors.border),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_modeIcons[m]!, size: 16,
                          color: sel ? color : KxColors.textMuted),
                      const SizedBox(height: 3),
                      Text(
                        _modeLabels[m]!.split(' ').first,
                        style: KxTypography.caption.copyWith(
                            color: sel ? color : KxColors.textMuted,
                            fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ]),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isThinking ? 1 : 0),
            itemBuilder: (_, i) {
              if (_isThinking && i == _messages.length) {
                return _ThinkingBubble(color: activeColor);
              }
              return _MessageBubble(msg: _messages[i]);
            },
          ),
        ),

        // Suggestions
        if (_messages.length <= 1 && !_isThinking)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _modeSuggestions[_mode]!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = _modeSuggestions[_mode]![i];
                return GestureDetector(
                  onTap: () => _send(s),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 240),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: KxColors.bgCard,
                      borderRadius: KxSpacing.radiusPill,
                      border: Border.all(color: KxColors.border),
                    ),
                    child: Text(s,
                        overflow: TextOverflow.ellipsis,
                        style: KxTypography.caption.copyWith(
                            color: KxColors.textSecondary)),
                  ),
                );
              },
            ),
          ),

        // Input bar
        _InputBar(
          controller: _inputCtrl,
          onSend: _send,
          activeColor: activeColor,
          mode: _modeLabels[_mode]!,
        ),
      ]),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────

enum _AiMode { differential, evidenceBased, drugAnalysis, caseReview }

class _Message {
  final String text;
  final bool isUser;
  final _AiMode mode;
  final DateTime timestamp;
  const _Message({
    required this.text,
    required this.isUser,
    required this.mode,
    required this.timestamp,
  });
}

class _MessageBubble extends StatelessWidget {
  final _Message msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: KxColors.teal400.withOpacity(0.15),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: const Radius.circular(14),
              bottomRight: const Radius.circular(4),
            ),
            border: Border.all(color: KxColors.teal400.withOpacity(0.3)),
          ),
          child: Text(msg.text,
              style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary)),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 40),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(14),
            bottomLeft: const Radius.circular(14),
            bottomRight: const Radius.circular(14),
          ),
          border: Border.all(color: KxColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded,
                color: KxColors.teal400, size: 12),
            const SizedBox(width: 4),
            Text('KONSENXIA AI',
                style: KxTypography.caption.copyWith(
                    color: KxColors.teal400, fontSize: 10)),
          ]),
          const SizedBox(height: 8),
          Text(msg.text,
              style: KxTypography.bodyMd.copyWith(
                  color: KxColors.textSecondary, height: 1.6)),
        ]),
      ),
    );
  }
}

class _ThinkingBubble extends StatefulWidget {
  final Color color;
  const _ThinkingBubble({required this.color});

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          FadeTransition(
            opacity: _ctrl,
            child: const Icon(Icons.circle, size: 6, color: KxColors.teal400),
          ),
          const SizedBox(width: 4),
          Text('Analiz ediliyor...',
              style: KxTypography.caption.copyWith(color: KxColors.textMuted)),
        ]),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final Color activeColor;
  final String mode;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.activeColor,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(top: BorderSide(color: KxColors.border)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 4,
            minLines: 1,
            style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
            cursorColor: activeColor,
            decoration: InputDecoration(
              hintText: 'Klinik sorunuzu yazın ($mode)...',
              hintStyle: KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
              filled: true,
              fillColor: KxColors.bgCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: BorderSide(color: KxColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: BorderSide(color: KxColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: BorderSide(color: activeColor, width: 1.5),
              ),
            ),
            onSubmitted: onSend,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => onSend(controller.text),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: KxSpacing.radiusMd,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}
