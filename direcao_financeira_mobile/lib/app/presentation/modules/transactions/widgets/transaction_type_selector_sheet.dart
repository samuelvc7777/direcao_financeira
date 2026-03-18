import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../routes/app_pages.dart';
import '../../../widgets/scale_button.dart';

class TransactionTypeSelectorSheet extends StatelessWidget {
  const TransactionTypeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.hp(context, 6),
        vertical: Responsive.vp(context, 4),
      ),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.sp(context, 32)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Responsive.hp(context, 12),
            height: Responsive.vp(context, 0.6),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(height: Responsive.vp(context, 4)),
          Text(
            'O que voce deseja registrar?',
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
              fontSize: Responsive.sp(context, 22),
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: Responsive.vp(context, 4)),
          // Row com IntrinsicHeight para garantir que ambos tenham a mesma altura
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SelectorItem(
                    title: 'Entrada',
                    subtitle: 'Receita / Salario',
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.emerald,
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.transactionIncome);
                    },
                  ),
                ),
                SizedBox(width: Responsive.hp(context, 4)),
                Expanded(
                  child: _SelectorItem(
                    title: 'Saida',
                    subtitle: 'Despesa / Pagamento',
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.rose,
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.transactionExpense);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.vp(context, 2)),
          _SelectorItem(
            title: 'Cartao de Credito',
            subtitle: 'Nova compra no credito',
            icon: Icons.credit_card_rounded,
            color: AppColors.royalBlue,
            isFullWidth: true,
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.transactionCreditCard);
            },
          ),
          // Aumentado o espacamento na base para nao ficar colado
          SizedBox(height: Responsive.vp(context, 6)),
        ],
      ),
    );
  }
}

class _SelectorItem extends StatelessWidget {
  const _SelectorItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isFullWidth = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.all(Responsive.sp(context, 20)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Responsive.sp(context, 24)),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: isFullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.sp(context, 12)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: color, 
                size: Responsive.sp(context, 28),
              ),
            ),
            SizedBox(height: Responsive.vp(context, 2)),
            Text(
              title,
              style: TextStyle(
                color: context.theme.colorScheme.onSurface,
                fontSize: Responsive.sp(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.vp(context, 0.5)),
            Text(
              subtitle,
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: Responsive.sp(context, 12),
              ),
              textAlign: isFullWidth ? TextAlign.center : TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
