import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final width = screenWidth - 24;
    final isCompact = width < 390 || textScale > 1.05;
    final isVeryCompact = width < 345;
    final navWidth = width > 720 ? 720.0 : width;
    final shellHorizontalPadding = isVeryCompact
        ? 8.0
        : isCompact
        ? 12.0
        : 16.0;
    final shellVerticalPadding = isCompact ? 10.0 : 12.0;
    final tabHorizontalPadding = isVeryCompact
        ? 6.0
        : isCompact
        ? 8.0
        : 10.0;
    final tabVerticalPadding = isCompact ? 12.0 : 14.0;
    final edgeSpacing = isVeryCompact
        ? 4.0
        : isCompact
        ? 8.0
        : 12.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: SizedBox(
            width: navWidth,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: shellHorizontalPadding,
                  vertical: shellVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.royalBlue.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: edgeSpacing),
                  child: GNav(
                    rippleColor: AppColors.royalBlue.withValues(alpha: 0.08),
                    hoverColor: AppColors.royalBlue.withValues(alpha: 0.08),
                    gap: isVeryCompact
                        ? 2
                        : isCompact
                        ? 4
                        : 6,
                    activeColor: Colors.white,
                    color: Colors.white60,
                    iconSize: isVeryCompact
                        ? 18
                        : isCompact
                        ? 20
                        : 22,
                    padding: EdgeInsets.symmetric(
                      horizontal: tabHorizontalPadding,
                      vertical: tabVerticalPadding,
                    ),
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.linear,
                    tabBorderRadius: 20,
                    tabBackgroundColor: AppColors.royalBlue,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: isVeryCompact
                          ? 9.5
                          : isCompact
                          ? 10.5
                          : 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    selectedIndex: currentIndex,
                    onTabChange: onTap,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    tabs: const [
                      GButton(icon: Icons.home_rounded, text: 'Inicio'),
                      GButton(
                        icon: Icons.receipt_long_rounded,
                        text: 'Financas',
                      ),
                      GButton(
                        icon: Icons.account_balance_wallet_rounded,
                        text: 'Jornada',
                      ),
                      GButton(
                        icon: Icons.directions_car_rounded,
                        text: 'Corridas',
                      ),
                      GButton(icon: Icons.settings_rounded, text: 'Ajustes'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
