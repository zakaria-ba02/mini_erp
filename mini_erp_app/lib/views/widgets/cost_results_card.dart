import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/helpers/format_helpers.dart';
import '../../data/models/cost.dart';

/// Visually separates per-unit breakdown from batch totals.
class CostResultsCard extends StatelessWidget {
  const CostResultsCard({super.key, required this.cost});

  final Cost cost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        boxShadow: AppShadows.soft(theme.brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'نتائج الحساب',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'تكلفة القطعة الواحدة',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SmallMetric(
            label: 'حصة اللوح (سعر اللوح ÷ الكمية)',
            value: FormatHelpers.money(cost.woodCostPerUnit),
          ),
          const SizedBox(height: AppSpacing.xs),
          _SmallMetric(
            label: 'الليزر (الدقائق × سعر الدقيقة)',
            value: FormatHelpers.money(cost.laserCostPerUnit),
          ),
          if ((cost.additionalCostsTotal ?? 0) != 0) ...[
            const SizedBox(height: AppSpacing.xs),
            _SmallMetric(
              label: 'إضافات للقطعة',
              value: FormatHelpers.money(cost.additionalCostsTotal),
            ),
            for (final extra in cost.additionalCosts)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md, top: 2),
                child: _SmallMetric(
                  label: '— ${extra.name}',
                  value: FormatHelpers.money(extra.price),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Divider(color: theme.dividerColor),
          const SizedBox(height: AppSpacing.md),
          _BigMetric(
            label: 'تكلفة القطعة',
            value: FormatHelpers.money(cost.costPerUnit),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BigMetric(
            label: 'سعر بيع القطعة',
            value: FormatHelpers.money(cost.sellingPricePerUnit),
            emphasize: true,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.06);
  }
}

class _BigMetric extends StatelessWidget {
  const _BigMetric({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            value,
            key: ValueKey('$label-$value'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: emphasize ? AppColors.gold : theme.colorScheme.onSurface,
              fontSize: emphasize ? 28 : 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
