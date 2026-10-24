import 'package:flutter/material.dart';
import '../molecules/kx_search_bar.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Template — KxHubTemplate
///
/// Case Hub / Knowledge Hub sayfa iskeleti.
/// Arama çubuğu + filtreler + grid/liste içerik.
/// Sticky header ile scroll'a duyarlı üst bölüm.
///
/// Kullanım:
/// ```dart
/// KxHubTemplate(
///   title: 'Case Hub',
///   searchHint: 'Vaka ara...',
///   onSearch: (q) {},
///   filters: ['kardiyoloji', 'nöroloji'],
///   body: CasesGrid(cases: cases),
///   fab: FloatingActionButton(...),
/// )
/// ```
class KxHubTemplate extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String searchHint;
  final ValueChanged<String>? onSearch;
  final List<String> filters;
  final String? selectedFilter;
  final ValueChanged<String?>? onFilterSelected;
  final Widget body;
  final List<Widget>? headerActions;
  final Widget? fab;
  final bool sliverBody;

  const KxHubTemplate({
    super.key,
    required this.title,
    this.subtitle,
    this.searchHint = 'Ara...',
    this.onSearch,
    this.filters = const [],
    this.selectedFilter,
    this.onFilterSelected,
    required this.body,
    this.headerActions,
    this.fab,
    this.sliverBody = false,
  });

  @override
  State<KxHubTemplate> createState() => _KxHubTemplateState();
}

class _KxHubTemplateState extends State<KxHubTemplate> {
  final ScrollController _scroll = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final scrolled = _scroll.offset > 10;
      if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky header
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: KxColors.bgSurface,
                border: Border(
                  bottom: BorderSide(
                    color: _isScrolled ? KxColors.border : Colors.transparent,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık + aksiyonlar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Color(0xFFF0F4FF),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (widget.subtitle != null)
                              Text(
                                widget.subtitle!,
                                style: const TextStyle(
                                  color: Color(0xFF8B96B5),
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        if (widget.headerActions != null)
                          ...widget.headerActions!,
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Arama
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: KxSearchBar(
                      hint: widget.searchHint,
                      onChanged: widget.onSearch,
                      filters: widget.filters,
                      selectedFilter: widget.selectedFilter,
                      onFilterSelected: widget.onFilterSelected,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // İçerik
            Expanded(
              child: widget.sliverBody
                  ? CustomScrollView(
                      controller: _scroll,
                      slivers: [
                        SliverPadding(
                          padding: KxSpacing.pagePadding,
                          sliver: widget.body,
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      controller: _scroll,
                      padding: KxSpacing.pagePadding,
                      child: widget.body,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.fab,
    );
  }
}
