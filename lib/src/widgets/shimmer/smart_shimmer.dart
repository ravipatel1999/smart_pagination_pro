import 'package:flutter/material.dart';
import '../../theme/smart_pagination_theme.dart';

/// Lightweight, zero-dependency shimmer animation wrapper.
class SmartShimmer extends StatefulWidget {
  /// Creates a [SmartShimmer].
  const SmartShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  });

  /// The widget over which the shimmer gradient sweeps.
  final Widget child;

  /// Custom base background color.
  final Color? baseColor;

  /// Custom highlight gradient sweep color.
  final Color? highlightColor;

  /// Animation cycle period.
  final Duration period;

  @override
  State<SmartShimmer> createState() => _SmartShimmerState();
}

class _SmartShimmerState extends State<SmartShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SmartPaginationTheme.of(context);
    final base =
        widget.baseColor ?? theme.getEffectiveShimmerBaseColor(context);
    final highlight = widget.highlightColor ??
        theme.getEffectiveShimmerHighlightColor(context);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base,
                base,
                highlight,
                base,
                base,
              ],
              stops: const [
                0.0,
                0.35,
                0.5,
                0.65,
                1.0,
              ],
              transform:
                  _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// Default rectangular skeleton item.
class SmartSkeletonItem extends StatelessWidget {
  /// Creates a [SmartSkeletonItem].
  const SmartSkeletonItem({
    super.key,
    this.height = 70.0,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
  });

  final double height;
  final double width;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Default shimmer list placeholder builder.
class SmartShimmerList extends StatelessWidget {
  /// Creates a [SmartShimmerList].
  const SmartShimmerList({
    super.key,
    this.itemCount = 8,
    this.shimmerBuilder,
    this.padding = const EdgeInsets.all(16.0),
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index)? shimmerBuilder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SmartShimmer(
      child: ListView.builder(
        padding: padding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (shimmerBuilder != null) {
            return shimmerBuilder!(context, index);
          }
          return const SmartSkeletonItem();
        },
      ),
    );
  }
}
