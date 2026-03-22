import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../widgets/scale_button.dart';
import '../transactions_controller.dart';

class TransactionsFilterTabs extends StatelessWidget {
  const TransactionsFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final TransactionsFilter selectedFilter;
  final ValueChanged<TransactionsFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final containerPadding = Responsive.hp(context, 1.2).clamp(4.0, 6.0);
    final spacing = Responsive.hp(context, 2.2).clamp(6.0, 8.0);
    final borderRadius = Responsive.hp(context, 6.4).clamp(18.0, 20.0);

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterTab(
              label: TransactionsFilter.all.label,
              icon: Icons.layers_rounded,
              isSelected: selectedFilter == TransactionsFilter.all,
              onTap: () => onChanged(TransactionsFilter.all),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: _FilterTab(
              label: TransactionsFilter.income.label,
              icon: Icons.arrow_upward_rounded,
              isSelected: selectedFilter == TransactionsFilter.income,
              onTap: () => onChanged(TransactionsFilter.income),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: _FilterTab(
              label: TransactionsFilter.expense.label,
              icon: Icons.arrow_downward_rounded,
              isSelected: selectedFilter == TransactionsFilter.expense,
              onTap: () => onChanged(TransactionsFilter.expense),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.hp(context, 3.2).clamp(8.0, 10.0);
    final verticalPadding = Responsive.vp(context, 1.2).clamp(8.0, 10.0);
    final borderRadius = Responsive.hp(context, 5.4).clamp(16.0, 18.0);
    final iconSize = Responsive.sp(context, 18).clamp(16.0, 18.0);
    final labelSize = Responsive.sp(context, 14).clamp(13.0, 14.0);

    return ScaleButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.violet.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.violet.withValues(alpha: 0.42)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: iconSize,
                      color: isSelected
                          ? AppColors.violet
                          : context.theme.colorScheme.onSurface.withValues(alpha: 0.46),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.violet
                            : context.theme.colorScheme.onSurface.withValues(alpha: 0.52),
                        fontSize: labelSize,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
