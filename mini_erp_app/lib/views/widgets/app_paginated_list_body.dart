import 'package:flutter/material.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/helpers/list_ui_state.dart';
import 'app_empty_state.dart';
import 'app_error_state.dart';
import 'app_skeleton_list.dart';

/// Unified list body: skeleton / error / empty / refresh + infinite scroll.
class AppPaginatedListBody extends StatelessWidget {
  const AppPaginatedListBody({
    super.key,
    required this.state,
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    required this.hasMore,
    required this.emptyTitle,
    this.errorMessage,
    this.emptySubtitle,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyAction,
    this.skeletonItemHeight = 88,
    this.padding,
  });

  final ListUiState state;
  final String? errorMessage;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final String emptyTitle;
  final String? emptySubtitle;
  final IconData emptyIcon;
  final Widget? emptyAction;
  final double skeletonItemHeight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (state == ListUiState.loading || state == ListUiState.initial) {
      return AppSkeletonList(itemHeight: skeletonItemHeight);
    }
    if (state == ListUiState.error) {
      return AppErrorState(
        message: errorMessage ?? 'تعذّر تحميل البيانات',
        onRetry: onRetry,
      );
    }
    if (state == ListUiState.empty) {
      return AppEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        action: emptyAction,
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
            onLoadMore();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding ??
              const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                100,
              ),
          itemCount: itemCount + (hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            if (index >= itemCount) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return itemBuilder(context, index);
          },
        ),
      ),
    );
  }
}
