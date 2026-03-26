import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../transactions_controller.dart';

class TransactionsDayGroupSection extends StatelessWidget {
  const TransactionsDayGroupSection({
    super.key,
    required this.group,
    required this.amountFormat,
    required this.compactAmountFormat,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionsDayGroup group;
  final NumberFormat amountFormat;
  final NumberFormat compactAmountFormat;
  final ValueChanged<TransactionEntity> onEdit;
  final ValueChanged<TransactionEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final dayLabel = DateFormat('dd/MM/yyyy', 'pt_BR').format(group.date);
    final totalIsNegative = group.totalCents < 0;
    final totalLabel = compactAmountFormat.format(group.totalCents.abs() / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.violet,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              dayLabel,
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.78,
                ),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${group.transactions.length}',
                style: TextStyle(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.45,
                  ),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${totalIsNegative ? '-' : '+'}$totalLabel',
              style: TextStyle(
                color: totalIsNegative ? AppColors.rose : AppColors.emerald,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            for (var index = 0; index < group.transactions.length; index++) ...[
              _TransactionFinanceCard(
                transaction: group.transactions[index],
                amountFormat: amountFormat,
                onEdit: () => onEdit(group.transactions[index]),
                onDelete: () => onDelete(group.transactions[index]),
              ),
              if (index != group.transactions.length - 1)
                const SizedBox(height: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _TransactionFinanceCard extends StatelessWidget {
  const _TransactionFinanceCard({
    required this.transaction,
    required this.amountFormat,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionEntity transaction;
  final NumberFormat amountFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final isExpense = transaction.type == TransactionType.expense;
    final accentColor = _resolveAccentColor();
    final title = _resolveTitle();
    final subtitle = _resolveSubtitle(title);
    final secondaryChipLabel = _resolveSecondaryChipLabel();
    final dateLabel = DateFormat(
      'dd/MMM',
      'pt_BR',
    ).format(transaction.transactionDate);
    final timeLabel = DateFormat(
      'HH:mm',
      'pt_BR',
    ).format(transaction.transactionDate);
    final amountLabel = amountFormat.format(transaction.displayedAmount);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnight : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.22 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _resolveIcon(),
                            color: accentColor,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.theme.colorScheme.onSurface,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      '${isExpense ? '-' : '+'} $amountLabel',
                                      textAlign: TextAlign.end,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isExpense
                                            ? AppColors.rose
                                            : AppColors.emerald,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Venc: ${_capitalizeMonthLabel(dateLabel)}',
                            style: TextStyle(
                              color: context.theme.colorScheme.onSurface
                                  .withValues(alpha: 0.66),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _InfoChip(
                          label: isExpense ? 'Pendente' : 'Recebido',
                          icon: isExpense
                              ? Icons.more_horiz_rounded
                              : Icons.check_circle_rounded,
                          backgroundColor:
                              (isExpense ? AppColors.rose : AppColors.emerald)
                                  .withValues(alpha: 0.14),
                          borderColor:
                              (isExpense ? AppColors.rose : AppColors.emerald)
                                  .withValues(alpha: 0.35),
                          textColor: isExpense
                              ? AppColors.rose
                              : AppColors.emerald,
                        ),
                        _InfoChip(
                          label: secondaryChipLabel,
                          icon: transaction.assetType == AssetType.creditCard
                              ? Icons.layers_rounded
                              : Icons.account_balance_wallet_rounded,
                          backgroundColor: AppColors.violet.withValues(
                            alpha: 0.13,
                          ),
                          borderColor: AppColors.violet.withValues(alpha: 0.25),
                          textColor: AppColors.violet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _TimeLabel(timeLabel: timeLabel),
                        const Spacer(),
                        _ActionButton(
                          label: 'Editar',
                          icon: Icons.edit_rounded,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          textColor: context.theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          label: 'Excluir',
                          icon: Icons.delete_rounded,
                          backgroundColor: AppColors.rose.withValues(
                            alpha: 0.14,
                          ),
                          textColor: AppColors.rose,
                          onTap: onDelete,
                        ),
                      ],
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

  String _resolveTitle() {
    final categoryName = transaction.categoryName?.trim();
    if (categoryName != null && categoryName.isNotEmpty) {
      return categoryName;
    }

    return transaction.description.trim();
  }

  String? _resolveSubtitle(String title) {
    final description = transaction.description.trim();
    if (description.isEmpty) {
      return null;
    }

    if (description.toLowerCase() == title.toLowerCase()) {
      return null;
    }

    return description;
  }

  String _resolveSecondaryChipLabel() {
    if (transaction.assetType == AssetType.creditCard) {
      if (transaction.installmentNumber != null &&
          transaction.installmentCount != null) {
        return '${transaction.installmentNumber}/${transaction.installmentCount}';
      }
      return 'À vista';
    }

    final assetName = transaction.assetName?.trim();
    if (assetName != null && assetName.isNotEmpty) {
      return assetName;
    }

    return 'À vista';
  }

  IconData _resolveIcon() {
    const iconMap = <String, IconData>{
      'briefcase': Icons.work_rounded,
      'fuel': Icons.local_gas_station_rounded,
      'shopping-cart': Icons.shopping_cart_rounded,
      'restaurant': Icons.restaurant_rounded,
      'car': Icons.directions_car_rounded,
      'wrench': Icons.build_rounded,
      'wallet': Icons.account_balance_wallet_rounded,
      'credit-card': Icons.credit_card_rounded,
      'chart-line': Icons.show_chart_rounded,
      'home': Icons.home_rounded,
      'heart': Icons.favorite_rounded,
      'tag': Icons.sell_rounded,
      'category': Icons.category_rounded,
    };

    return iconMap[transaction.categoryIcon] ??
        (transaction.assetType == AssetType.creditCard
            ? Icons.credit_card_rounded
            : Icons.account_balance_wallet_rounded);
  }

  Color _resolveAccentColor() {
    final colorHex = transaction.categoryColor;
    if (colorHex == null || colorHex.isEmpty) {
      return transaction.type == TransactionType.expense
          ? AppColors.rose
          : AppColors.emerald;
    }

    final normalized = colorHex.replaceFirst('#', '');
    if (normalized.length != 6) {
      return transaction.type == TransactionType.expense
          ? AppColors.rose
          : AppColors.emerald;
    }

    return Color(int.parse('FF$normalized', radix: 16));
  }

  String _capitalizeMonthLabel(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.timeLabel});

  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 14,
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.36),
        ),
        const SizedBox(width: 5),
        Text(
          timeLabel,
          style: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.38),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
