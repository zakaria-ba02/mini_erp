import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/customers_controller.dart';
import '../../../data/models/app_currency.dart';
import '../../../data/models/customer.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_paginated_list_body.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/glass_card.dart';
import '../../widgets/fx/press_scale.dart';

class CustomersListScreen extends GetView<CustomersController> {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const FxAppBar(title: 'الزبائن'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreate,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('زبون جديد'),
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
                    controller.errorMessage.value ?? 'تعذّر تحميل الزبائن',
                itemCount: controller.items.length,
                hasMore: controller.hasMore,
                onRefresh: controller.fetchFirstPage,
                onRetry: controller.fetchFirstPage,
                onLoadMore: controller.loadMore,
                emptyIcon: Icons.groups_outlined,
                emptyTitle: 'لا يوجد زبائن',
                emptySubtitle: controller.searchQuery.value.isEmpty
                    ? 'أضف أول زبون للبدء.'
                    : 'لا نتائج مطابقة لبحثك.',
                emptyAction: ElevatedButton.icon(
                  onPressed: controller.openCreate,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('إضافة زبون'),
                ),
                itemBuilder: (context, index) {
                  final customer = controller.items[index];
                  return _CustomerTile(
                    customer: customer,
                    onTap: () => controller.openDetails(customer),
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

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer, required this.onTap});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: -2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                customer.name.isNotEmpty ? customer.name[0] : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyOnGold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customer.phone,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  FormatHelpers.moneyWithCurrency(
                    customer.balances.syp,
                    AppCurrency.syp,
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  FormatHelpers.moneyWithCurrency(
                    customer.balances.usd,
                    AppCurrency.usd,
                  ),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
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
