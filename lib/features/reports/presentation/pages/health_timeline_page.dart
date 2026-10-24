import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../../domain/entities/medical_report_entity.dart';

/// KONSENXIA Health Timeline — Tıbbi Geçmiş
class HealthTimelinePage extends StatefulWidget {
  const HealthTimelinePage({super.key});

  @override
  State<HealthTimelinePage> createState() => _HealthTimelinePageState();
}

class _HealthTimelinePageState extends State<HealthTimelinePage> {
  static final _years = [
    DateTime.now().year,
    DateTime.now().year - 1,
    DateTime.now().year - 2,
  ];

  @override
  void initState() {
    super.initState();
    context
        .read<ReportsBloc>()
        .add(LoadReportsEvent(year: DateTime.now().year));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      appBar: AppBar(
        backgroundColor: KxColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: KxColors.textPrimary, size: 18),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
        title: Text('Sağlık Geçmişi', style: KxTypography.headingSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded,
                color: KxColors.teal400),
            onPressed: () => context.go('/reports/upload'),
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          final selectedYear = state is ReportsLoaded
              ? state.selectedYear
              : DateTime.now().year;

          return Column(
            children: [
              // ── Year selector ──────────────────────────────────
              Container(
                color: KxColors.bgSurface,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: _years.map((y) {
                    final isSelected = y == selectedYear;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => context
                            .read<ReportsBloc>()
                            .add(ChangeReportsYearEvent(y)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? KxColors.teal400.withOpacity(0.12)
                                : KxColors.bgCard,
                            borderRadius: KxSpacing.radiusPill,
                            border: Border.all(
                              color: isSelected
                                  ? KxColors.teal400.withOpacity(0.5)
                                  : KxColors.border,
                            ),
                          ),
                          child: Text('$y',
                              style: KxTypography.labelSm.copyWith(
                                color: isSelected
                                    ? KxColors.teal400
                                    : KxColors.textSecondary,
                              )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Content ────────────────────────────────────────
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReportsState state) {
    if (state is ReportsLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _TimelineSkeleton(),
        ),
      );
    }
    if (state is ReportsError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 40, color: KxColors.crimson300),
            const SizedBox(height: 12),
            Text(state.message, style: KxTypography.bodyMd),
            const SizedBox(height: 16),
            KxButton.secondary(
              label: 'Tekrar Dene',
              onPressed: () => context
                  .read<ReportsBloc>()
                  .add(LoadReportsEvent(year: DateTime.now().year)),
            ),
          ],
        ),
      );
    }
    if (state is ReportsLoaded) {
      if (state.reports.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_rounded,
                  size: 40, color: KxColors.textMuted),
              const SizedBox(height: 12),
              Text('${state.selectedYear} yılına ait kayıt yok.',
                  style: KxTypography.bodyMd
                      .copyWith(color: KxColors.textMuted)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.reports.length,
        itemBuilder: (_, i) {
          final r = state.reports[i];
          final isLast = i == state.reports.length - 1;
          return _TimelineItem(report: r, isLast: isLast);
        },
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Timeline Item ─────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final MedicalReportEntity report;
  final bool isLast;
  const _TimelineItem({required this.report, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(report.type);
    final typeIcon = _typeIcon(report.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline spine ────────────────────────────────
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: KxSpacing.radiusSm,
                    border: Border.all(color: typeColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    DateFormat('d MMM', 'tr').format(report.date),
                    textAlign: TextAlign.center,
                    style: KxTypography.monoSm
                        .copyWith(color: typeColor, fontSize: 9),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: KxColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Event card ──────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KxColors.bgCard,
                  borderRadius: KxSpacing.radiusMd,
                  border: Border.all(
                    color: report.isAbnormal
                        ? KxColors.amber300.withOpacity(0.3)
                        : KxColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(typeIcon, size: 14, color: typeColor),
                        const SizedBox(width: 6),
                        Text(report.type.label,
                            style: KxTypography.caption
                                .copyWith(color: typeColor)),
                        const Spacer(),
                        if (report.isAbnormal)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: KxColors.amber300.withOpacity(0.1),
                              borderRadius: KxSpacing.radiusPill,
                            ),
                            child: Text('Anormal',
                                style: KxTypography.caption.copyWith(
                                    color: KxColors.amber300)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(report.title, style: KxTypography.labelMd),
                    const SizedBox(height: 4),
                    Text(report.summary,
                        style: KxTypography.caption.copyWith(
                            color: KxColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_hospital_outlined,
                            size: 11, color: KxColors.textMuted),
                        const SizedBox(width: 4),
                        Text(report.institution,
                            style: KxTypography.caption.copyWith(
                                color: KxColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(ReportType t) => switch (t) {
        ReportType.labResult   => KxColors.blue400,
        ReportType.imaging     => KxColors.teal400,
        ReportType.diagnosis   => KxColors.crimson300,
        ReportType.report      => KxColors.jade300,
        ReportType.procedure   => KxColors.amber300,
        ReportType.vaccination => KxColors.jade300,
      };

  IconData _typeIcon(ReportType t) => switch (t) {
        ReportType.labResult   => Icons.science_rounded,
        ReportType.imaging     => Icons.medical_information_rounded,
        ReportType.diagnosis   => Icons.local_hospital_rounded,
        ReportType.report      => Icons.description_rounded,
        ReportType.procedure   => Icons.vaccines_rounded,
        ReportType.vaccination => Icons.vaccines_rounded,
      };
}

class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: KxColors.bgCard,
        highlightColor: KxColors.bgSurface,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: KxColors.bgCard,
                borderRadius: KxSpacing.radiusSm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: KxColors.bgCard,
                  borderRadius: KxSpacing.radiusMd,
                ),
              ),
            ),
          ],
        ),
      );
}
