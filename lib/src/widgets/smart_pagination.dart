import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/smart_pagination_enums.dart';
import '../theme/smart_pagination_theme.dart';

/// Clean, state-management agnostic, production-ready pagination UI widget.
///
/// Supports simple direct usage with page parameters and callbacks,
/// responsive layouts, customizable theme, accessibility semantics, and optional keyboard controls.
class SmartPagination extends StatelessWidget {
  /// Creates a [SmartPagination] widget.
  const SmartPagination({
    super.key,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.showPageNumbers = true,
    this.showPreviousNext = true,
    this.showFirstLastButtons = false,
    this.showPageSizeSelector = true,
    this.showItemRange = true,
    this.itemsLabel = '',
    this.maxVisiblePageButtons = 5,
    this.layout = PaginationLayout.auto,
    this.enableKeyboardNavigation = true,
    this.showCard = true,
    this.padding,
    this.theme,
  });

  /// 1-based index of the currently active page.
  final int currentPage;

  /// Number of records displayed per page.
  final int pageSize;

  /// Total number of items across all pages.
  final int totalItems;

  /// Callback fired when user selects or navigates to a new page index.
  final ValueChanged<int> onPageChanged;

  /// Callback fired when user selects a new page size from dropdown.
  final ValueChanged<int> onPageSizeChanged;

  /// Available options for page size dropdown selector.
  final List<int> pageSizeOptions;

  /// Whether to render numbered page buttons.
  final bool showPageNumbers;

  /// Whether to show Previous and Next navigation buttons.
  final bool showPreviousNext;

  /// Whether to show First Page (<<) and Last Page (>>) navigation buttons.
  final bool showFirstLastButtons;

  /// Whether to show page size dropdown selector.
  final bool showPageSizeSelector;

  /// Whether to display item range count label (e.g. `Showing 1–20 of 100 items`).
  final bool showItemRange;

  /// Label used for item range description (default: 'items').
  final String itemsLabel;

  /// Maximum visible numbered page buttons at any one time.
  final int maxVisiblePageButtons;

  /// Layout mode switch (auto, compact, standard, expanded).
  final PaginationLayout layout;

  /// Whether keyboard shortcut navigation (Left/Right/Home/End) is enabled when focused.
  final bool enableKeyboardNavigation;

  /// Whether to enclose controls in a styled card surface container.
  final bool showCard;

  /// Outer padding override for the pagination container.
  final EdgeInsetsGeometry? padding;

  /// Theme override for pagination controls.
  final SmartPaginationThemeData? theme;

  /// Calculated total number of pages based on [totalItems] and [pageSize].
  int get totalPages {
    if (totalItems <= 0 || pageSize <= 0) return 0;
    return (totalItems + pageSize - 1) ~/ pageSize;
  }

  void _handlePageSizeChange(int newSize) {
    if (newSize == pageSize) return;
    onPageSizeChanged(newSize);
    onPageChanged(1);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? SmartPaginationTheme.of(context);

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        PaginationLayout effectiveLayout = layout;
        if (effectiveLayout == PaginationLayout.auto) {
          if (constraints.maxWidth < 480) {
            effectiveLayout = PaginationLayout.compact;
          } else if (constraints.maxWidth < 768) {
            effectiveLayout = PaginationLayout.standard;
          } else {
            effectiveLayout = PaginationLayout.expanded;
          }
        }

        switch (effectiveLayout) {
          case PaginationLayout.compact:
            return _buildCompact(context, effectiveTheme);
          case PaginationLayout.standard:
            return _buildStandard(context, effectiveTheme);
          case PaginationLayout.expanded:
            return _buildExpanded(context, effectiveTheme);
          case PaginationLayout.auto:
            return _buildStandard(context, effectiveTheme);
        }
      },
    );

    if (showCard) {
      final surfaceColor =
          effectiveTheme.surfaceColor ?? Theme.of(context).cardColor;
      final borderColor =
          effectiveTheme.borderColor ?? Theme.of(context).dividerColor;

      content = Material(
        color: surfaceColor,
        borderRadius: effectiveTheme.borderRadius,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: effectiveTheme.borderRadius,
            border: Border.all(color: borderColor),
          ),
          child: content,
        ),
      );
    }

    if (enableKeyboardNavigation) {
      content = Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                currentPage > 1) {
              onPageChanged(currentPage - 1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                currentPage < totalPages) {
              onPageChanged(currentPage + 1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.home &&
                currentPage > 1) {
              onPageChanged(1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.end &&
                currentPage < totalPages) {
              onPageChanged(totalPages);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildItemRangeText(
      BuildContext context, SmartPaginationThemeData themeData) {
    if (!showItemRange || totalItems <= 0) return const SizedBox.shrink();

    final start = (currentPage - 1) * pageSize + 1;
    final end = (start + pageSize - 1).clamp(1, totalItems);

    final textStyle = themeData.labelTextStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: themeData.mutedColor ??
                  Theme.of(context).colorScheme.onSurface.withAlpha(178),
            );

    final String labelSuffix =
        itemsLabel.trim().isNotEmpty ? ' ${itemsLabel.trim()}' : '';

    return Text(
      'Showing $start–$end of $totalItems$labelSuffix',
      style: textStyle,
    );
  }

  Widget _buildPageSizeSelector(
      BuildContext context, SmartPaginationThemeData themeData) {
    if (!showPageSizeSelector) return const SizedBox.shrink();

    final currentOption = pageSizeOptions.contains(pageSize)
        ? pageSize
        : (pageSizeOptions.isNotEmpty ? pageSizeOptions.first : pageSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: themeData.borderColor ?? Theme.of(context).dividerColor,
        ),
        borderRadius: themeData.borderRadius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentOption,
          isDense: true,
          style: themeData.buttonTextStyle ??
              Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
          items: pageSizeOptions.map((size) {
            return DropdownMenuItem<int>(
              value: size,
              child: Text('$size / page'),
            );
          }).toList(),
          onChanged: (newSize) {
            if (newSize != null) {
              _handlePageSizeChange(newSize);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFirstButton(
      BuildContext context, SmartPaginationThemeData themeData) {
    if (!showFirstLastButtons) return const SizedBox.shrink();
    final canGoFirst = currentPage > 1;

    return Semantics(
      label: 'First page',
      button: true,
      enabled: canGoFirst,
      child: Tooltip(
        message: 'First page',
        child: IconButton(
          icon: const Icon(Icons.first_page, size: 20.0),
          onPressed: canGoFirst ? () => onPageChanged(1) : null,
        ),
      ),
    );
  }

  Widget _buildLastButton(
      BuildContext context, SmartPaginationThemeData themeData) {
    if (!showFirstLastButtons) return const SizedBox.shrink();
    final canGoLast = totalPages > 0 && currentPage < totalPages;

    return Semantics(
      label: 'Last page',
      button: true,
      enabled: canGoLast,
      child: Tooltip(
        message: 'Last page',
        child: IconButton(
          icon: const Icon(Icons.last_page, size: 20.0),
          onPressed: canGoLast ? () => onPageChanged(totalPages) : null,
        ),
      ),
    );
  }

  Widget _buildPreviousButton(
      BuildContext context, SmartPaginationThemeData themeData) {
    if (!showPreviousNext) return const SizedBox.shrink();
    final canPrev = currentPage > 1;

    return Semantics(
      label: 'Previous page',
      button: true,
      enabled: canPrev,
      child: Tooltip(
        message: 'Previous page',
        child: OutlinedButton.icon(
          onPressed: canPrev ? () => onPageChanged(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left, size: 18.0),
          label: const Text('Previous'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: themeData.borderRadius,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
      BuildContext context, SmartPaginationThemeData themeData) {
    if (!showPreviousNext) return const SizedBox.shrink();
    final canNext = totalPages > 0 && currentPage < totalPages;

    return Semantics(
      label: 'Next page',
      button: true,
      enabled: canNext,
      child: Tooltip(
        message: 'Next page',
        child: OutlinedButton(
          onPressed: canNext ? () => onPageChanged(currentPage + 1) : null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: themeData.borderRadius,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Next'),
              SizedBox(width: 4.0),
              Icon(Icons.chevron_right, size: 18.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumbers(
      BuildContext context, SmartPaginationThemeData themeData) {
    if (!showPageNumbers || totalPages <= 0) return const SizedBox.shrink();

    final pages = <int>[];
    final startPage =
        (currentPage - (maxVisiblePageButtons ~/ 2)).clamp(1, totalPages);
    final endPage =
        (startPage + maxVisiblePageButtons - 1).clamp(1, totalPages);

    for (int p = startPage; p <= endPage; p++) {
      pages.add(p);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final activeBg = themeData.activePageColor ?? colorScheme.primary;
    final inactiveBg = themeData.inactivePageColor ?? Colors.transparent;
    final activeFg = themeData.activeTextColor ?? colorScheme.onPrimary;
    final inactiveFg = themeData.inactiveTextColor ?? colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pages.map((p) {
        final isSelected = p == currentPage;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Semantics(
            label: 'Page $p',
            selected: isSelected,
            button: true,
            child: Tooltip(
              message: 'Page $p',
              child: InkWell(
                onTap: () => onPageChanged(p),
                borderRadius: themeData.borderRadius,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isSelected ? activeBg : inactiveBg,
                    borderRadius: themeData.borderRadius,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: themeData.borderColor ??
                                Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    '$p',
                    style: themeData.buttonTextStyle?.copyWith(
                          color: isSelected ? activeFg : inactiveFg,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ) ??
                        TextStyle(
                          color: isSelected ? activeFg : inactiveFg,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13.0,
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompact(
      BuildContext context, SmartPaginationThemeData themeData) {
    final canPrev = currentPage > 1;
    final canNext = totalPages > 0 && currentPage < totalPages;
    final pageIndicator =
        totalPages > 0 ? '$currentPage / $totalPages' : 'Page $currentPage';

    return Container(
      padding: padding ?? themeData.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFirstButton(context, themeData),
                  Semantics(
                    label: 'Previous page',
                    button: true,
                    enabled: canPrev,
                    child: Tooltip(
                      message: 'Previous page',
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16.0),
                        onPressed: canPrev
                            ? () => onPageChanged(currentPage - 1)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              Semantics(
                label: 'Current page $pageIndicator',
                child: Text(
                  pageIndicator,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Next page',
                    button: true,
                    enabled: canNext,
                    child: Tooltip(
                      message: 'Next page',
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16.0),
                        onPressed: canNext
                            ? () => onPageChanged(currentPage + 1)
                            : null,
                      ),
                    ),
                  ),
                  _buildLastButton(context, themeData),
                ],
              ),
            ],
          ),
          if (showItemRange || showPageSizeSelector)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildItemRangeText(context, themeData),
                    if (showItemRange && showPageSizeSelector)
                      const SizedBox(width: 12.0),
                    _buildPageSizeSelector(context, themeData),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStandard(
      BuildContext context, SmartPaginationThemeData themeData) {
    return Container(
      padding: padding ?? themeData.padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItemRangeText(context, themeData),
            if (showItemRange && totalItems > 0) const SizedBox(width: 12.0),
            _buildFirstButton(context, themeData),
            _buildPreviousButton(context, themeData),
            SizedBox(width: themeData.spacing),
            _buildPageNumbers(context, themeData),
            SizedBox(width: themeData.spacing),
            _buildNextButton(context, themeData),
            _buildLastButton(context, themeData),
            if (showPageSizeSelector) ...[
              const SizedBox(width: 12.0),
              _buildPageSizeSelector(context, themeData),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(
      BuildContext context, SmartPaginationThemeData themeData) {
    return Container(
      padding: padding ?? themeData.padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItemRangeText(context, themeData),
            if (showItemRange && totalItems > 0) const SizedBox(width: 16.0),
            _buildPageSizeSelector(context, themeData),
            if (showPageSizeSelector) const SizedBox(width: 16.0),
            _buildFirstButton(context, themeData),
            _buildPreviousButton(context, themeData),
            SizedBox(width: themeData.spacing),
            _buildPageNumbers(context, themeData),
            SizedBox(width: themeData.spacing),
            _buildNextButton(context, themeData),
            _buildLastButton(context, themeData),
          ],
        ),
      ),
    );
  }
}

/// Backward compatibility widget for legacy `GlobalPagination` migrations.
@Deprecated('Use SmartPagination instead.')
class GlobalPagination extends StatelessWidget {
  /// Creates a legacy [GlobalPagination] adapter widget.
  const GlobalPagination({
    super.key,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    this.totalPages,
    required this.onPageChanged,
    required ValueChanged<int> onRowsPerPageChanged,
    List<int> pageSizeOptions = const [10, 20, 50, 100],
    bool showPageNumbers = true,
    bool showPreviousNext = true,
    bool showPageSizeSelector = true,
    bool showItemRange = true,
    PaginationLayout layout = PaginationLayout.auto,
  })  : _onRowsPerPageChanged = onRowsPerPageChanged,
        _pageSizeOptions = pageSizeOptions,
        _showPageNumbers = showPageNumbers,
        _showPreviousNext = showPreviousNext,
        _showPageSizeSelector = showPageSizeSelector,
        _showItemRange = showItemRange,
        _layout = layout;

  /// Current 1-based page.
  final int currentPage;

  /// Number of items per page.
  final int pageSize;

  /// Total count of items.
  final int totalItems;

  /// Total pages override (optional).
  final int? totalPages;

  /// Page change callback.
  final ValueChanged<int> onPageChanged;

  /// Rows per page change callback alias.
  final ValueChanged<int> _onRowsPerPageChanged;

  final List<int> _pageSizeOptions;
  final bool _showPageNumbers;
  final bool _showPreviousNext;
  final bool _showPageSizeSelector;
  final bool _showItemRange;
  final PaginationLayout _layout;

  @override
  Widget build(BuildContext context) {
    return SmartPagination(
      currentPage: currentPage,
      pageSize: pageSize,
      totalItems: totalItems,
      onPageChanged: onPageChanged,
      onPageSizeChanged: _onRowsPerPageChanged,
      pageSizeOptions: _pageSizeOptions,
      showPageNumbers: _showPageNumbers,
      showPreviousNext: _showPreviousNext,
      showPageSizeSelector: _showPageSizeSelector,
      showItemRange: _showItemRange,
      itemsLabel: '',
      layout: _layout,
    );
  }
}
