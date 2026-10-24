import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Offline state banner that shows when the device loses connectivity.
///
/// Displays a slim amber/red strip at the top of the screen with the message:
/// "Cevrimdisi -- Veriler son guncellemeye gore gosteriliyor"
///
/// Usage -- wrap your Scaffold body or place inside a Column/Stack:
/// ```dart
/// Column(
///   children: [
///     const ConnectivityBanner(),
///     Expanded(child: yourContent),
///   ],
/// )
/// ```
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final Connectivity _connectivity;
  late final StreamSubscription<ConnectivityResult> _subscription;
  late final AnimationController _animController;
  late final Animation<double> _heightFactor;

  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _heightFactor = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    // Check initial connectivity
    _checkConnectivity();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _onChanged(result);
  }

  void _onChanged(ConnectivityResult result) {
    final offline = result == ConnectivityResult.none;

    if (offline == _isOffline) return;

    setState(() {
      _isOffline = offline;
    });

    if (_isOffline) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightFactor,
      builder: (context, child) {
        final value = _heightFactor.value;
        if (value <= 0.01 && !_isOffline) {
          return const SizedBox.shrink();
        }

        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: _buildBannerContent(),
    );
  }

  Widget _buildBannerContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade700,
            Colors.amber.shade800,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 16,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '\u00C7evrimd\u0131\u015F\u0131 \u2014 Veriler son g\u00FCncellemeye g\u00F6re g\u00F6steriliyor',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
