import 'package:flutter/material.dart';

import '../errors/smart_pagination_error.dart';

/// Footer widget for infinite scroll list/grid state representation.
class SmartLoadMoreFooter extends StatelessWidget {
  /// Creates a [SmartLoadMoreFooter].
  const SmartLoadMoreFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
    this.onRetry,
    this.loadingMoreBuilder,
    this.loadMoreErrorBuilder,
    this.noMoreItemsBuilder,
  });

  /// Whether controller is currently fetching the next page.
  final bool isLoadingMore;

  /// Whether additional pages exist.
  final bool hasMore;

  /// Active error if next-page fetch failed.
  final SmartPaginationError? error;

  /// Callback to trigger retry.
  final VoidCallback? onRetry;

  /// Optional builder for custom loading-more indicator.
  final WidgetBuilder? loadingMoreBuilder;

  /// Optional builder for custom load-more error.
  final Widget Function(
          BuildContext context, SmartPaginationError error, VoidCallback retry)?
      loadMoreErrorBuilder;

  /// Optional builder when no more items exist.
  final WidgetBuilder? noMoreItemsBuilder;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      if (loadMoreErrorBuilder != null && onRetry != null) {
        return loadMoreErrorBuilder!(context, error!, onRetry!);
      }
      return Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load more data.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(width: 8.0),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18.0),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (isLoadingMore) {
      if (loadingMoreBuilder != null) {
        return loadingMoreBuilder!(context);
      }
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        alignment: Alignment.center,
        child: Semantics(
          label: 'Loading more items',
          child: const SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (!hasMore) {
      if (noMoreItemsBuilder != null) {
        return noMoreItemsBuilder!(context);
      }
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        alignment: Alignment.center,
        child: Text(
          'You\'ve reached the end',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
            fontSize: 13.0,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
