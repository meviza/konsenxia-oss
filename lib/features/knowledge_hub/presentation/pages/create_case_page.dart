import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/hub_case_entity.dart';
import '../../domain/usecases/create_hub_case_usecase.dart';
import '../../domain/repositories/hub_case_repository.dart';

/// KONSENXIA Knowledge Hub — Eğitim Vakası Ekleme Formu
class CreateKnowledgeHubCasePage extends StatefulWidget {
  const CreateKnowledgeHubCasePage({super.key});

  @override
  State<CreateKnowledgeHubCasePage> createState() =>
      _CreateKnowledgeHubCasePageState();
}

class _CreateKnowledgeHubCasePageState
    extends State<CreateKnowledgeHubCasePage> {
  final _titleCtrl = TextEditingController();
  final _abstractCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  HubCaseCategory _selectedCategory = HubCaseCategory.clinicalPearl;
  String _selectedSpecialty = 'Dahiliye';
  HubDifficulty _selectedDifficulty = HubDifficulty.intermediate;
  bool _isSubmitting = false;

  static const _specialties = [
    'Dahiliye',
    'Kardiyoloji',
    'Nöroloji',
    'Endokrinoloji',
    'Enfeksiyon Hastalıkları',
    'Radyoloji',
    'Göğüs Hastalıkları',
    'Gastroenteroloji',
    'Nefroloji',
    'Hematoloji',
  ];

  static final _categories = HubCaseCategory.values
      .where((c) => c != HubCaseCategory.all)
      .toList();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _abstractCtrl.dispose();
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      appBar: AppBar(
        backgroundColor: KxColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: KxColors.textPrimary, size: 20),
          onPressed: _isSubmitting
              ? null
              : () => context.canPop()
                  ? context.pop()
                  : context.go('/knowledge-hub'),
        ),
        title: Text('Eğitim Vakası Ekle', style: KxTypography.headingSm),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: KxColors.teal400),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: Text(
                'Yayınla',
                style: KxTypography.labelMd
                    .copyWith(color: KxColors.teal400),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Kategori ─────────────────────────────────────────
              _Label('Kategori'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories
                    .map((cat) => GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: _selectedCategory == cat
                                  ? KxColors.teal400.withOpacity(0.15)
                                  : KxColors.bgCard,
                              borderRadius: KxSpacing.radiusPill,
                              border: Border.all(
                                color: _selectedCategory == cat
                                    ? KxColors.teal400.withOpacity(0.5)
                                    : KxColors.border,
                              ),
                            ),
                            child: Text(
                              cat.label,
                              style: KxTypography.labelSm.copyWith(
                                color: _selectedCategory == cat
                                    ? KxColors.teal400
                                    : KxColors.textSecondary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // ── Başlık ────────────────────────────────────────────
              _Label('Vaka Başlığı'),
              const SizedBox(height: 8),
              KxTextField(
                controller: _titleCtrl,
                hint:
                    'Klinisyenlerin dikkatini çeken, açıklayıcı bir başlık...',
              ),

              const SizedBox(height: 20),

              // ── Uzmanlık ──────────────────────────────────────────
              _Label('Uzmanlık Alanı'),
              const SizedBox(height: 8),
              _DropdownField(
                value: _selectedSpecialty,
                items: _specialties,
                onChanged: (v) =>
                    setState(() => _selectedSpecialty = v!),
              ),

              const SizedBox(height: 20),

              // ── Zorluk ────────────────────────────────────────────
              _Label('Zorluk Seviyesi'),
              const SizedBox(height: 8),
              Row(
                children: HubDifficulty.values.map((d) {
                  final isSelected = _selectedDifficulty == d;
                  final color = switch (d) {
                    HubDifficulty.beginner     => KxColors.jade300,
                    HubDifficulty.advanced     => KxColors.crimson300,
                    HubDifficulty.intermediate => KxColors.amber300,
                  };
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedDifficulty = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : KxColors.bgCard,
                          borderRadius: KxSpacing.radiusMd,
                          border: Border.all(
                            color: isSelected
                                ? color.withOpacity(0.5)
                                : KxColors.border,
                          ),
                        ),
                        child: Text(
                          d.label,
                          textAlign: TextAlign.center,
                          style: KxTypography.labelSm.copyWith(
                            color: isSelected
                                ? color
                                : KxColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── Özet ──────────────────────────────────────────────
              _Label('Kısa Özet'),
              const SizedBox(height: 4),
              Text(
                'Listelemede görünecek 1-2 cümlelik tanıtım metni.',
                style: KxTypography.caption
                    .copyWith(color: KxColors.textMuted),
              ),
              const SizedBox(height: 8),
              KxTextField(
                controller: _abstractCtrl,
                hint:
                    'Bu vakada ne öğrenilecek? Klinisyeni neden ilgilendiriyor?',
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // ── Ana içerik ────────────────────────────────────────
              _Label('Vaka İçeriği'),
              const SizedBox(height: 4),
              Text(
                'Vaka sunumu, tanısal süreç, klinik inciyi içeren tam metin.',
                style: KxTypography.caption
                    .copyWith(color: KxColors.textMuted),
              ),
              const SizedBox(height: 8),
              KxTextField(
                controller: _contentCtrl,
                hint:
                    'Hasta demografisi, başvuru şikayeti, muayene bulguları, laboratuvar, görüntüleme, tanı ve tedavi süreci...',
                maxLines: 10,
              ),

              const SizedBox(height: 20),

              // ── Etiketler ─────────────────────────────────────────
              _Label('Etiketler'),
              const SizedBox(height: 4),
              Text(
                'Virgülle ayırın: Adrenal, Kriz, Kortizol',
                style: KxTypography.caption
                    .copyWith(color: KxColors.textMuted),
              ),
              const SizedBox(height: 8),
              KxTextField(
                controller: _tagsCtrl,
                hint: 'NMDAR, Ensefalit, Paraneoplastik',
              ),

              const SizedBox(height: 32),

              // ── Submit ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: KxButton(
                  label: _isSubmitting ? 'Yayınlanıyor...' : 'Vakayı Yayınla',
                  onPressed: _isSubmitting ? null : _submit,
                  variant: KxButtonVariant.primary,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
    );
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Başlık gerekli',
            style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid)),
        backgroundColor: KxColors.crimson400,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_abstractCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Özet gerekli',
            style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid)),
        backgroundColor: KxColors.crimson400,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_contentCtrl.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('İçerik en az 20 karakter olmalı',
            style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid)),
        backgroundColor: KxColors.crimson400,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSubmitting = true);

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    try {
      final useCase = GetIt.instance<CreateHubCaseUseCase>();
      await useCase(CreateHubCaseParams(
        title: _titleCtrl.text.trim(),
        abstract_: _abstractCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        category: _selectedCategory,
        specialty: _selectedSpecialty,
        difficulty: _selectedDifficulty,
        tags: tags,
      ));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vaka başarıyla yayınlandı!',
            style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid),
          ),
          backgroundColor: KxColors.jade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
        ),
      );
      context.go('/knowledge-hub');
    } on HubCaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message,
            style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid),
          ),
          backgroundColor: KxColors.crimson400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
        ),
      );
      setState(() => _isSubmitting = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bir hata oluştu. Lütfen tekrar deneyin.',
            style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid),
          ),
          backgroundColor: KxColors.crimson400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: KxTypography.labelMd
            .copyWith(color: KxColors.textSecondary),
      );
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: KxColors.bgCard,
        icon: const Icon(Icons.expand_more_rounded,
            color: KxColors.textSecondary, size: 20),
        style: KxTypography.bodyMd
            .copyWith(color: KxColors.textPrimary),
        items: items
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
