import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../journey_controller.dart';

class OperationalMetricsSection extends GetView<JourneyController> {
  const OperationalMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: Responsive.vp(context, 1.0).clamp(6.0, 10.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.circular(
          Responsive.sp(context, 24).clamp(20.0, 28.0),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(
              Responsive.sp(context, 20).clamp(16.0, 24.0),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    Responsive.sp(context, 10).clamp(8.0, 12.0),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(
                      Responsive.sp(context, 16).clamp(12.0, 20.0),
                    ),
                  ),
                  child: Icon(
                    Icons.show_chart_rounded,
                    color: AppColors.royalBlue,
                    size: Responsive.sp(context, 24).clamp(20.0, 28.0),
                  ),
                ),
                SizedBox(width: Responsive.hp(context, 4.0).clamp(12.0, 20.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Métricas Operacionais',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: Responsive.sp(
                            context,
                            20,
                          ).clamp(18.0, 22.0),
                        ),
                      ),
                      SizedBox(height: Responsive.vp(context, 0.5)),
                      Text(
                        'Desempenho, ganhos e custos das suas corridas',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontSize: Responsive.sp(
                            context,
                            14,
                          ).clamp(12.0, 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Profit Card
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: Responsive.hp(context, 4.0).clamp(12.0, 20.0),
            ),
            padding: EdgeInsets.all(
              Responsive.sp(context, 20).clamp(16.0, 24.0),
            ),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(
                Responsive.sp(context, 20).clamp(16.0, 24.0),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: AppColors.rose,
                          size: Responsive.sp(context, 20).clamp(16.0, 24.0),
                        ),
                        SizedBox(
                          width: Responsive.hp(context, 2.0).clamp(6.0, 10.0),
                        ),
                        Text(
                          'Lucro Líquido',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: Responsive.sp(
                              context,
                              16,
                            ).clamp(14.0, 18.0),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.hp(
                            context,
                            3.0,
                          ).clamp(8.0, 14.0),
                          vertical: Responsive.vp(context, 0.5).clamp(2.0, 6.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            Responsive.sp(context, 12).clamp(8.0, 16.0),
                          ),
                        ),
                        child: Text(
                          '${controller.totalRides.value} corridas',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: Responsive.sp(
                              context,
                              12,
                            ).clamp(10.0, 14.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.vp(context, 2.0).clamp(12.0, 20.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() {
                      final net = controller.netEarningsCents.value;
                      final isNegative = net < 0;
                      return Text(
                        controller.formatCurrency(net),
                        style: context.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isNegative
                              ? AppColors.rose
                              : AppColors.emerald,
                          fontSize: Responsive.sp(
                            context,
                            32,
                          ).clamp(28.0, 36.0),
                        ),
                      );
                    }),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Margem',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: Responsive.sp(
                              context,
                              12,
                            ).clamp(10.0, 14.0),
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${controller.margin.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: controller.margin < 0
                                  ? AppColors.rose
                                  : AppColors.emerald,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.sp(
                                context,
                                14,
                              ).clamp(12.0, 16.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.trending_up,
                                color: AppColors.emerald,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Ganhos Brutos',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.formatCurrency(
                                controller.grossEarningsCents.value,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.trending_down,
                                color: AppColors.rose,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Custos Totais',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.formatCurrency(
                                controller.totalCostsCents.value,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Análise por corrida
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análise por corrida',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Médias de desempenho, ganho e custo variável',
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

          // Formas de Pagamento
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Formas de pagamento',
                      style: TextStyle(
                        color: AppColors.royalBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        '${controller.totalRides.value} corridas concluídas',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.royalBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bairros
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bairros com mais chamados',
                      style: TextStyle(
                        color: AppColors.royalBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        '${(controller.totalRides.value * 0.45).round()} corridas mapeadas',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.royalBlue,
                ),
              ],
            ),
          ),
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
      // Garantir altura mínima para todos os cards ficarem iguais
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
