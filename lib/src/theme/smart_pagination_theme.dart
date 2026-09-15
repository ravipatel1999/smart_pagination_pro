import 'package:flutter/material.dart';

/// Lightweight theme data for customizing [SmartPaginationBar] and loading/error states.
@immutable
class SmartPaginationThemeData {
  /// Creates a [SmartPaginationThemeData].
  const SmartPaginationThemeData({
    this.activePageColor,
    this.inactivePageColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.spacing = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  /// Background color for the currently active page button in [SmartPaginationBar].
  final Color? activePageColor;

  /// Background color for inactive page buttons in [SmartPaginationBar].
  final Color? inactivePageColor;

  /// Text color for the active page button.
  final Color? activeTextColor;

  /// Text color for inactive page buttons.
  final Color? inactiveTextColor;

  /// Border radius applied to pagination buttons and card surfaces.
  final BorderRadius borderRadius;

  /// Spacing between elements in [SmartPaginationBar].
  final double spacing;

  /// Outer padding for pagination components.
  final EdgeInsetsGeometry padding;

  /// Base color for built-in shimmer loading placeholders.
  final Color? shimmerBaseColor;

  /// Highlight gradient color for built-in shimmer placeholders.
  final Color? shimmerHighlightColor;

  /// Resolves effective shimmer base color from Theme context.
  Color getEffectiveShimmerBaseColor(BuildContext context) {
    if (shimmerBaseColor != null) return shimmerBaseColor!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[800]! : Colors.grey[300]!;
  }

  /// Resolves effective shimmer highlight color from Theme context.
  Color getEffectiveShimmerHighlightColor(BuildContext context) {
    if (shimmerHighlightColor != null) return shimmerHighlightColor!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[700]! : Colors.grey[100]!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartPaginationThemeData &&
        other.activePageColor == activePageColor &&
        other.inactivePageColor == inactivePageColor &&
        other.activeTextColor == activeTextColor &&
        other.inactiveTextColor == inactiveTextColor &&
        other.borderRadius == borderRadius &&
        other.spacing == spacing &&
        other.padding == padding &&
        other.shimmerBaseColor == shimmerBaseColor &&
        other.shimmerHighlightColor == shimmerHighlightColor;
  }

  @override
  int get hashCode => Object.hash(
        activePageColor,
        inactivePageColor,
        activeTextColor,
        inactiveTextColor,
        borderRadius,
        spacing,
        padding,
        shimmerBaseColor,
        shimmerHighlightColor,
      );
}

/// Inherited widget for supplying [SmartPaginationThemeData] down the widget tree.
class SmartPaginationTheme extends InheritedWidget {
  /// Creates a [SmartPaginationTheme].
  const SmartPaginationTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The pagination theme configuration.
  final SmartPaginationThemeData data;

  /// Obtains the nearest ancestor [SmartPaginationThemeData], or default if none found.
  static SmartPaginationThemeData of(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<SmartPaginationTheme>();
    return theme?.data ?? const SmartPaginationThemeData();
  }

  @override
  bool updateShouldNotify(SmartPaginationTheme oldWidget) =>
      data != oldWidget.data;
}
