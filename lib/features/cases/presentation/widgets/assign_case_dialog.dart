import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../design_system/design_system.dart';
import '../../data/repositories/case_assignment_repository_impl.dart';

/// KONSENXIA — Vaka Atama Dialog'u
///
/// Professor/Specialist rolündeki kullanıcılar bir vakayı intern/residente atar.
/// Doktor adına / uzmanlığına göre arama yapılabilir.
/// `onAssigned` callback başarılı atamadan sonra çağrılır.
Future<void> showAssignCaseDialog({
  required BuildContext context,
  required String caseId,
  required String caseTitle,
  required String caseSpecialty,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AssignCaseSheet(
      caseId: caseId,
      caseTitle: caseTitle,
      caseSpecialty: caseSpecialty,
    ),
  );
}

class _AssignCaseSheet extends StatefulWidget {
  final String caseId;
  final String caseTitle;
  final String caseSpecialty;

  const _AssignCaseSheet({
    required this.caseId,
    required this.caseTitle,
    required this.caseSpecialty,
  });

  @override
  State<_AssignCaseSheet> createState() => _AssignCaseSheetState();
}

class _AssignCaseSheetState extends State<_AssignCaseSheet> {
  final _searchCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  final _repo = CaseAssignmentRepositoryImpl();

  List<_DoctorResult> _results = [];
  _DoctorResult? _selected;
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection('users')
          .where('role', whereIn: ['INTERN', 'RESIDENT'])
          .limit(20);

      if (query.trim().isNotEmpty) {
        final lower = query.trim().toLowerCase();
        q = FirebaseFirestore.instance
            .collection('users')
            .where('role', whereIn: ['INTERN', 'RESIDENT'])
            .where('searchTokens', arrayContains: lower)
            .limit(20);
      }

      final snap = await q.get();
      setState(() {
        _results = snap.docs.map((d) {
          final data = d.data();
          return _DoctorResult(
            id: d.id,
            firstName: data['firstName'] as String? ?? '',
            lastName: data['lastName'] as String? ?? '',
            role: data['role'] as String? ?? 'RESIDENT',
            specialty: data['specialty'] as String? ?? '',
          );
        }).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _assign() async {
    if (_selected == null) return;
    setState(() { _submitting = true; _error = null; });
    try {
      await _repo.createAssignment(
        caseId: widget.caseId,
        caseTitle: widget.caseTitle,
        caseSpecialty: widget.caseSpecialty,
        assignedToUserId: _selected!.id,
        assignedToName: _selected!.fullName,
        notes: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = 'Atama başarısız: ${e.toString()}';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: EdgeInsets.only(bottom: bottomPad > 0 ? bottomPad : 16),
      decoration: BoxDecoration(
        color: KxColors.bgElevated,
        borderRadius: KxSpacing.radiusXl,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: KxColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaka Ata', style: KxTypography.headingSm),
                      Text(
                        widget.caseTitle,
                        style: KxTypography.caption.copyWith(
                          color: KxColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: KxColors.textSecondary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: KxColors.border, height: 20),

          // Arama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: KxSearchBar(
              hint: 'İntern veya asistan ara...',
              onChanged: _search,
            ),
          ),

          const SizedBox(height: 10),

          // Sonuç listesi
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: _loading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: KxColors.teal400,
                      ),
                    ),
                  )
                : _results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Kayıtlı intern/asistan bulunamadı.',
                          style: KxTypography.bodyMd
                              .copyWith(color: KxColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 6),
                        itemBuilder: (context, i) {
                          final doc = _results[i];
                          final isSelected = _selected?.id == doc.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selected = isSelected ? null : doc),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? KxColors.teal400.withOpacity(0.08)
                                    : KxColors.bgCard,
                                borderRadius: KxSpacing.radiusMd,
                                border: Border.all(
                                  color: isSelected
                                      ? KxColors.teal400
                                      : KxColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  KxAvatar(
                                    name: doc.fullName,
                                    size: KxAvatarSize.sm,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(doc.fullName,
                                            style: KxTypography.labelSm),
                                        Text(
                                          '${doc.roleLabel}${doc.specialty.isNotEmpty ? ' · ${doc.specialty}' : ''}',
                                          style: KxTypography.caption
                                              .copyWith(color: KxColors.teal400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle_rounded,
                                        color: KxColors.teal400, size: 18),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(
                                delay: Duration(milliseconds: 20 + i * 30));
                        },
                      ),
          ),

          // Not alanı
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: KxTextField(
              controller: _noteCtrl,
              label: 'Not (opsiyonel)',
              hint: 'Öğrenciye not ekleyin...',
              maxLines: 2,
            ),
          ),

          // Hata
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(_error!,
                  style: KxTypography.caption
                      .copyWith(color: KxColors.crimson400)),
            ),

          // Ata butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: KxButton.primary(
              label: _submitting ? 'Atanıyor...' : 'Vakayı Ata',
              onPressed: _selected == null || _submitting ? null : _assign,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doktor arama sonuç modeli ────────────────────────────────────────

class _DoctorResult {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String specialty;

  const _DoctorResult({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.specialty,
  });

  String get fullName => '$firstName $lastName';

  String get roleLabel => switch (role) {
    'INTERN'   => 'İntern',
    'RESIDENT' => 'Asistan Dr.',
    _          => 'Hekim',
  };
}
