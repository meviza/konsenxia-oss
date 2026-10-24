import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Atom — KxTag
///
/// Tıbbi uzmanlık alanı, vaka kategorisi ve filtre etiketleri.
/// Badge'den farklı olarak tag daha çok kategori/filtre amacıyla kullanılır.
///
/// Kullanım:
/// ```dart
/// KxTag('Kardiyoloji')
/// KxTag.specialty('Nöroloji')
/// KxTag.filter('Acil', isActive: true, onTap: () {})
/// KxTag.removable('Kardiyoloji', onRemove: () {})
/// ```
class KxTag extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isRemovable;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Color? customColor;
  final bool _isFilter;

  const KxTag(
    this.label, {
    super.key,
    this.isActive = false,
    this.onTap,
    this.customColor,
  })  : isRemovable = false,
        onRemove = null,
        _isFilter = false;

  /// Uzmanlık alanı — rengi otomatik belirlenir
  factory KxTag.specialty(String name, {Key? key, VoidCallback? onTap}) {
    final color = KxColors.specialtyColors[name.toLowerCase()];
    return KxTag(
      name,
      key: key,
      customColor: color ?? KxColors.teal400,
      onTap: onTap,
    );
  }

  /// Filtre chip'i — aktif/pasif state'i var
  const KxTag.filter(
    String label, {
    super.key,
    required bool isActive,
    VoidCallback? onTap,
  })  : label = label,
        isActive = isActive,
        isRemovable = false,
        onRemove = null,
        onTap = onTap,
        customColor = null,
        _isFilter = true;

  /// Kaldırılabilir tag (çoklu seçim alanları için)
  const KxTag.removable(
    String label, {
    super.key,
    required VoidCallback onRemove,
  })  : label = label,
        isActive = true,
        isRemovable = true,
        onRemove = onRemove,
        onTap = null,
        customColor = null,
        _isFilter = false;

  // ── Stil hesabı ───────────────────────────────────────────────

  Color get _accentColor {
    if (customColor != null) return customColor!;
    return KxColors.teal400;
  }

  Color get _bg {
    if (_isFilter && isActive) return _accentColor.withOpacity(0.1);
    if (_isFilter)              return KxColors.bgSurface;
    if (isActive)               return _accentColor.withOpacity(0.1);
    return KxColors.bgCard;
  }

  Color get _border {
    if (_isFilter && isActive) return _accentColor.withOpacity(0.4);
    if (_isFilter)              return KxColors.border;
    if (isActive)               return _accentColor.withOpacity(0.3);
    return KxColors.border;
  }

  Color get _textColor {
    if (_isFilter && isActive) return _accentColor;
    if (isActive)               return _accentColor;
    return KxColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    Widget tag = Container(
      padding: isRemovable
          ? const EdgeInsets.only(left: 10, right: 4, top: 5, bottom: 5)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: KxSpacing.radiusSm,
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: KxTypography.labelSm.copyWith(color: _textColor),
          ),
          if (isRemovable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 12,
                color: _textColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: tag,
      );
    }

    return tag;
  }
}

/// Birden fazla tag'ı yatay scroll edilebilir şekilde listeler
class KxTagRow extends StatelessWidget {
  final List<String> tags;
  final Set<String> activeTags;
  final void Function(String tag)? onTagTap;
  final bool isSpecialty;

  const KxTagRow({
    super.key,
    required this.tags,
    this.activeTags = const {},
    this.onTagTap,
    this.isSpecialty = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.asMap().entries.map((entry) {
          final tag = entry.value;
          final isActive = activeTags.contains(tag);

          final widget = isSpecialty
              ? KxTag.specialty(tag, onTap: onTagTap != null
                  ? () => onTagTap!(tag)
                  : null)
              : KxTag.filter(
                  tag,
                  isActive: isActive,
                  onTap: onTagTap != null ? () => onTagTap!(tag) : null,
                );

          return Padding(
            padding: EdgeInsets.only(
              right: entry.key < tags.length - 1 ? 6 : 0,
            ),
            child: widget,
          );
        }).toList(),
      ),
    );
  }
}
