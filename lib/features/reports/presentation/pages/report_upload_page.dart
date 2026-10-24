import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/medical_report_entity.dart';
import '../../domain/usecases/upload_report_usecase.dart';

/// KONSENXIA — Rapor Yükleme
///
/// Yeni sağlık raporu oluşturur ve Firestore'a kaydeder.
/// Dosya seçimi file_picker ile yapılır (PDF, JPG, PNG).
/// Firestore erişim hatalarında yerel depolamaya yedekleme yapılır.
class ReportUploadPage extends StatefulWidget {
  const ReportUploadPage({super.key});

  @override
  State<ReportUploadPage> createState() => _ReportUploadPageState();
}

class _ReportUploadPageState extends State<ReportUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  DateTime? _pickedDate;
  ReportType _selectedType = ReportType.labResult;
  bool _isAbnormal = false;
  bool _isUploading = false;

  /// Seçilen dosya bilgileri
  PlatformFile? _selectedFile;

  static const _typeLabels = [
    'Lab Sonucu',
    'Görüntüleme',
    'Tanı',
    'Rapor',
    'Girişim',
    'Aşı',
  ];

  static const _typeEnums = [
    ReportType.labResult,
    ReportType.imaging,
    ReportType.diagnosis,
    ReportType.report,
    ReportType.procedure,
    ReportType.vaccination,
  ];

  /// İzin verilen dosya uzantıları
  static const _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  /// Maksimum dosya boyutu (20 MB)
  static const _maxFileSize = 20 * 1024 * 1024;

  String get _formattedDate => _pickedDate == null
      ? ''
      : '${_pickedDate!.day.toString().padLeft(2, '0')}'
          '.${_pickedDate!.month.toString().padLeft(2, '0')}'
          '.${_pickedDate!.year}';

  bool get _hasFile => _selectedFile != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _institutionCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      appBar: AppBar(
        backgroundColor: KxColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: KxColors.textPrimary, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/reports'),
        ),
        title: Text('Rapor Ekle', style: KxTypography.headingSm),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: KxColors.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dosya seçimi ──────────────────────────────────────
              GestureDetector(
                onTap: _hasFile ? null : _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: _hasFile
                        ? KxColors.teal400.withOpacity(0.06)
                        : KxColors.bgCard,
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(
                      color: _hasFile
                          ? KxColors.teal400.withOpacity(0.4)
                          : KxColors.border,
                      width: _hasFile ? 1.5 : 1,
                    ),
                  ),
                  child: _hasFile
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedFile!.extension == 'pdf'
                                  ? Icons.picture_as_pdf_rounded
                                  : Icons.image_rounded,
                              color: KxColors.teal400,
                              size: 34,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedFile!.name,
                              style: KxTypography.labelMd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatFileSize(_selectedFile!.size),
                              style: KxTypography.caption
                                  .copyWith(color: KxColors.textMuted),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedFile = null),
                              child: Text('Kaldır',
                                  style: KxTypography.labelSm.copyWith(
                                      color: KxColors.crimson400)),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined,
                                color: KxColors.textMuted, size: 34),
                            const SizedBox(height: 8),
                            Text('Dosya Seç veya Sürükle',
                                style: KxTypography.labelMd),
                            const SizedBox(height: 4),
                            Text('PDF, JPG, PNG — maks. 20 MB',
                                style: KxTypography.caption
                                    .copyWith(color: KxColors.textMuted)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    KxColors.teal400.withOpacity(0.1),
                                borderRadius: KxSpacing.radiusMd,
                                border: Border.all(
                                    color: KxColors.teal400
                                        .withOpacity(0.3)),
                              ),
                              child: Text('Dosya Seç',
                                  style: KxTypography.labelSm.copyWith(
                                      color: KxColors.teal400)),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Başlık ────────────────────────────────────────────
              _Label('Rapor Başlığı *'),
              const SizedBox(height: 8),
              KxTextField(
                controller: _titleCtrl,
                hint: 'Ör. Kan Tahlili — Kasım 2024',
              ),

              const SizedBox(height: 20),

              // ── Rapor türü ────────────────────────────────────────
              _Label('Rapor Türü'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _typeLabels.length,
                  (i) => GestureDetector(
                    onTap: () =>
                        setState(() => _selectedType = _typeEnums[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedType == _typeEnums[i]
                            ? KxColors.teal400.withOpacity(0.15)
                            : KxColors.bgCard,
                        borderRadius: KxSpacing.radiusPill,
                        border: Border.all(
                          color: _selectedType == _typeEnums[i]
                              ? KxColors.teal400.withOpacity(0.5)
                              : KxColors.border,
                        ),
                      ),
                      child: Text(
                        _typeLabels[i],
                        style: KxTypography.labelSm.copyWith(
                          color: _selectedType == _typeEnums[i]
                              ? KxColors.teal400
                              : KxColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Kurum ─────────────────────────────────────────────
              _Label('Kurum / Hastane'),
              const SizedBox(height: 8),
              KxTextField(
                controller: _institutionCtrl,
                hint: 'Ör. Ankara Şehir Hastanesi',
              ),

              const SizedBox(height: 20),

              // ── Tarih ─────────────────────────────────────────────
              _Label('Rapor Tarihi *'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: KxColors.bgCard,
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(
                      color: _pickedDate == null
                          ? KxColors.border
                          : KxColors.teal400.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: _pickedDate == null
                            ? KxColors.textSecondary
                            : KxColors.teal400,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _pickedDate == null
                            ? 'Tarih seçin'
                            : _formattedDate,
                        style: KxTypography.bodyMd.copyWith(
                          color: _pickedDate == null
                              ? KxColors.textMuted
                              : KxColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Anormal değer ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: KxColors.bgCard,
                  borderRadius: KxSpacing.radiusMd,
                  border: Border.all(color: KxColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anormal / Kritik Değer',
                              style: KxTypography.labelMd),
                          const SizedBox(height: 2),
                          Text('Sınır dışı veya dikkat gerektiren sonuç',
                              style: KxTypography.caption
                                  .copyWith(color: KxColors.textMuted)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAbnormal,
                      onChanged: (v) =>
                          setState(() => _isAbnormal = v),
                      activeColor: KxColors.crimson400,
                      inactiveThumbColor: KxColors.textMuted,
                      inactiveTrackColor: KxColors.bgSurface,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Notlar ────────────────────────────────────────────
              _Label('Notlar (opsiyonel)'),
              const SizedBox(height: 8),
              KxTextField(
                controller: _summaryCtrl,
                hint: 'Doktorunuzun dikkat etmesini istediğiniz bilgiler...',
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // ── Kaydet butonu ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: _isUploading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: KxColors.teal400))
                    : KxButton(
                        label: 'Raporu Kaydet',
                        onPressed: _upload,
                        variant: KxButtonVariant.primary,
                      ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dosya seçimi (file_picker) ───────────────────────────────────

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        withData: false,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      // Boyut kontrolü
      if (file.size > _maxFileSize) {
        if (!mounted) return;
        _showSnackBar(
          'Dosya boyutu çok büyük (maks. 20 MB). Seçilen: ${_formatFileSize(file.size)}',
          isError: true,
        );
        return;
      }

      // Uzantı kontrolü (ek güvenlik)
      final ext = file.extension?.toLowerCase() ?? '';
      if (!_allowedExtensions.contains(ext)) {
        if (!mounted) return;
        _showSnackBar(
          'Desteklenmeyen dosya türü. Lütfen PDF, JPG veya PNG seçin.',
          isError: true,
        );
        return;
      }

      setState(() => _selectedFile = file);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        'Dosya seçilemedi. Lütfen tekrar deneyin.',
        isError: true,
      );
    }
  }

  // ── Tarih seçimi ────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: KxColors.teal400,
            surface: KxColors.bgCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickedDate = picked);
  }

  // ── Yükleme (Firestore + offline fallback) ─────────────────────

  Future<void> _upload() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_pickedDate == null) {
      _showSnackBar('Lütfen rapor tarihi seçin', isError: true);
      return;
    }
    setState(() => _isUploading = true);
    try {
      final useCase = GetIt.instance<UploadReportUseCase>();
      final summary = _summaryCtrl.text.trim();
      await useCase(UploadReportParams(
        title: _titleCtrl.text.trim(),
        summary: summary,
        detail: summary,
        institution: _institutionCtrl.text.trim(),
        type: _selectedType,
        date: _pickedDate!,
        isAbnormal: _isAbnormal,
        fileUrl: _selectedFile?.path,
      ));
      if (!mounted) return;
      _showSnackBar(
        '"${_titleCtrl.text.trim()}" başarıyla eklendi.',
        isError: false,
      );
      context.go('/reports');
    } catch (e) {
      if (!mounted) return;

      // Firestore PERMISSION_DENIED kontrolü
      final errorStr = e.toString().toLowerCase();
      final isPermissionDenied = errorStr.contains('permission-denied') ||
          errorStr.contains('permission_denied') ||
          errorStr.contains('missing or insufficient permissions');

      if (isPermissionDenied) {
        // Yerel depolamaya yedekle
        final savedLocally = await _saveToLocalStorage();
        if (!mounted) return;

        if (savedLocally) {
          setState(() => _isUploading = false);
          _showSnackBar(
            'Firestore izinleri güncellenmeyi bekliyor. Rapor yerel olarak kaydedildi. '
            'Lütfen birkaç dakika sonra tekrar deneyin.',
            isError: false,
          );
          context.go('/reports');
        } else {
          setState(() => _isUploading = false);
          _showSnackBar(
            'Firestore izinleri güncellenmeyi bekliyor. Lütfen birkaç dakika sonra tekrar deneyin.',
            isError: true,
          );
        }
        return;
      }

      // Genel ağ/bağlantı hataları için de offline fallback
      final isNetworkError = errorStr.contains('unavailable') ||
          errorStr.contains('network') ||
          errorStr.contains('timeout') ||
          errorStr.contains('socketexception') ||
          errorStr.contains('failed to connect');

      if (isNetworkError) {
        final savedLocally = await _saveToLocalStorage();
        if (!mounted) return;

        if (savedLocally) {
          setState(() => _isUploading = false);
          _showSnackBar(
            'Çevrimdışı kaydedildi. Bağlantı sağlandığında otomatik yüklenecektir.',
            isError: false,
          );
          context.go('/reports');
        } else {
          setState(() => _isUploading = false);
          _showSnackBar(
            'Bağlantı hatası. Yerel kayıt da başarısız oldu.',
            isError: true,
          );
        }
        return;
      }

      // Diğer hatalar
      setState(() => _isUploading = false);
      _showSnackBar(
        _friendlyErrorMessage(e),
        isError: true,
      );
    }
  }

  /// Firestore erişim hatalarında raporu yerel depoya kaydet
  Future<bool> _saveToLocalStorage() async {
    try {
      final prefs = GetIt.instance<SharedPreferences>();
      final pendingReports = prefs.getStringList('pending_reports') ?? [];

      final reportJson = jsonEncode({
        'title': _titleCtrl.text.trim(),
        'summary': _summaryCtrl.text.trim(),
        'detail': _summaryCtrl.text.trim(),
        'institution': _institutionCtrl.text.trim(),
        'type': _selectedType.name,
        'date': _pickedDate!.toIso8601String(),
        'isAbnormal': _isAbnormal,
        'filePath': _selectedFile?.path,
        'fileName': _selectedFile?.name,
        'savedAt': DateTime.now().toIso8601String(),
      });

      pendingReports.add(reportJson);
      await prefs.setStringList('pending_reports', pendingReports);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Hata mesajlarını kullanıcı dostu hale getir
  String _friendlyErrorMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('permission-denied') ||
        msg.contains('PERMISSION_DENIED')) {
      return 'Erişim izniniz yok. Lütfen yöneticinizle iletişime geçin.';
    }
    if (msg.contains('not-found')) {
      return 'Kaynak bulunamadı. Lütfen tekrar deneyin.';
    }
    if (msg.contains('already-exists')) {
      return 'Bu rapor zaten mevcut.';
    }
    if (msg.contains('resource-exhausted')) {
      return 'Sunucu meşgul. Lütfen bir süre sonra tekrar deneyin.';
    }
    if (msg.contains('unauthenticated')) {
      return 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.';
    }
    // Genel hata — Exception: prefix'ini kaldır
    return msg.replaceAll('Exception: ', '').replaceAll('ReportException: ', '');
  }

  // ── Yardımcılar ─────────────────────────────────────────────────

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid)),
        backgroundColor:
            isError ? KxColors.crimson400 : KxColors.jade500,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }
}

// ── Küçük yardımcılar ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: KxTypography.labelMd.copyWith(
            color: KxColors.textSecondary),
      );
}
