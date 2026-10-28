import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/costing_controller.dart';
import '../../../data/models/cost.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_paginated_list_body.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/glass_card.dart';
import '../../widgets/fx/press_scale.dart';

class CostCatalogScreen extends GetView<CostingListController> {
  const CostCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const FxAppBar(title: 'كتالوج التكليف'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreate,
        icon: const Icon(Icons.calculate_rounded),
        label: const Text('حساب تكليف'),
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              kToolbarHeight + AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.clear_rounded),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => AppPaginatedListBody(
                state: controller.uiState.value,
                errorMessage:
                    controller.errorMessage.value ?? 'تعذّر تحميل الكتالوج',
                itemCount: controller.items.length,
                hasMore: controller.hasMore,
                skeletonItemHeight: 96,
                onRefresh: controller.fetchFirstPage,
                onRetry: controller.fetchFirstPage,
                onLoadMore: controller.loadMore,
                emptyIcon: Icons.inventory_2_outlined,
                emptyTitle: 'لا يوجد تكليف',
                emptySubtitle: controller.searchQuery.value.isEmpty
                    ? 'احسب أول لوح وأضفه للكتالوج.'
                    : 'لا نتائج مطابقة لبحثك.',
                emptyAction: ElevatedButton.icon(
                  onPressed: controller.openCreate,
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text('حساب تكليف'),
                ),
                itemBuilder: (context, index) {
                  final cost = controller.items[index];
                  return _CostTile(
                    cost: cost,
                    onTap: () => controller.openDetails(cost),
                  )
                      .animate(delay: (40 * (index % 8)).ms)
                      .fadeIn(duration: 320.ms)
                      .slideX(begin: 0.06, curve: Curves.easeOutCubic);
                },
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _CostTile extends StatelessWidget {
  const _CostTile({required this.cost, required this.onTap});

  final Cost cost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cost.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'تكلفة القطعة',
                    value: FormatHelpers.money(cost.costPerUnit),
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'سعر القطعة',
                    value: FormatHelpers.money(cost.sellingPricePerUnit),
                    highlight: true,
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'الكمية',
                    value: FormatHelpers.money(cost.quantity),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.gold : null,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
