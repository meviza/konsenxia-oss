import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// KONSENXIA Splash
///
/// Uygulama açılış ekranı. Logo animasyonu → auth kontrolü → yönlendirme.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Animasyon bittikten sonra yönlendir
    Future.delayed(const Duration(milliseconds: 2400), _navigate);
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  void _navigate() {
    if (!mounted) return;
    final storage = GetIt.instance<LocalStorage>();
    final isAuth = storage.isAuthenticated();

    if (isAuth) {
      // AuthBloc'u mevcut kullanıcı ile güncelle
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
      context.go('/dashboard');
    } else {
      // İlk açılışta onboarding göster
      final hasSeenOnboarding = storage.getBool('has_seen_onboarding');
      context.go(hasSeenOnboarding ? '/login' : '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgVoid,
      body: Stack(
        children: [
          // Arka plan gradyan halkalar
          const _BackgroundRings(),

          // Merkez logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo mark — teal halka + ⚕ simgesi
                _LogoMark(rotCtrl: _rotCtrl)
                    .animate()
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // Wordmark
                _Wordmark()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.1, delay: 400.ms),

                const SizedBox(height: 12),

                // Tagline
                Text(
                  'Tıbbın Kolektif Zekası.',
                  style: KxTypography.bodyMd.copyWith(
                    color: KxColors.textMuted,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Instrument Serif',
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 500.ms),

                const SizedBox(height: 60),

                // Loading göstergesi
                SizedBox(
                  width: 120,
                  child: KxProgressBar.thin(
                    value: 1.0,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 400.ms),
              ],
            ),
          ),

          // Alt — versiyon numarası
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'v0.1.0 — Beta',
              textAlign: TextAlign.center,
              style: KxTypography.caption.copyWith(color: KxColors.textDisabled),
            ).animate().fadeIn(delay: 1400.ms),
          ),
        ],
      ),
    );
  }
}

// ── Logo Mark ──────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  final AnimationController rotCtrl;
  const _LogoMark({required this.rotCtrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dönen teal halka
          AnimatedBuilder(
            animation: rotCtrl,
            builder: (_, __) => Transform.rotate(
              angle: rotCtrl.value * 2 * math.pi,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: KxColors.teal400.withOpacity(0.4),
                    width: 1.5,
                  ),
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      KxColors.teal400.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // İç kare
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: KxShadows.tealGlow(opacity: 0.35),
            ),
            child: const Center(
              child: Text(
                '⚕',
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wordmark ───────────────────────────────────────────────────────

class _Wordmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'KONSEN',
            style: KxTypography.headingLg.copyWith(
              color: KxColors.textPrimary,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'xia',
            style: KxTypography.headingLg.copyWith(
              color: KxColors.teal400,
              fontStyle: FontStyle.italic,
              fontFamily: 'Instrument Serif',
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arka Plan Halkaları ────────────────────────────────────────────

class _BackgroundRings extends StatelessWidget {
  const _BackgroundRings();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = size.height / 2;

    return CustomPaint(
      size: size,
      painter: _RingsPainter(cx: cx, cy: cy),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double cx, cy;
  const _RingsPainter({required this.cx, required this.cy});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      paint.color = KxColors.teal400.withOpacity(0.04 * i);
      canvas.drawCircle(
        Offset(cx, cy),
        80.0 + i * 80,
        paint,
      );
    }

    // Radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          KxColors.teal400.withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 280));
    canvas.drawCircle(Offset(cx, cy), 280, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
