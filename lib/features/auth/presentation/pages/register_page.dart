import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../../features/auth/domain/entities/user_role.dart';
import '../bloc/auth_bloc.dart';

/// KONSENXIA Kayıt Sayfası
///
/// 3 adımlı multi-step kayıt formu:
///   Adım 1: Rol seçimi (Doktor / Öğrenci)
///   Adım 2: Kişisel bilgiler (ad, soyad, e-posta, şifre)
///   Adım 3: Mesleki doğrulama (diploma, uzmanlık, kurum)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _step = 0;
  UserRole _role = UserRole.resident;

  // Adım 2
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Adım 3
  final _institutionCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  String? _selectedSpecialty;

  // Hata mesajları
  String? _firstNameErr, _lastNameErr, _emailErr, _passwordErr;
  String? _specialtyErr, _institutionErr;

  // Doğrulama belgesi yüklendi mi?
  bool _documentUploaded = false;

  static const List<String> _specialties = [
    'Dahiliye', 'Kardiyoloji', 'Nöroloji', 'Enfeksiyon Hastalıkları',
    'Göğüs Hastalıkları', 'Ortopedi', 'Genel Cerrahi', 'Radyoloji',
    'Patoloji', 'Pediatri', 'Kadın Hastalıkları', 'Psikiyatri',
    'Dermatoloji', 'Üroloji', 'Göz Hastalıkları', 'KBB',
    'Anesteziyoloji', 'Acil Tıp', 'Aile Hekimliği', 'Diğer',
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _institutionCtrl.dispose();
    _specialtyCtrl.dispose();
    super.dispose();
  }

  bool _validateStep2() {
    bool ok = true;
    setState(() {
      _firstNameErr = _firstNameCtrl.text.trim().isEmpty ? 'Ad gerekli' : null;
      _lastNameErr  = _lastNameCtrl.text.trim().isEmpty  ? 'Soyad gerekli' : null;
      _emailErr     = !_emailCtrl.text.contains('@')     ? 'Geçerli e-posta girin' : null;
      _passwordErr  = _passwordCtrl.text.length < 8     ? 'En az 8 karakter' : null;
      if (_firstNameErr != null || _lastNameErr != null ||
          _emailErr != null || _passwordErr != null) ok = false;
    });
    return ok;
  }

  bool _validateStep3() {
    bool ok = true;
    setState(() {
      _specialtyErr  = _selectedSpecialty == null ? 'Uzmanlık seçin' : null;
      _institutionErr = _institutionCtrl.text.trim().isEmpty ? 'Kurum adı gerekli' : null;
      if (_specialtyErr != null || _institutionErr != null) ok = false;
    });
    return ok;
  }

  void _next() {
    if (_step == 1 && !_validateStep2()) return;
    if (_step == 2 && !_validateStep3()) return;
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _submit() {
    context.read<AuthBloc>().add(
      RegisterEvent(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _role.apiValue,
        specialty: _selectedSpecialty ?? '',
        institution: _institutionCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/dashboard');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: KxColors.crimson500,
              content: Text(state is AuthError ? (state as AuthError).message : "", style: KxTypography.bodyMd),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: KxColors.bgBase,
        body: isWide ? _buildWide() : _buildNarrow(),
      ),
    );
  }

  Widget _buildWide() {
    return Row(
      children: [
        // Sol: adım göstergesi paneli
        Container(
          width: 340,
          decoration: const BoxDecoration(
            color: KxColors.bgSurface,
            border: Border(right: BorderSide(color: KxColors.border)),
          ),
          child: _LeftPanel(step: _step, role: _role),
        ),
        // Sağ: form
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _buildForm(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrow() {
    return SafeArea(
      child: Column(
        children: [
          _StepIndicator(step: _step),
          Expanded(
            child: SingleChildScrollView(
              padding: KxSpacing.screenPadding,
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: switch (_step) {
        0 => _Step1Role(
            key: const ValueKey(0),
            selectedRole: _role,
            onRoleChanged: (r) => setState(() => _role = r),
            onNext: _next,
            onBack: () => context.go('/login'),
          ),
        1 => _Step2Personal(
            key: const ValueKey(1),
            firstNameCtrl: _firstNameCtrl,
            lastNameCtrl: _lastNameCtrl,
            emailCtrl: _emailCtrl,
            passwordCtrl: _passwordCtrl,
            firstNameErr: _firstNameErr,
            lastNameErr: _lastNameErr,
            emailErr: _emailErr,
            passwordErr: _passwordErr,
            onNext: _next,
            onBack: () => setState(() => _step--),
          ),
        _ => _Step3Verify(
            key: const ValueKey(2),
            role: _role,
            specialties: _specialties,
            selectedSpecialty: _selectedSpecialty,
            institutionCtrl: _institutionCtrl,
            specialtyErr: _specialtyErr,
            institutionErr: _institutionErr,
            documentUploaded: _documentUploaded,
            onSpecialtyChanged: (s) => setState(() => _selectedSpecialty = s),
            onDocumentTap: () => setState(() => _documentUploaded = true),
            onNext: _next,
            onBack: () => setState(() => _step--),
          ),
      },
    );
  }
}

// ── Sol Panel (geniş ekran) ────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  final int step;
  final UserRole role;
  const _LeftPanel({required this.step, required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('⚕', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'KONSEN',
                      style: KxTypography.labelLg.copyWith(
                        color: KxColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'xia',
                      style: KxTypography.labelLg.copyWith(
                        color: KxColors.teal400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          Text(
            'Topluluğa katıl.',
            style: KxTypography.displaySm.copyWith(color: KxColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Dünya genelinde ${role.isLearner ? 'tıp öğrencileri ve asistanlar' : 'uzman hekimler'} '
            'ile vaka paylaş, öğren ve katkı yap.',
            style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
          ),

          const SizedBox(height: 48),

          // Adım listesi
          ...[
            ('Rol seçimi', 'Hekim mi, öğrenci mi?'),
            ('Hesap bilgileri', 'Ad, e-posta, şifre'),
            ('Mesleki doğrulama', 'Diploma ve kurum'),
          ].indexed.map(
            (entry) => _StepItem(
              number: entry.$1 + 1,
              title: entry.$2.$1,
              subtitle: entry.$2.$2,
              state: entry.$1 < step
                  ? _StepState.done
                  : entry.$1 == step
                      ? _StepState.active
                      : _StepState.upcoming,
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, active, upcoming }

class _StepItem extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final _StepState state;

  const _StepItem({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StepState.done     => KxColors.jade300,
      _StepState.active   => KxColors.teal400,
      _StepState.upcoming => KxColors.textDisabled,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Center(
              child: state == _StepState.done
                  ? Icon(Icons.check_rounded, size: 14, color: color)
                  : Text(
                      '$number',
                      style: KxTypography.monoSm.copyWith(color: color),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: KxTypography.labelMd.copyWith(color: color),
              ),
              Text(
                subtitle,
                style: KxTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dar ekran adım göstergesi ──────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: BoxDecoration(
                color: i <= step ? KxColors.teal400 : KxColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Adım 1: Rol Seçimi ─────────────────────────────────────────────

class _Step1Role extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step1Role({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: KxSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Kim olarak katılıyorsunuz?', style: KxTypography.headingMd)
              .animate().fadeIn(delay: 50.ms).slideY(begin: 0.08),
          const SizedBox(height: 8),
          Text(
            'Rol, profilinizi ve erişim izinlerinizi belirler.',
            style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          // Admin hariç 4 tıbbi rol
          ...UserRole.values
              .where((r) => r != UserRole.admin)
              .map(
            (role) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RoleOptionCard(
                role: role,
                isSelected: selectedRole == role,
                onTap: () => onRoleChanged(role),
              ),
            ),
          ),
          const SizedBox(height: 32),
          KxButton.primary(
            label: 'Devam et',
            onPressed: onNext,
            isFullWidth: true,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onBack,
              child: Text(
                'Zaten hesabım var',
                style: KxTypography.labelMd.copyWith(color: KxColors.teal400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? KxColors.teal400.withOpacity(0.08) : KxColors.bgCard,
          borderRadius: KxSpacing.radiusLg,
          border: Border.all(
            color: isSelected ? KxColors.teal400 : KxColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(role.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role.displayName, style: KxTypography.labelMd),
                  Text(
                    switch (role) {
                      UserRole.intern     => '5-6. sınıf tıp öğrencisi veya intern',
                      UserRole.resident   => 'Uzmanlık eğitimi alan asistan doktor',
                      UserRole.specialist => 'Diplomalı uzman hekim veya pratisyen',
                      UserRole.professor  => 'Akademisyen, doçent veya profesör',
                      UserRole.admin      => 'Platform yöneticisi',
                    },
                    style: KxTypography.caption,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: KxColors.teal400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Adım 2: Kişisel Bilgiler ───────────────────────────────────────

class _Step2Personal extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl, passwordCtrl;
  final String? firstNameErr, lastNameErr, emailErr, passwordErr;
  final VoidCallback onNext, onBack;

  const _Step2Personal({
    super.key,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    this.firstNameErr,
    this.lastNameErr,
    this.emailErr,
    this.passwordErr,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: KxSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Hesap bilgileriniz', style: KxTypography.headingMd)
              .animate().fadeIn(delay: 50.ms).slideY(begin: 0.08),
          const SizedBox(height: 8),
          Text(
            'Adınız profilinizde diğer hekimlere görünür.',
            style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: KxTextField(
                  controller: firstNameCtrl,
                  label: 'Ad',
                  errorText: firstNameErr,
                  prefixIcon: Icons.person_outline_rounded,
                ).animate().fadeIn(delay: 120.ms),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KxTextField(
                  controller: lastNameCtrl,
                  label: 'Soyad',
                  errorText: lastNameErr,
                ).animate().fadeIn(delay: 150.ms),
              ),
            ],
          ),
          const SizedBox(height: 16),

          KxTextField.email(
            controller: emailCtrl,
            label: 'Kurumsal e-posta',
            errorText: emailErr,
          ).animate().fadeIn(delay: 180.ms),
          const SizedBox(height: 16),

          KxTextField.password(
            controller: passwordCtrl,
            label: 'Şifre',
            errorText: passwordErr,
          ).animate().fadeIn(delay: 210.ms),
          const SizedBox(height: 8),

          Text(
            'En az 8 karakter, büyük harf ve rakam içermelidir.',
            style: KxTypography.caption,
          ).animate().fadeIn(delay: 230.ms),

          const SizedBox(height: 28),

          KxButton.primary(
            label: 'Devam et',
            onPressed: onNext,
            isFullWidth: true,
          ).animate().fadeIn(delay: 260.ms),
          const SizedBox(height: 12),
          KxButton.ghost(
            label: '← Geri',
            onPressed: onBack,
            isFullWidth: true,
          ).animate().fadeIn(delay: 280.ms),
        ],
      ),
    );
  }
}

// ── Adım 3: Mesleki Doğrulama ──────────────────────────────────────

class _Step3Verify extends StatelessWidget {
  final UserRole role;
  final List<String> specialties;
  final String? selectedSpecialty;
  final TextEditingController institutionCtrl;
  final String? specialtyErr, institutionErr;
  final bool documentUploaded;
  final ValueChanged<String?> onSpecialtyChanged;
  final VoidCallback onDocumentTap;
  final VoidCallback onNext, onBack;

  const _Step3Verify({
    super.key,
    required this.role,
    required this.specialties,
    required this.selectedSpecialty,
    required this.institutionCtrl,
    this.specialtyErr,
    this.institutionErr,
    required this.documentUploaded,
    required this.onSpecialtyChanged,
    required this.onDocumentTap,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: KxSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Mesleki doğrulama', style: KxTypography.headingMd)
              .animate().fadeIn(delay: 50.ms).slideY(begin: 0.08),
          const SizedBox(height: 8),
          Text(
            role.requiresDocument
                ? 'Diploma ve uzmanlık belgesini yükleyin. '
                  'Ekibimiz 24 saat içinde doğrular.'
                : 'Öğrenci kimliğini veya transkripti yükleyin.',
            style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          // Uzmanlık seçici
          _SpecialtyDropdown(
            specialties: specialties,
            selected: selectedSpecialty,
            errorText: specialtyErr,
            onChanged: onSpecialtyChanged,
          ).animate().fadeIn(delay: 130.ms),
          const SizedBox(height: 16),

          KxTextField(
            controller: institutionCtrl,
            label: 'Çalıştığınız / Okuduğunuz Kurum',
            errorText: institutionErr,
            prefixIcon: Icons.business_outlined,
          ).animate().fadeIn(delay: 160.ms),
          const SizedBox(height: 16),

          // Belge yükleme
          _DocumentUpload(
            uploaded: documentUploaded,
            onTap: onDocumentTap,
            label: role.requiresDocument ? 'Diploma / Uzmanlık belgesi' : 'Öğrenci kimliği veya transkript',
          ).animate().fadeIn(delay: 190.ms),
          const SizedBox(height: 8),

          // Gizlilik notu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KxColors.teal400.withOpacity(0.06),
              borderRadius: KxSpacing.radiusMd,
              border: Border.all(color: KxColors.teal400.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    size: 16, color: KxColors.teal400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Belgeler yalnızca doğrulama için kullanılır. '
                    'KVKK ve GDPR kapsamında korunur.',
                    style: KxTypography.caption.copyWith(
                      color: KxColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 210.ms),

          const SizedBox(height: 28),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return KxButton.primary(
                label: 'Kayıt ol',
                onPressed: onNext,
                isLoading: state is AuthLoading,
                isFullWidth: true,
              ).animate().fadeIn(delay: 240.ms);
            },
          ),
          const SizedBox(height: 12),
          KxButton.ghost(
            label: '← Geri',
            onPressed: onBack,
            isFullWidth: true,
          ).animate().fadeIn(delay: 260.ms),
        ],
      ),
    );
  }
}

// ── Uzmanlık Dropdown ──────────────────────────────────────────────

class _SpecialtyDropdown extends StatelessWidget {
  final List<String> specialties;
  final String? selected;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  const _SpecialtyDropdown({
    required this.specialties,
    required this.selected,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Uzmanlık / Bölüm', style: KxTypography.labelSm),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius: KxSpacing.radiusMd,
            border: Border.all(
              color: errorText != null ? KxColors.crimson400 : KxColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'Uzmanlık seçin',
                  style: KxTypography.bodyMd.copyWith(
                    color: KxColors.textDisabled,
                  ),
                ),
              ),
              dropdownColor: KxColors.bgElevated,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              borderRadius: KxSpacing.radiusMd,
              style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: KxColors.textMuted),
              items: specialties
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: KxTypography.caption.copyWith(color: KxColors.crimson400),
          ),
        ],
      ],
    );
  }
}

// ── Belge Yükleme ──────────────────────────────────────────────────

class _DocumentUpload extends StatelessWidget {
  final bool uploaded;
  final VoidCallback onTap;
  final String label;

  const _DocumentUpload({
    required this.uploaded,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: uploaded
              ? KxColors.jade500.withOpacity(0.06)
              : KxColors.bgCard,
          borderRadius: KxSpacing.radiusLg,
          border: Border.all(
            color: uploaded ? KxColors.jade300 : KxColors.border,
            style: uploaded ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              uploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
              size: 32,
              color: uploaded ? KxColors.jade300 : KxColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              uploaded ? 'Belge yüklendi ✓' : label,
              style: KxTypography.labelMd.copyWith(
                color: uploaded ? KxColors.jade300 : KxColors.textSecondary,
              ),
            ),
            if (!uploaded) ...[
              const SizedBox(height: 4),
              Text(
                'PDF, JPG veya PNG · Maks. 5MB',
                style: KxTypography.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
