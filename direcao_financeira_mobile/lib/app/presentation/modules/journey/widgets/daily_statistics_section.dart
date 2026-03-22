import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../journey_controller.dart';

class DailyStatisticsSection extends GetView<JourneyController> {
  const DailyStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.circular(24),
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bar_chart_rounded,
                          color: AppColors.royalBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Estatísticas',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Obx(() {
                  String label = 'Resumo das atividades de Hoje';
                  switch (controller.selectedFilter.value) {
                    case 'week':
                      label = 'Resumo das atividades da Semana';
                      break;
                    case 'month':
                      label = 'Resumo das atividades do Mês';
                      break;
                    case 'year':
                      label = 'Resumo das atividades do Ano';
                      break;
                  }
                  return Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  icon: Icons.work_outline_rounded,
                  title: 'Total de Turnos',
                  value: controller.totalShifts,
                  color: AppColors.royalBlue,
                ),
                _buildStatCard(
                  icon: Icons.schedule_rounded,
                  title: 'Tempo Total',
                  value: controller.totalTime,
                  color: AppColors.emerald,
                ),
                _buildStatCard(
                  icon: Icons.update_rounded,
                  title: 'Tempo Médio',
                  value: controller.averageTime,
                  color: AppColors.amber,
                ),
                _buildStatCard(
                  icon: Icons.pause_circle_outline_rounded,
                  title: 'Tempo Parado',
                  value: controller.idleTime,
                  color: AppColors.royalBlue,
                ),
                _buildStatCard(
                  icon: Icons.route_rounded,
                  title: 'Km Rodados',
                  value: controller.drivenKm,
                  color: AppColors.electricCyan,
                ),
                _buildStatCard(
                  icon: Icons.speed_rounded,
                  title: 'Km/h Médio',
                  value: controller.averageKmh,
                  color: AppColors.rose,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required RxString value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              value.value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


