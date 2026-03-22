import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/responsive.dart';
import '../../../domain/entities/traffic_light_settings_entity.dart';
import '../../widgets/custom_app_bar.dart';
import 'traffic_light_settings_controller.dart';
import 'widgets/traffic_light_monitored_apps_section.dart';

class TrafficLightSettingsView extends GetView<TrafficLightSettingsController> {
  const TrafficLightSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Configurar Semaforo',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.hp(context, 5),
          vertical: Responsive.vp(context, 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'PREVIEW AO VIVO', isLive: true),
            SizedBox(height: Responsive.vp(context, 2)),
            const _PreviewCard(),
            SizedBox(height: Responsive.vp(context, 2.6)),
            Obx(
              () => _buildSectionHeader(
                context,
                'Apps Monitorados',
                icon: Icons.grid_view_rounded,
                trailing:
                    '${controller.selectedMonitoredAppsCount} selecionados',
              ),
            ),
            SizedBox(height: Responsive.vp(context, 1.0)),
            const TrafficLightMonitoredAppsSection(),
            SizedBox(height: Responsive.vp(context, 2.4)),
            _buildSectionHeader(
              context,
              'Posicao na Tela',
              icon: Icons.grid_view_rounded,
            ),
            SizedBox(height: Responsive.vp(context, 2)),
            _PositionSelector(),
            SizedBox(height: Responsive.vp(context, 4)),
            _buildSectionHeader(
              context,
              'Tema do Card',
              icon: Icons.palette_rounded,
            ),
            SizedBox(height: Responsive.vp(context, 2)),
            _ThemeSelector(),
            SizedBox(height: Responsive.vp(context, 4)),
            Obx(
              () => _buildSectionHeader(
                context,
                'Indicadores',
                icon: Icons.dashboard_customize_rounded,
                trailing:
                    '${controller.selectedIndicatorsCount}/4 selecionados',
              ),
            ),
            SizedBox(height: Responsive.vp(context, 2)),
            _IndicatorsGrid(),
            SizedBox(height: Responsive.vp(context, 4)),
            _buildSectionHeader(
              context,
              'Ajustes Visuais',
              icon: Icons.tune_rounded,
            ),
            SizedBox(height: Responsive.vp(context, 2)),
            _VisualAdjustments(),
            SizedBox(height: Responsive.vp(context, 4)),
            _ColorBlindToggle(),
            SizedBox(height: Responsive.vp(context, 5)),
            _SaveButton(),
            SizedBox(height: Responsive.vp(context, 5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool isLive = false,
    IconData? icon,
    String? trailing,
  }) {
    return Row(
      children: [
        if (isLive)
          Container(
            width: Responsive.sp(context, 8),
            height: Responsive.sp(context, 8),
            margin: EdgeInsets.only(right: Responsive.sp(context, 8)),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        if (icon != null) ...[
          Icon(
            icon,
            size: Responsive.sp(context, 20),
            color: Colors.white.withValues(alpha: 0.6),
          ),
          SizedBox(width: Responsive.sp(context, 8)),
        ],
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: Responsive.sp(context, 13),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: Responsive.sp(context, 12),
            ),
          ),
        if (isLive)
          Text(
            'Mude as opcoes abaixo',
            style: TextStyle(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
              fontSize: Responsive.sp(context, 12),
            ),
          ),
      ],
    );
  }
}

class _PreviewCard extends GetView<TrafficLightSettingsController> {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final previewTheme = _TrafficLightPreviewTheme.fromSettings(
        controller.selectedTheme.value,
        controller.colorBlindMode.value,
      );
      final baseFontSize = controller.fontSize.value;
      final activeIndicators = controller.orderedActiveIndicators;
      final indicatorValues = <String, String>{
        'R\$/Km': '2.35',
        'R\$/Hora': '52.8',
        'Nota': '4.92',
        'Lucro/H': '38.9',
      };

      return Container(
        height: Responsive.vp(context, 50),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(Responsive.sp(context, 32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
            Container(
              width: Responsive.hp(context, 55),
              height: Responsive.vp(context, 45),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Responsive.sp(context, 30)),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Responsive.sp(context, 28)),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: Responsive.vp(context, 1),
                      left: Responsive.hp(context, 2),
                      right: Responsive.hp(context, 2),
                      child: _buildRideMockup(context),
                    ),
                    _buildTrafficLightPositioned(
                      context,
                      controller.selectedPosition.value,
                      Opacity(
                        opacity: (controller.opacity.value / 100).clamp(
                          0.0,
                          1.0,
                        ),
                        child: _buildTrafficLightPreview(
                          context,
                          previewTheme,
                          baseFontSize,
                          activeIndicators,
                          indicatorValues,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRideMockup(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.sp(context, 10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: Responsive.sp(context, 12),
                backgroundColor: Colors.deepPurpleAccent,
              ),
              SizedBox(width: Responsive.sp(context, 8)),
              Text(
                'Ricardo Silva',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Responsive.sp(context, 10),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.sp(context, 4),
                  vertical: Responsive.sp(context, 2),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    Responsive.sp(context, 4),
                  ),
                ),
                child: Text(
                  '4.98',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: Responsive.sp(context, 8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: Responsive.vp(context, 1.5)),
          _buildMockAddress(
            context,
            Colors.blue,
            'Shopping Cidade Sao Paulo',
            '1.2 km',
          ),
          SizedBox(height: Responsive.vp(context, 0.5)),
          _buildMockAddress(
            context,
            Colors.red,
            'Aeroporto de Congonhas',
            '8.5 km',
          ),
          SizedBox(height: Responsive.vp(context, 1)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: Responsive.vp(context, 0.8),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(Responsive.sp(context, 8)),
            ),
            alignment: Alignment.center,
            child: Text(
              'Aceitar â€¢ R\$ 35,40',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.sp(context, 10),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLightPreview(
    BuildContext context,
    _TrafficLightPreviewTheme previewTheme,
    double baseFontSize,
    List<String> activeIndicators,
    Map<String, String> indicatorValues,
  ) {
    final isVerticalMetrics =
        controller.selectedPosition.value == TrafficLightPosition.esquerda ||
        controller.selectedPosition.value == TrafficLightPosition.direita;

    return Container(
      padding: EdgeInsets.all(Responsive.sp(context, 10)),
      decoration: BoxDecoration(
        color: previewTheme.backgroundColor,
        borderRadius: BorderRadius.circular(Responsive.sp(context, 12)),
        border: Border.all(color: previewTheme.borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RICARDO â€¢ 4.92',
            style: TextStyle(
              color: previewTheme.secondaryTextColor,
              fontSize: Responsive.sp(context, _scaledFont(baseFontSize, 0.52)),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.vp(context, 0.8)),
          if (activeIndicators.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.sp(context, 8),
                vertical: Responsive.vp(context, 1),
              ),
              decoration: BoxDecoration(
                color: previewTheme.tagBackgroundColor,
                borderRadius: BorderRadius.circular(Responsive.sp(context, 8)),
              ),
              child: Text(
                'Nenhum indicador selecionado',
                style: TextStyle(
                  color: previewTheme.primaryTextColor,
                  fontSize: Responsive.sp(
                    context,
                    _scaledFont(baseFontSize, 0.7),
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (isVerticalMetrics)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: activeIndicators
                  .map(
                    (name) => Padding(
                      padding: EdgeInsets.only(
                        bottom: Responsive.vp(context, 0.8),
                      ),
                      child: _buildMockMetric(
                        context,
                        label: name,
                        value: indicatorValues[name] ?? '--',
                        color: previewTheme.indicatorColor(name),
                        theme: previewTheme,
                        baseFontSize: baseFontSize,
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            Wrap(
              spacing: Responsive.sp(context, 10),
              runSpacing: Responsive.vp(context, 0.8),
              children: activeIndicators
                  .map(
                    (name) => _buildMockMetric(
                      context,
                      label: name,
                      value: indicatorValues[name] ?? '--',
                      color: previewTheme.indicatorColor(name),
                      theme: previewTheme,
                      baseFontSize: baseFontSize,
                    ),
                  )
                  .toList(),
            ),
          SizedBox(height: Responsive.vp(context, 1)),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.sp(context, 2)),
                decoration: BoxDecoration(
                  color: previewTheme.tagBackgroundColor,
                  borderRadius: BorderRadius.circular(
                    Responsive.sp(context, 2),
                  ),
                ),
                child: Text(
                  controller.selectedTheme.value.name
                      .substring(0, 3)
                      .toUpperCase(),
                  style: TextStyle(
                    color: previewTheme.primaryTextColor,
                    fontSize: Responsive.sp(
                      context,
                      _scaledFont(baseFontSize, 0.4),
                    ),
                  ),
                ),
              ),
              SizedBox(width: Responsive.sp(context, 4)),
              Expanded(
                child: isVerticalMetrics
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${controller.cardDuration.value.toInt()}s',
                            style: TextStyle(
                              color: previewTheme.primaryTextColor,
                              fontSize: Responsive.sp(
                                context,
                                _scaledFont(baseFontSize, 0.65),
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '8.5km',
                            style: TextStyle(
                              color: previewTheme.secondaryTextColor,
                              fontSize: Responsive.sp(
                                context,
                                _scaledFont(baseFontSize, 0.55),
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '${controller.cardDuration.value.toInt()}s • 8.5km',
                        style: TextStyle(
                          color: previewTheme.primaryTextColor,
                          fontSize: Responsive.sp(
                            context,
                            _scaledFont(baseFontSize, 0.65),
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(width: Responsive.sp(context, 6)),
              Icon(
                Icons.close,
                color: previewTheme.secondaryTextColor,
                size: Responsive.sp(context, _scaledFont(baseFontSize, 0.65)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLightPositioned(
    BuildContext context,
    TrafficLightPosition position,
    Widget child,
  ) {
    final horizontal = Responsive.hp(context, 2);
    final vertical = Responsive.vp(context, 2);

    switch (position) {
      case TrafficLightPosition.topo:
        return Positioned(
          top: vertical,
          left: horizontal,
          right: horizontal,
          child: child,
        );
      case TrafficLightPosition.esquerda:
        return Positioned(
          top: vertical,
          left: horizontal,
          right: Responsive.hp(context, 16),
          child: child,
        );
      case TrafficLightPosition.direita:
        return Positioned(
          top: vertical,
          left: Responsive.hp(context, 16),
          right: horizontal,
          child: child,
        );
      case TrafficLightPosition.rodape:
        return Positioned(
          bottom: Responsive.vp(context, 15),
          left: horizontal,
          right: horizontal,
          child: child,
        );
    }
  }

  Widget _buildMockAddress(
    BuildContext context,
    Color color,
    String text,
    String dist,
  ) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: Responsive.sp(context, 6)),
        SizedBox(width: Responsive.sp(context, 6)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: Responsive.sp(context, 8),
            ),
          ),
        ),
        Text(
          dist,
          style: TextStyle(
            color: Colors.blue,
            fontSize: Responsive.sp(context, 8),
          ),
        ),
      ],
    );
  }

  Widget _buildMockMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required _TrafficLightPreviewTheme theme,
    required double baseFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.secondaryTextColor,
            fontSize: Responsive.sp(context, _scaledFont(baseFontSize, 0.4)),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.sp(context, 2),
              height: Responsive.sp(context, 10),
              color: color,
            ),
            SizedBox(width: Responsive.sp(context, 2)),
            Text(
              value,
              style: TextStyle(
                color: theme.primaryTextColor,
                fontSize: Responsive.sp(
                  context,
                  _scaledFont(baseFontSize, 0.8),
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _scaledFont(double base, double factor) {
    return (base * factor).clamp(6.0, 18.0);
  }
}

class _TrafficLightPreviewTheme {
  final Color backgroundColor;
  final Color borderColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color tagBackgroundColor;
  final Map<String, Color> indicatorColors;

  const _TrafficLightPreviewTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.tagBackgroundColor,
    required this.indicatorColors,
  });

  factory _TrafficLightPreviewTheme.fromSettings(
    TrafficLightTheme theme,
    bool colorBlindMode,
  ) {
    final indicatorColors = colorBlindMode
        ? <String, Color>{
            'R\$/Km': const Color(0xFF1565C0),
            'R\$/Hora': const Color(0xFFEF6C00),
            'Nota': const Color(0xFF6A1B9A),
            'Lucro/H': const Color(0xFF00897B),
          }
        : <String, Color>{
            'R\$/Km': Colors.green,
            'R\$/Hora': Colors.orange,
            'Nota': Colors.lightGreenAccent,
            'Lucro/H': Colors.greenAccent,
          };

    switch (theme) {
      case TrafficLightTheme.claro:
        return _TrafficLightPreviewTheme(
          backgroundColor: Colors.white,
          borderColor: indicatorColors['R\$/Km']!,
          primaryTextColor: const Color(0xFF111111),
          secondaryTextColor: const Color(0xFF666666),
          tagBackgroundColor: const Color(0xFFF1F1F1),
          indicatorColors: indicatorColors,
        );
      case TrafficLightTheme.escuro:
        return _TrafficLightPreviewTheme(
          backgroundColor: const Color(0xFF121212),
          borderColor: indicatorColors['R\$/Km']!,
          primaryTextColor: Colors.white,
          secondaryTextColor: Colors.white38,
          tagBackgroundColor: Colors.white12,
          indicatorColors: indicatorColors,
        );
      case TrafficLightTheme.verde:
        return _TrafficLightPreviewTheme(
          backgroundColor: const Color(0xFF034D35),
          borderColor: indicatorColors['Lucro/H']!,
          primaryTextColor: Colors.white,
          secondaryTextColor: Colors.white70,
          tagBackgroundColor: Colors.white12,
          indicatorColors: indicatorColors,
        );
    }
  }

  Color indicatorColor(String label) => indicatorColors[label] ?? borderColor;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _PositionSelector extends GetView<TrafficLightSettingsController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildItem(
          context,
          TrafficLightPosition.topo,
          Icons.vertical_align_top_rounded,
          'Topo',
        ),
        _buildItem(
          context,
          TrafficLightPosition.esquerda,
          Icons.align_horizontal_left_rounded,
          'Esquerda',
        ),
        _buildItem(
          context,
          TrafficLightPosition.direita,
          Icons.align_horizontal_right_rounded,
          'Direita',
        ),
        _buildItem(
          context,
          TrafficLightPosition.rodape,
          Icons.vertical_align_bottom_rounded,
          'Rodape',
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    TrafficLightPosition pos,
    IconData icon,
    String label,
  ) {
    return Obx(() {
      final isSelected = controller.selectedPosition.value == pos;
      return GestureDetector(
        onTap: () => controller.selectedPosition.value = pos,
        child: Container(
          width: (Responsive.width(context) - 70) / 4,
          padding: EdgeInsets.symmetric(vertical: Responsive.vp(context, 1.5)),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.deepPurpleAccent.withValues(alpha: 0.15)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
            border: Border.all(
              color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.deepPurpleAccent : Colors.white38,
                size: Responsive.sp(context, 24),
              ),
              SizedBox(height: Responsive.vp(context, 1)),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: Responsive.sp(context, 11),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ThemeSelector extends GetView<TrafficLightSettingsController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildItem(
          context,
          TrafficLightTheme.claro,
          'Claro',
          Colors.white,
          Colors.black,
        ),
        _buildItem(
          context,
          TrafficLightTheme.escuro,
          'Escuro',
          const Color(0xFF1A1A1A),
          Colors.white,
        ),
        _buildItem(
          context,
          TrafficLightTheme.verde,
          'Verde',
          const Color(0xFF034D35),
          Colors.white,
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    TrafficLightTheme theme,
    String label,
    Color bg,
    Color text,
  ) {
    return Obx(() {
      final isSelected = controller.selectedTheme.value == theme;
      return GestureDetector(
        onTap: () => controller.selectedTheme.value = theme,
        child: Column(
          children: [
            Container(
              width: (Responsive.width(context) - 60) / 3,
              height: Responsive.vp(context, 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
                border: Border.all(
                  color: isSelected
                      ? Colors.deepPurpleAccent
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 2, height: 20, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '2.35',
                    style: TextStyle(color: text, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 2, height: 20, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '52',
                    style: TextStyle(color: text, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.vp(context, 1)),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.deepPurpleAccent : Colors.white38,
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _IndicatorsGrid extends GetView<TrafficLightSettingsController> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildIndicator(context, 'R\$/Km', Icons.speed_rounded, '1'),
        _buildIndicator(context, 'R\$/Hora', Icons.timer_outlined, '2'),
        _buildIndicator(context, 'Lucro/H', Icons.trending_up_rounded, '4'),
        _buildIndicator(context, 'Nota', Icons.person_rounded, '3'),
      ],
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    String name,
    IconData icon,
    String number,
  ) {
    return Obx(() {
      final isActive = controller.indicators[name] ?? false;
      return GestureDetector(
        onTap: () => controller.toggleIndicator(name),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.hp(context, 3),
            vertical: Responsive.vp(context, 1),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
            border: Border.all(
              color: isActive ? Colors.deepPurpleAccent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.sp(context, 8),
                  vertical: Responsive.sp(context, 2),
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    Responsive.sp(context, 8),
                  ),
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: Responsive.sp(context, 9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                icon,
                size: Responsive.sp(context, 20),
                color: isActive ? Colors.deepPurpleAccent : Colors.white24,
              ),
              SizedBox(height: Responsive.vp(context, 0.5)),
              Text(
                name,
                style: TextStyle(
                  color: isActive ? Colors.deepPurpleAccent : Colors.white24,
                  fontSize: Responsive.sp(context, 11),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    });
  }
}

class _VisualAdjustments extends GetView<TrafficLightSettingsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.sp(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(Responsive.sp(context, 24)),
      ),
      child: Column(
        children: [
          _buildSliderRow(
            context,
            'Tamanho da Fonte',
            controller.fontSize,
            10,
            30,
          ),
          SizedBox(height: Responsive.vp(context, 2.5)),
          _buildSliderRow(context, 'Opacidade', controller.opacity, 0, 100),
          SizedBox(height: Responsive.vp(context, 2.5)),
          _buildSliderRow(
            context,
            'Duracao do Card',
            controller.cardDuration,
            5,
            30,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    BuildContext context,
    String label,
    RxDouble value,
    double min,
    double max,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _getIcon(label),
                  size: Responsive.sp(context, 18),
                  color: Colors.deepPurpleAccent,
                ),
                SizedBox(width: Responsive.sp(context, 8)),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.sp(context, 8),
                vertical: Responsive.sp(context, 4),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Responsive.sp(context, 8)),
              ),
              child: Obx(
                () => Text(
                  label == 'Opacidade'
                      ? '${value.value.toInt()}%'
                      : (label == 'Duracao do Card'
                            ? '${value.value.toInt()}s'
                            : '${value.value.toInt()}'),
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: Responsive.sp(context, 12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        Obx(
          () => Slider(
            value: value.value,
            min: min,
            max: max,
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.white10,
            thumbColor: Colors.deepPurpleAccent,
            onChanged: (v) => value.value = v,
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String label) {
    if (label.contains('Fonte')) return Icons.text_fields_rounded;
    if (label.contains('Opacidade')) return Icons.opacity_rounded;
    return Icons.timer_outlined;
  }
}

class _ColorBlindToggle extends GetView<TrafficLightSettingsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.sp(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(Responsive.sp(context, 24)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.accessibility_new_rounded,
            color: Colors.deepPurpleAccent,
            size: Responsive.sp(context, 24),
          ),
          SizedBox(width: Responsive.sp(context, 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modo Daltonico',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Usar paleta adaptada no preview',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: Responsive.sp(context, 12),
                ),
              ),
            ],
          ),
          const Spacer(),
          Obx(
            () => Switch(
              value: controller.colorBlindMode.value,
              onChanged: (v) => controller.colorBlindMode.value = v,
              activeThumbColor: Colors.deepPurpleAccent,
              activeTrackColor: Colors.deepPurpleAccent.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends GetView<TrafficLightSettingsController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.vp(context, 7),
      child: ElevatedButton.icon(
        onPressed: controller.saveSettings,
        icon: Icon(
          Icons.save_rounded,
          color: Colors.white,
          size: Responsive.sp(context, 20),
        ),
        label: Text(
          'Salvar Configuracoes',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
