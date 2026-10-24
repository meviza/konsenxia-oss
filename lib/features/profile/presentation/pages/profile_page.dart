import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../dashboard/domain/entities/dashboard_summary.dart';
import '../bloc/profile_bloc.dart';

/// KONSENXIA Profil Sayfası
///
/// Kullanıcı profil bilgileri, istatistikler, XP/level, ayarlar.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: isWide ? _buildWide() : _buildNarrow(),
    );
  }

  Widget _buildWide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: _ProfileContent(),
    );
  }

  Widget _buildNarrow() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _ProfileContent(),
      ),
    );
  }

}

// ── İçerik ──────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  String _roleTitleTurkish(String role) => switch (role) {
    'PROFESSOR'  => 'Profesor',
    'SPECIALIST' => 'Uzman Doktor',
    'RESIDENT'   => 'Asistan Doktor',
    'INTERN'     => 'Intern',
    _            => role,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(80),
              child: CircularProgressIndicator(color: KxColors.teal400),
            ),
          );
        }

        final stats = state is ProfileLoaded ? state.stats : null;
        final name = stats?.displayName ?? 'Dr. Kullanici';
        final specialty = stats?.specialty ?? 'Uzman Doktor';
        final level = stats?.level ?? 1;
        // Use Firestore role if available, otherwise fall back to XP-based levelTitle
        final firestoreRole = stats?.role ?? '';
        final levelTitle = firestoreRole.isNotEmpty
            ? _roleTitleTurkish(firestoreRole)
            : (stats?.levelTitle ?? 'Intern');
        final xpCurrent = stats?.xpCurrent ?? 0;
        final xpTotal = stats?.xpTotal ?? 1000;
        final totalCases = stats?.totalCases ?? 0;
        final totalContribs = stats?.totalContributions ?? 0;
        final countries = stats?.totalCountries ?? 0;
        final rank = stats?.rank;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profil başlığı ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: KxColors.bgCard,
                borderRadius: KxSpacing.radiusXl,
                border: Border.all(color: KxColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      KxAvatar(
                        name: name,
                        imageUrl: stats?.photoUrl,
                        size: KxAvatarSize.xl,
                        level: level,
                        showLevelRing: true,
                        isOnline: true,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: KxTypography.headingMd,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                KxBadge.amber('Lvl $level'),
                                KxBadge.teal(levelTitle),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              specialty,
                              style: KxTypography.bodyMd
                                  .copyWith(color: KxColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  KxProgressBar.xp(
                    current: xpCurrent,
                    total: xpTotal,
                    level: level,
                    levelName: levelTitle,
                  ),
                  const SizedBox(height: 12),
                  // Düzenle butonu
                  KxButton.secondary(
                    label: 'Düzenle',
                    onPressed: stats == null
                        ? null
                        : () => _showEditSheet(context, stats),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── İstatistikler (2x2 grid) ──────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final boxWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: boxWidth,
                      child: _StatBox(
                        icon: Icons.folder_rounded,
                        label: 'Vakalar',
                        value: totalCases.toString(),
                        color: KxColors.teal400,
                      ),
                    ),
                    SizedBox(
                      width: boxWidth,
                      child: _StatBox(
                        icon: Icons.group_rounded,
                        label: 'Katkılar',
                        value: totalContribs.toString(),
                        color: KxColors.blue400,
                      ),
                    ),
                    SizedBox(
                      width: boxWidth,
                      child: _StatBox(
                        icon: Icons.public_rounded,
                        label: 'Ülkeler',
                        value: countries.toString(),
                        color: KxColors.amber300,
                      ),
                    ),
                    SizedBox(
                      width: boxWidth,
                      child: _StatBox(
                        icon: Icons.leaderboard_rounded,
                        label: 'Sıralama',
                        value: rank != null ? '#$rank' : '-',
                        color: KxColors.jade300,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Uzmanlık etiketleri ──────────────────────────────
            Text('Uzmanlık Alanları', style: KxTypography.headingSm),
            const SizedBox(height: 10),
            KxTagRow(
              tags: stats != null ? [stats.specialty] : ['Dahiliye'],
              isSpecialty: true,
            ),

            const SizedBox(height: 24),

            // ── AI Profil Modları ─────────────────────────────────
            Text('AI Asistan Modları', style: KxTypography.headingSm),
            const SizedBox(height: 10),
            _AiModeTile(
              icon: Icons.account_tree_rounded,
              label: 'Diferansiyel Tanı',
              subtitle: 'Semptomlardan olası tanıları sırala',
              color: KxColors.teal400,
              onTap: () => context.push('/differential-diagnosis'),
            ),
            _AiModeTile(
              icon: Icons.science_rounded,
              label: 'Kanıta Dayalı Tıp',
              subtitle: 'Kılavuz ve meta-analiz sorgulama',
              color: KxColors.blue400,
              onTap: () => context.push('/evidence-based'),
            ),
            _AiModeTile(
              icon: Icons.medication_rounded,
              label: 'İlaç Etkileşim Analizi',
              subtitle: 'CYP450 etkileşim ve doz kontrolü',
              color: KxColors.amber300,
              onTap: () => context.push('/drug-analysis'),
            ),
            _AiModeTile(
              icon: Icons.folder_open_rounded,
              label: 'Vaka İnceleme',
              subtitle: 'Sistematik değerlendirme ve risk skoru',
              color: KxColors.jade300,
              onTap: () => context.push('/case-review'),
            ),

            const SizedBox(height: 24),

            // ── Ayarlar ──────────────────────────────────────────
            Text('Ayarlar', style: KxTypography.headingSm),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.settings_rounded,
              label: 'Ayarlar',
              onTap: () => context.push('/settings'),
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Bildirimler',
              onTap: () => context.push('/notifications'),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Gizlilik & KVKK',
              onTap: () => context.push('/kvkk'),
            ),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              label: 'Destek',
              onTap: () => context.push('/support'),
            ),
            const SizedBox(height: 16),
            KxButton.danger(
              label: 'Çıkış Yap',
              onPressed: () async {
                final prefs = GetIt.instance<SharedPreferences>();
                await prefs.remove('auth_token');
                await prefs.remove('auth_user');
                context.read<AuthBloc>().add(LogoutEvent());
                if (context.mounted) context.go('/login');
              },
              isFullWidth: true,
            ),
          ],
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, UserStats stats) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KxColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: _ProfileEditSheet(stats: stats),
      ),
    );
  }
}

// ── Edit Sheet ───────────────────────────────────────────────────────────────

class _ProfileEditSheet extends StatefulWidget {
  final UserStats stats;
  const _ProfileEditSheet({required this.stats});

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _specialtyCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _institutionCtrl;
  late final TextEditingController _bioCtrl;

  bool _savingInitiated = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.stats.displayName);
    _specialtyCtrl = TextEditingController(text: widget.stats.specialty);
    _titleCtrl = TextEditingController();
    _institutionCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specialtyCtrl.dispose();
    _titleCtrl.dispose();
    _institutionCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (_savingInitiated &&
            state is ProfileLoaded &&
            !state.isUpdating) {
          _savingInitiated = false;
          if (state.updateError == null) {
            Navigator.of(context).pop(); // başarılı → kapat
          }
        }
      },
      builder: (context, state) {
        final isUpdating =
            state is ProfileLoaded && state.isUpdating;
        final error =
            state is ProfileLoaded ? state.updateError : null;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: KxColors.border,
                    borderRadius: KxSpacing.radiusPill,
                  ),
                ),
              ),

              Text('Profili Düzenle',
                  style: KxTypography.headingSm),
              const SizedBox(height: 20),

              // Hata mesajı
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: KxColors.crimson400.withOpacity(0.1),
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(
                        color: KxColors.crimson400.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: KxColors.crimson400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(error,
                            style: KxTypography.labelSm.copyWith(
                                color: KxColors.crimson400)),
                      ),
                    ],
                  ),
                ),
              ],

              // İsim
              _SheetLabel('Ad Soyad'),
              const SizedBox(height: 6),
              KxTextField(controller: _nameCtrl, hint: 'Ad Soyad'),
              const SizedBox(height: 14),

              // Uzmanlık
              _SheetLabel('Uzmanlık'),
              const SizedBox(height: 6),
              KxTextField(
                  controller: _specialtyCtrl,
                  hint: 'Ör. Kardiyoloji'),
              const SizedBox(height: 14),

              // Unvan
              _SheetLabel('Unvan'),
              const SizedBox(height: 6),
              KxTextField(
                  controller: _titleCtrl, hint: 'Ör. Uzm. Dr.'),
              const SizedBox(height: 14),

              // Kurum
              _SheetLabel('Kurum'),
              const SizedBox(height: 6),
              KxTextField(
                  controller: _institutionCtrl,
                  hint: 'Çalıştığınız hastane / klinik'),
              const SizedBox(height: 14),

              // Biyografi
              _SheetLabel('Biyografi'),
              const SizedBox(height: 6),
              KxTextField(
                  controller: _bioCtrl,
                  hint: 'Kendinizden kısaca bahsedin...',
                  maxLines: 2),
              const SizedBox(height: 24),

              // Kaydet
              SizedBox(
                width: double.infinity,
                child: isUpdating
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: KxColors.teal400))
                    : KxButton(
                        label: 'Kaydet',
                        onPressed: _save,
                        variant: KxButtonVariant.primary,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final specialty = _specialtyCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    final institution = _institutionCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    _savingInitiated = true;
    context.read<ProfileBloc>().add(UpdateProfileEvent(
      displayName: name.isEmpty ? null : name,
      specialty: specialty.isEmpty ? null : specialty,
      bio: bio.isEmpty ? null : bio,
      institution: institution.isEmpty ? null : institution,
      title: title.isEmpty ? null : title,
    ));
  }
}

// ── Alt yardımcılar ──────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: KxTypography.labelSm
            .copyWith(color: KxColors.textSecondary),
      );
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: KxTypography.monoMd.copyWith(
              color: KxColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: KxTypography.caption,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Icon(icon, color: KxColors.textSecondary, size: 20),
      title: Text(label, style: KxTypography.bodyMd),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: KxColors.textMuted, size: 18),
      onTap: onTap,
    );
  }
}

class _AiModeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AiModeTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: KxSpacing.radiusMd,
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: KxSpacing.radiusMd,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: KxTypography.labelMd
                            .copyWith(color: KxColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
