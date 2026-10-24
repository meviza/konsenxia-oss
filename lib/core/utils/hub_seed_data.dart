// KONSENXIA — Knowledge Hub Zengin Seed Data (Beta Test)
//
// 16 eğitim vakası, 5 kategori, karışık zorluk seviyeleri.
// Tıbbi içerikler gerçek terminoloji ve klinik bilgi içerir.

/// Zengin Knowledge Hub seed verileri — beta test için 16 eğitim vakası.
const List<Map<String, dynamic>> kHubSeedCases = [
  // ══════════════════════════════════════════════════════════════════
  // KLİNİK İNCİ (Clinical Pearls) — 4 vaka
  // ══════════════════════════════════════════════════════════════════
  {
    'id': 'hub_cp_001',
    'title': 'Gizli Hipotiroidi: TSH Normal Olsa Bile Dikkat!',
    'abstract':
        'Subklinik hipotiroidizm tanısında TSH tek başına yetersiz kalabilir. '
            'Özellikle serbest T4 düşüklüğü ve anti-TPO pozitifliği eşlik ediyorsa, '
            'klinik bulgular dikkatle değerlendirilmelidir.',
    'content':
        'Subklinik hipotiroidizm, TSH düzeyinin referans aralığının üst sınırında '
            'veya hafif yüksek olmasıyla karakterize, serbest T4\'ün genellikle normal '
            'sınırlarda kaldığı bir durumdur. Ancak klinisyenler sıklıkla "TSH normal, '
            'hasta ötiroidi" yaklaşımına kapılarak önemli ipuçlarını kaçırabilir.\n\n'
            'Klinik pratikte dikkat edilmesi gereken durumlar şunlardır: Birincisi, '
            'TSH\'nın 2.5-4.5 mIU/L arasında olduğu "gri zon" hastalarında anti-TPO '
            've anti-tiroglobulin antikorları mutlaka bakılmalıdır. Antikor pozitifliği, '
            'Hashimoto tiroiditinin erken evrelerine işaret edebilir. İkincisi, gebelik '
            'planlayan kadınlarda TSH eşik değeri 2.5 mIU/L olarak kabul edilmeli ve '
            'trimestere özgü referans aralıkları kullanılmalıdır.\n\n'
            'Üçüncü önemli nokta, yaşlı hastalarda hafif TSH yüksekliğinin her zaman '
            'tedavi gerektirmediğidir. 70 yaş üstü bireylerde TSH\'nın 4.5-7.0 mIU/L '
            'arasında olması fizyolojik kabul edilebilir. Ancak semptomlar belirginse '
            '(kronik yorgunluk, kabızlık, kilo artışı, bradikardi), düşük doz '
            'levotiroksin başlanması düşünülmelidir.\n\n'
            'Pratik ipucu: Anti-TPO pozitif subklinik hipotiroidili hastalarda yıllık '
            '%4.3 oranında aşikar hipotiroidiye progresyon riski vardır. Bu nedenle '
            '6 aylık aralıklarla TSH ve sT4 takibi önerilmektedir. Gebelik, '
            'kardiyovasküler risk faktörleri ve semptom varlığında tedavi eşiği '
            'düşürülmelidir.',
    'category': 'clinical_pearl',
    'specialty': 'Endokrinoloji',
    'difficulty': 'intermediate',
    'authorId': 'doc_prof_ayse',
    'authorName': 'Prof. Dr. Selin Aksoy',
    'authorSpecialty': 'Endokrinoloji',
    'tags': ['Hipotiroidi', 'TSH', 'Hashimoto', 'Tiroid', 'Subklinik'],
    'searchTokens': [
      'hipotiroidi', 'tsh', 'hashimoto', 'tiroid', 'subklinik',
      'anti-tpo', 'levotiroksin', 'endokrinoloji',
    ],
    'likeCount': 134,
    'viewCount': 578,
    'commentCount': 28,
    'isPinned': true,
    'isApproved': true,
  },
  {
    'id': 'hub_cp_002',
    'title': 'Akut Batında Kaçırılan İpucu: Mezenterik İskemi',
    'abstract':
        'Akut mezenterik iskemi, erken tanı konulamadığında mortalitesi %60-80\'e '
            'ulaşan acil bir vasküler tablodur. "Fizik muayene ile orantısız ağrı" '
            'en önemli klinik ipucudur.',
    'content':
        'Akut mezenterik iskemi (AMİ), mezenterik damarların tromboz veya emboli '
            'ile tıkanması sonucu bağırsak duvarında iskemik hasar gelişmesidir. '
            'Superior mezenterik arter (SMA) embolisi en sık nedendir (%50) ve '
            'genellikle atriyal fibrilasyon zemininde gelişir.\n\n'
            'AMİ\'nin en kritik tanı ipucu "fizik muayene bulgularıyla orantısız '
            'karın ağrısı"dır. Hasta şiddetli karın ağrısından yakınırken, erken '
            'dönemde batın muayenesi şaşırtıcı derecede yumuşak olabilir. Bu '
            'uyumsuzluk (pain-out-of-proportion), klinisyeni AMİ yönünden '
            'uyarmalıdır. İleri dönemde peritonit bulguları gelişir ancak bu '
            'aşamada transmural nekroz genellikle başlamıştır.\n\n'
            'Laboratuvar bulguları arasında laktik asidoz, lökositoz ve D-dimer '
            'yüksekliği tanıyı destekler. Kesin tanı BT anjiyografi ile konulur. '
            'BT anjiyografide SMA veya dallarında dolma defekti, bağırsak duvarında '
            'kalınlaşma veya pnömatozis intestinalis görülebilir.\n\n'
            'Tedavide altın standart erken cerrahi müdahale veya endovasküler '
            'revaskülarizasyondur. Sıvı resüsitasyonu, geniş spektrumlu antibiyotik '
            've antikoagülasyon başlanmalıdır. Geciken tanı nekroz ve perforasyon ile '
            'sonuçlanır. Pratik mesaj: AF\'li bir hastada ani başlayan karın ağrısında, '
            'batın muayenesi normal olsa bile AMİ mutlaka düşünülmelidir.',
    'category': 'clinical_pearl',
    'specialty': 'Genel Cerrahi',
    'difficulty': 'advanced',
    'authorId': 'doc_uzm_mehmet',
    'authorName': 'Doç. Dr. Burak Yıldırım',
    'authorSpecialty': 'Genel Cerrahi',
    'tags': ['Mezenterik İskemi', 'Akut Batın', 'SMA Embolisi', 'Cerrahi Acil'],
    'searchTokens': [
      'mezenterik', 'iskemi', 'akut batın', 'sma', 'emboli',
      'cerrahi', 'laktik asidoz', 'bt anjiyografi',
    ],
    'likeCount': 98,
    'viewCount': 423,
    'commentCount': 19,
    'isPinned': false,
    'isApproved': true,
  },
  {
    'id': 'hub_cp_003',
    'title': 'Pediatrik Ateşte Kawasaki Hastalığı Tanı Kriterleri',
    'abstract':
        'Kawasaki hastalığı, 5 yaş altı çocuklarda edinsel kalp hastalığının en sık '
            'nedenidir. Erken tanı ve IVIG tedavisi koroner arter anevrizması riskini '
            '%25\'ten %4\'e düşürür.',
    'content':
        'Kawasaki hastalığı, orta çaplı arterleri etkileyen akut bir vaskülittir ve '
            'özellikle koroner arterleri tutarak anevrizma oluşumuna yol açabilir. '
            'En sık 6 ay-5 yaş arasında görülür ve erkek çocuklarda 1.5 kat daha '
            'sıktır.\n\n'
            'Klasik tanı kriterleri (5 günden uzun süren ateş + aşağıdakilerden 4\'ü):\n'
            '1. Bilateral konjunktival enjeksiyon (eksüda olmadan)\n'
            '2. Oral mukoza değişiklikleri (çilek dili, dudak çatlağı)\n'
            '3. Ekstremite değişiklikleri (el/ayak ödemi, periungual deskuamasyon)\n'
            '4. Polimorf döküntü\n'
            '5. Servikal lenfadenopati (≥1.5 cm, genellikle unilateral)\n\n'
            'İnkomplet Kawasaki\'de tanı kriterleri tam karşılanmaz ancak 5 günden '
            'uzun ateş + 2-3 kriter varsa ve CRP ≥30 mg/L veya ESR ≥40 mm/saat ise '
            'ekokardiyografi yapılmalıdır. Koroner arter dilatasyonu veya Z-skoru ≥2.5 '
            'saptanırsa tedavi başlanmalıdır.\n\n'
            'Tedavide IVIG 2 g/kg tek doz + yüksek doz aspirin (80-100 mg/kg/gün) '
            'ilk 10 gün içinde verilmelidir. Ateş düştükten sonra aspirin düşük doza '
            '(3-5 mg/kg/gün) geçilir. IVIG dirençli vakalarda (%10-15) ikinci doz '
            'IVIG veya infliksimab düşünülmelidir.\n\n'
            'Kritik uyarı: 6 ay altında ve 9 yaş üstünde atipik prezentasyon daha '
            'sıktır. Bu yaş gruplarında açıklanamayan uzamış ateşte Kawasaki akılda '
            'tutulmalı ve ekokardiyografi geciktirilmemelidir.',
    'category': 'clinical_pearl',
    'specialty': 'Pediatri',
    'difficulty': 'intermediate',
    'authorId': 'doc_asist_elif',
    'authorName': 'Uzm. Dr. Zeynep Koç',
    'authorSpecialty': 'Pediatri',
    'tags': ['Kawasaki', 'Pediatri', 'Vaskülit', 'Koroner Anevrizma', 'IVIG'],
    'searchTokens': [
      'kawasaki', 'pediatri', 'vaskülit', 'koroner', 'anevrizma',
      'ivig', 'ateş', 'çocuk',
    ],
    'likeCount': 156,
    'viewCount': 612,
    'commentCount': 31,
    'isPinned': true,
    'isApproved': true,
  },
  {
    'id': 'hub_cp_004',
    'title': 'Troponin Yüksekliğinde AKS Dışı Nedenler',
    'abstract':
        'Yüksek hassasiyetli troponin testleri AKS tanısını kolaylaştırırken, '
            'AKS dışı nedenlerin tanınması gereksiz invaziv girişimleri önler. '
            'Tip 2 MI ve miyokardiyal hasar ayrımı kritik önem taşır.',
    'content':
        'Yüksek hassasiyetli kardiyak troponin (hs-cTn) testleri, miyokardiyal '
            'hasarı pikomolar düzeyde tespit edebilmektedir. Ancak bu yüksek duyarlılık, '
            'AKS dışı pek çok durumda da troponin yüksekliğine yol açarak klinisyenleri '
            'yanıltabilir.\n\n'
            'AKS dışı troponin yüksekliğinin başlıca nedenleri:\n'
            '• Kardiyak nedenler: Miyokardit, perikardit, kalp yetersizliği '
            'dekompanzasyonu, takotsubo kardiyomiyopatisi, aort diseksiyonu, '
            'kardiyoversiyon sonrası, ablasyon sonrası\n'
            '• Non-kardiyak nedenler: Pulmoner emboli, sepsis/septik şok, kronik '
            'böbrek yetmezliği (GFR <30), rabdomiyoliz, serebrovasküler olaylar '
            '(özellikle SAK), yanıklar, kemoterapi ilişkili kardiyotoksisite\n\n'
            'Tip 1 MI (plak rüptürü) ile Tip 2 MI (oksijen arz-talep dengesizliği) '
            'ayrımı tedavi yaklaşımını temelden değiştirir. Tip 2 MI\'da altta yatan '
            'nedenin tedavisi esastır; rutin koroner anjiyografi endike değildir. '
            'Seri troponin ölçümünde yükselme-düşme (rise-fall) paterni AKS\'yi '
            'desteklerken, stabil düzeyde kalan yükseklik kronik miyokardiyal hasarı '
            'düşündürür.\n\n'
            'Pratik algoritma: Troponin yüksekliği saptandığında, EKG değişiklikleri '
            've klinik tablo birlikte değerlendirilmelidir. İskemik semptom yoksa, EKG '
            'normal veya değişiksizse ve troponin seyri stabil ise, AKS dışı nedenler '
            'öncelikli olarak araştırılmalıdır. Ekokardiyografi, bölgesel duvar hareket '
            'kusuru değerlendirmesi için erken dönemde yapılmalıdır.',
    'category': 'clinical_pearl',
    'specialty': 'Kardiyoloji',
    'difficulty': 'intermediate',
    'authorId': 'doc_prof_ayse',
    'authorName': 'Prof. Dr. Ayşe Yılmaz',
    'authorSpecialty': 'Kardiyoloji',
    'tags': ['Troponin', 'AKS', 'Miyokardiyal Hasar', 'Tip 2 MI', 'Kardiyoloji'],
    'searchTokens': [
      'troponin', 'aks', 'miyokard', 'hasar', 'tip 2 mi',
      'kardiyoloji', 'miyokardit', 'pulmoner emboli',
    ],
    'likeCount': 189,
    'viewCount': 734,
    'commentCount': 42,
    'isPinned': false,
    'isApproved': true,
  },

  // ══════════════════════════════════════════════════════════════════
  // NADİR HASTALIK (Rare Disease) — 3 vaka
  // ══════════════════════════════════════════════════════════════════
  {
    'id': 'hub_rd_001',
    'title': 'Erdheim-Chester Hastalığı: Kemik Ağrısı ve Çoklu Organ Tutulumu',
    'abstract':
        'Erdheim-Chester hastalığı, non-Langerhans hücreli histiyositozların '
            'nadir bir formudur. Simetrik uzun kemik tutulumu ve çoklu organ '
            'infiltrasyonu ile karakterizedir.',
    'content':
        'Erdheim-Chester Hastalığı (ECH), lipid yüklü histiyositlerin çeşitli '
            'dokulara infiltrasyonu ile karakterize, nadir görülen bir non-Langerhans '
            'hücreli histiyositozdur. Dünya genelinde yaklaşık 800-1000 olgu '
            'bildirilmiştir. Ortalama tanı yaşı 53\'tür ve erkeklerde hafif '
            'predileksiyon gösterir.\n\n'
            'Klinik prezentasyon son derece heterojendir. En sık bulgu, uzun '
            'kemiklerin diafiz ve metafizlerinde bilateral simetrik osteoskleroz '
            'ile kendini gösteren kemik ağrısıdır (%95). Retroperitoneal '
            'fibrozis (%30), perikardiyal efüzyon, perirenal yağlı doku '
            'infiltrasyonu ("hairy kidney" görünümü), ekzoftalmus ve diabetes '
            'insipidus diğer sık tutulum alanlarıdır.\n\n'
            'Tanıda direkt grafi ve BT\'de uzun kemiklerin bilateral simetrik '
            'osteosklerozu patognomoniktir. PET-BT tutulum yaygınlığını '
            'değerlendirmede altın standarttır. Biyopside CD68(+), CD1a(-), '
            'S100(-) köpüksü histiyositler görülür. Hastaların %50-70\'inde BRAF '
            'V600E mutasyonu saptanır.\n\n'
            'Tedavide BRAF V600E pozitif hastalarda vemurafenib ilk basamak tedavi '
            'olarak önerilmektedir. BRAF negatif hastalarda MEK inhibitörleri '
            '(cobimetinib, trametinib) veya interferon-alfa kullanılabilir. Prognoz, '
            'organ tutulumunun yaygınlığına bağlıdır; kardiyovasküler ve SSS tutulumu '
            'kötü prognostik faktörlerdir.\n\n'
            'Önemli mesaj: Açıklanamayan kemik ağrısı, retroperitoneal fibrozis ve '
            'diabetes insipidus birlikteliğinde ECH mutlaka düşünülmelidir.',
    'category': 'rare_disease',
    'specialty': 'Hematoloji',
    'difficulty': 'advanced',
    'authorId': 'doc_uzm_mehmet',
    'authorName': 'Prof. Dr. Hakan Türkmen',
    'authorSpecialty': 'Hematoloji',
    'tags': ['Erdheim-Chester', 'Histiyositoz', 'Nadir Hastalık', 'BRAF', 'Osteoskleroz'],
    'searchTokens': [
      'erdheim', 'chester', 'histiyositoz', 'nadir', 'braf',
      'osteoskleroz', 'hematoloji', 'retroperitoneal',
    ],
    'likeCount': 67,
    'viewCount': 289,
    'commentCount': 14,
    'isPinned': false,
    'isApproved': true,
  },
  {
    'id': 'hub_rd_002',
    'title': 'Pheochromocytoma Krizi: Tanı ve Acil Yönetim',
    'abstract':
        'Feokromositoma krizi, katekolamin deşarjına bağlı hipertansif acil, '
            'kardiyak aritmi ve multi-organ yetmezliği ile sonuçlanabilir. '
            'Alfa-blokaj tedavinin temel taşıdır.',
    'content':
        'Feokromositoma, adrenal medulla kromafin hücrelerinden kaynaklanan, '
            'katekolamin salgılayan nadir bir nöroendokrin tümördür. İnsidansı '
            'yılda 2-8/milyon\'dur. Vakaların %10\'u bilateral, %10\'u ekstra-adrenal '
            '(paraganglioma), %10\'u malign ve %25-35\'i herediter sendromlarla '
            'ilişkilidir (MEN2, VHL, NF1, SDH mutasyonları).\n\n'
            'Kriz prezentasyonu: Paroksismal hipertansiyon (>200/120 mmHg), '
            'şiddetli baş ağrısı, terleme ve taşikardi klasik triadıdır. '
            'Tetikleyiciler arasında anestezi indüksiyonu, metoklopramid, '
            'kortikosteroidler, tiramin içeren gıdalar ve tümöre mekanik bası '
            'sayılabilir. Kriz sırasında takotsubo benzeri kardiyomiyopati, '
            'pulmoner ödem ve inme gelişebilir.\n\n'
            'Acil yönetim: İlk adım IV fentolaminin (alfa-blokör) bolus dozudur '
            '(2.5-5 mg, her 5 dakikada tekrarlanabilir). Nitroprussid infüzyonu '
            'alternatif olarak kullanılabilir. KRİTİK UYARI: Beta-blokör asla '
            'alfa-blokajdan önce verilmemelidir; karşılanmamış alfa-stimülasyon '
            'paradoksal hipertansif krize yol açar.\n\n'
            'Preoperatif hazırlık: Cerrahi öncesi en az 10-14 gün fenoksibenzamin '
            '(10 mg 2x1, titre edilerek) veya doksazosin başlanmalıdır. Yeterli '
            'alfa-blokaj sağlandıktan sonra refleks taşikardi kontrolü için '
            'beta-blokör eklenebilir. Yüksek tuzlu diyet ve sıvı replasmanı ile '
            'intravasküler volüm genişletilmelidir.\n\n'
            'Kural: "Alpha before beta, never the reverse."',
    'category': 'rare_disease',
    'specialty': 'Endokrinoloji',
    'difficulty': 'advanced',
    'authorId': 'doc_prof_ayse',
    'authorName': 'Prof. Dr. Selin Aksoy',
    'authorSpecialty': 'Endokrinoloji',
    'tags': ['Feokromositoma', 'Hipertansif Kriz', 'Alfa-Blokaj', 'Katekolamin', 'MEN2'],
    'searchTokens': [
      'feokromositoma', 'pheochromocytoma', 'kriz', 'hipertansif',
      'alfa-blokaj', 'katekolamin', 'men2', 'fentolamin',
    ],
    'likeCount': 112,
    'viewCount': 467,
    'commentCount': 26,
    'isPinned': true,
    'isApproved': true,
  },
  {
    'id': 'hub_rd_003',
    'title': 'Amiloidoz: Kardiyak Tutulumda Erken Tanının Önemi',
    'abstract':
        'Kardiyak amiloidoz, restriktif kardiyomiyopatinin önemli bir nedenidir. '
            'Ekokardiyografide artmış duvar kalınlığı ve "granular sparkling" paterni '
            'tanısal ipucu verir.',
    'content':
        'Amiloidoz, yanlış katlanmış proteinlerin çözünmeyen fibriller halinde '
            'dokularda birikmesiyle karakterize sistemik bir hastalıktır. Kardiyak '
            'tutulum en sık AL (hafif zincir) ve ATTR (transthyretin) tiplerinde '
            'görülür. ATTR amiloidoz, özellikle 65 yaş üstü erkeklerde düşünülenden '
            'çok daha sık olup, HFpEF olgularının %13-16\'sını oluşturur.\n\n'
            'Klinik prezentasyon: Egzersiz intoleransı, dispne, periferik ödem ve '
            'atriyal fibrilasyon sıktır. Bilateral karpal tünel sendromu, spinal '
            'stenoz ve otonom nöropati (ortostatik hipotansiyon) yıllar öncesinden '
            'başlayabilir ve tanı için önemli ipuçlarıdır. EKG\'de düşük voltaj '
            'veya psödoinfarktüs paterni (Q dalgaları) görülebilir.\n\n'
            'Tanı yaklaşımı: Ekokardiyografide konsantrik sol ventrikül hipertrofisi, '
            'biatiyal dilatasyon, restriktif doluş paterni ve "granular sparkling" '
            'amiloidoz düşündürür. Kardiyak MR\'da karakteristik geç gadolinyum '
            'tutulumu (subendokardiyal, diffüz) tanıyı güçlü şekilde destekler. '
            'ATTR amiloidoz için Tc-99m pirofosfat sintigrafisi non-invaziv tanı '
            'imkanı sunar (Grade 2-3 tutulum tanısaldır).\n\n'
            'AL amiloidozda serum serbest hafif zincir oranı, serum ve idrar '
            'immünfiksasyon elektroforezi ve kemik iliği biyopsisi tanısal '
            'algoritmada yer alır. Tedavide AL amiloidoz için bortezomib bazlı '
            'kemoterapi ve daratumumab kombinasyonu, ATTR için tafamidis '
            '(transthyretin stabilizatörü) kullanılmaktadır.\n\n'
            'Erken tanı hayat kurtarır: Açıklanamayan HFpEF + sol ventrikül '
            'duvar kalınlığı >12 mm + düşük voltajlı EKG kombinasyonunda '
            'kardiyak amiloidoz mutlaka dışlanmalıdır.',
    'category': 'rare_disease',
    'specialty': 'Kardiyoloji',
    'difficulty': 'advanced',
    'authorId': 'doc_prof_ayse',
    'authorName': 'Prof. Dr. Ayşe Yılmaz',
    'authorSpecialty': 'Kardiyoloji',
    'tags': ['Amiloidoz', 'ATTR', 'Kardiyomiyopati', 'Restriktif', 'Tafamidis'],
    'searchTokens': [
      'amiloidoz', 'attr', 'kardiyomiyopati', 'restriktif',
      'tafamidis', 'granular sparkling', 'transthyretin',
    ],
    'likeCount': 145,
    'viewCount': 523,
    'commentCount': 33,
    'isPinned': false,
    'isApproved': true,
  },

  // ══════════════════════════════════════════════════════════════════
  // TANI TUZAĞI (Diagnostic Pitfall) — 3 vaka
  // ══════════════════════════════════════════════════════════════════
  {
    'id': 'hub_dp_001',
    'title': 'Pulmoner Emboli Taklit Eden Pnömotoraks',
    'abstract':
        'Ani başlayan dispne ve göğüs ağrısında pulmoner emboli ön tanısıyla '
            'antikoagülasyon başlanmadan önce pnömotoraks mutlaka dışlanmalıdır. '
            'PA akciğer grafisi hayat kurtarıcı olabilir.',
    'content':
        'Acil servise ani başlayan dispne ve plöretik göğüs ağrısı ile başvuran '
            'hastalarda PE en sık düşünülen tanılar arasındadır. Ancak spontan '
            'pnömotoraks, özellikle uzun boylu, astenik genç erkeklerde ve KOAH\'lı '
            'yaşlı hastalarda benzer klinik tablo oluşturabilir.\n\n'
            'Tuzak senaryo: 28 yaşında, uzun boylu erkek hasta, ani başlayan sağ '
            'yan ağrısı ve nefes darlığıyla başvuruyor. Taşikardi (110/dk), '
            'takipne (24/dk) ve hafif hipoksi (SpO2 %92) mevcut. Wells skoru '
            'hesaplanıyor, D-dimer isteniyor. D-dimer yüksek çıkıyor (pnömotoraksta '
            'da yükselebilir!) ve BT pulmoner anjiyografi planlanıyor.\n\n'
            'Bu yaklaşımdaki kritik hata: PA akciğer grafisi çekilmeden ileri '
            'tetkike geçilmesidir. Oysa basit bir PA grafide sağda apikal '
            'pnömotoraks kolaylıkla saptanabilirdi. Daha da tehlikelisi, '
            'pnömotoraks varlığında antikoagülasyon başlanması kanama riskini '
            'artırır. Tansiyon pnömotoraksa progresyon durumunda heparin altındaki '
            'hasta için durum hayati tehlike oluşturur.\n\n'
            'Ayırıcı tanı ipuçları:\n'
            '• Pnömotoraks: Etkilenen tarafta solunum seslerinde azalma, '
            'hiperrezonans, trakeal deviasyon (tansiyon)\n'
            '• PE: Genellikle bilateral solunum sesleri korunur, S1Q3T3 EKG '
            'paterni, alt ekstremite ödemi/DVT bulguları\n\n'
            'Pratik kural: Ani dispne + göğüs ağrısında BT istemeden önce PA '
            'akciğer grafisi çekmek hem pnömotoraksı dışlar hem de zaman kazandırır.',
    'category': 'diagnostic_pitfall',
    'specialty': 'Acil Tıp',
    'difficulty': 'beginner',
    'authorId': 'doc_asist_elif',
    'authorName': 'Uzm. Dr. Can Özdemir',
    'authorSpecialty': 'Acil Tıp',
    'tags': ['Pnömotoraks', 'Pulmoner Emboli', 'Tanı Tuzağı', 'Acil', 'Dispne'],
    'searchTokens': [
      'pnömotoraks', 'pulmoner emboli', 'tanı tuzağı', 'dispne',
      'acil', 'göğüs ağrısı', 'antikoagülasyon',
    ],
    'likeCount': 203,
    'viewCount': 867,
    'commentCount': 47,
    'isPinned': false,
    'isApproved': true,
  },
  {
    'id': 'hub_dp_002',
    'title': 'Apandisit Gibi Başlayan Mezenterik Lenfadenit',
    'abstract':
        'Çocuk ve genç erişkinlerde sağ alt kadran ağrısında mezenterik lenfadenit, '
            'gereksiz apendektomilerin önemli bir nedenidir. USG ve BT bulguları '
            'ayırıcı tanıda yol göstericidir.',
    'content':
        'Mezenterik lenfadenit, mezenterik lenf nodlarının enflamasyonu olup genellikle '
            'viral bir üst solunum yolu enfeksiyonunu takiben gelişir. Özellikle 5-15 '
            'yaş grubunda sık görülür ve akut apandisiti taklit ederek gereksiz '
            'cerrahiye neden olabilir. Negatif apendektomi oranlarının %15-20\'sinden '
            'mezenterik lenfadenit sorumlu tutulmaktadır.\n\n'
            'Klinik benzerlikler: Her iki durumda da sağ alt kadran ağrısı, ateş, '
            'bulantı ve lökositoz görülebilir. Rebound hassasiyeti mezenterik '
            'lenfadenitte genellikle daha hafif ve diffüzdür. Önemli fark olarak '
            'mezenterik lenfadenitte ağrı genellikle göbek çevresinden başlayıp '
            'sağ alt kadrana lokalize olmaz; ağrı yeri değişkendir.\n\n'
            'Tanısal ipuçları:\n'
            '• Öncesinde ÜSYE öyküsü (boğaz ağrısı, burun akıntısı)\n'
            '• Ağrının sabit bir noktada lokalize olmaması\n'
            '• USG\'de apendiks normal çapta (<6 mm), sağ alt kadranda büyümüş '
            'birden fazla lenf nodu (>5 mm kısa aks)\n'
            '• BT\'de normal apendiks, terminal ileum çevresinde büyümüş '
            'mezenterik lenf nodları, periçekal yağ planının korunmuş olması\n\n'
            'Tedavi: Mezenterik lenfadenit self-limited bir durumdur. Semptomatik '
            'tedavi (analjezi, hidrasyon) yeterlidir. Ancak ilk 24 saatte klinik '
            'kötüleşme olursa apandisit ihtimali yeniden değerlendirilmelidir.\n\n'
            'Altın kural: Çocuklarda sağ alt kadran ağrısında ÜSYE öyküsü varsa, '
            'cerrahiye karar vermeden önce USG ile apendiks görüntülenmeli ve '
            'mezenterik lenf nodları değerlendirilmelidir.',
    'category': 'diagnostic_pitfall',
    'specialty': 'Pediatri',
    'difficulty': 'beginner',
    'authorId': 'doc_asist_elif',
    'authorName': 'Dr. Elif Demir',
    'authorSpecialty': 'Dahiliye',
    'tags': ['Mezenterik Lenfadenit', 'Apandisit', 'Pediatri', 'Tanı Tuzağı', 'USG'],
    'searchTokens': [
      'mezenterik', 'lenfadenit', 'apandisit', 'pediatri',
      'tanı tuzağı', 'sağ alt kadran', 'usg',
    ],
    'likeCount': 176,
    'viewCount': 698,
    'commentCount': 38,
    'isPinned': false,
    'isApproved': true,
  },
  {
    'id': 'hub_dp_003',
    'title': 'Diyabetik Ketoasidozda Gözden Kaçan Enfeksiyon Odağı',
    'abstract':
        'DKA\'nın tetikleyicisi olarak enfeksiyon %30-50 oranında saptanır. '
            'Hipergliseminin maskelediği enfeksiyon bulguları gözden kaçabilir '
            've mortaliteyi önemli ölçüde artırır.',
    'content':
        'Diyabetik ketoasidoz (DKA), tip 1 ve ileri tip 2 diyabette görülen metabolik '
            'bir acildir. DKA\'nın en sık tetikleyicisi enfeksiyonlardır (%30-50) ve '
            'enfeksiyon odağının saptanamaması tedavi başarısızlığının önemli bir '
            'nedenidir.\n\n'
            'Enfeksiyonun maskelenmesi: DKA\'da hiperglisemiye bağlı osmotik diürez '
            'dehidratasyona, asidoz kompansatuvar hiperventilasyona (Kussmaul '
            'solunumu) yol açar. Bu bulgular enfeksiyonun ateş, taşikardi ve '
            'takipne gibi klasik bulgularını maskeler. DKA\'lı hastalarda lökosit '
            'sayısı enfeksiyon olmaksızın da 15.000-25.000/mm³\'e ulaşabilir '
            '(stres lökositozu). Bu durum enfeksiyon değerlendirmesini zorlaştırır.\n\n'
            'Gözden kaçan enfeksiyon odakları:\n'
            '• Üriner sistem enfeksiyonları (özellikle kadınlarda; kateterizasyon '
            'öncesi idrar kültürü mutlaka alınmalı)\n'
            '• Diyabetik ayak enfeksiyonları (ayak muayenesi her DKA hastasında yapılmalı)\n'
            '• Perineal/perianal apseler (fournier gangreni riski yüksek)\n'
            '• Mukormikoz (rinoserebal; DKA zemininde klasik prezentasyon)\n'
            '• Amfizematöz pyelonefrit ve amfizematöz kolesistit\n\n'
            'Pratik yaklaşım: Her DKA hastasında standart enfeksiyon taraması '
            'yapılmalıdır: Kan kültürü (2 set), idrar kültürü, akciğer grafisi, '
            'ayak muayenesi. CRP ve prokalsitonin takibi enfeksiyöz tetikleyiciyi '
            'stres yanıtından ayırmada yardımcıdır (prokalsitonin >0.5 ng/mL '
            'bakteriyel enfeksiyonu destekler).\n\n'
            'Uyarı: DKA düzeldikten sonra ateş devam ediyorsa veya metabolik asidoz '
            'beklenenden yavaş düzeliyorsa, derin enfeksiyon odağı (apse, '
            'osteomiyelit) için ileri görüntüleme yapılmalıdır.',
    'category': 'diagnostic_pitfall',
    'specialty': 'Dahiliye',
    'difficulty': 'intermediate',
    'authorId': 'doc_asist_elif',
    'authorName': 'Doç. Dr. Merve Aydın',
    'authorSpecialty': 'Dahiliye',
    'tags': ['DKA', 'Enfeksiyon', 'Diyabet', 'Tanı Tuzağı', 'Mukormikoz'],
    'searchTokens': [
      'dka', 'ketoasidoz', 'enfeksiyon', 'diyabet', 'tanı tuzağı',
      'mukormikoz', 'prokalsitonin', 'dahiliye',
    ],
    'likeCount': 132,
    'viewCount': 521,
    'commentCount': 29,
    'isPinned': false,
    'isApproved': true,
  },

  // ══════════════════════════════════════════════════════════════════
  // VAKA SERİLERİ (Case Series) — 3 vaka
  // ══════════════════════════════════════════════════════════════════
  {
    'id': 'hub_cs_001',
    'title': 'COVID-19 Sonrası Kardiyak Komplikasyonlar: 5 Vaka Serisi',
    'abstract':
        'COVID-19 sonrası miyokardit, perikardit ve aritmiler bildirilmektedir. '
            'Bu vaka serisinde 5 hastanın kardiyak komplikasyonları ve tedavi '
            'yanıtları sunulmaktadır.',
    'content':
        'SARS-CoV-2 enfeksiyonu, akut dönemde ve post-COVID sürecinde çeşitli '
            'kardiyak komplikasyonlara yol açabilmektedir. Bu vaka serisinde COVID-19 '
            'sonrası kardiyak tutulum gelişen 5 hasta sunulmaktadır.\n\n'
            'Vaka 1 (34/E): COVID-19 sonrası 3. haftada göğüs ağrısı ve ST '
            'değişiklikleri. Troponin: 2.8 ng/mL. Kardiyak MR: subepikardiyel '
            'geç gadolinyum tutulumu. Tanı: Akut miyokardit. NSAİİ ve kolşisin '
            'ile 6 haftada tam iyileşme.\n\n'
            'Vaka 2 (56/K): Hastane taburculuğundan 10 gün sonra çarpıntı. '
            'Holter: Yeni başlangıçlı AF. Ekokardiyografi: EF %55, sol atriyal '
            'dilatasyon. Rate kontrol + antikoagülasyon başlandı.\n\n'
            'Vaka 3 (42/E): 2. ayda egzersiz dispnesi. Ekokardiyografi: EF %35, '
            'global hipokinezi. Kardiyak MR: Yaygın miyokardiyal ödem ve fibrozis. '
            'Tanı: Post-COVID dilate kardiyomiyopati. ACEi + beta-blokör + '
            'MRA başlandı. 6. ayda EF %48\'e düzeldi.\n\n'
            'Vaka 4 (28/K): COVID sonrası 6. haftada plöretik göğüs ağrısı, '
            'ateş. Perikardiyal efüzyon (15 mm). CRP: 85 mg/L. Kolşisin + '
            'ibuprofen ile 4 haftada rezolüsyon.\n\n'
            'Vaka 5 (61/E): COVID sırasında masif PE, sağ ventrikül dilatasyonu. '
            'Trombolitik tedavi uygulandı, ardından 6 ay antikoagülasyon.\n\n'
            'Sonuç: COVID-19 sonrası kardiyak semptomlar ciddiye alınmalı, '
            'ekokardiyografi ve troponin ile taranmalı, gerektiğinde kardiyak '
            'MR ile ileri değerlendirme yapılmalıdır.',
    'category': 'case_series',
    'specialty': 'Kardiyoloji',
    'difficulty': 'intermediate',
    'authorId': 'doc_prof_ayse',
    'authorName': 'Prof. Dr. Ayşe Yılmaz',
    'authorSpecialty': 'Kardiyoloji',
    'tags': ['COVID-19', 'Miyokardit', 'Perikardit', 'Kardiyak MR', 'Vaka Serisi'],
    'searchTokens': [
      'covid', 'miyokardit', 'perikardit', 'kardiyak',
      'vaka serisi', 'post-covid', 'komplikasyon',
    ],
    'likeCount': 234,
    'viewCount': 1023,
    'commentCount': 56,
    'isPinned': false,
    'isApproved': true,
  },
  {
    'id': 'hub_cs_002',
    'title': 'Gebelikte Tiroid Fonksiyon Bozuklukları: 4 Olgu Analizi',
    'abstract':
        'Gebelikte tiroid disfonksiyonu hem anne hem fetus sağlığını etkiler. '
            'Trimestere özgü TSH referans aralıkları ve tedavi eşikleri '
            'güncel kılavuzlara göre değerlendirilmelidir.',
    'content':
        'Gebelikte tiroid fonksiyon bozuklukları %2-5 oranında görülür ve erken '
            'tanı ile tedavi, obstetrik komplikasyonları ve fetal nörogelişimsel '
            'sorunları önlemede kritiktir. Bu seride 4 olgu sunulmaktadır.\n\n'
            'Olgu 1 — Gestasyonel hipertiroidi (12. hafta, 29/K): Hiperemezis '
            'gravidarum ile başvuran hastada TSH <0.01, sT4: 2.8 ng/dL. β-hCG: '
            '180.000 mIU/mL. Anti-TSH reseptör antikoru negatif. Gestasyonel '
            'geçici tirotoksikoz tanısı kondu. Antitiroid ilaç başlanmadı, '
            'semptomatik tedavi uygulandı. 16. haftada spontan düzelme.\n\n'
            'Olgu 2 — Graves hastalığı alevlenmesi (8. hafta, 33/K): Bilinen '
            'Graves, gebelik öncesi remisyonda. TSH <0.01, sT4: 4.2 ng/dL, '
            'TRAb: 15 IU/L. Propiltiourasil (PTU) 100 mg 3x1 başlandı (ilk '
            'trimester). 2. trimesterde metimazole geçildi. Fetal tiroid USG '
            'takibi planlandı.\n\n'
            'Olgu 3 — Subklinik hipotiroidi (6. hafta, 31/K): TSH: 4.8 mIU/L, '
            'sT4: normal, anti-TPO: 320 IU/mL. ATA kılavuzuna göre (TSH >4.0 '
            '+ anti-TPO pozitif) levotiroksin 50 mcg/gün başlandı. Hedef TSH: '
            '<2.5 mIU/L.\n\n'
            'Olgu 4 — Aşikar hipotiroidi (10. hafta, 27/K): TSH: 12.4, sT4: '
            '0.4 ng/dL. Şiddetli yorgunluk, kabızlık. Levotiroksin 100 mcg/gün '
            'başlandı. 4 haftada TSH: 3.2\'ye düştü, doz 75 mcg\'a azaltıldı. '
            'Gebelik komplikasyonsuz tamamlandı.\n\n'
            'Özet: 1. trimesterde PTU, 2-3. trimesterde metimazol tercih edilir. '
            'Hipotiroidide trimestere özgü TSH hedefleri kullanılmalı, '
            'levotiroksin dozu gebelikte %30-50 artırılabilir.',
    'category': 'case_series',
    'specialty': 'Endokrinoloji',
    'difficulty': 'intermediate',
    'authorId': 'doc_prof_ayse',
    'authorName': 'Doç. Dr. Pınar Ertaş',
    'authorSpecialty': 'Endokrinoloji',
    'tags': ['Gebelik', 'Tiroid', 'Graves', 'Hipotiroidi', 'Levotiroksin'],
    'searchTokens': [
      'gebelik', 'tiroid', 'graves', 'hipotiroidi', 'levotiroksin',
      'tsh', 'ptu', 'metimazol',
    ],
    'likeCount': 167,
    'viewCount': 689,
    'commentCount': 34,
    'isPinned': false,
    'isApproved': true,
  },
  {
    'id': 'hub_cs_003',
    'title': 'İlaç Etkileşimlerinden Kaynaklanan Aritmi: 3 Vaka',
    'abstract':
        'QT uzaması ve torsades de pointes riski taşıyan ilaç kombinasyonları '
            'hakkında farkındalık oluşturmak amacıyla 3 olgu sunulmaktadır. '
            'Polifarmasi değerlendirmesi hayat kurtarır.',
    'content':
        'İlaca bağlı QT uzaması ve sonuçta gelişen torsades de pointes (TdP), '
            'özellikle polifarmasili hastalarda önemli bir morbidite ve mortalite '
            'nedenidir. Bu seride 3 olgu sunulmaktadır.\n\n'
            'Vaka 1 (72/K): Kronik AF nedeniyle amiodaron kullanan hasta, '
            'üriner enfeksiyon için moksifloksasin başlanması sonrası senkop '
            'ile acile başvurdu. EKG: QTc 580 ms, monitörde TdP atakları. '
            'Moksifloksasin kesildi, IV magnezyum ve geçici transvenöz pacing '
            'uygulandı. Mekanizma: İki QT uzatıcı ilacın sinerjik etkisi.\n\n'
            'Vaka 2 (45/E): Depresyon için sitalopram 40 mg kullanan hasta, '
            'migren profilaksisi için ondansetron eklenmesi sonrası çarpıntı '
            'gelişti. Holter: QTc 510 ms, non-sustained VT episodları. '
            'Ondansetron kesildi, sitalopram dozu 20 mg\'a düşürüldü. '
            'İki hafta sonra QTc: 430 ms.\n\n'
            'Vaka 3 (68/E): Psikiyatrik tedavi altında haloperidol + metadon '
            'kullanan hasta, kardiyak arrest ile bulundu. Ritim: TdP → VF. '
            'KPR + defibrilasyon ile ROSC sağlandı. QTc: 620 ms. Metadon '
            'kesildi, haloperidol yerine ketiapin (daha düşük QT riski) '
            'başlandı.\n\n'
            'Öğrenilen dersler:\n'
            '• QT uzatıcı ilaç başlanırken mevcut ilaç listesi mutlaka '
            'kontrol edilmelidir (crediblemeds.org)\n'
            '• Risk faktörleri: Kadın cinsiyet, hipokalemi, hipomagnezemi, '
            'bradikardi, yapısal kalp hastalığı, böbrek/karaciğer yetmezliği\n'
            '• QT uzatan ilaç kombinasyonlarında bazal ve kontrol EKG çekilmeli, '
            'QTc >500 ms ise ilaç kesilmelidir\n'
            '• IV magnezyum (2 g bolus) TdP\'nin ilk basamak tedavisidir.',
    'category': 'case_series',
    'specialty': 'Kardiyoloji',
    'difficulty': 'intermediate',
    'authorId': 'doc_uzm_mehmet',
    'authorName': 'Uzm. Dr. Emre Şahin',
    'authorSpecialty': 'Kardiyoloji',
    'tags': ['QT Uzaması', 'Torsades de Pointes', 'İlaç Etkileşimi', 'Aritmi', 'Polifarmasi'],
    'searchTokens': [
      'qt uzaması', 'torsades', 'ilaç etkileşimi', 'aritmi',
      'polifarmasi', 'amiodaron', 'magnezyum',
    ],
    'likeCount': 198,
    'viewCount': 812,
    'commentCount': 44,
    'isPinned': false,
    'isApproved': true,
  },

  // ══════════════════════════════════════════════════════════════════
  // KILAVUZLAR (Guidelines) — 3 vaka
  // ══════════════════════════════════════════════════════════════════
  {
    'id': 'hub_gl_001',
    'title': '2024 ESC Kalp Yetersizliği Kılavuzu: Güncel Yaklaşımlar',
    'abstract':
        'ESC 2024 kalp yetersizliği kılavuzu, SGLT2 inhibitörlerini tüm EF '
            'spektrumunda önermekte ve erken dörtlü tedaviyi vurgulamaktadır. '
            'Yeni algoritma önceki kılavuzdan önemli farklılıklar içerir.',
    'content':
        'Avrupa Kardiyoloji Derneği (ESC) 2024 kalp yetersizliği (KY) kılavuzu, '
            'özellikle farmakoterapi ve cihaz tedavisi alanlarında önemli '
            'güncellemeler getirmiştir.\n\n'
            'Temel yenilikler:\n'
            '1. Dörtlü tedavinin erken başlanması: HFrEF\'de (EF ≤40%) ACEi/ARNI, '
            'beta-blokör, MRA ve SGLT2i\'nin tümü ilk 4 hafta içinde titre edilerek '
            'başlanmalıdır. Sıralı yaklaşım yerine eşzamanlı başlangıç önerilmektedir. '
            'SGLT2i artık ilk basamakta yer almaktadır.\n\n'
            '2. HFmrEF ve HFpEF\'de SGLT2i: DELIVER ve EMPEROR-Preserved çalışmaları '
            'temelinde dapagliflozin ve empagliflozin, EF >40% olan KY hastalarında '
            'da Klass I endikasyon almıştır. Bu, HFpEF\'de kanıtlanmış ilk tedavi '
            'seçeneğidir.\n\n'
            '3. Finerenon: Diyabetik KY hastalarında MRA olarak finerenon, '
            'spironolakton/eplerenona alternatif olarak değerlendirilmektedir '
            '(hiperkalemi riski daha düşük).\n\n'
            '4. Demir replasmanı: Demir eksikliği olan KY hastalarında (ferritin '
            '<100 veya transferrin satürasyonu <%20 + ferritin 100-299) IV demir '
            'karboksimaltoz veya derisomaltoz ile replasman önerilmektedir '
            '(semptom iyileşmesi ve hospitalizasyon azalması).\n\n'
            '5. Cihaz tedavisi güncellemeleri: CRT endikasyonunda LBBB + QRS >150 ms '
            'Klass I iken, non-LBBB morfolojide CRT yerine ICD tercih edilmektedir. '
            'Konjesyon monitörizasyonu için implante edilebilir pulmoner arter basınç '
            'sensörleri (CardioMEMS) Klass IIa önerilmektedir.\n\n'
            'Pratik özet: "Start all four, titrate to more" yaklaşımı benimsenmelidir.',
    'category': 'guidelines',
    'specialty': 'Kardiyoloji',
    'difficulty': 'intermediate',
    'authorId': 'doc_prof_ayse',
    'authorName': 'Prof. Dr. Ayşe Yılmaz',
    'authorSpecialty': 'Kardiyoloji',
    'tags': ['ESC', 'Kalp Yetersizliği', 'SGLT2i', 'HFrEF', 'Kılavuz 2024'],
    'searchTokens': [
      'esc', 'kalp yetersizliği', 'sglt2', 'hfref', 'hfpef',
      'kılavuz', '2024', 'dapagliflozin', 'arni',
    ],
    'likeCount': 267,
    'viewCount': 1145,
    'commentCount': 58,
    'isPinned': false,
    'isApproved': true,
  },
  {
    'id': 'hub_gl_002',
    'title': 'Sepsis Yönetimi: Surviving Sepsis Campaign 2024 Güncelleme',
    'abstract':
        'SSC 2024 güncellemesi, sıvı resüsitasyonunda bireyselleştirilmiş '
            'yaklaşımı, erken antibiyotik başlanmasını ve vazopressör yönetiminde '
            'norepinefrinin birinci basamak olduğunu vurgular.',
    'content':
        'Surviving Sepsis Campaign (SSC) 2024 güncellemesi, sepsis ve septik '
            'şokun tanı ve tedavisinde önemli paradigma değişiklikleri '
            'getirmektedir.\n\n'
            'Erken tanı ve antibiyotik:\n'
            '• Sepsis şüphesinde ilk 1 saat içinde geniş spektrumlu antibiyotik '
            'başlanmalıdır (Klass I). Septik şokta her saat gecikme mortaliteyi '
            '%7.6 artırır.\n'
            '• Antibiyotik öncesi kan kültürü alınmalı ancak kültür alımı '
            'antibiyotiği geciktirmemelidir.\n'
            '• 48-72 saatte klinik yanıt ve kültür sonuçlarına göre de-eskalasyon '
            'yapılmalıdır.\n\n'
            'Sıvı resüsitasyonu — Bireyselleştirilmiş yaklaşım:\n'
            '• İlk 3 saatte 30 mL/kg kristaloid uygulaması artık katı bir kural '
            'değil, bireysel değerlendirme önerilmektedir (dengeli kristaloidler '
            'tercih edilmeli, %0.9 NaCl\'den kaçınılmalı).\n'
            '• Sıvı yanıtlılığı değerlendirmesi: Pasif bacak kaldırma testi, '
            'pulse pressure varyasyonu veya mini sıvı bolus testi ile '
            'değerlendirilmelidir.\n'
            '• Aşırı sıvı yüklemesinden kaçınılmalıdır (kümülatif pozitif sıvı '
            'dengesi mortalite ile ilişkilidir).\n\n'
            'Vazopressör yönetimi:\n'
            '• Norepinefrin ilk basamak vazopressördür (hedef MAP ≥65 mmHg).\n'
            '• Norepinefrin 0.5 mcg/kg/dk üzerine çıkıldığında vazopresin (0.03 U/dk) '
            'eklenmeli.\n'
            '• Refrakter şokta IV hidrokortizon 200 mg/gün (50 mg 6 saatte bir) '
            'düşünülmelidir.\n\n'
            'Yeni öneriler:\n'
            '• Laktat klerensini rehber alan resüsitasyon (hedef: 2 saatte %20 azalma)\n'
            '• Periferik vazopressör uygulaması santral hat yerleştirilene kadar güvenlidir\n'
            '• Vitamin C rutin olarak önerilmemektedir (LOVIT çalışması)',
    'category': 'guidelines',
    'specialty': 'Yoğun Bakım',
    'difficulty': 'intermediate',
    'authorId': 'doc_uzm_mehmet',
    'authorName': 'Prof. Dr. Oğuz Kılınç',
    'authorSpecialty': 'Yoğun Bakım',
    'tags': ['Sepsis', 'SSC', 'Vazopressör', 'Norepinefrin', 'Kılavuz 2024'],
    'searchTokens': [
      'sepsis', 'ssc', 'surviving', 'vazopressör', 'norepinefrin',
      'kılavuz', '2024', 'septik şok', 'laktat',
    ],
    'likeCount': 312,
    'viewCount': 1567,
    'commentCount': 67,
    'isPinned': false,
    'isApproved': true,
  },
  {
    'id': 'hub_gl_003',
    'title': 'Tip 2 Diyabet Tedavisinde ADA/EASD 2024 Algoritması',
    'abstract':
        'ADA/EASD 2024 konsensüs raporu, kardiyovasküler ve renal komorbiditelere '
            'göre bireyselleştirilmiş tedavi yaklaşımını öne çıkarmakta, GLP-1 RA '
            've SGLT2i\'yi HbA1c\'den bağımsız olarak önermektedir.',
    'content':
        'American Diabetes Association (ADA) ve European Association for the Study '
            'of Diabetes (EASD) 2024 konsensüs raporu, tip 2 diyabet tedavisinde '
            'glukoz merkezli yaklaşımdan organ koruma merkezli yaklaşıma geçişi '
            'pekiştirmektedir.\n\n'
            'Tedavi algoritması:\n'
            '1. Yaşam tarzı modifikasyonu tüm hastalarda temeldir.\n'
            '2. İlk basamak farmakoterapi:\n'
            '   • Kardiyovasküler hastalık (ASKH) varsa → GLP-1 RA (semaglutid, '
            'liraglutid) veya SGLT2i HbA1c değerinden bağımsız olarak başlanmalı\n'
            '   • Kalp yetersizliği varsa → SGLT2i (dapagliflozin/empagliflozin) '
            'öncelikli\n'
            '   • Kronik böbrek hastalığı varsa → SGLT2i (eGFR >20) + finerenon '
            '(albüminüri varsa)\n'
            '   • Yukarıdakiler yoksa → Metformin ilk basamak, hedef HbA1c\'ye göre '
            'ek ajan\n\n'
            '3. Kilo yönetimi ön plana çıkmaktadır:\n'
            '   • BMI >27 + diyabet → Tirzepatid (GIP/GLP-1 dual agonist) veya '
            'yüksek doz semaglutid\n'
            '   • %15\'e varan kilo kaybı sağlanabilir\n'
            '   • Bariatrik cerrahi BMI >35 + diyabette Klass I\n\n'
            '4. HbA1c hedefleri bireyselleştirilmeli:\n'
            '   • Genç, komplikasyonsuz → <6.5%\n'
            '   • Çoğu erişkin → <7.0%\n'
            '   • Yaşlı, komorbiditeli → <8.0%\n\n'
            '5. Yeni öneriler:\n'
            '   • Sürekli glukoz monitörizasyonu (CGM): TIR (Time in Range) >%70 '
            'hedeflenmeli\n'
            '   • İnsülin gereken hastalarda bazal insülin + GLP-1 RA kombinasyonu '
            '(iDegLira, iGlarLixi) tercih edilmeli\n'
            '   • Metformin artık tek başına ilk basamak değildir; komorbiditeye '
            'göre doğrudan GLP-1 RA veya SGLT2i başlanabilir.',
    'category': 'guidelines',
    'specialty': 'Endokrinoloji',
    'difficulty': 'beginner',
    'authorId': 'doc_prof_ayse',
    'authorName': 'Prof. Dr. Selin Aksoy',
    'authorSpecialty': 'Endokrinoloji',
    'tags': ['Diyabet', 'ADA', 'EASD', 'GLP-1', 'SGLT2i', 'Kılavuz 2024'],
    'searchTokens': [
      'diyabet', 'ada', 'easd', 'glp-1', 'sglt2', 'kılavuz',
      '2024', 'metformin', 'semaglutid', 'tirzepatid',
    ],
    'likeCount': 289,
    'viewCount': 1389,
    'commentCount': 63,
    'isPinned': false,
    'isApproved': true,
  },
];
