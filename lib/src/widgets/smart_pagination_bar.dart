import 'package:flutter/material.dart';

import '../controller/smart_pagination_controller.dart';
import '../models/smart_pagination_enums.dart';
import '../state/smart_pagination_state.dart';
import '../theme/smart_pagination_theme.dart';

/// Modern, accessible, responsive pagination control bar.
class SmartPaginationBar<T> extends StatelessWidget {
  /// Creates a [SmartPaginationBar].
  const SmartPaginationBar({
    super.key,
    required this.controller,
    this.layout = PaginationLayout.auto,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.showPageSizeSelector = true,
    this.showRangeCount = true,
    this.maxVisiblePages = 5,
    this.paginationBuilder,
  });

  /// Target pagination controller.
  final SmartPaginationController<T> controller;

  /// Layout mode (auto, compact, standard, expanded).
  final PaginationLayout layout;

  /// Options for page size dropdown selector.
  final List<int> pageSizeOptions;

  /// Whether to display page size selector dropdown.
  final bool showPageSizeSelector;

  /// Whether to show items range text (e.g., `Showing 21–40 of 127`).
  final bool showRangeCount;

  /// Maximum visible numbered page buttons.
  final int maxVisiblePages;

  /// Custom builder callback to completely override default pagination bar.
  final Widget Function(BuildContext context, SmartPaginationState<T> state)?
      paginationBuilder;

  void _goToPage(int page) {
    if (page == controller.state.currentPage) return;
    if (controller.strategy == PaginationStrategy.page) {
      final targetOffset =
          (page - controller.initialPage) * controller.pageSize;
      controller.state.copyWith(currentPage: page, currentOffset: targetOffset);
    }
    controller.loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SmartPaginationState<T>>(
      valueListenable: controller,
      builder: (context, state, _) {
        if (paginationBuilder != null) {
          return paginationBuilder!(context, state);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            PaginationLayout effectiveLayout = layout;
            if (effectiveLayout == PaginationLayout.auto) {
              if (constraints.maxWidth < 450) {
                effectiveLayout = PaginationLayout.compact;
              } else if (constraints.maxWidth < 750) {
                effectiveLayout = PaginationLayout.standard;
              } else {
                effectiveLayout = PaginationLayout.expanded;
              }
            }

            switch (effectiveLayout) {
              case PaginationLayout.compact:
                return _buildCompact(context, state);
              case PaginationLayout.standard:
                return _buildStandard(context, state);
              case PaginationLayout.expanded:
                return _buildExpanded(context, state);
              case PaginationLayout.auto:
                return _buildStandard(context, state);
            }
          },
        );
      },
    );
  }

  Widget _buildRangeText(BuildContext context, SmartPaginationState<T> state) {
    if (!showRangeCount || state.items.isEmpty) return const SizedBox.shrink();

    final start =
        (state.currentPage - controller.initialPage) * state.pageSize + 1;
    final end = start + state.items.length - 1;

    final String text;
    if (state.totalItems != null) {
      text = 'Showing $start–$end of ${state.totalItems}';
    } else {
      text = 'Showing $start–$end';
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
          ),
    );
  }

  Widget _buildPageSizeSelector(
      BuildContext context, SmartPaginationState<T> state) {
    if (!showPageSizeSelector) return const SizedBox.shrink();
    final themeData = SmartPaginationTheme.of(context);

    final currentOption = pageSizeOptions.contains(state.pageSize)
        ? state.pageSize
        : pageSizeOptions.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: themeData.borderRadius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentOption,
          isDense: true,
          style: Theme.of(context)
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
              controller.setPageSize(newSize);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, SmartPaginationState<T> state) {
    final themeData = SmartPaginationTheme.of(context);
    final canPrev =
        state.currentPage > controller.initialPage && !state.isLoading;
    final canNext = state.hasMore && !state.isLoading;

    final totalPages = state.totalPages;
    final pageIndicator = totalPages != null
        ? '${state.currentPage} / $totalPages'
        : 'Page ${state.currentPage}';

    return Container(
      padding: themeData.padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.arrow_back_ios_new, size: 16.0),
            onPressed: canPrev ? () => _goToPage(state.currentPage - 1) : null,
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
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.arrow_forward_ios, size: 16.0),
            onPressed: canNext ? () => _goToPage(state.currentPage + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStandard(BuildContext context, SmartPaginationState<T> state) {
    final themeData = SmartPaginationTheme.of(context);
    final canPrev =
        state.currentPage > controller.initialPage && !state.isLoading;
    final canNext = state.hasMore && !state.isLoading;

    return Container(
      padding: themeData.padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildRangeText(context, state),
            const SizedBox(width: 16.0),
            OutlinedButton.icon(
              onPressed:
                  canPrev ? () => _goToPage(state.currentPage - 1) : null,
              icon: const Icon(Icons.chevron_left, size: 18.0),
              label: const Text('Previous'),
            ),
            SizedBox(width: themeData.spacing),
            _buildPageNumbers(context, state),
            SizedBox(width: themeData.spacing),
            OutlinedButton(
              onPressed:
                  canNext ? () => _goToPage(state.currentPage + 1) : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next'),
                  SizedBox(width: 4.0),
                  Icon(Icons.chevron_right, size: 18.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context, SmartPaginationState<T> state) {
    final themeData = SmartPaginationTheme.of(context);
    final canPrev =
        state.currentPage > controller.initialPage && !state.isLoading;
    final canNext = state.hasMore && !state.isLoading;

    return Container(
      padding: themeData.padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildRangeText(context, state),
            const SizedBox(width: 16.0),
            _buildPageSizeSelector(context, state),
            const SizedBox(width: 16.0),
            OutlinedButton.icon(
              onPressed:
                  canPrev ? () => _goToPage(state.currentPage - 1) : null,
              icon: const Icon(Icons.chevron_left, size: 18.0),
              label: const Text('Previous'),
            ),
            SizedBox(width: themeData.spacing),
            _buildPageNumbers(context, state),
            SizedBox(width: themeData.spacing),
            OutlinedButton(
              onPressed:
                  canNext ? () => _goToPage(state.currentPage + 1) : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next'),
                  SizedBox(width: 4.0),
                  Icon(Icons.chevron_right, size: 18.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageNumbers(
      BuildContext context, SmartPaginationState<T> state) {
    final totalPages = state.totalPages;
    final current = state.currentPage;

    if (totalPages == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Text(
          'Page $current',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    final pages = <int>[];
    final startPage = (current - (maxVisiblePages ~/ 2))
        .clamp(controller.initialPage, totalPages);
    final endPage = (startPage + maxVisiblePages - 1)
        .clamp(controller.initialPage, totalPages);

    for (int p = startPage; p <= endPage; p++) {
      pages.add(p);
    }

    final themeData = SmartPaginationTheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pages.map((p) {
        final isSelected = p == current;
        final activeBg = themeData.activePageColor ?? colorScheme.primary;
        final inactiveBg = themeData.inactivePageColor ?? Colors.transparent;
        final activeFg = themeData.activeTextColor ?? colorScheme.onPrimary;
        final inactiveFg = themeData.inactiveTextColor ?? colorScheme.onSurface;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: InkWell(
            onTap: state.isLoading ? null : () => _goToPage(p),
            borderRadius: themeData.borderRadius,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : inactiveBg,
                borderRadius: themeData.borderRadius,
                border: isSelected
                    ? null
                    : Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                '$p',
                style: TextStyle(
                  color: isSelected ? activeFg : inactiveFg,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
