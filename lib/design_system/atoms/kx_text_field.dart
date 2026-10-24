import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_shadows.dart';

/// KONSENXIA Atom — KxTextField
///
/// Klinik ortama uygun input. Prefix/suffix ikonu, hata
/// mesajı ve özel tıbbi formatter desteğiyle.
///
/// Kullanım:
/// ```dart
/// KxTextField(label: 'Uzmanlık Alanı', hint: 'Kardiyoloji...')
/// KxTextField.medical(label: 'Vaka Kodu', prefix: '⬡')
/// KxTextField.search(hint: 'Vaka, semptom, tanı ara...')
/// KxTextField.password(label: 'Şifre')
/// ```
class KxTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? prefixText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool _isSearch;
  final bool _isMedical;

  const KxTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  })  : _isSearch = false,
        _isMedical = false;

  /// Tıbbi veri girişi — mono font, özel stil
  const KxTextField.medical({
    super.key,
    required String label,
    String? hint,
    String? prefixText,
    TextEditingController? controller,
    void Function(String)? onChanged,
    String? errorText,
    bool readOnly = false,
  })  : label = label,
        hint = hint,
        helperText = null,
        errorText = errorText,
        prefixText = prefixText,
        prefixIcon = null,
        suffixIcon = null,
        onSuffixTap = null,
        controller = controller,
        focusNode = null,
        keyboardType = TextInputType.text,
        textInputAction = TextInputAction.next,
        inputFormatters = null,
        onChanged = onChanged,
        onSubmitted = null,
        obscureText = false,
        readOnly = readOnly,
        autofocus = false,
        enabled = true,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        _isSearch = false,
        _isMedical = true;

  /// Arama kutusu
  const KxTextField.search({
    super.key,
    String hint = 'Vaka, semptom, tanı ara...',
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
  })  : label = null,
        hint = hint,
        helperText = null,
        errorText = null,
        prefixText = null,
        prefixIcon = Icons.search_rounded,
        suffixIcon = null,
        onSuffixTap = null,
        controller = controller,
        focusNode = null,
        keyboardType = TextInputType.text,
        textInputAction = TextInputAction.search,
        inputFormatters = null,
        onChanged = onChanged,
        onSubmitted = onSubmitted,
        obscureText = false,
        readOnly = false,
        autofocus = false,
        enabled = true,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        _isSearch = true,
        _isMedical = false;

  /// E-posta alanı
  const KxTextField.email({
    super.key,
    String label = 'E-posta',
    String? hint,
    TextEditingController? controller,
    void Function(String)? onChanged,
    String? errorText,
  })  : label = label,
        hint = hint,
        helperText = null,
        errorText = errorText,
        prefixText = null,
        prefixIcon = Icons.email_outlined,
        suffixIcon = null,
        onSuffixTap = null,
        controller = controller,
        focusNode = null,
        keyboardType = TextInputType.emailAddress,
        textInputAction = TextInputAction.next,
        inputFormatters = null,
        onChanged = onChanged,
        onSubmitted = null,
        obscureText = false,
        readOnly = false,
        autofocus = false,
        enabled = true,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        _isSearch = false,
        _isMedical = false;

  /// Şifre alanı
  factory KxTextField.password({
    Key? key,
    String label = 'Şifre',
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    TextInputAction textInputAction = TextInputAction.done,
    String? errorText,
  }) {
    return _PasswordField(
      key: key,
      label: label,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      errorText: errorText,
    );
  }

  @override
  State<KxTextField> createState() => _KxTextFieldState();
}

class _KxTextFieldState extends State<KxTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.errorText != null) return KxColors.crimson500;
    if (_hasFocus) return KxColors.teal500;
    return KxColors.border;
  }

  List<BoxShadow> get _shadow {
    if (widget.errorText != null) return [];
    if (_hasFocus) return KxShadows.focusRing;
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: KxTypography.labelMd.copyWith(
            color: _hasFocus ? KxColors.teal400 : KxColors.textSecondary,
          )),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: KxSpacing.radiusMd,
            boxShadow: _shadow,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            style: (widget._isMedical
                    ? KxTypography.monoMd
                    : KxTypography.bodyMd)
                .copyWith(color: KxColors.textPrimary),
            cursorColor: KxColors.teal400,
            cursorWidth: 1.5,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: KxTypography.bodyMd.copyWith(
                color: KxColors.textMuted,
              ),
              prefixText: widget.prefixText,
              prefixStyle: KxTypography.monoMd.copyWith(
                color: KxColors.textMuted,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon,
                      size: KxSpacing.iconMd,
                      color: _hasFocus
                          ? KxColors.teal400
                          : KxColors.textMuted)
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onSuffixTap,
                      child: Icon(widget.suffixIcon,
                          size: KxSpacing.iconMd,
                          color: KxColors.textMuted),
                    )
                  : null,
              filled: true,
              fillColor: widget.enabled
                  ? KxColors.bgElevated
                  : KxColors.bgCard,
              contentPadding: widget._isSearch
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: const BorderSide(color: KxColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: BorderSide(
                  color: _borderColor, width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: const BorderSide(color: KxColors.crimson500),
              ),
              counterText: '',
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 12, color: KxColors.crimson300),
              const SizedBox(width: 4),
              Text(
                widget.errorText!,
                style: KxTypography.caption.copyWith(
                  color: KxColors.crimson300,
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 5),
          Text(
            widget.helperText!,
            style: KxTypography.caption,
          ),
        ],
      ],
    );
  }
}

/// Password field — ayrı widget çünkü obscure toggle state'i var
class _PasswordField extends KxTextField {
  const _PasswordField({
    super.key,
    required String label,
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    TextInputAction textInputAction = TextInputAction.done,
    String? errorText,
  }) : super(
          label: label,
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          errorText: errorText,
          obscureText: true,
          suffixIcon: Icons.visibility_outlined,
        );

  @override
  State<KxTextField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends _KxTextFieldState {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: KxTypography.labelMd.copyWith(
            color: _hasFocus ? KxColors.teal400 : KxColors.textSecondary,
          )),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: KxSpacing.radiusMd,
            boxShadow: _shadow,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            obscureText: _obscure,
            style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
            cursorColor: KxColors.teal400,
            cursorWidth: 1.5,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: KxSpacing.iconMd,
                  color: KxColors.textMuted,
                ),
              ),
              filled: true,
              fillColor: KxColors.bgElevated,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: const BorderSide(color: KxColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: const BorderSide(
                  color: KxColors.teal500, width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: KxSpacing.radiusMd,
                borderSide: const BorderSide(color: KxColors.crimson500),
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 5),
          Text(widget.errorText!,
              style: KxTypography.caption.copyWith(color: KxColors.crimson300)),
        ],
      ],
    );
  }
}
