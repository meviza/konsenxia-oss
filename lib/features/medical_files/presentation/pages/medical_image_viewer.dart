import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/animations/kx_pressable.dart';
import '../../domain/entities/medical_file_entity.dart';

/// Tam ekran tibbi goruntu goruntuleme sayfasi.
///
/// Pinch-to-zoom, yatay swipe ve dosya bilgileri gosterir.
/// Mock verilerinde gercek dosya yoksa placeholder gosterir.
class MedicalImageViewer extends StatefulWidget {
  final List<MedicalFile> files;
  final int initialIndex;

  const MedicalImageViewer({
    super.key,
    required this.files,
    this.initialIndex = 0,
  });

  @override
  State<MedicalImageViewer> createState() => _MedicalImageViewerState();
}

class _MedicalImageViewerState extends State<MedicalImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  MedicalFile get _currentFile => widget.files[_currentIndex];

  void _toggleOverlay() {
    HapticFeedback.selectionClick();
    setState(() => _showOverlay = !_showOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Image PageView ──────────────────────────────────────────
          GestureDetector(
            onTap: _toggleOverlay,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final file = widget.files[index];
                return _buildImageView(file);
              },
            ),
          ),

          // ── Top Bar ─────────────────────────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            top: _showOverlay ? 0 : -140,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // ── Bottom Bar ──────────────────────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            bottom: _showOverlay ? 0 : -220,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),

          // ── Page Indicator ──────────────────────────────────────────
          if (widget.files.length > 1 && _showOverlay)
            Positioned(
              bottom: _bottomBarHeight + 16,
              left: 0,
              right: 0,
              child: _buildPageIndicator(),
            ),
        ],
      ),
    );
  }

  double get _bottomBarHeight {
    final padding = MediaQuery.of(context).padding.bottom;
    return 140 + padding;
  }

  // ── Image View (with placeholder for mock data) ─────────────────────
  Widget _buildImageView(MedicalFile file) {
    final imageFile = File(file.fileUrl);
    final hasRealFile =
        file.fileUrl.isNotEmpty && imageFile.existsSync();

    if (hasRealFile) {
      return PhotoView(
        imageProvider: FileImage(imageFile),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3.0,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(KxColors.teal400),
              value: event?.expectedTotalBytes != null
                  ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
                  : null,
            ),
          ),
        ),
      );
    }

    // Placeholder for mock files
    return _buildPlaceholder(file);
  }

  Widget _buildPlaceholder(MedicalFile file) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category icon in a large circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    file.category.color.withOpacity(0.2),
                    file.category.color.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                file.category.icon,
                size: 56,
                color: file.category.color.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              file.originalName,
              style: KxTypography.headingMd.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: file.category.color.withOpacity(0.15),
                borderRadius: KxSpacing.radiusPill,
              ),
              child: Text(
                file.category.label,
                style: KxTypography.labelSm.copyWith(
                  color: file.category.color,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (file.width != null && file.height != null)
              Text(
                '${file.width} x ${file.height} piksel',
                style: KxTypography.monoSm.copyWith(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            const SizedBox(height: 32),
            Text(
              'Onizleme mevcut degil',
              style: KxTypography.bodySm.copyWith(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(8, topPadding + 8, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Close button
          KxPressable(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // File name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentFile.originalName,
                  style: KxTypography.headingSm.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_currentIndex + 1} / ${widget.files.length}',
                  style: KxTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Size row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _currentFile.category.color.withOpacity(0.2),
                  borderRadius: KxSpacing.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_currentFile.category.icon,
                        size: 13, color: _currentFile.category.color),
                    const SizedBox(width: 5),
                    Text(
                      _currentFile.category.label,
                      style: KxTypography.labelSm.copyWith(
                        color: _currentFile.category.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _currentFile.sizeText,
                style: KxTypography.monoSm.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(_currentFile.uploadedAt),
                style: KxTypography.caption.copyWith(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),

          // Notes
          if (_currentFile.notes != null) ...[
            const SizedBox(height: 10),
            Text(
              _currentFile.notes!,
              style: KxTypography.bodyMd.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Uploaded by
          const SizedBox(height: 8),
          Text(
            'Yukleyen: ${_currentFile.uploadedBy}',
            style: KxTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page Indicator ──────────────────────────────────────────────────
  Widget _buildPageIndicator() {
    if (widget.files.length <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.files.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 20 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive
                ? KxColors.teal400
                : Colors.white.withOpacity(0.3),
            borderRadius: KxSpacing.radiusFull,
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'tr').format(date);
  }
}
