import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:desktop_drop/desktop_drop.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../../../design_system/animations/kx_pressable.dart';
import '../../domain/entities/medical_file_entity.dart';
import '../../domain/entities/medical_image_analysis.dart';
import '../bloc/medical_files_bloc.dart';
import 'medical_image_viewer.dart';

class MedicalFilesPage extends StatefulWidget {
  final String? caseId;
  const MedicalFilesPage({super.key, this.caseId});

  @override
  State<MedicalFilesPage> createState() => _MedicalFilesPageState();
}

class _MedicalFilesPageState extends State<MedicalFilesPage> {
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();
    context.read<MedicalFilesBloc>().add(LoadFilesEvent(caseId: widget.caseId));
  }

  bool get _isDesktopOrWeb =>
      kIsWeb ||
      (!kIsWeb &&
          (Platform.isMacOS || Platform.isWindows || Platform.isLinux));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: DropTarget(
        onDragEntered: (_) => setState(() => _isDragOver = true),
        onDragExited: (_) => setState(() => _isDragOver = false),
        onDragDone: (details) {
          setState(() => _isDragOver = false);
          _handleDroppedFiles(details);
        },
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                if (_isDesktopOrWeb) _buildDropZone(),
                _buildUploadProgressBanner(),
                _buildCategoryFilters(),
                _buildFileGrid(),
              ],
            ),
            // Drag overlay
            if (_isDragOver) _buildDragOverlay(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ── Drag Overlay ─────────────────────────────────────────────────────────
  Widget _buildDragOverlay() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: KxColors.teal400.withOpacity(0.08),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            decoration: BoxDecoration(
              color: KxColors.bgSurface.withOpacity(0.95),
              borderRadius: KxSpacing.radiusLg,
              border: Border.all(color: KxColors.teal400, width: 2),
              boxShadow: KxShadows.tealGlowStrong(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_upload_rounded,
                    size: 56, color: KxColors.teal400),
                const SizedBox(height: 16),
                Text(
                  'Dosyalarinizi birakin',
                  style: KxTypography.headingLg
                      .copyWith(color: KxColors.teal300),
                ),
                const SizedBox(height: 8),
                Text(
                  'JPG, PNG, PDF, DICOM',
                  style: KxTypography.bodyMd
                      .copyWith(color: KxColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Drop Zone (visible on desktop/web) ────────────────────────────────────
  Widget _buildDropZone() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: KxPressable(
          onTap: () => _showUploadSheet(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: KxColors.bgCard.withOpacity(0.5),
              borderRadius: KxSpacing.radiusLg,
            ),
            child: CustomPaint(
              painter: _DashBorderPainter(
                color: KxColors.teal400.withOpacity(0.35),
                strokeWidth: 1.5,
                radius: 16,
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 36, color: KxColors.teal400.withOpacity(0.7)),
                  const SizedBox(height: 10),
                  Text(
                    'Dosyalarinizi buraya surukleyin',
                    style: KxTypography.headingSm.copyWith(
                      color: KxColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'veya tiklayarak secin  •  JPG, PNG, PDF, DICOM',
                    style: KxTypography.bodySm.copyWith(
                      color: KxColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDroppedFiles(DropDoneDetails details) {
    final files = details.files;
    if (files.isEmpty) return;

    final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'dcm'];
    final validFiles = files.where((f) {
      final ext = f.path.split('.').last.toLowerCase();
      return allowedExtensions.contains(ext);
    }).toList();

    if (validFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Desteklenmeyen dosya formati. JPG, PNG, PDF veya DICOM kullanin.',
            style: KxTypography.bodySm.copyWith(color: Colors.white),
          ),
          backgroundColor: KxColors.crimson500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
        ),
      );
      return;
    }

    if (validFiles.length == 1) {
      context.read<MedicalFilesBloc>().add(UploadFileEvent(
            filePath: validFiles.first.path,
            fileName: validFiles.first.name,
            category: _guessCategoryFromName(validFiles.first.name),
            caseId: widget.caseId,
          ));
    } else {
      context.read<MedicalFilesBloc>().add(UploadMultipleFilesEvent(
            filePaths: validFiles.map((f) => f.path).toList(),
            fileNames: validFiles.map((f) => f.name).toList(),
            category: FileCategory.other,
            caseId: widget.caseId,
          ));
    }
  }

  FileCategory _guessCategoryFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('xray') || lower.contains('rontgen')) {
      return FileCategory.xray;
    }
    if (lower.contains('ct') || lower.contains('bt') || lower.contains('tomo')) {
      return FileCategory.ct;
    }
    if (lower.contains('mr') || lower.contains('mri')) {
      return FileCategory.mri;
    }
    if (lower.contains('ekg') || lower.contains('ecg')) {
      return FileCategory.ecg;
    }
    if (lower.contains('ultra') || lower.contains('usg')) {
      return FileCategory.ultrasound;
    }
    if (lower.contains('lab') || lower.contains('kan') || lower.contains('test')) {
      return FileCategory.labResult;
    }
    if (lower.contains('pato')) {
      return FileCategory.pathology;
    }
    return FileCategory.other;
  }

  // ── Upload Progress Banner ────────────────────────────────────────────────
  Widget _buildUploadProgressBanner() {
    return SliverToBoxAdapter(
      child: BlocBuilder<MedicalFilesBloc, MedicalFilesState>(
        buildWhen: (prev, curr) =>
            curr is FileUploading || curr is FileUploaded || curr is UploadCancelled,
        builder: (context, state) {
          if (state is FileUploading) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KxColors.bgElevated,
                  borderRadius: KxSpacing.radiusMd,
                  border: Border.all(
                    color: KxColors.teal400.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                KxColors.teal400),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.fileName ?? 'Yukleniyor...',
                                style: KxTypography.labelMd.copyWith(
                                  color: KxColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (state.totalFiles > 1)
                                Text(
                                  '${state.currentFile} / ${state.totalFiles} dosya',
                                  style: KxTypography.caption,
                                ),
                            ],
                          ),
                        ),
                        // Cancel button
                        KxPressable(
                          onTap: () {
                            context
                                .read<MedicalFilesBloc>()
                                .add(const CancelUploadEvent());
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: KxColors.crimson400.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 16, color: KxColors.crimson400),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: KxSpacing.radiusSm,
                      child: LinearProgressIndicator(
                        value: state.progress,
                        minHeight: 4,
                        backgroundColor: KxColors.bgCard,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            KxColors.teal400),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: KxColors.bgBase,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: KxColors.textPrimary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          'Tibbi Dosyalar',
          style: KxTypography.headingLg.copyWith(
            color: KxColors.textPrimary,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                KxColors.teal900.withOpacity(0.3),
                KxColors.bgBase,
              ],
            ),
          ),
        ),
      ),
      actions: [
        BlocBuilder<MedicalFilesBloc, MedicalFilesState>(
          builder: (context, state) {
            if (state is MedicalFilesLoaded) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KxColors.teal400.withOpacity(0.15),
                      borderRadius: KxSpacing.radiusPill,
                    ),
                    child: Text(
                      '${state.filteredFiles.length} dosya',
                      style: KxTypography.labelSm.copyWith(
                        color: KxColors.teal300,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // ── Category Filter Chips ───────────────────────────────────────────────
  Widget _buildCategoryFilters() {
    return SliverToBoxAdapter(
      child: BlocBuilder<MedicalFilesBloc, MedicalFilesState>(
        builder: (context, state) {
          final activeFilter =
              state is MedicalFilesLoaded ? state.activeFilter : null;
          return SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                _FilterChip(
                  label: 'Tumu',
                  icon: Icons.grid_view_rounded,
                  isActive: activeFilter == null,
                  color: KxColors.teal400,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context
                        .read<MedicalFilesBloc>()
                        .add(const FilterByCategoryEvent(null));
                  },
                ),
                const SizedBox(width: 8),
                ...FileCategory.values.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: cat.label,
                        icon: cat.icon,
                        isActive: activeFilter == cat,
                        color: cat.color,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context
                              .read<MedicalFilesBloc>()
                              .add(FilterByCategoryEvent(cat));
                        },
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── File Grid ───────────────────────────────────────────────────────────
  Widget _buildFileGrid() {
    return BlocBuilder<MedicalFilesBloc, MedicalFilesState>(
      builder: (context, state) {
        if (state is MedicalFilesLoading) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(KxColors.teal400),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dosyalar yukleniyor...',
                    style: KxTypography.bodyMd.copyWith(
                      color: KxColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is MedicalFilesError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: KxColors.crimson400),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: KxTypography.bodyMd
                          .copyWith(color: KxColors.textSecondary)),
                ],
              ),
            ),
          );
        }

        if (state is MedicalFilesLoaded) {
          if (state.filteredFiles.isEmpty) {
            return SliverFillRemaining(child: _buildEmptyState());
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Each item = file card + optional AI analysis card
                  final fileIndex = index ~/ 2; // pair index
                  final isPairStart = index.isEven;

                  if (isPairStart) {
                    // Build a row of 2 file cards
                    final file1 = state.filteredFiles[fileIndex * 2];
                    final file2 = (fileIndex * 2 + 1) < state.filteredFiles.length
                        ? state.filteredFiles[fileIndex * 2 + 1]
                        : null;

                    final imageFiles = state.filteredFiles
                        .where((f) => f.isImage)
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 0.72,
                              child: _FileCard(
                                file: file1,
                                aiAnalysis: state.aiAnalyses[file1.id],
                                isAnalyzing:
                                    state.analyzingFileIds.contains(file1.id),
                                onTap: () => _openFileViewer(file1, imageFiles),
                                onLongPress: () => _showFileOptions(file1),
                                onReanalyze: () => _reanalyzeFile(file1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: file2 != null
                                ? AspectRatio(
                                    aspectRatio: 0.72,
                                    child: _FileCard(
                                      file: file2,
                                      aiAnalysis: state.aiAnalyses[file2.id],
                                      isAnalyzing: state.analyzingFileIds
                                          .contains(file2.id),
                                      onTap: () =>
                                          _openFileViewer(file2, imageFiles),
                                      onLongPress: () =>
                                          _showFileOptions(file2),
                                      onReanalyze: () =>
                                          _reanalyzeFile(file2),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Build AI analysis cards for the pair
                    final file1 = state.filteredFiles[fileIndex * 2];
                    final file2 = (fileIndex * 2 + 1) < state.filteredFiles.length
                        ? state.filteredFiles[fileIndex * 2 + 1]
                        : null;

                    final analysis1 = state.aiAnalyses[file1.id];
                    final analysis2 =
                        file2 != null ? state.aiAnalyses[file2.id] : null;
                    final analyzing1 =
                        state.analyzingFileIds.contains(file1.id);
                    final analyzing2 = file2 != null
                        ? state.analyzingFileIds.contains(file2.id)
                        : false;

                    final hasContent = analysis1 != null ||
                        analysis2 != null ||
                        analyzing1 ||
                        analyzing2;

                    if (!hasContent) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          if (analysis1 != null || analyzing1)
                            _AIAnalysisCard(
                              fileName: file1.originalName,
                              analysis: analysis1,
                              isAnalyzing: analyzing1,
                              onReanalyze: () => _reanalyzeFile(file1),
                            ),
                          if (analysis2 != null || analyzing2) ...[
                            const SizedBox(height: 8),
                            _AIAnalysisCard(
                              fileName: file2!.originalName,
                              analysis: analysis2,
                              isAnalyzing: analyzing2,
                              onReanalyze: () => _reanalyzeFile(file2),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                },
                childCount: _calculateListCount(state.filteredFiles.length),
              ),
            ),
          );
        }

        return const SliverFillRemaining(child: SizedBox.shrink());
      },
    );
  }

  int _calculateListCount(int fileCount) {
    // Each pair of files takes 2 slots: row of cards + AI analysis cards
    final pairs = (fileCount + 1) ~/ 2;
    return pairs * 2;
  }

  void _reanalyzeFile(MedicalFile file) {
    if (file.isImage) {
      // We need the file path; use fileUrl as path fallback
      context.read<MedicalFilesBloc>().add(AnalyzeFileWithAIEvent(
            fileId: file.id,
            filePath: file.fileUrl,
            mimeType: file.mimeType,
          ));
    }
  }

  // ── Empty State ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: KxColors.bgElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: KxColors.border,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 36,
                color: KxColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Henuz dosya yok',
              style: KxTypography.headingMd.copyWith(
                color: KxColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isDesktopOrWeb
                  ? 'Dosyalarinizi surukleyin veya\n"+" butonuna dokunun.'
                  : 'Tibbi dosyalarinizi yuklemek icin\n"+" butonuna dokunun.',
              textAlign: TextAlign.center,
              style: KxTypography.bodyMd.copyWith(
                color: KxColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return KxPressable(
      onTap: () => _showUploadSheet(),
      hapticType: HapticType.medium,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [KxColors.teal400, KxColors.teal500],
          ),
          shape: BoxShape.circle,
          boxShadow: KxShadows.tealGlow(),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // ── File Viewer Navigation ──────────────────────────────────────────────
  void _openFileViewer(MedicalFile file, List<MedicalFile> imageFiles) {
    HapticFeedback.lightImpact();
    if (file.isImage) {
      final initialIndex = imageFiles.indexOf(file);
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MedicalImageViewer(
            files: imageFiles,
            initialIndex: initialIndex >= 0 ? initialIndex : 0,
          ),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (file.isPdf) {
      _showPdfInfo(file);
    }
  }

  void _showPdfInfo(MedicalFile file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: KxColors.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: KxColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: KxColors.textMuted,
                  borderRadius: KxSpacing.radiusFull,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: KxColors.crimson400.withOpacity(0.15),
                    borderRadius: KxSpacing.radiusMd,
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded,
                      color: KxColors.crimson400, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.originalName,
                          style: KxTypography.headingMd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(file.sizeText,
                          style: KxTypography.bodySm
                              .copyWith(color: KxColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            if (file.notes != null) ...[
              const SizedBox(height: 16),
              Text(file.notes!,
                  style: KxTypography.bodyMd
                      .copyWith(color: KxColors.textSecondary)),
            ],
            const SizedBox(height: 24),
            Text(
              'PDF goruntuleme yaklnda eklenecek.',
              style: KxTypography.bodySm.copyWith(color: KxColors.textMuted),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  // ── File Options (Long Press) ───────────────────────────────────────────
  void _showFileOptions(MedicalFile file) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KxColors.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: KxColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: KxColors.textMuted,
                  borderRadius: KxSpacing.radiusFull,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(file.originalName,
                style: KxTypography.headingSm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            _OptionTile(
              icon: Icons.info_outline_rounded,
              label: 'Detaylar',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            if (file.isImage)
              _OptionTile(
                icon: Icons.auto_awesome_rounded,
                label: 'AI Analiz',
                onTap: () {
                  Navigator.pop(context);
                  _reanalyzeFile(file);
                },
              ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Sil',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(file);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(MedicalFile file) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: KxColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusLg),
        title: Text('Dosyayi Sil',
            style: KxTypography.headingMd
                .copyWith(color: KxColors.textPrimary)),
        content: Text(
          '"${file.originalName}" dosyasini silmek istediginizden emin misiniz?',
          style:
              KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Iptal',
                style: KxTypography.labelMd
                    .copyWith(color: KxColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<MedicalFilesBloc>()
                  .add(DeleteFileEvent(file.id));
            },
            child: Text('Sil',
                style: KxTypography.labelMd
                    .copyWith(color: KxColors.crimson400)),
          ),
        ],
      ),
    );
  }

  // ── Upload Bottom Sheet ─────────────────────────────────────────────────
  void _showUploadSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<MedicalFilesBloc>(),
        child: _UploadSheet(caseId: widget.caseId),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHED BORDER PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _DashBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  _DashBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));

    // Draw dashed path
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius;
}

// ═══════════════════════════════════════════════════════════════════════════
// AI ANALYSIS CARD
// ═══════════════════════════════════════════════════════════════════════════

class _AIAnalysisCard extends StatefulWidget {
  final String fileName;
  final MedicalImageAnalysis? analysis;
  final bool isAnalyzing;
  final VoidCallback onReanalyze;

  const _AIAnalysisCard({
    required this.fileName,
    required this.analysis,
    required this.isAnalyzing,
    required this.onReanalyze,
  });

  @override
  State<_AIAnalysisCard> createState() => _AIAnalysisCardState();
}

class _AIAnalysisCardState extends State<_AIAnalysisCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isAnalyzing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KxColors.bgElevated,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(
            color: KxColors.teal400.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(KxColors.teal400),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI analiz yapiliyor: ${widget.fileName}',
                style: KxTypography.bodySm.copyWith(
                  color: KxColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final analysis = widget.analysis;
    if (analysis == null) return const SizedBox.shrink();

    // Confidence color
    Color confidenceColor;
    if (analysis.confidenceScore >= 0.8) {
      confidenceColor = KxColors.jade300;
    } else if (analysis.confidenceScore >= 0.5) {
      confidenceColor = KxColors.amber300;
    } else {
      confidenceColor = KxColors.crimson300;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: KxColors.bgElevated,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(
          color: KxColors.teal400.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — always visible
          KxPressable(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: KxColors.teal400.withOpacity(0.15),
                      borderRadius: KxSpacing.radiusSm,
                    ),
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 16, color: KxColors.teal400),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Analiz Sonucu',
                          style: KxTypography.labelMd.copyWith(
                            color: KxColors.teal300,
                          ),
                        ),
                        Text(
                          widget.fileName,
                          style: KxTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Confidence badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.15),
                      borderRadius: KxSpacing.radiusSm,
                    ),
                    child: Text(
                      '${(analysis.confidenceScore * 100).toStringAsFixed(0)}%',
                      style: KxTypography.labelSm.copyWith(
                        color: confidenceColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: KxColors.textMuted),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: KxColors.border, height: 1),
                  const SizedBox(height: 12),

                  // Findings
                  _AnalysisSection(
                    title: 'Bulgular',
                    icon: Icons.search_rounded,
                    content: analysis.findings,
                  ),
                  const SizedBox(height: 10),

                  // Impression
                  _AnalysisSection(
                    title: 'Degerlendirme',
                    icon: Icons.lightbulb_outline_rounded,
                    content: analysis.impression,
                  ),
                  const SizedBox(height: 10),

                  // Recommendations
                  if (analysis.recommendations.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.recommend_rounded,
                            size: 14, color: KxColors.jade300),
                        const SizedBox(width: 6),
                        Text(
                          'Oneriler',
                          style: KxTypography.labelSm.copyWith(
                            color: KxColors.jade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...analysis.recommendations.map(
                      (rec) => Padding(
                        padding: const EdgeInsets.only(
                            left: 20, bottom: 4),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('- ',
                                style: KxTypography.bodySm.copyWith(
                                    color: KxColors.textSecondary)),
                            Expanded(
                              child: Text(
                                rec,
                                style: KxTypography.bodySm.copyWith(
                                  color: KxColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Model info + Re-analyze button
                  Row(
                    children: [
                      Text(
                        'Model: ${analysis.aiModel}',
                        style: KxTypography.caption.copyWith(fontSize: 10),
                      ),
                      const Spacer(),
                      KxPressable(
                        onTap: widget.onReanalyze,
                        hapticType: HapticType.light,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: KxColors.teal400.withOpacity(0.12),
                            borderRadius: KxSpacing.radiusSm,
                            border: Border.all(
                              color: KxColors.teal400.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded,
                                  size: 13, color: KxColors.teal400),
                              const SizedBox(width: 4),
                              Text(
                                'Tekrar Analiz Et',
                                style: KxTypography.labelSm.copyWith(
                                  color: KxColors.teal400,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Disclaimer
                  const SizedBox(height: 8),
                  Text(
                    'Bu analiz klinik karar destegi amaclidir. Kesin tani icin uzman degerlendirmesi gereklidir.',
                    style: KxTypography.caption.copyWith(
                      fontSize: 9,
                      color: KxColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const _AnalysisSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: KxColors.teal300),
            const SizedBox(width: 6),
            Text(
              title,
              style: KxTypography.labelSm
                  .copyWith(color: KxColors.teal300),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            content,
            style: KxTypography.bodySm
                .copyWith(color: KxColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILTER CHIP
// ═══════════════════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KxPressable(
      onTap: onTap,
      hapticType: HapticType.selection,
      scaleFactor: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.18) : KxColors.bgElevated,
          borderRadius: KxSpacing.radiusPill,
          border: Border.all(
            color: isActive ? color.withOpacity(0.4) : KxColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isActive ? color : KxColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: KxTypography.labelSm.copyWith(
                color: isActive ? color : KxColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILE CARD
// ═══════════════════════════════════════════════════════════════════════════

class _FileCard extends StatelessWidget {
  final MedicalFile file;
  final MedicalImageAnalysis? aiAnalysis;
  final bool isAnalyzing;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onReanalyze;

  const _FileCard({
    required this.file,
    this.aiAnalysis,
    this.isAnalyzing = false,
    required this.onTap,
    required this.onLongPress,
    required this.onReanalyze,
  });

  @override
  Widget build(BuildContext context) {
    return KxPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      scaleFactor: 0.95,
      child: Container(
        decoration: BoxDecoration(
          color: KxColors.bgSurface,
          borderRadius: KxSpacing.radiusLg,
          border: Border.all(color: KxColors.border, width: 0.5),
          boxShadow: KxShadows.sm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: file.category.color.withOpacity(0.2),
                        borderRadius: KxSpacing.radiusSm,
                        border: Border.all(
                          color: file.category.color.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(file.category.icon,
                              size: 10, color: file.category.color),
                          const SizedBox(width: 4),
                          Text(
                            file.category.label,
                            style: KxTypography.labelSm.copyWith(
                              color: file.category.color,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // AI badge (if analyzed or analyzing)
                  if (aiAnalysis != null || isAnalyzing)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAnalyzing
                              ? KxColors.amber500.withOpacity(0.2)
                              : KxColors.teal400.withOpacity(0.2),
                          borderRadius: KxSpacing.radiusSm,
                          border: Border.all(
                            color: isAnalyzing
                                ? KxColors.amber500.withOpacity(0.3)
                                : KxColors.teal400.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAnalyzing)
                              SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      KxColors.amber500),
                                ),
                              )
                            else
                              Icon(Icons.auto_awesome_rounded,
                                  size: 9, color: KxColors.teal400),
                            const SizedBox(width: 3),
                            Text(
                              isAnalyzing ? 'AI...' : 'AI',
                              style: KxTypography.labelSm.copyWith(
                                color: isAnalyzing
                                    ? KxColors.amber500
                                    : KxColors.teal400,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.originalName,
                      style: KxTypography.labelMd.copyWith(
                        color: KxColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${file.sizeText}  •  ${_formatDate(file.uploadedAt)}',
                      style: KxTypography.caption.copyWith(fontSize: 10),
                    ),
                    if (file.notes != null) ...[
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          file.notes!,
                          style: KxTypography.bodySm.copyWith(
                            color: KxColors.textSecondary,
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (file.isPdf) {
      return Container(
        color: KxColors.bgElevated,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_rounded,
                  size: 36, color: KxColors.crimson400.withOpacity(0.7)),
              const SizedBox(height: 4),
              Text('PDF',
                  style: KxTypography.labelSm
                      .copyWith(color: KxColors.textMuted)),
            ],
          ),
        ),
      );
    }

    // Mock image placeholder with category-themed gradient
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            file.category.color.withOpacity(0.15),
            KxColors.bgElevated,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          file.category.icon,
          size: 40,
          color: file.category.color.withOpacity(0.4),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk once';
    if (diff.inHours < 24) return '${diff.inHours} saat once';
    if (diff.inDays < 7) return '${diff.inDays} gun once';
    return DateFormat('dd MMM', 'tr').format(date);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OPTION TILE (bottom sheet)
// ═══════════════════════════════════════════════════════════════════════════

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? KxColors.crimson400 : KxColors.textPrimary;
    return KxPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Text(label,
                style: KxTypography.bodyLg.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UPLOAD BOTTOM SHEET (Enhanced with Camera + Multi-file)
// ═══════════════════════════════════════════════════════════════════════════

class _UploadSheet extends StatefulWidget {
  final String? caseId;
  const _UploadSheet({this.caseId});

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  FileCategory _selectedCategory = FileCategory.other;
  final _notesController = TextEditingController();
  final List<_SelectedFile> _selectedFiles = [];
  bool _isUploading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'dcm'],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (final file in result.files) {
          if (file.path != null) {
            _selectedFiles.add(_SelectedFile(
              path: file.path!,
              name: file.name,
              size: file.size,
            ));
          }
        }
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (image != null) {
      final file = File(image.path);
      final size = await file.length();
      setState(() {
        _selectedFiles.add(_SelectedFile(
          path: image.path,
          name: image.name,
          size: size,
        ));
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _upload() {
    if (_selectedFiles.isEmpty) return;
    setState(() => _isUploading = true);

    if (_selectedFiles.length == 1) {
      context.read<MedicalFilesBloc>().add(UploadFileEvent(
            filePath: _selectedFiles.first.path,
            fileName: _selectedFiles.first.name,
            category: _selectedCategory,
            caseId: widget.caseId,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          ));
    } else {
      context.read<MedicalFilesBloc>().add(UploadMultipleFilesEvent(
            filePaths: _selectedFiles.map((f) => f.path).toList(),
            fileNames: _selectedFiles.map((f) => f.name).toList(),
            category: _selectedCategory,
            caseId: widget.caseId,
          ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: KxColors.border, width: 0.5),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: KxColors.textMuted,
                  borderRadius: KxSpacing.radiusFull,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Dosya Yukle',
                style: KxTypography.headingLg
                    .copyWith(color: KxColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Tibbi dosyanizi secin ve kategori belirleyin.',
                style: KxTypography.bodyMd
                    .copyWith(color: KxColors.textSecondary)),
            const SizedBox(height: 24),

            // Source selection: File Picker + Camera
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.folder_open_rounded,
                    label: 'Dosya Sec',
                    sublabel: 'Coklu secim',
                    onTap: _pickFiles,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera ile Cek',
                    sublabel: 'Fotograf',
                    onTap: _pickFromCamera,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selected files list
            if (_selectedFiles.isNotEmpty) ...[
              Text(
                '${_selectedFiles.length} dosya secildi',
                style: KxTypography.labelMd
                    .copyWith(color: KxColors.textSecondary),
              ),
              const SizedBox(height: 8),
              ..._selectedFiles.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: KxColors.bgElevated,
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(
                        color: KxColors.teal400.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(file.name),
                          size: 20,
                          color: KxColors.teal400,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: KxTypography.labelSm.copyWith(
                                  color: KxColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _formatSize(file.size),
                                style: KxTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        KxPressable(
                          onTap: () => _removeFile(index),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: KxColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ] else ...[
              // Empty state for file picker
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: KxColors.bgElevated,
                  borderRadius: KxSpacing.radiusLg,
                  border: Border.all(color: KxColors.border, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_rounded,
                        size: 36, color: KxColors.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      'Dosya secmek icin yukaridaki\nbuttonlari kullanin',
                      style: KxTypography.labelMd.copyWith(
                        color: KxColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JPG, PNG, PDF, DICOM',
                      style: KxTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Category selector
            Text('Kategori',
                style: KxTypography.labelMd
                    .copyWith(color: KxColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FileCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return KxPressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  },
                  scaleFactor: 0.94,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withOpacity(0.18)
                          : KxColors.bgCard,
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(
                        color: isSelected
                            ? cat.color.withOpacity(0.4)
                            : KxColors.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon,
                            size: 14,
                            color: isSelected ? cat.color : KxColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: KxTypography.labelSm.copyWith(
                            color: isSelected
                                ? cat.color
                                : KxColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Notes
            Text('Notlar (opsiyonel)',
                style: KxTypography.labelMd
                    .copyWith(color: KxColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: KxTypography.bodyMd.copyWith(color: KxColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Klinik notlar, bulgular...',
                hintStyle: KxTypography.bodyMd
                    .copyWith(color: KxColors.textDisabled),
                filled: true,
                fillColor: KxColors.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: KxSpacing.radiusMd,
                  borderSide: BorderSide(color: KxColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: KxSpacing.radiusMd,
                  borderSide: BorderSide(color: KxColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: KxSpacing.radiusMd,
                  borderSide: BorderSide(color: KxColors.teal400, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),

            // Upload button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: KxPressable(
                onTap: _selectedFiles.isNotEmpty && !_isUploading
                    ? _upload
                    : null,
                hapticType: HapticType.medium,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _selectedFiles.isNotEmpty
                        ? const LinearGradient(
                            colors: [KxColors.teal400, KxColors.teal500],
                          )
                        : null,
                    color: _selectedFiles.isEmpty
                        ? KxColors.bgCard
                        : null,
                    borderRadius: KxSpacing.radiusMd,
                    boxShadow: _selectedFiles.isNotEmpty
                        ? KxShadows.tealGlow()
                        : null,
                  ),
                  child: _isUploading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_rounded,
                              size: 20,
                              color: _selectedFiles.isNotEmpty
                                  ? Colors.white
                                  : KxColors.textDisabled,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedFiles.length > 1
                                  ? '${_selectedFiles.length} Dosya Yukle'
                                  : 'Yukle',
                              style: KxTypography.headingSm.copyWith(
                                color: _selectedFiles.isNotEmpty
                                    ? Colors.white
                                    : KxColors.textDisabled,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'dcm':
        return Icons.view_in_ar_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ── Source Selection Button ─────────────────────────────────────────────────

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KxPressable(
      onTap: onTap,
      hapticType: HapticType.light,
      scaleFactor: 0.96,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: KxColors.bgElevated,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: KxColors.teal400),
            const SizedBox(height: 8),
            Text(
              label,
              style:
                  KxTypography.labelMd.copyWith(color: KxColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: KxTypography.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selected File Model ─────────────────────────────────────────────────────

class _SelectedFile {
  final String path;
  final String name;
  final int size;

  const _SelectedFile({
    required this.path,
    required this.name,
    required this.size,
  });
}
