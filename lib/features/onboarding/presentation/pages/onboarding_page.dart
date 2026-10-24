import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../../../design_system/animations/kx_pressable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KONSENXIA Onboarding — Apple Design Award Quality
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingPage({super.key, required this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _bgAnimController;
  late final AnimationController _contentAnimController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        setState(() => _currentPage = _pageController.page ?? 0);
      });

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    HapticFeedback.selectionClick();
    _contentAnimController.reset();
    _contentAnimController.forward();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage.round() < 3) {
      _goToPage(_currentPage.round() + 1);
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: Stack(
        children: [
          // ── Background gradient ──
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, _) => CustomPaint(
              painter: _BackgroundPainter(
                progress: _bgAnimController.value,
                page: _currentPage,
              ),
              size: Size.infinite,
            ),
          ),

          // ── Page content ──
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (_) => HapticFeedback.selectionClick(),
            children: [
              _HeroScreen(currentPage: _currentPage, pageIndex: 0),
              _VakaSimulasyonScreen(currentPage: _currentPage, pageIndex: 1),
              _AcilKonsultasyonScreen(currentPage: _currentPage, pageIndex: 2),
              _AyiriciTaniScreen(currentPage: _currentPage, pageIndex: 3),
            ],
          ),

          // ── Bottom controls ──
          Positioned(
            left: KxSpacing.xl2,
            right: KxSpacing.xl2,
            bottom: safePadding.bottom + KxSpacing.xl4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dot indicator
                _DotIndicator(currentPage: _currentPage),
                const SizedBox(height: KxSpacing.xl4),

                // CTA button
                KxPressable(
                  onTap: _nextPage,
                  hapticType: HapticType.medium,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: KxColors.teal400,
                      borderRadius: KxSpacing.radiusXl,
                      boxShadow: _currentPage.round() == 3
                          ? KxShadows.tealGlowStrong()
                          : KxShadows.tealGlow(),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _currentPage.round() == 3 ? 'Basla' : 'Devam',
                        key: ValueKey(_currentPage.round() == 3),
                        style: KxTypography.headingMd.copyWith(
                          color: KxColors.bgBase,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: KxSpacing.lg),

                // Skip button (screens 0-2)
                AnimatedOpacity(
                  opacity: _currentPage.round() < 3 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: GestureDetector(
                    onTap: _currentPage.round() < 3
                        ? () {
                            HapticFeedback.selectionClick();
                            widget.onComplete();
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: KxSpacing.sm),
                      child: Text(
                        'Atla',
                        style: KxTypography.labelLg.copyWith(
                          color: KxColors.textMuted,
                        ),
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Dot Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final double currentPage;
  const _DotIndicator({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final distance = (currentPage - i).abs().clamp(0.0, 1.0);
        final width = lerpDouble(24.0, 6.0, distance)!;
        final color = Color.lerp(KxColors.teal400, KxColors.textMuted, distance)!;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: KxSpacing.radiusFull,
          ),
        );
      }),
    );
  }

  static double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen wrapper — handles parallax slide-up + fade
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingScreenWrapper extends StatelessWidget {
  final double currentPage;
  final int pageIndex;
  final Widget child;

  const _OnboardingScreenWrapper({
    required this.currentPage,
    required this.pageIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delta = (currentPage - pageIndex).clamp(-1.0, 1.0);
    final opacity = (1.0 - delta.abs()).clamp(0.0, 1.0);
    final slideY = delta.abs() * 40.0;

    return Transform.translate(
      offset: Offset(0, slideY),
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 1: Hero
// ─────────────────────────────────────────────────────────────────────────────

class _HeroScreen extends StatelessWidget {
  final double currentPage;
  final int pageIndex;

  const _HeroScreen({required this.currentPage, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScreenWrapper(
      currentPage: currentPage,
      pageIndex: pageIndex,
      child: Padding(
        padding: KxSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Medical cross icon
            SizedBox(
              width: 140,
              height: 140,
              child: _AnimatedMedicalCross(),
            ),

            const SizedBox(height: KxSpacing.xl5),

            // Title with glow
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [KxColors.teal300, KxColors.teal100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text(
                'KONSENXIA',
                style: KxTypography.displayLg.copyWith(
                  color: Colors.white,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: KxSpacing.xl),

            // Subtitle
            Text(
              'Doktorlar icin yapay zeka\ndestekli klinik platform',
              style: KxTypography.bodyLg.copyWith(
                color: KxColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 2: Vaka Simulasyonu
// ─────────────────────────────────────────────────────────────────────────────

class _VakaSimulasyonScreen extends StatelessWidget {
  final double currentPage;
  final int pageIndex;

  const _VakaSimulasyonScreen({
    required this.currentPage,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScreenWrapper(
      currentPage: currentPage,
      pageIndex: pageIndex,
      child: Padding(
        padding: KxSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Stethoscope + heartbeat
            SizedBox(
              width: 200,
              height: 160,
              child: _AnimatedStethoscope(),
            ),

            const SizedBox(height: KxSpacing.xl5),

            // Overline
            Text(
              'VAKA SIMULASYONU',
              style: KxTypography.overline.copyWith(
                color: KxColors.teal400,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: KxSpacing.md),

            Text(
              'Gercekci Hasta\nSimulasyonu',
              style: KxTypography.displayMd.copyWith(
                color: KxColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: KxSpacing.lg),

            Text(
              'AI destekli interaktif vakalarla\ntani koyma becerilerinizi gelistirin',
              style: KxTypography.bodyLg.copyWith(
                color: KxColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: KxSpacing.xl4),

            // Feature bullets
            _FeatureBullet(
              icon: Icons.psychology_outlined,
              text: 'Yapay zeka ile dinamik hasta yaniti',
            ),
            const SizedBox(height: KxSpacing.md),
            _FeatureBullet(
              icon: Icons.trending_up_rounded,
              text: 'Performans takibi ve ilerleme raporu',
            ),
            const SizedBox(height: KxSpacing.md),
            _FeatureBullet(
              icon: Icons.school_outlined,
              text: '500+ gercek vaka senaryosu',
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 3: Acil Konsultasyon
// ─────────────────────────────────────────────────────────────────────────────

class _AcilKonsultasyonScreen extends StatelessWidget {
  final double currentPage;
  final int pageIndex;

  const _AcilKonsultasyonScreen({
    required this.currentPage,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScreenWrapper(
      currentPage: currentPage,
      pageIndex: pageIndex,
      child: Padding(
        padding: KxSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // SOS pulsing rings
            SizedBox(
              width: 180,
              height: 180,
              child: _AnimatedSOSRings(),
            ),

            const SizedBox(height: KxSpacing.xl5),

            Text(
              'ACIL KONSULTASYON',
              style: KxTypography.overline.copyWith(
                color: KxColors.crimson400,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: KxSpacing.md),

            Text(
              'Aninda Uzman\nYardimi',
              style: KxTypography.displayMd.copyWith(
                color: KxColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: KxSpacing.lg),

            Text(
              'Kritik vakalarda saniyeler icinde\nuzman gorusu alin',
              style: KxTypography.bodyLg.copyWith(
                color: KxColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: KxSpacing.xl4),

            // Response time badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ResponseTimeBadge(time: '5dk', label: 'Acil', color: KxColors.crimson400),
                const SizedBox(width: KxSpacing.md),
                _ResponseTimeBadge(time: '15dk', label: 'Oncelikli', color: KxColors.amber500),
                const SizedBox(width: KxSpacing.md),
                _ResponseTimeBadge(time: '30dk', label: 'Standart', color: KxColors.teal400),
              ],
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 4: Ayirici Tani
// ─────────────────────────────────────────────────────────────────────────────

class _AyiriciTaniScreen extends StatelessWidget {
  final double currentPage;
  final int pageIndex;

  const _AyiriciTaniScreen({
    required this.currentPage,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScreenWrapper(
      currentPage: currentPage,
      pageIndex: pageIndex,
      child: Padding(
        padding: KxSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Neural network icon
            SizedBox(
              width: 200,
              height: 180,
              child: _AnimatedNeuralNetwork(),
            ),

            const SizedBox(height: KxSpacing.xl5),

            Text(
              'AYIRICI TANI',
              style: KxTypography.overline.copyWith(
                color: KxColors.blue400,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: KxSpacing.md),

            Text(
              'AI ile Ayirici Tani',
              style: KxTypography.displayMd.copyWith(
                color: KxColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: KxSpacing.lg),

            Text(
              'Semptom girin, yapay zeka destekli\ndiferansiyel tani alin',
              style: KxTypography.bodyLg.copyWith(
                color: KxColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: KxSpacing.xl4),

            // Confidence badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KxSpacing.xl,
                vertical: KxSpacing.md,
              ),
              decoration: BoxDecoration(
                color: KxColors.bgSurface,
                borderRadius: KxSpacing.radiusLg,
                border: Border.all(
                  color: KxColors.blue400.withOpacity(0.3),
                ),
                boxShadow: KxShadows.blueGlow(opacity: 0.12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: KxColors.jade500,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: KxColors.jade500.withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KxSpacing.md),
                  Text(
                    '%95 dogruluk',
                    style: KxTypography.monoMd.copyWith(
                      color: KxColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: KxSpacing.sm),
                  Text(
                    'orani',
                    style: KxTypography.labelMd.copyWith(
                      color: KxColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: KxColors.teal400.withOpacity(0.08),
            borderRadius: KxSpacing.radiusMd,
          ),
          child: Icon(icon, color: KxColors.teal400, size: 18),
        ),
        const SizedBox(width: KxSpacing.md),
        Expanded(
          child: Text(
            text,
            style: KxTypography.bodyMd.copyWith(
              color: KxColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponseTimeBadge extends StatelessWidget {
  final String time;
  final String label;
  final Color color;

  const _ResponseTimeBadge({
    required this.time,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(
        vertical: KxSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: KxTypography.monoLg.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: KxSpacing.xs),
          Text(
            label,
            style: KxTypography.labelSm.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background Painter — radial gradient + floating particles
// ─────────────────────────────────────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  final double progress;
  final double page;

  _BackgroundPainter({required this.progress, required this.page});

  @override
  void paint(Canvas canvas, Size size) {
    // Radial gradient from center
    final center = Offset(size.width / 2, size.height * 0.4);
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF00C4B0).withOpacity(0.03),
          const Color(0xFF0A0F1E).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );

    // Floating particles
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final rng = Random(42);

    for (int i = 0; i < 30; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final radius = 1.0 + rng.nextDouble() * 1.5;

      final x = baseX + sin(progress * 2 * pi * speed + i) * 15;
      final y = baseY + cos(progress * 2 * pi * speed * 0.7 + i * 0.5) * 10;

      final alpha = (0.06 + sin(progress * 2 * pi + i) * 0.03).clamp(0.0, 1.0);
      particlePaint.color = const Color(0xFF00C4B0).withOpacity(alpha);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Medical Cross — morphing + pulsing with teal glow
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedMedicalCross extends StatefulWidget {
  @override
  State<_AnimatedMedicalCross> createState() => _AnimatedMedicalCrossState();
}

class _AnimatedMedicalCrossState extends State<_AnimatedMedicalCross>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
      builder: (context, _) => CustomPaint(
        painter: _MedicalCrossPainter(progress: _ctrl.value),
        size: const Size(140, 140),
      ),
    );
  }
}

class _MedicalCrossPainter extends CustomPainter {
  final double progress;
  _MedicalCrossPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final pulse = 0.92 + sin(progress * 2 * pi) * 0.08;
    final glowPulse = 0.12 + sin(progress * 2 * pi) * 0.08;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = const Color(0xFF00C4B0).withOpacity(glowPulse * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(cx, cy), 50 * pulse, glowPaint);

    // Circle background
    final bgPaint = Paint()
      ..color = const Color(0xFF0E1628)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 44 * pulse, bgPaint);

    // Circle border
    final borderPaint = Paint()
      ..color = const Color(0xFF00C4B0).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), 44 * pulse, borderPaint);

    // Cross
    final crossPaint = Paint()
      ..color = const Color(0xFF00C4B0)
      ..style = PaintingStyle.fill;

    final armW = 8.0 * pulse;
    final armH = 24.0 * pulse;

    // Vertical arm
    final vertRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: armW, height: armH),
      const Radius.circular(3),
    );
    canvas.drawRRect(vertRect, crossPaint);

    // Horizontal arm
    final horizRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: armH, height: armW),
      const Radius.circular(3),
    );
    canvas.drawRRect(horizRect, crossPaint);

    // Inner glow on cross
    final crossGlow = Paint()
      ..color = const Color(0xFF00C4B0).withOpacity(glowPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(vertRect, crossGlow);
    canvas.drawRRect(horizRect, crossGlow);
  }

  @override
  bool shouldRepaint(_MedicalCrossPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Stethoscope + Heartbeat Line
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedStethoscope extends StatefulWidget {
  @override
  State<_AnimatedStethoscope> createState() => _AnimatedStethoscopeState();
}

class _AnimatedStethoscopeState extends State<_AnimatedStethoscope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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
      builder: (context, _) => CustomPaint(
        painter: _StethoscopePainter(progress: _ctrl.value),
        size: const Size(200, 160),
      ),
    );
  }
}

class _StethoscopePainter extends CustomPainter {
  final double progress;
  _StethoscopePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stethoscope head (circle at center-top)
    final headCenter = Offset(w * 0.5, h * 0.28);
    final pulse = 0.95 + sin(progress * 2 * pi * 2) * 0.05;

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00C4B0).withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(headCenter, 22 * pulse, glowPaint);

    // Head circle
    final headPaint = Paint()
      ..color = const Color(0xFF0E1628)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headCenter, 18 * pulse, headPaint);

    final headBorder = Paint()
      ..color = const Color(0xFF00C4B0).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(headCenter, 18 * pulse, headBorder);

    // Inner dot
    final dotPaint = Paint()
      ..color = const Color(0xFF00C4B0).withOpacity(0.6 + sin(progress * 2 * pi * 2) * 0.3);
    canvas.drawCircle(headCenter, 5, dotPaint);

    // Tube (curved lines going down)
    final tubePaint = Paint()
      ..color = const Color(0xFF00C4B0).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final leftTube = Path()
      ..moveTo(headCenter.dx - 12, headCenter.dy + 14)
      ..quadraticBezierTo(w * 0.25, h * 0.55, w * 0.3, h * 0.5);
    canvas.drawPath(leftTube, tubePaint);

    final rightTube = Path()
      ..moveTo(headCenter.dx + 12, headCenter.dy + 14)
      ..quadraticBezierTo(w * 0.75, h * 0.55, w * 0.7, h * 0.5);
    canvas.drawPath(rightTube, tubePaint);

    // Heartbeat line (sine wave that draws in)
    final linePaint = Paint()
      ..color = const Color(0xFF00C4B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final lineY = h * 0.78;
    final lineStart = w * 0.08;
    final lineEnd = w * 0.92;
    final lineWidth = lineEnd - lineStart;
    final drawEnd = lineStart + lineWidth * ((progress * 1.5) % 1.0).clamp(0.0, 1.0);

    final heartPath = Path();
    heartPath.moveTo(lineStart, lineY);

    for (double x = lineStart; x <= drawEnd; x += 1.0) {
      final t = (x - lineStart) / lineWidth;
      double y = lineY;

      // QRS complex shape
      final beat1 = (t - 0.3).abs();
      final beat2 = (t - 0.7).abs();

      if (beat1 < 0.05) {
        // P wave
        y -= 6 * (1 - beat1 / 0.05);
      } else if (beat1 < 0.02 + 0.05) {
        // Q dip
        y += 4;
      } else if ((t - 0.35).abs() < 0.02) {
        // R peak
        y -= 22;
      } else if ((t - 0.38).abs() < 0.02) {
        // S dip
        y += 8;
      } else if (beat2 < 0.05) {
        y -= 6 * (1 - beat2 / 0.05);
      } else if ((t - 0.75).abs() < 0.02) {
        y -= 22;
      } else if ((t - 0.78).abs() < 0.02) {
        y += 8;
      }

      heartPath.lineTo(x, y);
    }

    canvas.drawPath(heartPath, linePaint);

    // Glow trail on the drawing tip
    if (drawEnd > lineStart + 2) {
      final tipGlow = Paint()
        ..color = const Color(0xFF00C4B0).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(drawEnd, lineY), 4, tipGlow);
    }
  }

  @override
  bool shouldRepaint(_StethoscopePainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated SOS Rings — pulsing crimson rings
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedSOSRings extends StatefulWidget {
  @override
  State<_AnimatedSOSRings> createState() => _AnimatedSOSRingsState();
}

class _AnimatedSOSRingsState extends State<_AnimatedSOSRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
      builder: (context, _) => CustomPaint(
        painter: _SOSRingsPainter(progress: _ctrl.value),
        size: const Size(180, 180),
      ),
    );
  }
}

class _SOSRingsPainter extends CustomPainter {
  final double progress;
  _SOSRingsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Expanding rings (3 staggered)
    for (int i = 0; i < 3; i++) {
      final ringProgress = ((progress + i * 0.33) % 1.0);
      final radius = 20.0 + ringProgress * 60.0;
      final alpha = (1.0 - ringProgress) * 0.25;

      final ringPaint = Paint()
        ..color = const Color(0xFFEF4444).withOpacity(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 - ringProgress * 1.5;

      canvas.drawCircle(Offset(cx, cy), radius, ringPaint);
    }

    // Center circle — pulsing
    final pulse = 0.9 + sin(progress * 2 * pi * 2) * 0.1;

    // Crimson glow
    final glowPaint = Paint()
      ..color = const Color(0xFFEF4444).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(cx, cy), 26 * pulse, glowPaint);

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFF0E1628)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 22 * pulse, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFFEF4444).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(cx, cy), 22 * pulse, borderPaint);

    // SOS text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SOS',
        style: TextStyle(
          color: const Color(0xFFEF4444),
          fontSize: 12 * pulse,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_SOSRingsPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Neural Network — nodes + connections
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedNeuralNetwork extends StatefulWidget {
  @override
  State<_AnimatedNeuralNetwork> createState() => _AnimatedNeuralNetworkState();
}

class _AnimatedNeuralNetworkState extends State<_AnimatedNeuralNetwork>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
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
      builder: (context, _) => CustomPaint(
        painter: _NeuralNetworkPainter(progress: _ctrl.value),
        size: const Size(200, 180),
      ),
    );
  }
}

class _NeuralNetworkPainter extends CustomPainter {
  final double progress;
  _NeuralNetworkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Define node positions in 3 layers
    final layer1 = [
      Offset(w * 0.15, h * 0.25),
      Offset(w * 0.15, h * 0.50),
      Offset(w * 0.15, h * 0.75),
    ];
    final layer2 = [
      Offset(w * 0.45, h * 0.2),
      Offset(w * 0.45, h * 0.45),
      Offset(w * 0.45, h * 0.7),
      Offset(w * 0.45, h * 0.9),
    ];
    final layer3 = [
      Offset(w * 0.75, h * 0.3),
      Offset(w * 0.75, h * 0.6),
    ];
    final output = Offset(w * 0.92, h * 0.45);

    final allNodes = [...layer1, ...layer2, ...layer3, output];

    // Draw connections
    final connectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Layer 1 -> 2
    for (int i = 0; i < layer1.length; i++) {
      for (int j = 0; j < layer2.length; j++) {
        final phase = (progress + (i * 0.1 + j * 0.07)) % 1.0;
        final alpha = 0.06 + sin(phase * 2 * pi) * 0.06;
        connectionPaint.color = const Color(0xFF3B82F6).withOpacity(alpha);
        canvas.drawLine(layer1[i], layer2[j], connectionPaint);

        // Signal dot traveling along connection
        final dotT = (progress * 2 + i * 0.15 + j * 0.12) % 1.0;
        final dotPos = Offset(
          layer1[i].dx + (layer2[j].dx - layer1[i].dx) * dotT,
          layer1[i].dy + (layer2[j].dy - layer1[i].dy) * dotT,
        );
        final dotPaint = Paint()
          ..color = const Color(0xFF3B82F6).withOpacity(0.3 * (1 - dotT))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(dotPos, 1.5, dotPaint);
      }
    }

    // Layer 2 -> 3
    for (int i = 0; i < layer2.length; i++) {
      for (int j = 0; j < layer3.length; j++) {
        final phase = (progress + 0.3 + (i * 0.08 + j * 0.1)) % 1.0;
        final alpha = 0.06 + sin(phase * 2 * pi) * 0.06;
        connectionPaint.color = const Color(0xFF3B82F6).withOpacity(alpha);
        canvas.drawLine(layer2[i], layer3[j], connectionPaint);
      }
    }

    // Layer 3 -> output
    for (int i = 0; i < layer3.length; i++) {
      final phase = (progress + 0.6 + i * 0.12) % 1.0;
      final alpha = 0.08 + sin(phase * 2 * pi) * 0.06;
      connectionPaint.color = const Color(0xFF3B82F6).withOpacity(alpha);
      canvas.drawLine(layer3[i], output, connectionPaint);
    }

    // Draw nodes
    for (int i = 0; i < allNodes.length; i++) {
      final node = allNodes[i];
      final phase = (progress + i * 0.09) % 1.0;
      final pulse = 0.9 + sin(phase * 2 * pi) * 0.1;
      final isOutput = i == allNodes.length - 1;
      final nodeRadius = isOutput ? 8.0 : 5.0;

      // Glow
      final glowPaint = Paint()
        ..color = (isOutput
                ? const Color(0xFF00C4B0)
                : const Color(0xFF3B82F6))
            .withOpacity(0.15 + sin(phase * 2 * pi) * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(node, nodeRadius * pulse * 1.5, glowPaint);

      // Node fill
      final fillPaint = Paint()
        ..color = isOutput
            ? const Color(0xFF00C4B0).withOpacity(0.8)
            : const Color(0xFF3B82F6).withOpacity(0.6 + sin(phase * 2 * pi) * 0.2);
      canvas.drawCircle(node, nodeRadius * pulse, fillPaint);

      // Node border
      final borderPaint = Paint()
        ..color = (isOutput
                ? const Color(0xFF00C4B0)
                : const Color(0xFF3B82F6))
            .withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(node, nodeRadius * pulse, borderPaint);
    }

    // Output node label: checkmark
    final checkPaint = Paint()
      ..color = const Color(0xFF00C4B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final checkPath = Path()
      ..moveTo(output.dx - 3, output.dy)
      ..lineTo(output.dx - 1, output.dy + 3)
      ..lineTo(output.dx + 4, output.dy - 3);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(_NeuralNetworkPainter old) => true;
}
