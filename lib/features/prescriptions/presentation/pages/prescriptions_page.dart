import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/prescriptions_bloc.dart';
import '../bloc/prescriptions_event.dart';
import '../bloc/prescriptions_state.dart';
import '../../domain/entities/prescription_entity.dart';

/// KONSENXIA — Reçetelerim
class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  static const _filters = ['Aktif', 'Tümü', 'Süresi Dolmuş'];

  @override
  void initState() {
    super.initState();
    context.read<PrescriptionsBloc>().add(const LoadPrescriptionsEvent());
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
        title: Text('Reçetelerim', style: KxTypography.headingSm),
      ),
      body: BlocBuilder<PrescriptionsBloc, PrescriptionsState>(
        builder: (context, state) {
          final activeFilter =
              state is PrescriptionsLoaded ? state.activeFilter : 'Aktif';

          return Column(
            children: [
              // ── Filter chips ──────────────────────────────────
              Container(
                color: KxColors.bgSurface,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = f == activeFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => context
                            .read<PrescriptionsBloc>()
                            .add(FilterPrescriptionsEvent(f)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
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
                          child: Text(f,
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

              // ── Content ──────────────────────────────────────
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PrescriptionsState state) {
    if (state is PrescriptionsLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _PrescriptionSkeleton(),
        ),
      );
    }
    if (state is PrescriptionsError) {
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
                  .read<PrescriptionsBloc>()
                  .add(const LoadPrescriptionsEvent()),
            ),
          ],
        ),
      );
    }
    if (state is PrescriptionsLoaded) {
      final items = state.filtered;
      if (items.isEmpty) {
        return Center(
          child: Text('Bu kategoride reçete yok.',
              style: KxTypography.bodyMd
                  .copyWith(color: KxColors.textMuted)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PrescriptionCard(prescription: items[i]),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Prescription Card ─────────────────────────────────────────────

class _PrescriptionCard extends StatelessWidget {
  final PrescriptionEntity prescription;
  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final rx = prescription;
    final isExpired = rx.isExpired;

    return Opacity(
      opacity: isExpired ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(
            color: rx.isControlled
                ? KxColors.amber300.withOpacity(0.4)
                : KxColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rx.drugName, style: KxTypography.headingSm),
                      Text(rx.form,
                          style: KxTypography.caption
                              .copyWith(color: KxColors.textMuted)),
                    ],
                  ),
                ),
                if (rx.isControlled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: KxColors.amber300.withOpacity(0.12),
                      borderRadius: KxSpacing.radiusPill,
                      border: Border.all(
                          color: KxColors.amber300.withOpacity(0.4)),
                    ),
                    child: Text('Kontrollü',
                        style: KxTypography.caption
                            .copyWith(color: KxColors.amber300)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(Icons.medication_rounded, rx.dosage),
            const SizedBox(height: 4),
            _InfoRow(Icons.person_rounded, rx.prescriber),
            const SizedBox(height: 4),
            _InfoRow(
              Icons.event_rounded,
              'Bitiş: ${DateFormat('d MMM y', 'tr').format(rx.expiryDate)}${isExpired ? ' (Dolmuş)' : ''}',
              color: isExpired ? KxColors.crimson300 : null,
            ),
            const SizedBox(height: 4),
            _InfoRow(Icons.repeat_rounded,
                'Kalan Tekrar: ${rx.refillsLeft}'),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: KxColors.teal400.withOpacity(0.08),
                borderRadius: KxSpacing.radiusSm,
              ),
              child: Text(
                rx.indication,
                style: KxTypography.caption
                    .copyWith(color: KxColors.teal400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _InfoRow(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 13, color: color ?? KxColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: KxTypography.caption.copyWith(
                  color: color ?? KxColors.textSecondary),
            ),
          ),
        ],
      );
}

class _PrescriptionSkeleton extends StatelessWidget {
  const _PrescriptionSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: KxColors.bgCard,
        highlightColor: KxColors.bgSurface,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius: KxSpacing.radiusMd,
          ),
        ),
      );
}
