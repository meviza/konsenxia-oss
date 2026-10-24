import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/search_bloc.dart';
import '../../domain/entities/search_result.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _FilterChips(),
          Expanded(child: _Results()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: KxColors.bgSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: KxColors.textSecondary),
        onPressed: () => context.pop(),
      ),
      title: TextField(
        controller: _ctrl,
        autofocus: true,
        style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Vaka veya doktor ara...',
          hintStyle:
              KxTypography.bodyMd.copyWith(color: KxColors.textDisabled),
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: (q) =>
            context.read<SearchBloc>().add(QueryChangedEvent(q)),
      ),
      actions: [
        BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: KxColors.textMuted),
              onPressed: () {
                _ctrl.clear();
                context.read<SearchBloc>().add(const ClearSearchEvent());
              },
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(color: KxColors.border, height: 1),
      ),
    );
  }
}

// ── Filter chips ────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        SearchFilter? active;
        if (state is SearchLoaded) active = state.activeFilter;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _Chip(
                label: 'Tumu',
                isActive: active == null,
                onTap: () => context
                    .read<SearchBloc>()
                    .add(const FilterChangedEvent(null)),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: 'Vakalar',
                isActive: active == SearchFilter.cases,
                onTap: () => context
                    .read<SearchBloc>()
                    .add(const FilterChangedEvent(SearchFilter.cases)),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: 'Doktorlar',
                isActive: active == SearchFilter.doctors,
                onTap: () => context
                    .read<SearchBloc>()
                    .add(const FilterChangedEvent(SearchFilter.doctors)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? KxColors.teal400 : KxColors.bgCard,
          borderRadius: KxSpacing.radiusPill,
          border: Border.all(
            color: isActive ? KxColors.teal400 : KxColors.border,
          ),
        ),
        child: Text(
          label,
          style: KxTypography.labelSm.copyWith(
            color: isActive ? KxColors.bgVoid : KxColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Results ─────────────────────────────────────────────────────────

class _Results extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return _Placeholder();
        }

        if (state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(color: KxColors.teal400),
          );
        }

        if (state is SearchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 48, color: KxColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: KxTypography.bodyMd
                        .copyWith(color: KxColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is SearchLoaded) {
          if (state.results.isEmpty) {
            return Center(
              child: Text(
                '"${state.query}" icin sonuc bulunamadi',
                style: KxTypography.bodyMd
                    .copyWith(color: KxColors.textSecondary),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (state.cases.isNotEmpty) ...[
                _SectionHeader('Vakalar (${state.cases.length})'),
                ...state.cases.map((r) => _ResultTile(result: r)),
              ],
              if (state.doctors.isNotEmpty) ...[
                _SectionHeader('Doktorlar (${state.doctors.length})'),
                ...state.doctors.map((r) => _DoctorResultTile(result: r)),
              ],
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(title,
          style:
              KxTypography.caption.copyWith(color: KxColors.textMuted)),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final SearchResult result;

  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (result.route != null) context.push(result.route!);
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: KxColors.teal400.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.folder_outlined,
          size: 18,
          color: KxColors.teal400,
        ),
      ),
      title: Text(result.title, style: KxTypography.labelMd),
      subtitle: Text(
        result.subtitle,
        style: KxTypography.caption.copyWith(color: KxColors.textMuted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          size: 18, color: KxColors.textMuted),
    );
  }
}

/// Doctor result tile with name, specialty, role, institution + Ekle / Mesaj buttons
class _DoctorResultTile extends StatelessWidget {
  final SearchResult result;

  const _DoctorResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: KxColors.blue400.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: KxColors.blue400,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.title,
                    style: KxTypography.labelMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  result.subtitle,
                  style: KxTypography.caption
                      .copyWith(color: KxColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ekle button (add as assistant)
              _ActionChip(
                label: 'Ekle',
                icon: Icons.person_add_alt_1_rounded,
                color: KxColors.teal400,
                onTap: () => _addAsAssistant(context, result),
              ),
              const SizedBox(width: 6),
              // Mesaj button (direct message)
              _ActionChip(
                label: 'Mesaj',
                icon: Icons.chat_bubble_outline_rounded,
                color: KxColors.blue400,
                onTap: () => context.push('/messages'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addAsAssistant(BuildContext context, SearchResult result) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: KxColors.crimson400,
            content: Text('Lutfen giris yapin.',
                style: KxTypography.bodyMd.copyWith(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Write to team_members collection
      final teamRef = firestore
          .collection('team_members')
          .doc('${currentUser.uid}_${result.id}');
      batch.set(teamRef, {
        'professorId': currentUser.uid,
        'assistantId': result.id,
        'assistantName': result.title,
        'assistantRole': result.role ?? '',
        'addedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      // Send notification to the added doctor
      final notifRef = firestore
          .collection('notifications')
          .doc(result.id)
          .collection('items')
          .doc();
      batch.set(notifRef, {
        'id': notifRef.id,
        'type': 'team_added',
        'title': 'Ekibe Eklendiz',
        'body': '${currentUser.displayName ?? "Bir profesor"} sizi ekibine ekledi.',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: KxColors.bgElevated,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: KxColors.jade300, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${result.title} ekibe eklendi.',
                  style: KxTypography.bodyMd
                      .copyWith(color: KxColors.textPrimary),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: KxColors.crimson400,
          content: Text(
            'Eklenemedi: $e',
            style: KxTypography.bodyMd.copyWith(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: KxSpacing.radiusSm,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: KxTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded,
                size: 48, color: KxColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Vaka veya doktor aramak icin\nyukariya yazmaya baslayin',
              style: KxTypography.bodyMd
                  .copyWith(color: KxColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
