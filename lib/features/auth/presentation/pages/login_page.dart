import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user_role.dart';
import '../bloc/auth_bloc.dart';
import '../../../../design_system/design_system.dart';

/// KONSENXIA — Login Page
/// Clinical Noir aesthetic. Responsive: mobile single-column,
/// tablet/desktop split-screen.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: KxColors.bgBase,
      body: _LoginView(),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _LoginView — ana stateful widget
// ════════════════════════════════════════════════════════════════

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.resident;
  String?  _emailError;
  String?  _passwordError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;

      if (_emailCtrl.text.trim().isEmpty) {
        _emailError = 'E-posta adresi zorunludur';
        valid = false;
      } else if (!_emailCtrl.text.contains('@')) {
        _emailError = 'Geçerli bir e-posta adresi girin';
        valid = false;
      }

      if (_passwordCtrl.text.isEmpty) {
        _passwordError = 'Şifre zorunludur';
        valid = false;
      } else if (_passwordCtrl.text.length < 6) {
        _passwordError = 'Şifre en az 6 karakter olmalıdır';
        valid = false;
      }
    });
    return valid;
  }

  void _onLogin() {
    // Dismiss keyboard before processing
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    debugPrint('[LOGIN] Dispatching LoginEvent for: ${_emailCtrl.text.trim()}');
    context.read<AuthBloc>().add(
      LoginEvent(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _selectedRole.apiValue,
      ),
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      // Navigate to dashboard on successful login
      context.go('/dashboard');
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: KxColors.crimson300, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
                ),
              ),
            ],
          ),
          backgroundColor: KxColors.bgElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
            side: BorderSide(color: KxColors.crimson500.withOpacity(0.3)),
          ),
        ),
      );
    } else if (state is AuthPasswordResetSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: KxColors.teal400, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sifre sifirlama baglantisi ${state.email} adresine gonderildi.',
                  style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
                ),
              ),
            ],
          ),
          backgroundColor: KxColors.bgElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
            side: BorderSide(color: KxColors.teal500.withOpacity(0.3)),
          ),
        ),
      );
    } else if (state is AuthPasswordResetError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: KxColors.crimson300, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
                ),
              ),
            ],
          ),
          backgroundColor: KxColors.bgElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
            side: BorderSide(color: KxColors.crimson500.withOpacity(0.3)),
          ),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController();
    String? resetEmailError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: KxColors.bgSurface,
              shape: RoundedRectangleBorder(
                borderRadius: KxSpacing.radiusLg,
                side: const BorderSide(color: KxColors.border),
              ),
              title: Text(
                'Sifre Sifirlama',
                style: KxTypography.displaySm.copyWith(fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kayitli e-posta adresinizi girin. Sifre sifirlama baglantisi gonderilecektir.',
                    style: KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  KxTextField(
                    label: 'E-posta',
                    hint: 'doktor@hastane.com.tr',
                    prefixIcon: Icons.alternate_email_rounded,
                    controller: resetEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    errorText: resetEmailError,
                    onChanged: (_) {
                      if (resetEmailError != null) {
                        setDialogState(() => resetEmailError = null);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Iptal',
                    style: KxTypography.labelMd.copyWith(color: KxColors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final email = resetEmailCtrl.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      setDialogState(() {
                        resetEmailError = 'Gecerli bir e-posta adresi girin';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    context.read<AuthBloc>().add(
                      ForgotPasswordEvent(email: email),
                    );
                  },
                  child: Text(
                    'Gonder',
                    style: KxTypography.labelMd.copyWith(color: KxColors.teal400),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 860;
          return isWide ? _buildWideLayout() : _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(child: _HeroPanel(selectedRole: _selectedRole)),
        SizedBox(
          width: 440,
          child: _buildFormPanel(isWide: true),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Row(
                children: [
                  _LogoMark(size: 34),
                  const SizedBox(width: 10),
                  const _WordMark(fontSize: 20),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, curve: Curves.easeOut),
            ),
            const SizedBox(height: 32),
            _buildFormPanel(isWide: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPanel({required bool isWide}) {
    return Container(
      height: isWide ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24),
      decoration: BoxDecoration(
        color: isWide ? KxColors.bgSurface : KxColors.bgBase,
        border: isWide
            ? const Border(left: BorderSide(color: KxColors.border))
            : null,
      ),
      child: isWide
          ? Center(child: _buildFormContent(isWide: true))
          : _buildFormContent(isWide: false),
    );
  }

  Widget _buildFormContent({required bool isWide}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isWide ? 360 : double.infinity),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWide) const SizedBox(height: 60),

            Text('Hesabınıza Girin', style: KxTypography.displaySm)
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms)
                .slideY(begin: 0.15, curve: Curves.easeOut),

            const SizedBox(height: 6),

            Text(
              'Tıbbi doğrulama gerektiren profesyonel platform.',
              style: KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
            ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

            const SizedBox(height: 28),

            Text('Hesap Türü',
                style: KxTypography.labelSm.copyWith(
                  color: KxColors.textSecondary,
                ))
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: 8),

            _RoleSelector(
              selected: _selectedRole,
              onChanged: (role) => setState(() => _selectedRole = role),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 250.ms)
                .slideY(begin: 0.1, curve: Curves.easeOut),

            const SizedBox(height: 20),

            KxTextField(
              label: 'Kurumsal E-posta',
              hint: 'doktor@hastane.com.tr',
              prefixIcon: Icons.alternate_email_rounded,
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
              },
              errorText: _emailError,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.1, curve: Curves.easeOut),

            const SizedBox(height: 16),

            KxTextField.password(
              label: 'Şifre',
              controller: _passwordCtrl,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_passwordError != null) setState(() => _passwordError = null);
              },
              onSubmitted: (_) => _onLogin(),
              errorText: _passwordError,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 350.ms)
                .slideY(begin: 0.1, curve: Curves.easeOut),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Şifremi Unuttum',
                    style: KxTypography.labelSm.copyWith(color: KxColors.teal400)),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 380.ms),

            const SizedBox(height: 22),

            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (prev, curr) =>
                  curr is AuthLoading || prev is AuthLoading,
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return KxButton.primary(
                  label: isLoading ? 'Giriş yapılıyor...' : '⚕  Giriş Yap',
                  isLoading: isLoading,
                  isFullWidth: true,
                  size: KxButtonSize.lg,
                  onPressed: isLoading ? null : _onLogin,
                );
              },
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms)
                .slideY(begin: 0.1, curve: Curves.easeOut),

            const SizedBox(height: 18),

            Row(
              children: [
                const Expanded(child: Divider(color: KxColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ya da', style: KxTypography.caption),
                ),
                const Expanded(child: Divider(color: KxColors.border)),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 440.ms),

            const SizedBox(height: 16),

            KxButton.secondary(
              label: 'Google ile Giriş',
              icon: Icons.language_rounded,
              isFullWidth: true,
              size: KxButtonSize.lg,
              onPressed: () {},
            ).animate().fadeIn(duration: 500.ms, delay: 460.ms),

            const SizedBox(height: 24),

            const _MedicalVerificationNote()
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),

            const SizedBox(height: 24),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hesabınız yok mu? ',
                    style: KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text(
                      'Kayıt Olun →',
                      style: KxTypography.labelMd.copyWith(color: KxColors.teal400),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 540.ms),

            SizedBox(height: isWide ? 60 : 32),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// HERO PANEL
// ════════════════════════════════════════════════════════════════

class _HeroPanel extends StatelessWidget {
  final UserRole selectedRole;
  const _HeroPanel({required this.selectedRole});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KxColors.bgBase,
      child: Stack(
        children: [
          const _BackgroundEffects(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _LogoMark(size: 40),
                      const SizedBox(width: 12),
                      const _WordMark(fontSize: 24),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, curve: Curves.easeOut),

                  const SizedBox(height: 72),

                  RichText(
                    text: TextSpan(
                      style: KxTypography.displayLg.copyWith(height: 1.1),
                      children: const [
                        TextSpan(text: 'Tıbbın\n'),
                        TextSpan(
                          text: 'Kolektif ',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: KxColors.teal300,
                          ),
                        ),
                        TextSpan(text: 'Zekası.'),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 700.ms, delay: 100.ms)
                      .slideY(begin: 0.15, curve: Curves.easeOut),

                  const SizedBox(height: 20),

                  Text(
                    'Dünya genelindeki doktorların anonim vaka paylaşımı '
                    've AI destekli konsültasyon platformu.',
                    style: KxTypography.bodyLg.copyWith(
                      color: KxColors.textSecondary,
                      height: 1.7,
                    ),
                  ).animate().fadeIn(duration: 700.ms, delay: 200.ms),

                  const SizedBox(height: 48),

                  const _StatsRow()
                      .animate()
                      .fadeIn(duration: 700.ms, delay: 300.ms),

                  const SizedBox(height: 48),

                  const _LiveCasePreview()
                      .animate()
                      .fadeIn(duration: 700.ms, delay: 450.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOut),

                  const Spacer(),

                  Text(
                    '© 2024 KONSENXIA  ·  GDPR & KVKK Uyumlu  ·  Tüm veriler anonimleştirilmiştir',
                    style: KxTypography.overline.copyWith(fontSize: 9),
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// YARDIMCI WİDGET'LAR
// ════════════════════════════════════════════════════════════════

class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: KxSpacing.radiusMd,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KxColors.teal500, KxColors.blue400],
        ),
        boxShadow: KxShadows.tealGlow(opacity: 0.3),
      ),
      alignment: Alignment.center,
      child: Text('⚕', style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

class _WordMark extends StatelessWidget {
  final double fontSize;
  const _WordMark({required this.fontSize, super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: KxTypography.displaySm.copyWith(
          fontSize: fontSize,
          letterSpacing: -0.5,
        ),
        children: const [
          TextSpan(text: 'KONSEN'),
          TextSpan(
            text: 'xia',
            style: TextStyle(
              color: KxColors.teal300,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundEffects extends StatelessWidget {
  const _BackgroundEffects();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  KxColors.teal500.withOpacity(0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -150, right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  KxColors.blue400.withOpacity(0.05),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Opacity(
            opacity: 0.025,
            child: GridPaper(
              color: Colors.white,
              interval: 40,
              divisions: 1,
              subdivisions: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(value: '12K+', label: 'Aktif Hekim'),
        _Separator(),
        _StatItem(value: '47', label: 'Ülke'),
        _Separator(),
        _StatItem(value: '8.4K', label: 'Çözülen Vaka'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: KxTypography.displaySm.copyWith(
              color: KxColors.textPrimary, fontSize: 28,
            )),
        const SizedBox(height: 2),
        Text(label, style: KxTypography.caption),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36, width: 1,
      color: KxColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 28),
    );
  }
}

class _LiveCasePreview extends StatelessWidget {
  const _LiveCasePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.border),
        boxShadow: KxShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const KxBadge('Canlı Vaka', variant: KxBadgeVariant.amber, hasDot: true),
              const Spacer(),
              Text('KNX-2024-1847', style: KxTypography.caseId),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: KxTypography.bodyMd.copyWith(
                color: KxColors.textSecondary, height: 1.6,
              ),
              children: [
                TextSpan(
                  text: '42Y/E, STEMI şüphesi. ',
                  style: KxTypography.labelMd.copyWith(color: KxColors.textPrimary),
                ),
                const TextSpan(
                  text: 'EKG\'de anterior ST elevasyonu mevcut. Troponin T yüksek. '
                      'Acil kateterizasyon kararı için 3 ülkeden kardiyolog görüşü bekleniyor...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              KxAvatar(name: 'Dr. T. Kim', size: KxAvatarSize.sm),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. T. Kim',
                      style: KxTypography.labelSm.copyWith(color: KxColors.textPrimary)),
                  Text('Seul, Güney Kore', style: KxTypography.caption),
                ],
              ),
              const Spacer(),
              KxBadge.teal('💬 7 yanıt'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicalVerificationNote extends StatelessWidget {
  const _MedicalVerificationNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KxColors.teal500.withOpacity(0.06),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.teal500.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚕', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tıbbi Doğrulama Hakkında',
                    style: KxTypography.labelSm.copyWith(color: KxColors.teal300)),
                const SizedBox(height: 4),
                Text(
                  'İlk girişinizde diploma veya uzmanlık belgesi yüklemeniz istenecektir. '
                  'Doğrulama 24 saat içinde tamamlanır.',
                  style: KxTypography.bodySm.copyWith(
                    color: KxColors.textMuted, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ROL SEÇİCİ
// ════════════════════════════════════════════════════════════════

class _RoleSelector extends StatelessWidget {
  final UserRole selected;
  final void Function(UserRole) onChanged;

  const _RoleSelector({required this.selected, required this.onChanged});

  // Admin hariç sadece 4 tıbbi rol
  static const _roles = [
    UserRole.intern,
    UserRole.resident,
    UserRole.specialist,
    UserRole.professor,
  ];

  @override
  Widget build(BuildContext context) {
    // 2x2 grid — küçük ekranlarda sığsın
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                role: _roles[0],
                isSelected: _roles[0] == selected,
                onTap: () => onChanged(_roles[0]),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RoleCard(
                role: _roles[1],
                isSelected: _roles[1] == selected,
                onTap: () => onChanged(_roles[1]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                role: _roles[2],
                isSelected: _roles[2] == selected,
                onTap: () => onChanged(_roles[2]),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RoleCard(
                role: _roles[3],
                isSelected: _roles[3] == selected,
                onTap: () => onChanged(_roles[3]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatefulWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.scale(scale: _ctrl.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.animateTo(0.97),
        onTapUp:   (_) => _ctrl.animateTo(1.0),
        onTapCancel: () => _ctrl.animateTo(1.0),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: KxSpacing.radiusLg,
            color: widget.isSelected
                ? KxColors.teal400.withOpacity(0.08)
                : KxColors.bgElevated,
            border: Border.all(
              color: widget.isSelected ? KxColors.teal400 : KxColors.border,
              width: widget.isSelected ? 1.5 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? KxShadows.tealGlow(opacity: 0.1)
                : null,
          ),
          child: Column(
            children: [
              Text(widget.role.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                widget.role.displayName,
                textAlign: TextAlign.center,
                style: KxTypography.labelSm.copyWith(
                  color: widget.isSelected
                      ? KxColors.teal300
                      : KxColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
