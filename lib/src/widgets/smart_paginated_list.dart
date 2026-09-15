import 'package:flutter/material.dart';

import '../controller/smart_pagination_controller.dart';
import '../errors/smart_pagination_error.dart';
import '../models/smart_pagination_enums.dart';
import '../state/smart_pagination_state.dart';
import 'shimmer/smart_shimmer.dart';
import 'smart_load_more.dart';
import 'smart_pagination_bar.dart';

/// Paginated ListView widget supporting infinite scrolling, shimmer loaders, and custom states.
class SmartPaginatedList<T> extends StatefulWidget {
  /// Creates a [SmartPaginatedList] using an explicit [SmartPaginationController].
  const SmartPaginatedList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.displayMode = PaginationDisplayMode.infiniteScroll,
    this.showShimmer = false,
    this.shimmerItemCount = 8,
    this.shimmerBuilder,
    this.separatorBuilder,
    this.loadingBuilder,
    this.loadingMoreBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.padding,
    this.physics,
    this.scrollController,
    this.shrinkWrap = false,
    this.reverse = false,
    this.primary,
    this.itemExtent,
    this.cacheExtent,
    this.enablePullToRefresh = true,
    this.showPaginationBarInInfiniteScroll = false,
  })  : fetch = null,
        pageSize = 20;

  /// Beginner-friendly constructor that creates and manages an internal controller.
  const SmartPaginatedList.simple({
    super.key,
    required SmartPageFetch<T> this.fetch,
    required this.itemBuilder,
    this.pageSize = 20,
    this.displayMode = PaginationDisplayMode.infiniteScroll,
    this.showShimmer = false,
    this.shimmerItemCount = 8,
    this.shimmerBuilder,
    this.separatorBuilder,
    this.loadingBuilder,
    this.loadingMoreBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.padding,
    this.physics,
    this.scrollController,
    this.shrinkWrap = false,
    this.reverse = false,
    this.primary,
    this.itemExtent,
    this.cacheExtent,
    this.enablePullToRefresh = true,
    this.showPaginationBarInInfiniteScroll = false,
  }) : controller = null;

  /// External controller if provided.
  final SmartPaginationController<T>? controller;

  /// Fetch callback for beginner constructor.
  final SmartPageFetch<T>? fetch;

  /// Configured page size for beginner constructor.
  final int pageSize;

  /// Builder for list items.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Display mode (infinite scroll vs pagination bar).
  final PaginationDisplayMode displayMode;

  /// Whether to render shimmer skeleton placeholder during initial load.
  final bool showShimmer;

  /// Count of shimmer skeleton items to render.
  final int shimmerItemCount;

  /// Optional custom shimmer builder callback.
  final Widget Function(BuildContext context, int index)? shimmerBuilder;

  /// Optional separator widget builder between list items.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Optional custom builder for full screen loading.
  final WidgetBuilder? loadingBuilder;

  /// Optional custom builder for load-more indicator.
  final WidgetBuilder? loadingMoreBuilder;

  /// Optional custom builder for primary error state.
  final Widget Function(
          BuildContext context, SmartPaginationError error, VoidCallback retry)?
      errorBuilder;

  /// Optional custom builder for empty state.
  final WidgetBuilder? emptyBuilder;

  /// ListView inner padding.
  final EdgeInsetsGeometry? padding;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// External ScrollController.
  final ScrollController? scrollController;

  /// ListView shrinkWrap.
  final bool shrinkWrap;

  /// ListView reverse.
  final bool reverse;

  /// ListView primary.
  final bool? primary;

  /// ListView itemExtent.
  final double? itemExtent;

  /// ListView cacheExtent.
  final double? cacheExtent;

  /// Enable pull to refresh.
  final bool enablePullToRefresh;

  /// Show pagination bar even when displayMode is infiniteScroll.
  final bool showPaginationBarInInfiniteScroll;

  @override
  State<SmartPaginatedList<T>> createState() => _SmartPaginatedListState<T>();
}

class _SmartPaginatedListState<T> extends State<SmartPaginatedList<T>> {
  late SmartPaginationController<T> _controller;
  late ScrollController _scrollController;
  bool _createdInternalController = false;
  bool _createdInternalScrollController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = SmartPaginationController<T>(
        fetch: widget.fetch!,
        pageSize: widget.pageSize,
      );
      _createdInternalController = true;
      _controller.loadInitial();
    }

    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _createdInternalScrollController = true;
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant SmartPaginatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      if (_createdInternalController) {
        _controller.dispose();
        _createdInternalController = false;
      }
      _controller = widget.controller!;
    }
  }

  void _onScroll() {
    if (!mounted) return;
    if (widget.displayMode != PaginationDisplayMode.infiniteScroll) return;

    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      final currentScroll = position.pixels;

      // Auto prefetch check near bottom
      if (maxScroll - currentScroll <= _controller.prefetchDistance) {
        _controller.loadNextPage();
      }

      // Viewport auto-fill check
      _controller.checkAutoFillViewport(
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
    if (_createdInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    if (widget.showShimmer) {
      return SmartShimmerList(
        itemCount: widget.shimmerItemCount,
        shimmerBuilder: widget.shimmerBuilder,
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 64.0, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12.0),
          Text(
            'No Data Found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'There are no records to display at this time.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, SmartPaginationError error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(
          context, error, () => _controller.loadInitial());
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
            Text(
              'Something Went Wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => _controller.loadInitial(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SmartPaginationState<T> state) {
    if (state.isLoading) {
      return _buildLoading(context);
    }

    if (state.isFailure && state.items.isEmpty) {
      return _buildError(context, state.error!);
    }

    if (state.isEmpty || (state.isSuccess && state.items.isEmpty)) {
      return _buildEmpty(context);
    }

    final isInfinite =
        widget.displayMode == PaginationDisplayMode.infiniteScroll;
    final itemCount = state.items.length + (isInfinite ? 1 : 0);

    Widget listView;
    if (widget.separatorBuilder != null) {
      listView = ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        primary: widget.primary,
        itemCount: itemCount,
        separatorBuilder: widget.separatorBuilder!,
        itemBuilder: (context, index) {
          if (isInfinite && index == state.items.length) {
            return SmartLoadMoreFooter(
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
              error: state.error,
              onRetry: () => _controller.loadNextPage(),
              loadingMoreBuilder: widget.loadingMoreBuilder,
            );
          }
          return widget.itemBuilder(context, state.items[index], index);
        },
      );
    } else {
      listView = ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        primary: widget.primary,
        itemExtent: widget.itemExtent,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (isInfinite && index == state.items.length) {
            return SmartLoadMoreFooter(
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
              error: state.error,
              onRetry: () => _controller.loadNextPage(),
              loadingMoreBuilder: widget.loadingMoreBuilder,
            );
          }
          return widget.itemBuilder(context, state.items[index], index);
        },
      );
    }

    if (widget.enablePullToRefresh) {
      listView = RefreshIndicator(
        onRefresh: () => _controller.refresh(),
        child: listView,
      );
    }

    if (widget.displayMode == PaginationDisplayMode.pagination ||
        widget.showPaginationBarInInfiniteScroll) {
      return Column(
        children: [
          Expanded(child: listView),
          SmartPaginationBar<T>(controller: _controller),
        ],
      );
    }

    return listView;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SmartPaginationState<T>>(
      valueListenable: _controller,
      builder: (context, state, _) {
        return _buildContent(context, state);
      },
    );
  }
}
