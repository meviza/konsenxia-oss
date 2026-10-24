import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Molecule — KxSearchBar
///
/// Medikal arama çubuğu. Filtre chip'leri ve tıbbi uzmanlık filtreleme
/// desteği ile birlikte gelir.
///
/// Kullanım:
/// ```dart
/// KxSearchBar(
///   hint: 'Vaka, doktor veya tanı ara...',
///   onChanged: (q) => bloc.add(SearchChanged(q)),
///   filters: ['kardiyoloji', 'nöroloji'],
///   selectedFilter: 'kardiyoloji',
///   onFilterSelected: (f) {},
/// )
///
/// KxSearchBar.simple(
///   hint: 'Ara...',
///   onChanged: (q) {},
/// )
/// ```
class KxSearchBar extends StatefulWidget {
  final String hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<String> filters;
  final String? selectedFilter;
  final ValueChanged<String?>? onFilterSelected;
  final VoidCallback? onFilterTap;
  final bool autofocus;
  final bool showClearButton;
  final bool _simple;

  const KxSearchBar({
    super.key,
    this.hint = 'Ara...',
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.filters = const [],
    this.selectedFilter,
    this.onFilterSelected,
    this.onFilterTap,
    this.autofocus = false,
    this.showClearButton = true,
  }) : _simple = false;

  const KxSearchBar.simple({
    Key? key,
    String hint = 'Ara...',
    String? initialValue,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool autofocus = false,
  }) : this(
          key: key,
          hint: hint,
          initialValue: initialValue,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
          filters: const [],
        );

  @override
  State<KxSearchBar> createState() => _KxSearchBarState();
}

class _KxSearchBarState extends State<KxSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue?.isNotEmpty ?? false;
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Arama input'u
        _buildInput(),

        // Filtreler (varsa)
        if (!widget._simple && widget.filters.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildFilters(),
        ],
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            size: 18,
            color: KxColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              style: KxTypography.bodyMd.copyWith(
                color: KxColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: KxTypography.bodyMd.copyWith(
                  color: KxColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),

          // Filtre butonu (filtre yoksa gösterme)
          if (widget.onFilterTap != null) ...[
            _DividerLine(),
            _FilterButton(onTap: widget.onFilterTap!),
          ],

          // Temizle butonu
          if (widget.showClearButton && _hasText) ...[
            GestureDetector(
              onTap: _clear,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: KxColors.textMuted,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // "Tümü" seçeneği
          _FilterChip(
            label: 'Tümü',
            isSelected: widget.selectedFilter == null,
            onTap: () => widget.onFilterSelected?.call(null),
          ),
          const SizedBox(width: 6),
          ...widget.filters.map((f) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _FilterChip(
                label: _capitalize(f),
                isSelected: widget.selectedFilter == f,
                onTap: () => widget.onFilterSelected?.call(f),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    final parts = s.replaceAll('_', ' ').split(' ');
    return parts
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? KxColors.teal400.withOpacity(0.15)
              : KxColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? KxColors.teal400 : KxColors.border,
          ),
        ),
        child: Text(
          label,
          style: KxTypography.labelSm.copyWith(
            color:
                isSelected ? KxColors.teal300 : KxColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      color: KxColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 16,
              color: KxColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Filtre',
              style: KxTypography.labelSm.copyWith(
                color: KxColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
