import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_loading_indicator.dart';
import 'journey_controller.dart';
import 'widgets/journey_status_banner.dart';
import 'widgets/shift_history_section.dart';
import 'widgets/rides_list_section.dart';

class JourneyView extends GetView<JourneyController> {
  const JourneyView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: const CustomAppBar(
          title: 'Jornada',
          subtitle: 'Controle de turnos e corridas',
          leadingIcon: Icons.work_history_rounded,
          showBackButton: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const JourneyStatusBanner(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.hp(context, 4.0).clamp(16.0, 24.0),
                  vertical: Responsive.vp(context, 1.5).clamp(12.0, 20.0),
                ),
                child: Container(
                  height: Responsive.vp(context, 6.0).clamp(48.0, 56.0),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(
                      Responsive.sp(context, 30).clamp(24.0, 30.0),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppColors.royalBlue,
                        borderRadius: BorderRadius.circular(
                          Responsive.sp(context, 26).clamp(20.0, 26.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.royalBlue.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.sp(context, 14).clamp(12.0, 15.0),
                      ),
                      unselectedLabelColor: Colors.white54,
                      unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Responsive.sp(context, 14).clamp(12.0, 15.0),
                      ),
                      splashBorderRadius: BorderRadius.circular(
                        Responsive.sp(context, 26).clamp(20.0, 26.0),
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work_outline_rounded,
                                size: Responsive.sp(
                                  context,
                                  18,
                                ).clamp(16.0, 20.0),
                              ),
                              SizedBox(
                                width: Responsive.hp(
                                  context,
                                  1.5,
                                ).clamp(6.0, 10.0),
                              ),
                              const Text('Turnos'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: Responsive.sp(
                                  context,
                                  18,
                                ).clamp(16.0, 20.0),
                              ),
                              SizedBox(
                                width: Responsive.hp(
                                  context,
                                  1.5,
                                ).clamp(6.0, 10.0),
                              ),
                              const Text('Corridas'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final horizontalPadding = width < 360
                              ? 8.0
                              : width < 430
                              ? 12.0
                              : 16.0;

                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: TabBarView(
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                    ),
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        ShiftHistorySection(),
                                        SizedBox(height: 100),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                    ),
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        RidesListSection(),
                                        SizedBox(height: 100),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (controller.isLoading.value)
                        const Align(
                          alignment: Alignment.topCenter,
                          child: AppLoadingBanner(
                            label: 'Atualizando jornada',
                            accentColor: AppColors.royalBlue,
                          ),
                        ),
                    ],
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
