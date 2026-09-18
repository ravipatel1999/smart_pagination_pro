import 'package:flutter/material.dart';

import '../controller/smart_pagination_controller.dart';
import '../models/smart_pagination_enums.dart';
import '../state/smart_pagination_state.dart';
import '../theme/smart_pagination_theme.dart';
import 'smart_pagination.dart';

/// Modern, accessible, responsive pagination control bar driven by a [SmartPaginationController].
class SmartPaginationBar<T> extends StatelessWidget {
  /// Creates a [SmartPaginationBar].
  const SmartPaginationBar({
    super.key,
    required this.controller,
    this.layout = PaginationLayout.auto,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.showPageNumbers = true,
    this.showPreviousNext = true,
    this.showFirstLastButtons = false,
    this.showPageSizeSelector = true,
    bool? showRangeCount,
    bool showItemRange = true,
    this.itemsLabel = '',
    this.maxVisiblePages = 5,
    this.enableKeyboardNavigation = true,
    this.showCard = true,
    this.padding,
    this.theme,
    this.paginationBuilder,
  })  : showRangeCount = showRangeCount ?? showItemRange,
        showItemRange = showRangeCount ?? showItemRange;

  /// Target pagination controller.
  final SmartPaginationController<T> controller;

  /// Layout mode (auto, compact, standard, expanded).
  final PaginationLayout layout;

  /// Options for page size dropdown selector.
  final List<int> pageSizeOptions;

  /// Whether to display numbered page buttons.
  final bool showPageNumbers;

  /// Whether to show Previous/Next buttons.
  final bool showPreviousNext;

  /// Whether to show First/Last page buttons.
  final bool showFirstLastButtons;

  /// Whether to display page size selector dropdown.
  final bool showPageSizeSelector;

  /// Whether to show items range text (e.g., `Showing 1–20 of 100`).
  final bool showRangeCount;

  /// Alias for [showRangeCount].
  final bool showItemRange;

  /// Label for items in range text.
  final String itemsLabel;

  /// Maximum visible numbered page buttons.
  final int maxVisiblePages;

  /// Whether keyboard navigation shortcuts are enabled.
  final bool enableKeyboardNavigation;

  /// Whether controls are rendered inside a card container.
  final bool showCard;

  /// Outer padding for the bar.
  final EdgeInsetsGeometry? padding;

  /// Custom theme override.
  final SmartPaginationThemeData? theme;

  /// Custom builder callback to completely override default pagination bar.
  final Widget Function(BuildContext context, SmartPaginationState<T> state)?
      paginationBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SmartPaginationState<T>>(
      valueListenable: controller,
      builder: (context, state, _) {
        if (paginationBuilder != null) {
          return paginationBuilder!(context, state);
        }

        return SmartPagination(
          currentPage: state.currentPage,
          pageSize: state.pageSize,
          totalItems: state.totalItems ?? state.items.length,
          onPageChanged: (page) => controller.goToPage(page),
          onPageSizeChanged: (size) => controller.setPageSize(size),
          pageSizeOptions: pageSizeOptions,
          showPageNumbers: showPageNumbers,
          showPreviousNext: showPreviousNext,
          showFirstLastButtons: showFirstLastButtons,
          showPageSizeSelector: showPageSizeSelector,
          showItemRange: showRangeCount,
          itemsLabel: itemsLabel,
          maxVisiblePageButtons: maxVisiblePages,
          layout: layout,
          enableKeyboardNavigation: enableKeyboardNavigation,
          showCard: showCard,
          padding: padding,
          theme: theme,
        );
      },
    );
  }
}
