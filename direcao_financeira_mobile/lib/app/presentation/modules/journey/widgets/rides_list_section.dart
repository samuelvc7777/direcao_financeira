import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../journey_controller.dart';

class RidesListSection extends GetView<JourneyController> {
  const RidesListSection({super.key});

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
                          Icons.directions_car,
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
                              'Corridas',
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
                              'Período atual',
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
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.bar_chart,
                        color: Colors.white54,
                        size: Responsive.sp(context, 24).clamp(20.0, 28.0),
                      ),
                      onPressed: () {
                        Get.toNamed('/journey/metrics');
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

          // Filters Tab
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.hp(context, 4.0).clamp(12.0, 20.0),
            ),
            child: Container(
              padding: EdgeInsets.all(
                Responsive.sp(context, 4).clamp(2.0, 6.0),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  Responsive.sp(context, 16).clamp(12.0, 20.0),
                ),
              ),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTab(
                      context,
                      'Todos',
                      Icons.layers,
                      controller.selectedRideStatusFilter.value == 'Todos',
                      AppColors.royalBlue,
                    ),
                    _buildTab(
                      context,
                      'Pendentes',
                      Icons.hourglass_empty,
                      controller.selectedRideStatusFilter.value == 'Pendentes',
                      AppColors.amber,
                    ),
                    _buildTab(
                      context,
                      'Finalizados',
                      Icons.check_circle_outline,
                      controller.selectedRideStatusFilter.value ==
                          'Finalizados',
                      AppColors.emerald,
                    ),
                    _buildTab(
                      context,
                      'Cancelados',
                      Icons.cancel_outlined,
                      controller.selectedRideStatusFilter.value == 'Cancelados',
                      AppColors.rose,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: Responsive.vp(context, 2.0).clamp(12.0, 20.0)),

          // List Count
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.hp(context, 5.0).clamp(16.0, 24.0),
            ),
            child: Obx(
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
                      Icons.directions_car,
                      size: Responsive.sp(context, 14).clamp(12.0, 16.0),
                      color: AppColors.royalBlue,
                    ),
                    SizedBox(
                      width: Responsive.hp(context, 2.0).clamp(6.0, 10.0),
                    ),
                    Text(
                      '${controller.filteredRidesList.length} corridas',
                      style: TextStyle(
                        color: AppColors.royalBlue,
                        fontSize: Responsive.sp(context, 12).clamp(10.0, 14.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: Responsive.vp(context, 2.0).clamp(12.0, 20.0)),

          // List
          Obx(() {
            final list = controller.filteredRidesList;
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(
                  Responsive.sp(context, 32.0).clamp(24.0, 40.0),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        controller.ridesError.value ??
                            'Nenhuma corrida encontrada',
                        style: const TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                      if (controller.ridesError.value != null) ...[
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
                final ride = list[index];
                final statusColor = ride.status == 'PENDING'
                    ? AppColors.amber
                    : ride.status == 'FINISHED'
                        ? AppColors.emerald
                        : AppColors.rose;
                final statusIcon = ride.status == 'PENDING'
                    ? Icons.hourglass_empty
                    : ride.status == 'FINISHED'
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined;


                return InkWell(
                  onTap: () => controller.openRideDetails(ride),
                  borderRadius: BorderRadius.circular(
                    Responsive.sp(context, 20).clamp(16.0, 24.0),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Responsive.hp(context, 4.0).clamp(12.0, 20.0),
                      vertical: Responsive.vp(context, 1.0).clamp(6.0, 10.0),
                    ),
                    padding: EdgeInsets.all(
                      Responsive.sp(context, 16).clamp(12.0, 20.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        Responsive.sp(context, 20).clamp(16.0, 24.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    Responsive.sp(context, 8).clamp(6.0, 10.0),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(
                                      Responsive.sp(
                                        context,
                                        12,
                                      ).clamp(8.0, 16.0),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    size: Responsive.sp(
                                      context,
                                      24,
                                    ).clamp(20.0, 28.0),
                                    color: ride.appName.toLowerCase() == 'uber'
                                        ? Colors.white
                                        : AppColors.amber,
                                  ),
                                ),
                                SizedBox(
                                  width: Responsive.hp(
                                    context,
                                    3.0,
                                  ).clamp(10.0, 14.0),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ride.appName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Responsive.sp(
                                          context,
                                          16,
                                        ).clamp(14.0, 18.0),
                                      ),
                                    ),
                                    Text(
                                      '${ride.date} às ${ride.time}',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: Responsive.sp(
                                          context,
                                          12,
                                        ).clamp(10.0, 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  controller.formatCurrency(
                                    ride.grossValueCents,
                                  ),
                                  style: TextStyle(
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.sp(
                                      context,
                                      16,
                                    ).clamp(14.0, 18.0),
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.vp(
                                    context,
                                    0.5,
                                  ).clamp(2.0, 6.0),
                                ),
                                 Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.hp(
                                      context,
                                      2.0,
                                    ).clamp(6.0, 10.0),
                                    vertical: Responsive.vp(
                                      context,
                                      0.2,
                                    ).clamp(2.0, 4.0),
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                      Responsive.sp(
                                        context,
                                        8,
                                      ).clamp(6.0, 10.0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        statusIcon,
                                        size: Responsive.sp(
                                          context,
                                          10,
                                        ).clamp(8.0, 12.0),
                                        color: statusColor,
                                      ),
                                      SizedBox(
                                        width: Responsive.hp(
                                          context,
                                          1.0,
                                        ).clamp(4.0, 6.0),
                                      ),
                                      Text(
                                        ride.status == 'PENDING'
                                            ? 'Pendente'
                                            : ride.status == 'FINISHED'
                                            ? 'Finalizada'
                                            : 'Cancelada',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: Responsive.sp(
                                            context,
                                            10,
                                          ).clamp(8.0, 12.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.vp(context, 2.0).clamp(12.0, 20.0),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
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
                            Expanded(
                              child: Text(
                                ride.origin,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Responsive.sp(
                                    context,
                                    14,
                                  ).clamp(12.0, 16.0),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.vp(context, 0.8).clamp(4.0, 8.0),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.flag,
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
                            Expanded(
                              child: Text(
                                ride.destination,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Responsive.sp(
                                    context,
                                    14,
                                  ).clamp(12.0, 16.0),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.vp(context, 1.0).clamp(6.0, 10.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
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
                                  ride.passenger,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: Responsive.sp(
                                      context,
                                      14,
                                    ).clamp(12.0, 16.0),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: Responsive.sp(
                                    context,
                                    16,
                                  ).clamp(14.0, 18.0),
                                  color: Colors.white54,
                                ),
                                SizedBox(
                                  width: Responsive.hp(
                                    context,
                                    1.0,
                                  ).clamp(4.0, 6.0),
                                ),
                                Text(
                                  '${ride.durationMinutes}min',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: Responsive.sp(
                                      context,
                                      14,
                                    ).clamp(12.0, 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          SizedBox(height: Responsive.vp(context, 2.0).clamp(12.0, 20.0)),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    Color selectedColor,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeRideStatusFilter(title),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: Responsive.vp(context, 1.5).clamp(8.0, 14.0),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              Responsive.sp(context, 12).clamp(10.0, 14.0),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: Responsive.sp(context, 20).clamp(18.0, 22.0),
                color: isSelected ? selectedColor : Colors.white54,
              ),
              SizedBox(height: Responsive.vp(context, 0.5).clamp(2.0, 6.0)),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? selectedColor : Colors.white54,
                  fontSize: Responsive.sp(context, 10).clamp(8.0, 12.0),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
