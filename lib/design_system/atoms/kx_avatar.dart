import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Atom — KxAvatar
///
/// Doktor avatarı. İsim baş harfleri, ağ görseli veya
/// yer tutucu. İsteğe bağlı level ring (XP göstergesi).
///
/// Kullanım:
/// ```dart
/// KxAvatar(name: 'Dr. Ahmet Yılmaz', size: KxAvatarSize.lg)
/// KxAvatar(imageUrl: 'https://...', size: KxAvatarSize.md)
/// KxAvatar(name: 'Sarah Kim', level: 8, showLevelRing: true)
/// ```
enum KxAvatarSize { xs, sm, md, lg, xl }

class KxAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final KxAvatarSize size;
  final bool showLevelRing;
  final int? level;
  final bool isOnline;
  final Color? overrideColor;

  const KxAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = KxAvatarSize.md,
    this.showLevelRing = false,
    this.level,
    this.isOnline = false,
    this.overrideColor,
  }) : assert(
          name != null || imageUrl != null,
          'KxAvatar: name veya imageUrl gereklidir',
        );

  // ── Boyutlar ─────────────────────────────────────────────────

  double get _diameter => switch (size) {
    KxAvatarSize.xs => 24.0,
    KxAvatarSize.sm => KxSpacing.avatarSm,
    KxAvatarSize.md => KxSpacing.avatarMd,
    KxAvatarSize.lg => KxSpacing.avatarLg,
    KxAvatarSize.xl => KxSpacing.avatarXl,
  };

  double get _fontSize => switch (size) {
    KxAvatarSize.xs => 9.0,
    KxAvatarSize.sm => 11.0,
    KxAvatarSize.md => 13.0,
    KxAvatarSize.lg => 16.0,
    KxAvatarSize.xl => 20.0,
  };

  double get _ringPadding => showLevelRing ? 3.0 : 0.0;
  double get _onlineDotSize => _diameter * 0.28;

  // ── İsim → Baş harfler ───────────────────────────────────────

  String _initials(String fullName) {
    final parts = fullName
        .replaceAll('Dr.', '')
        .replaceAll('Prof.', '')
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  // ── İsim → Renk (deterministik) ─────────────────────────────

  Color _colorFromName(String name) {
    final gradients = [
      [KxColors.teal700, KxColors.blue500],
      [KxColors.teal500, KxColors.teal300],
      [KxColors.blue500, const Color(0xFF7C3AED)],
      [KxColors.jade500, KxColors.teal500],
      [const Color(0xFF7C3AED), KxColors.blue400],
      [KxColors.amber500, const Color(0xFFEA580C)],
    ];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % gradients.length;
    return gradients[idx][0];
  }

  Color _colorFromNameEnd(String name) {
    final gradients = [
      [KxColors.teal700, KxColors.blue500],
      [KxColors.teal500, KxColors.teal300],
      [KxColors.blue500, const Color(0xFF7C3AED)],
      [KxColors.jade500, KxColors.teal500],
      [const Color(0xFF7C3AED), KxColors.blue400],
      [KxColors.amber500, const Color(0xFFEA580C)],
    ];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % gradients.length;
    return gradients[idx][1];
  }

  // ── Level ring rengi ─────────────────────────────────────────

  Color get _ringColor {
    if (level == null) return KxColors.teal400;
    if (level! >= 10) return KxColors.amber300;
    if (level! >= 7)  return KxColors.teal400;
    if (level! >= 4)  return KxColors.blue400;
    return KxColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = _diameter + (_ringPadding * 2);

    Widget avatar = _buildInner();

    if (showLevelRing) {
      avatar = Container(
        width: totalSize,
        height: totalSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [_ringColor, _ringColor.withOpacity(0.2), _ringColor],
          ),
        ),
        padding: EdgeInsets.all(_ringPadding),
        child: avatar,
      );
    }

    if (isOnline) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: _onlineDotSize,
              height: _onlineDotSize,
              decoration: BoxDecoration(
                color: KxColors.jade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: KxColors.bgSurface,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: avatar,
    );
  }

  Widget _buildInner() {
    if (imageUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: _diameter,
          height: _diameter,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildInitials(),
          errorWidget: (_, __, ___) => _buildInitials(),
        ),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    final n = name ?? '?';
    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: overrideColor != null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _colorFromName(n),
                  _colorFromNameEnd(n),
                ],
              ),
        color: overrideColor,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(n),
        style: KxTypography.labelMd.copyWith(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
