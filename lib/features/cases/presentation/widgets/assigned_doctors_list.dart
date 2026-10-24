import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../design_system/design_system.dart';
import '../../data/repositories/case_assignment_repository_impl.dart';
import '../../domain/entities/case_assignment.dart';

/// KONSENXIA — Atanan Doktorlar Listesi
///
/// Case detail sayfasında, vakaya atanmış intern/asistanları listeler.
/// Sadece specialist/professor rolüne göre gösterilir.
class AssignedDoctorsList extends StatefulWidget {
  final String caseId;
  const AssignedDoctorsList({super.key, required this.caseId});

  @override
  State<AssignedDoctorsList> createState() => _AssignedDoctorsListState();
}

class _AssignedDoctorsListState extends State<AssignedDoctorsList> {
  final _repo = CaseAssignmentRepositoryImpl();
  List<CaseAssignment> _assignments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _repo.getAssignmentsForCase(widget.caseId);
      if (mounted) setState(() { _assignments = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(
            strokeWidth: 2, color: KxColors.teal400,
          ),
        ),
      );
    }

    if (_assignments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_off_outlined,
                size: 16, color: KxColors.textMuted),
            const SizedBox(width: 8),
            Text('Bu vakaya henüz kimse atanmadı.',
                style: KxTypography.bodyMd
                    .copyWith(color: KxColors.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: _assignments.indexed.map((entry) {
        final i = entry.$1;
        final a = entry.$2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _AssignmentRow(assignment: a, onRefresh: _load)
              .animate().fadeIn(delay: Duration(milliseconds: 40 + i * 50)),
        );
      }).toList(),
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  final CaseAssignment assignment;
  final VoidCallback onRefresh;

  const _AssignmentRow({required this.assignment, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (assignment.status) {
      'completed'   => 'Tamamlandı',
      'in_progress' => 'Devam ediyor',
      _             => 'Bekliyor',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Row(
        children: [
          KxAvatar(
            name: assignment.assignedToName,
            size: KxAvatarSize.sm,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.assignedToName,
                    style: KxTypography.labelSm),
                if (assignment.notes != null && assignment.notes!.isNotEmpty)
                  Text(assignment.notes!,
                      style: KxTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          switch (assignment.status) {
            'completed'   => KxBadge.jade(statusLabel),
            'in_progress' => KxBadge.teal(statusLabel),
            _             => KxBadge.amber(statusLabel),
          },
        ],
      ),
    );
  }
}
