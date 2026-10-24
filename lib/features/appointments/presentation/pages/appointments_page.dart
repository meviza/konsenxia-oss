import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/appointments_bloc.dart';
import '../bloc/appointments_event.dart';
import '../bloc/appointments_state.dart';
import '../../domain/entities/appointment_entity.dart';

/// KONSENXIA Randevular
class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  static const _tabs = ['Yaklaşan', 'Geçmiş', 'Bekleyen'];

  @override
  void initState() {
    super.initState();
    context.read<AppointmentsBloc>().add(const LoadAppointmentsEvent());
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
        title: Text('Randevularım', style: KxTypography.headingSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: KxColors.teal400),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        builder: (context, state) {
          final activeTab =
              state is AppointmentsLoaded ? state.activeTab : 'Yaklaşan';
          return Column(
            children: [
              // ── Tab bar ────────────────────────────────────────
              Container(
                color: KxColors.bgSurface,
                child: Row(
                  children: _tabs.map((tab) {
                    final isSelected = tab == activeTab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => context
                            .read<AppointmentsBloc>()
                            .add(FilterAppointmentsEvent(tab)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected
                                    ? KxColors.teal400
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            tab,
                            textAlign: TextAlign.center,
                            style: KxTypography.labelSm.copyWith(
                              color: isSelected
                                  ? KxColors.teal400
                                  : KxColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppointmentsState state) {
    if (state is AppointmentsLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _AppointmentSkeleton(),
        ),
      );
    }
    if (state is AppointmentsError) {
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
                  .read<AppointmentsBloc>()
                  .add(const LoadAppointmentsEvent()),
            ),
          ],
        ),
      );
    }
    if (state is AppointmentsLoaded) {
      final items = state.filtered;
      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_available_rounded,
                  size: 40, color: KxColors.textMuted),
              const SizedBox(height: 12),
              Text('${state.activeTab} randevu yok.',
                  style: KxTypography.bodyMd
                      .copyWith(color: KxColors.textMuted)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AppointmentCard(
            appointment: items[i],
            onCancel: () => _confirmCancel(context, items[i]),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _confirmCancel(BuildContext context, AppointmentEntity apt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KxColors.bgCard,
        title: Text('Randevuyu İptal Et', style: KxTypography.headingSm),
        content: Text(
          '${apt.doctorName} ile randevuyu iptal etmek istiyor musunuz?',
          style: KxTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Vazgeç',
                style: KxTypography.labelSm
                    .copyWith(color: KxColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AppointmentsBloc>()
                  .add(CancelAppointmentEvent(apt.id));
            },
            child: Text('İptal Et',
                style: KxTypography.labelSm
                    .copyWith(color: KxColors.crimson300)),
          ),
        ],
      ),
    );
  }
}

// ── Appointment Card ──────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onCancel;
  const _AppointmentCard({required this.appointment, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final apt = appointment;
    final isCancelled = apt.status == AppointmentStatus.cancelled;
    final isCompleted = apt.status == AppointmentStatus.completed;

    final typeColor = switch (apt.type) {
      AppointmentType.video    => KxColors.teal400,
      AppointmentType.phone    => KxColors.blue400,
      AppointmentType.inPerson => KxColors.jade300,
    };
    final typeIcon = switch (apt.type) {
      AppointmentType.video    => Icons.videocam_rounded,
      AppointmentType.phone    => Icons.phone_rounded,
      AppointmentType.inPerson => Icons.local_hospital_rounded,
    };

    return Opacity(
      opacity: isCancelled ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(
            color: isCancelled
                ? KxColors.crimson300.withOpacity(0.3)
                : KxColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: KxSpacing.radiusMd,
                  ),
                  child: Icon(typeIcon, size: 20, color: typeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(apt.doctorName, style: KxTypography.labelMd),
                      Text(apt.specialty,
                          style: KxTypography.caption
                              .copyWith(color: KxColors.textMuted)),
                    ],
                  ),
                ),
                _StatusChip(status: apt.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: KxColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  DateFormat('d MMMM y, HH:mm', 'tr').format(apt.date),
                  style: KxTypography.labelSm
                      .copyWith(color: KxColors.textSecondary),
                ),
              ],
            ),
            if (apt.location != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 14, color: KxColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(apt.location!,
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textSecondary)),
                  ),
                ],
              ),
            ],
            if (apt.notes != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 14, color: KxColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(apt.notes!,
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textMuted)),
                  ),
                ],
              ),
            ],
            if (!isCancelled && !isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (apt.type == AppointmentType.video) ...[
                    Expanded(
                      child: KxButton(
                        label: 'Görüşmeye Katıl',
                        onPressed: () {},
                        variant: KxButtonVariant.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: KxButton(
                      label: 'İptal Et',
                      onPressed: onCancel,
                      variant: KxButtonVariant.ghost,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AppointmentStatus.confirmed => ('Onaylandı', KxColors.jade300),
      AppointmentStatus.pending   => ('Bekliyor',  KxColors.amber300),
      AppointmentStatus.completed => ('Tamamlandı', KxColors.teal400),
      AppointmentStatus.cancelled => ('İptal',     KxColors.crimson300),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: KxSpacing.radiusPill,
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label,
          style: KxTypography.caption.copyWith(color: color)),
    );
  }
}

class _AppointmentSkeleton extends StatelessWidget {
  const _AppointmentSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: KxColors.bgCard,
        highlightColor: KxColors.bgSurface,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius: KxSpacing.radiusMd,
          ),
        ),
      );
}
