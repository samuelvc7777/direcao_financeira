import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../widgets/app_loading_indicator.dart';
import '../journey_controller.dart';
import 'shift_card.dart';

class ShiftHistorySection extends GetView<JourneyController> {
  const ShiftHistorySection({super.key});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          Responsive.sp(context, 10).clamp(8.0, 12.0),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.royalBlue,
                          borderRadius: BorderRadius.circular(
                            Responsive.sp(context, 16).clamp(12.0, 20.0),
                          ),
                        ),
                        child: Icon(
                          Icons.work_history,
                          color: Colors.white,
                          size: Responsive.sp(context, 24).clamp(20.0, 28.0),
                        ),
                      ),
                      SizedBox(
                        width: Responsive.hp(context, 4.0).clamp(12.0, 20.0),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Turnos',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: Responsive.sp(
                                  context,
                                  20,
                                ).clamp(18.0, 22.0),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Responsive.vp(context, 0.5)),
                            Text(
                              'Gestão de jornada',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryDark,
                                fontSize: Responsive.sp(
                                  context,
                                  14,
                                ).clamp(12.0, 16.0),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.hp(context, 2.0).clamp(6.0, 10.0)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.bar_chart,
                        color: Colors.white54,
                        size: Responsive.sp(context, 24).clamp(20.0, 28.0),
                      ),
                      onPressed: () {
                        Get.toNamed('/journey/shift-metrics');
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.royalBlue,
                                  onPrimary: Colors.white,
                                  surface: AppColors.midnight,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          controller.setCustomRange(picked.start, picked.end);
                        }
                      },
                      borderRadius: BorderRadius.circular(
                        Responsive.sp(context, 12).clamp(8.0, 16.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.hp(
                            context,
                            3.0,
                          ).clamp(10.0, 14.0),
                          vertical: Responsive.vp(
                            context,
                            1.0,
                          ).clamp(6.0, 10.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            Responsive.sp(context, 12).clamp(8.0, 16.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: Responsive.sp(
                                context,
                                16,
                              ).clamp(14.0, 18.0),
                              color: Colors.white54,
                            ),
                            SizedBox(
                              width: Responsive.hp(
                                context,
                                2.0,
                              ).clamp(6.0, 10.0),
                            ),
                            Text(
                              'Filtrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.sp(
                                  context,
                                  14,
                                ).clamp(12.0, 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Active Shift / Start Shift Section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.hp(context, 4.0).clamp(12.0, 20.0),
            ),
            child: Obx(() {
              if (!controller.hasActiveShift) {
                return _buildStartShiftButton(context);
              }
              return _buildActiveShiftPanel(context);
            }),
          ),

          SizedBox(height: Responsive.vp(context, 3.0).clamp(20.0, 28.0)),
          Divider(
            color: Colors.white10,
            indent: Responsive.hp(context, 5.0).clamp(16.0, 24.0),
            endIndent: Responsive.hp(context, 5.0).clamp(16.0, 24.0),
          ),
          SizedBox(height: Responsive.vp(context, 2.0).clamp(12.0, 20.0)),

          // List Count
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.hp(context, 5.0).clamp(16.0, 24.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Histórico Recente',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(context, 16).clamp(14.0, 18.0),
                  ),
                ),
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.hp(context, 3.0).clamp(10.0, 14.0),
                      vertical: Responsive.vp(context, 0.8).clamp(4.0, 8.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        Responsive.sp(context, 12).clamp(8.0, 16.0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: Responsive.sp(context, 14).clamp(12.0, 16.0),
                          color: AppColors.royalBlue,
                        ),
                        SizedBox(
                          width: Responsive.hp(context, 2.0).clamp(6.0, 10.0),
                        ),
                        Text(
                          '${controller.shiftsCount.value} turnos',
                          style: TextStyle(
                            color: AppColors.royalBlue,
                            fontSize: Responsive.sp(
                              context,
                              12,
                            ).clamp(10.0, 14.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Responsive.vp(context, 2.0).clamp(12.0, 20.0)),

          // List
          Obx(() {
            final list = controller.shiftsList;
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(
                  Responsive.sp(context, 32.0).clamp(24.0, 40.0),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        controller.historyError.value ??
                            'Nenhum turno encontrado',
                        style: const TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                      if (controller.historyError.value != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: controller.retryJourneyData,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final shift = list[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.hp(context, 4.0).clamp(12.0, 20.0),
                  ),
                  child: ShiftCard(shift: shift),
                );
              },
            );
          }),
          SizedBox(height: Responsive.vp(context, 2.0).clamp(12.0, 20.0)),
        ],
      ),
    );
  }

  Widget _buildStartShiftButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.sp(context, 12).clamp(10.0, 14.0)),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(
          Responsive.sp(context, 20).clamp(16.0, 24.0),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: Responsive.vp(context, 6.0).clamp(48.0, 56.0),
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: controller.canStartShift
                    ? controller.startShift
                    : null,
                icon: controller.isStartingShift.value
                    ? const AppLoadingIndicator(
                        size: AppLoadingSize.compact,
                        accentColor: Colors.white,
                        onDark: true,
                      )
                    : Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: Responsive.sp(context, 24).clamp(20.0, 28.0),
                      ),
                label: Text(
                  'INICIAR TURNO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(context, 15).clamp(13.0, 17.0),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B873F),
                  disabledBackgroundColor: const Color(
                    0xFF1B873F,
                  ).withValues(alpha: 0.45),
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.sp(context, 14).clamp(10.0, 18.0),
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.vp(context, 1.0).clamp(6.0, 10.0)),
          _buildTrafficLightButton(context, compact: true),
        ],
      ),
    );
  }

  Widget _buildActiveShiftPanel(BuildContext context) {
    return Column(
      children: [
        // Timer Card (Green) - More Compact
        Container(
          padding: EdgeInsets.symmetric(
            vertical: Responsive.vp(context, 2.0).clamp(12.0, 20.0),
            horizontal: Responsive.hp(context, 4.0).clamp(12.0, 20.0),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1B873F),
            borderRadius: BorderRadius.circular(
              Responsive.sp(context, 20).clamp(16.0, 24.0),
            ),
          ),
          child: Column(
            children: [
              Obx(
                () => Text(
                  controller.formattedElapsed,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(context, 32).clamp(28.0, 36.0),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Icon(
                      controller.isShiftPaused
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      color: Colors.white70,
                      size: Responsive.sp(context, 14).clamp(12.0, 16.0),
                    ),
                  ),
                  SizedBox(width: Responsive.hp(context, 1.0).clamp(4.0, 8.0)),
                  Obx(
                    () => Text(
                      controller.startTimeStr.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.sp(context, 12).clamp(10.0, 14.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Responsive.hp(context, 5.0).clamp(16.0, 24.0),
                  ),
                  Icon(
                    Icons.route_outlined,
                    color: Colors.white70,
                    size: Responsive.sp(context, 14).clamp(12.0, 16.0),
                  ),
                  SizedBox(width: Responsive.hp(context, 1.0).clamp(4.0, 8.0)),
                  Obx(
                    () => Text(
                      '${controller.currentKm.value.toStringAsFixed(1)} Km',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.sp(context, 12).clamp(10.0, 14.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.vp(context, 0.8).clamp(4.0, 8.0)),
              Obx(
                () => AnimatedOpacity(
                  opacity: controller.isShiftPaused ? 1 : 0.75,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.hp(context, 2.5).clamp(8.0, 12.0),
                      vertical: Responsive.vp(context, 0.5).clamp(4.0, 6.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: controller.isShiftPaused ? 0.18 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(
                        Responsive.sp(context, 999).clamp(999.0, 999.0),
                      ),
                    ),
                    child: Text(
                      controller.isShiftPaused
                          ? 'Turno pausado'
                          : 'Turno em andamento',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: Responsive.sp(context, 11).clamp(10.0, 12.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: Responsive.vp(context, 1.2).clamp(8.0, 14.0)),

        // Actions Row - adapts on compact widths to avoid clipped labels
        // Actions Row - always horizontally aligned
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildSmallActionButton(
                  context,
                  onPressed: controller.canPauseOrResumeShift
                      ? controller.pauseShift
                      : null,
                  icon: controller.isPauseShiftLoading.value
                      ? Icons.hourglass_top_rounded
                      : controller.isShiftPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_circle_outline,
                  label: controller.isShiftPaused ? 'Retomar' : 'Pausar',
                  color: const Color(0xFFF2994A),
                ),
              ),
            ),
            SizedBox(width: Responsive.hp(context, 2.5).clamp(8.0, 14.0)),
            Expanded(
              child: Obx(
                () => _buildSmallActionButton(
                  context,
                  onPressed: controller.canFinishShift
                      ? controller.finishShift
                      : null,
                  icon: controller.isFinishingShift.value
                      ? Icons.hourglass_top_rounded
                      : Icons.stop,
                  label: 'Parar',
                  color: const Color(0xFFEB5757),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.vp(context, 1.2).clamp(8.0, 14.0)),
        _buildTrafficLightButton(context, compact: true),
      ],
    );
  }

  Widget _buildSmallActionButton(
    BuildContext context, {
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.vp(context, 6.2).clamp(46.0, 54.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: Responsive.sp(context, 18).clamp(16.0, 20.0),
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.sp(context, 13).clamp(11.0, 15.0),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? color.withValues(alpha: 0.5)
              : color,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.hp(context, 2.5).clamp(10.0, 14.0),
            vertical: Responsive.vp(context, 0.9).clamp(6.0, 10.0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.sp(context, 12).clamp(10.0, 14.0),
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildTrafficLightButton(
    BuildContext context, {
    bool compact = false,
  }) {
    return Obx(() {
      // O botão reflete se o usuário ATIVOU no app, mas só funciona se o serviço estiver ON
      final isServiceOn = controller.isAccessibilityServiceEnabled;
      final isAppActive = controller.isTrafficLightActive.value;
      final showAsActive = isServiceOn && isAppActive;

      return InkWell(
        onTap: controller.toggleTrafficLight,
        borderRadius: BorderRadius.circular(
          Responsive.sp(context, 12).clamp(8.0, 16.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Responsive.vp(context, 1.0).clamp(6.0, 10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showAsActive)
                _PulseIcon(
                  icon: Icons.traffic_rounded,
                  color: AppColors.emerald,
                )
              else
                Icon(
                  Icons.traffic_rounded,
                  color: Colors.white70,
                  size: Responsive.sp(context, 18).clamp(16.0, 20.0),
                ),
              SizedBox(width: Responsive.hp(context, 2.0).clamp(6.0, 10.0)),
              Text(
                showAsActive ? 'Desativar Semáforo' : 'Ativar Semáforo',
                style: TextStyle(
                  color: showAsActive ? AppColors.emerald : Colors.white70,
                  fontSize: Responsive.sp(context, 14).clamp(12.0, 16.0),
                  fontWeight: showAsActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _PulseIcon({required this.icon, required this.color});

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: 20,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            );
          },
        ),
        Icon(widget.icon, color: widget.color, size: 18),
      ],
    );
  }
}
