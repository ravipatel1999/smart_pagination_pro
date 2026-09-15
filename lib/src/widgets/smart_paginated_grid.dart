import 'package:flutter/material.dart';

import '../controller/smart_pagination_controller.dart';
import '../errors/smart_pagination_error.dart';
import '../models/smart_pagination_enums.dart';
import '../state/smart_pagination_state.dart';
import 'shimmer/smart_shimmer.dart';
import 'smart_load_more.dart';
import 'smart_pagination_bar.dart';

/// Paginated GridView widget supporting infinite scrolling, adaptive cross-axis layout, and custom builders.
class SmartPaginatedGrid<T> extends StatefulWidget {
  /// Creates a [SmartPaginatedGrid].
  const SmartPaginatedGrid({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.gridDelegate,
    this.crossAxisCount = 2,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.displayMode = PaginationDisplayMode.infiniteScroll,
    this.showShimmer = false,
    this.shimmerItemCount = 6,
    this.shimmerBuilder,
    this.loadingBuilder,
    this.loadingMoreBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.padding,
    this.physics,
    this.scrollController,
    this.shrinkWrap = false,
    this.reverse = false,
    this.enablePullToRefresh = true,
  });

  /// The pagination controller.
  final SmartPaginationController<T> controller;

  /// Grid item builder.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Explicit grid delegate.
  final SliverGridDelegate? gridDelegate;

  /// Fixed column count if [gridDelegate] and [maxCrossAxisExtent] are omitted.
  final int crossAxisCount;

  /// Max cross-axis extent for responsive auto-wrapping grid columns.
  final double? maxCrossAxisExtent;

  /// Grid spacing.
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  /// Display mode.
  final PaginationDisplayMode displayMode;

  /// Shimmer controls.
  final bool showShimmer;
  final int shimmerItemCount;
  final Widget Function(BuildContext context, int index)? shimmerBuilder;

  /// State builders.
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? loadingMoreBuilder;
  final Widget Function(
          BuildContext context, SmartPaginationError error, VoidCallback retry)?
      errorBuilder;
  final WidgetBuilder? emptyBuilder;

  /// Scroll properties.
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final bool reverse;
  final bool enablePullToRefresh;

  @override
  State<SmartPaginatedGrid<T>> createState() => _SmartPaginatedGridState<T>();
}

class _SmartPaginatedGridState<T> extends State<SmartPaginatedGrid<T>> {
  late ScrollController _scrollController;
  bool _createdInternalScrollController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _createdInternalScrollController = true;
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;
    if (widget.displayMode != PaginationDisplayMode.infiniteScroll) return;

    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      final currentScroll = position.pixels;

      if (maxScroll - currentScroll <= widget.controller.prefetchDistance) {
        widget.controller.loadNextPage();
      }

      widget.controller.checkAutoFillViewport(
        position.viewportDimension,
        position.maxScrollExtent,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_createdInternalScrollController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  SliverGridDelegate _resolveGridDelegate() {
    if (widget.gridDelegate != null) return widget.gridDelegate!;
    if (widget.maxCrossAxisExtent != null) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: widget.maxCrossAxisExtent!,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      );
    }
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      childAspectRatio: widget.childAspectRatio,
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    if (widget.showShimmer) {
      return SmartShimmer(
        child: GridView.builder(
          padding: widget.padding ?? const EdgeInsets.all(16.0),
          gridDelegate: _resolveGridDelegate(),
          itemCount: widget.shimmerItemCount,
          itemBuilder: (context, index) {
            if (widget.shimmerBuilder != null) {
              return widget.shimmerBuilder!(context, index);
            }
            return const SmartSkeletonItem(margin: EdgeInsets.zero);
          },
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmpty(BuildContext context) {
    if (widget.emptyBuilder != null) return widget.emptyBuilder!(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view_outlined,
              size: 64.0, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12.0),
          Text(
            'No Grid Data',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, SmartPaginationError error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(
          context, error, () => widget.controller.loadInitial());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 56.0, color: Colors.redAccent),
            const SizedBox(height: 12.0),
            Text(error.message, textAlign: TextAlign.center),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => widget.controller.loadInitial(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SmartPaginationState<T> state) {
    if (state.isLoading) return _buildLoading(context);
    if (state.isFailure && state.items.isEmpty) {
      return _buildError(context, state.error!);
    }
    if (state.isEmpty || (state.isSuccess && state.items.isEmpty)) {
      return _buildEmpty(context);
    }

    final isInfinite =
        widget.displayMode == PaginationDisplayMode.infiniteScroll;

    Widget gridView = CustomScrollView(
      controller: _scrollController,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      reverse: widget.reverse,
      slivers: [
        SliverPadding(
          padding: widget.padding ?? const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: _resolveGridDelegate(),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  widget.itemBuilder(context, state.items[index], index),
              childCount: state.items.length,
            ),
          ),
        ),
        if (isInfinite)
          SliverToBoxAdapter(
            child: SmartLoadMoreFooter(
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
              error: state.error,
              onRetry: () => widget.controller.loadNextPage(),
              loadingMoreBuilder: widget.loadingMoreBuilder,
            ),
          ),
      ],
    );

    if (widget.enablePullToRefresh) {
      gridView = RefreshIndicator(
        onRefresh: () => widget.controller.refresh(),
        child: gridView,
      );
    }

    if (widget.displayMode == PaginationDisplayMode.pagination) {
      return Column(
        children: [
          Expanded(child: gridView),
          SmartPaginationBar<T>(controller: widget.controller),
        ],
      );
    }

    return gridView;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SmartPaginationState<T>>(
      valueListenable: widget.controller,
      builder: (context, state, _) {
        return _buildContent(context, state);
      },
    );
  }
}
