import 'package:flutter/material.dart';

/// Comprehensive theme configuration for customizing pagination widgets.
@immutable
class SmartPaginationThemeData {
  /// Creates a [SmartPaginationThemeData].
  const SmartPaginationThemeData({
    this.primaryColor,
    this.onPrimaryColor,
    this.surfaceColor,
    this.textColor,
    this.mutedColor,
    this.disabledColor,
    this.hoverColor,
    this.borderColor,
    this.activePageColor,
    this.inactivePageColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.spacing = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.labelTextStyle,
    this.buttonTextStyle,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  /// Constructs a [SmartPaginationThemeData] derived from a Flutter [ThemeData].
  factory SmartPaginationThemeData.fromTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return SmartPaginationThemeData(
      primaryColor: colorScheme.primary,
      onPrimaryColor: colorScheme.onPrimary,
      surfaceColor: theme.cardColor,
      textColor: colorScheme.onSurface,
      mutedColor: colorScheme.onSurface.withAlpha(178),
      disabledColor: theme.disabledColor,
      hoverColor: colorScheme.primary.withAlpha(20),
      borderColor: theme.dividerColor,
      activePageColor: colorScheme.primary,
      inactivePageColor: Colors.transparent,
      activeTextColor: colorScheme.onPrimary,
      inactiveTextColor: colorScheme.onSurface,
      shimmerBaseColor: theme.brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[300],
      shimmerHighlightColor: theme.brightness == Brightness.dark
          ? Colors.grey[700]
          : Colors.grey[100],
    );
  }

  /// Primary color used for active page indicator and highlighted elements.
  final Color? primaryColor;

  /// Text/icon color on top of primary color background.
  final Color? onPrimaryColor;

  /// Background surface color for pagination container / card.
  final Color? surfaceColor;

  /// Default text color.
  final Color? textColor;

  /// Muted / subtle text color for item ranges and secondary labels.
  final Color? mutedColor;

  /// Disabled state color for controls.
  final Color? disabledColor;

  /// Hover highlight color for interactive page buttons.
  final Color? hoverColor;

  /// Border color for containers and page buttons.
  final Color? borderColor;

  /// Background color for the currently active page button.
  final Color? activePageColor;

  /// Background color for inactive page buttons.
  final Color? inactivePageColor;

  /// Text color for the active page button.
  final Color? activeTextColor;

  /// Text color for inactive page buttons.
  final Color? inactiveTextColor;

  /// Border radius applied to pagination buttons and card containers.
  final BorderRadius borderRadius;

  /// Spacing between UI elements in pagination controls.
  final double spacing;

  /// Outer padding for pagination container.
  final EdgeInsetsGeometry padding;

  /// Text style for labels such as range counts and item info.
  final TextStyle? labelTextStyle;

  /// Text style for page numbers and button labels.
  final TextStyle? buttonTextStyle;

  /// Base color for built-in shimmer loading placeholders.
  final Color? shimmerBaseColor;

  /// Highlight gradient color for built-in shimmer placeholders.
  final Color? shimmerHighlightColor;

  /// Resolves effective shimmer base color from context.
  Color getEffectiveShimmerBaseColor(BuildContext context) {
    if (shimmerBaseColor != null) return shimmerBaseColor!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[800]! : Colors.grey[300]!;
  }

  /// Resolves effective shimmer highlight color from context.
  Color getEffectiveShimmerHighlightColor(BuildContext context) {
    if (shimmerHighlightColor != null) return shimmerHighlightColor!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[700]! : Colors.grey[100]!;
  }

  /// Creates a copy of this theme with given fields replaced.
  SmartPaginationThemeData copyWith({
    Color? primaryColor,
    Color? onPrimaryColor,
    Color? surfaceColor,
    Color? textColor,
    Color? mutedColor,
    Color? disabledColor,
    Color? hoverColor,
    Color? borderColor,
    Color? activePageColor,
    Color? inactivePageColor,
    Color? activeTextColor,
    Color? inactiveTextColor,
    BorderRadius? borderRadius,
    double? spacing,
    EdgeInsetsGeometry? padding,
    TextStyle? labelTextStyle,
    TextStyle? buttonTextStyle,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) {
    return SmartPaginationThemeData(
      primaryColor: primaryColor ?? this.primaryColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      mutedColor: mutedColor ?? this.mutedColor,
      disabledColor: disabledColor ?? this.disabledColor,
      hoverColor: hoverColor ?? this.hoverColor,
      borderColor: borderColor ?? this.borderColor,
      activePageColor: activePageColor ?? this.activePageColor,
      inactivePageColor: inactivePageColor ?? this.inactivePageColor,
      activeTextColor: activeTextColor ?? this.activeTextColor,
      inactiveTextColor: inactiveTextColor ?? this.inactiveTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
      spacing: spacing ?? this.spacing,
      padding: padding ?? this.padding,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor:
          shimmerHighlightColor ?? this.shimmerHighlightColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartPaginationThemeData &&
        other.primaryColor == primaryColor &&
        other.onPrimaryColor == onPrimaryColor &&
        other.surfaceColor == surfaceColor &&
        other.textColor == textColor &&
        other.mutedColor == mutedColor &&
        other.disabledColor == disabledColor &&
        other.hoverColor == hoverColor &&
        other.borderColor == borderColor &&
        other.activePageColor == activePageColor &&
        other.inactivePageColor == inactivePageColor &&
        other.activeTextColor == activeTextColor &&
        other.inactiveTextColor == inactiveTextColor &&
        other.borderRadius == borderRadius &&
        other.spacing == spacing &&
        other.padding == padding &&
        other.labelTextStyle == labelTextStyle &&
        other.buttonTextStyle == buttonTextStyle &&
        other.shimmerBaseColor == shimmerBaseColor &&
        other.shimmerHighlightColor == shimmerHighlightColor;
  }

  @override
  int get hashCode => Object.hashAll([
        primaryColor,
        onPrimaryColor,
        surfaceColor,
        textColor,
        mutedColor,
        disabledColor,
        hoverColor,
        borderColor,
        activePageColor,
        inactivePageColor,
        activeTextColor,
        inactiveTextColor,
        borderRadius,
        spacing,
        padding,
        labelTextStyle,
        buttonTextStyle,
        shimmerBaseColor,
        shimmerHighlightColor,
      ]);
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

  /// Obtains the nearest ancestor [SmartPaginationThemeData], or falls back to Theme context.
  static SmartPaginationThemeData of(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<SmartPaginationTheme>();
    return theme?.data ?? SmartPaginationThemeData.fromTheme(Theme.of(context));
  }

  @override
  bool updateShouldNotify(SmartPaginationTheme oldWidget) =>
      data != oldWidget.data;
}
