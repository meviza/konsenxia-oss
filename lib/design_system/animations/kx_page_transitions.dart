import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// KONSENXIA — Custom Page Transitions
///
/// Apple-quality route transitions:
/// - Slide + Fade (default, iOS-inspired)
/// - Vertical reveal (for modals/sheets)
/// - Scale + Fade (for feature pages)
///
/// GoRouter entegrasyonu:
/// ```dart
/// GoRoute(
///   pageBuilder: (context, state) => KxTransitions.slideUp(
///     child: const MyPage(),
///     key: state.pageKey,
///   ),
/// )
/// ```
abstract final class KxTransitions {
  static const _duration = Duration(milliseconds: 350);
  static const _fastDuration = Duration(milliseconds: 250);

  /// iOS-style horizontal slide with subtle fade
  static CustomTransitionPage<void> slideRight({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

        // Outgoing page slides slightly left and dims
        final slideOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        ));

        final fadeOut = Tween<double>(begin: 1.0, end: 0.85).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeInOut,
          ),
        );

        return SlideTransition(
          position: slideOut,
          child: FadeTransition(
            opacity: fadeOut,
            child: SlideTransition(
              position: slideIn,
              child: FadeTransition(
                opacity: fadeIn,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Vertical slide up — for modal-style pages
  static CustomTransitionPage<void> slideUp({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: fade,
            child: child,
          ),
        );
      },
    );
  }

  /// Scale + fade — for feature/detail pages (immersive entry)
  static CustomTransitionPage<void> scaleUp({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: _duration,
      reverseTransitionDuration: _fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }

  /// Fade only — for tab switches within shell
  static CustomTransitionPage<void> fade({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: _fastDuration,
      reverseTransitionDuration: _fastDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }
}
