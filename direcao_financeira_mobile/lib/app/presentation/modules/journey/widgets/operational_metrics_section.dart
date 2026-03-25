import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../journey_controller.dart';

part 'operational_metrics_ride_analysis.dart';
part 'operational_metrics_support.dart';

final NumberFormat _currencyFormatter = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
);

String _formatCurrencyPtBr(int cents) => _currencyFormatter.format(cents / 100);

class OperationalMetricsSection extends StatefulWidget {
  const OperationalMetricsSection({super.key});

  @override
  State<OperationalMetricsSection> createState() =>
      _OperationalMetricsSectionState();
}

class _OperationalMetricsSectionState extends State<OperationalMetricsSection> {
  JourneyController get controller => Get.find<JourneyController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: AppColors.royalBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MÃ©tricas Operacionais',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Desempenho, ganhos e custos das suas corridas',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.5,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => controller.hasActiveShift
                      ? const _LiveBadge()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const _OperationalSummaryWidget(),
          const SizedBox(height: 20),

          // Main Profit Card
          if (DateTime.now().microsecondsSinceEpoch == -1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.rose.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.attach_money,
                              color: AppColors.rose,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lucro LÃ­quido',
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${controller.totalRides.value} corridas',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final net = controller.operationalNetEarningsCents;
                    final isNegative = net < 0;
                    final accent = isNegative
                        ? AppColors.rose
                        : AppColors.emerald;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accent.withValues(alpha: 0.22),
                                    accent.withValues(alpha: 0.06),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: const SizedBox.expand(),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: accent.withValues(alpha: 0.14),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrencyPtBr(net),
                                  style: context.textTheme.headlineLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: accent,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                      ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Margem',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      '${controller.operationalMargin.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white10,
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _TopSummaryMetric(
                            icon: Icons.trending_up_rounded,
                            iconColor: AppColors.emerald,
                            title: 'Ganhos Brutos',
                            value: _formatCurrencyPtBr(
                              controller.operationalGrossEarningsCents,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: controller.toggleOperationalCostBreakdown,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _TopSummaryMetric(
                                    icon: Icons.trending_down_rounded,
                                    iconColor: AppColors.rose,
                                    title: 'Custos Totais',
                                    value: _formatCurrencyPtBr(
                                      controller.operationalTotalCostsCents,
                                    ),
                                  ),
                                ),
                                AnimatedRotation(
                                  turns:
                                      controller
                                          .isOperationalCostBreakdownExpanded
                                          .value
                                      ? 0.5
                                      : 0,
                                  duration: const Duration(milliseconds: 180),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white60,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: controller.toggleOperationalCostBreakdown,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            color: Colors.white60,
                            size: 14,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Detalhamento dos Custos',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    if (!controller.isOperationalCostBreakdownExpanded.value) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          _CostDetailGroupCard(
                            title: 'Custos VariÃ¡veis',
                            totalCents:
                                controller.operationalVariableCostsCents,
                            items: controller.operationalVariableCostItems,
                            accentColor: const Color(0xFFF2B84B),
                            icon: Icons.local_gas_station_rounded,
                          ),
                          if (controller.operationalFixedCostItems.isNotEmpty)
                            const SizedBox(height: 10),
                          if (controller.operationalFixedCostItems.isNotEmpty)
                            _CostDetailGroupCard(
                              title: 'Custos Fixos',
                              totalCents: controller.operationalFixedCostsCents,
                              items: controller.operationalFixedCostItems,
                              accentColor: AppColors.rose,
                              icon: Icons.receipt_long_rounded,
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 4),

          const _RideAnalysisSection(),

          if (DateTime.now().microsecondsSinceEpoch == -1) ...[
            // AnÃ¡lise por corrida
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AnÃ¡lise por corrida',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MÃ©dias de desempenho, ganho e custo variÃ¡vel',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Desempenho Widgets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: const [
                  Icon(Icons.speed, color: AppColors.royalBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Desempenho',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.directions_car,
                      'Viagens',
                      () => controller.totalRides.value.toString(),
                      AppColors.royalBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.schedule,
                      'Horas',
                      () => controller.formatDuration(
                        controller.ridesTotalTime.value,
                      ),
                      AppColors.electricCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.route,
                      'KM',
                      () => controller.ridesTotalKm.value.toStringAsFixed(1),
                      AppColors.royalBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ganhos Widgets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.royalBlue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ganhos',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.royalBlue),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.directions_car,
                      'por viagem',
                      () => controller.formatCurrency(
                        controller.totalRides.value > 0
                            ? controller.grossEarningsCents.value ~/
                                  controller.totalRides.value
                            : 0,
                      ),
                      AppColors.royalBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.schedule,
                      'por hora',
                      () => controller.formatCurrency(
                        controller.ridesTotalTime.value > 0
                            ? (controller.grossEarningsCents.value /
                                      (controller.ridesTotalTime.value / 3600))
                                  .round()
                            : 0,
                      ),
                      AppColors.royalBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.speed,
                      'por km',
                      () => controller.formatCurrency(
                        controller.ridesTotalKm.value > 0
                            ? (controller.grossEarningsCents.value /
                                      controller.ridesTotalKm.value)
                                  .round()
                            : 0,
                      ),
                      AppColors.royalBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Custos Widgets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.local_gas_station,
                        color: AppColors.rose,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Custos das corridas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.rose),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.local_gas_station,
                      'por viagem',
                      () => controller.formatCurrency(
                        controller.totalRides.value > 0
                            ? controller.totalCostsCents.value ~/
                                  controller.totalRides.value
                            : 0,
                      ),
                      AppColors.rose,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.schedule,
                      'por hora',
                      () => controller.formatCurrency(
                        controller.ridesTotalTime.value > 0
                            ? (controller.totalCostsCents.value /
                                      (controller.ridesTotalTime.value / 3600))
                                  .round()
                            : 0,
                      ),
                      AppColors.rose,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.speed,
                      'por km',
                      () => controller.formatCurrency(
                        controller.ridesTotalKm.value > 0
                            ? (controller.totalCostsCents.value /
                                      controller.ridesTotalKm.value)
                                  .round()
                            : 0,
                      ),
                      AppColors.rose,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Lucro Widgets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.savings, color: AppColors.emerald, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Lucro das corridas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.emerald),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.emoji_events,
                      'por viagem',
                      () => controller.formatCurrency(
                        controller.totalRides.value > 0
                            ? controller.netEarningsCents.value ~/
                                  controller.totalRides.value
                            : 0,
                      ),
                      AppColors.emerald,
                      iconColor: Colors.white,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.schedule,
                      'por hora',
                      () => controller.formatCurrency(
                        controller.ridesTotalTime.value > 0
                            ? (controller.netEarningsCents.value /
                                      (controller.ridesTotalTime.value / 3600))
                                  .round()
                            : 0,
                      ),
                      AppColors.emerald,
                      iconColor: Colors.white,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      Icons.speed,
                      'por km',
                      () => controller.formatCurrency(
                        controller.ridesTotalKm.value > 0
                            ? (controller.netEarningsCents.value /
                                      controller.ridesTotalKm.value)
                                  .round()
                            : 0,
                      ),
                      AppColors.emerald,
                      iconColor: Colors.white,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Formas de Pagamento
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.togglePaymentMethodSection,
                borderRadius: BorderRadius.circular(18),
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.royalBlue.withValues(alpha: 0.08),
                          AppColors.royalBlue.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: controller.isPaymentMethodSectionExpanded.value
                            ? AppColors.royalBlue.withValues(alpha: 0.3)
                            : context.theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.royalBlue.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: AppColors.royalBlue,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Formas de pagamento',
                                      style: TextStyle(
                                        color: context.theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Obx(
                                      () => Text(
                                        '${controller.totalRides.value} corridas concluidas',
                                        softWrap: true,
                                        style: TextStyle(
                                          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: AnimatedRotation(
                              turns:
                                  controller
                                      .isPaymentMethodSectionExpanded
                                      .value
                                  ? -0.5 // Roda o Ã­cone apontando p/ cima dependendo do Ã­cone original (-0.5 = 180 graus invertido)
                                  : 0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDark
                                    ? Colors.white70
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.62,
                                      ),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const _PaymentMethodsSectionBody(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    IconData icon,
    String title,
    String Function() getValue,
    Color color, {
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
  }) {
    return Container(
      // Garantir altura mÃ­nima para todos os cards ficarem iguais
      constraints: BoxConstraints(
        minHeight: Responsive.vp(context, 15.0).clamp(110.0, 140.0),
      ),
      padding: EdgeInsets.all(Responsive.sp(context, 12).clamp(8.0, 16.0)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(
          Responsive.sp(context, 16).clamp(12.0, 20.0),
        ),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: Responsive.sp(context, 24).clamp(20.0, 28.0),
          ),
          SizedBox(height: Responsive.vp(context, 1.0).clamp(8.0, 14.0)),
          Obx(
            () => Text(
              getValue(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: Responsive.sp(context, 16).clamp(14.0, 18.0),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: Responsive.vp(context, 0.5).clamp(2.0, 6.0)),
          Text(
            title,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: Responsive.sp(context, 11).clamp(10.0, 13.0),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
