part of 'operational_metrics_section.dart';

class _RideAnalysisSection extends StatefulWidget {
  const _RideAnalysisSection();

  @override
  State<_RideAnalysisSection> createState() => _RideAnalysisSectionState();
}

class _RideAnalysisSectionState extends State<_RideAnalysisSection>
    with TickerProviderStateMixin {
  JourneyController get controller => Get.find<JourneyController>();

  final Map<String, bool> _sectionExpanded = {
    'desempenho': false,
    'ganhos': false,
    'custos': false,
    'lucro': false,
  };

  late final Map<String, AnimationController> _sectionArrow;
  late final Map<String, Animation<double>> _sectionTurn;

  @override
  void initState() {
    super.initState();
    _sectionArrow = {
      for (final key in _sectionExpanded.keys)
        key: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
          value: (_sectionExpanded[key] ?? false) ? 1.0 : 0.0,
        ),
    };
    _sectionTurn = {
      for (final entry in _sectionArrow.entries)
        entry.key: Tween<double>(begin: 0.0, end: 0.5).animate(
          CurvedAnimation(parent: entry.value, curve: Curves.easeInOut),
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _sectionArrow.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleSection(String key) {
    setState(() {
      _sectionExpanded[key] = !(_sectionExpanded[key] ?? true);
      if (_sectionExpanded[key]!) {
        _sectionArrow[key]!.forward();
      } else {
        _sectionArrow[key]!.reverse();
      }
    });
  }

  String _fmt(double v) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    );
    return formatter.format(v);
  }

  String _fmtHours(double hours) {
    final totalMin = (hours * 60).round().clamp(0, 999999);
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  int get _rideAnalysisGrossCents => controller.grossEarningsCents.value;

  int get _rideAnalysisFuelCostCents => controller.rideAnalysisFuelCostsCents;

  int get _rideAnalysisProfitCents =>
      _rideAnalysisGrossCents - _rideAnalysisFuelCostCents;

  Widget _buildInsuficienteAviso({
    required bool semHoras,
    required bool semKm,
  }) {
    final partes = <String>[];
    if (semKm) partes.add('km < 1 km (GPS insuficiente)');
    if (semHoras) partes.add('turno < 1 min');
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 13,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Médias por ${partes.join(' e ')} — amostra pequena, valores estimados',
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.5,
                ),
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String sectionKey,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isExpanded = _sectionExpanded[sectionKey] ?? true;
    return GestureDetector(
      onTap: () => _toggleSection(sectionKey),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              RotationTransition(
                turns: _sectionTurn[sectionKey]!,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: color.withValues(alpha: 0.8),
                  size: 22,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 46, top: 2),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.55,
                  ),
                  fontSize: 11,
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildSemTurnoAviso() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.07,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.timer_off_outlined,
              size: 20,
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.45,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nenhum turno registrado neste período',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'As médias por viagem, hora e km dependem do tempo de turno registrado pelo timer.',
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.45,
                    ),
                    height: 1.4,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.sp(context, 10).clamp(6.0, 12.0)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(
          Responsive.sp(context, 16).clamp(12.0, 20.0),
        ),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = (constraints.maxWidth * 0.28).clamp(16.0, 24.0);
          final valueSize = (constraints.maxWidth * 0.22).clamp(11.0, 18.0);
          final labelSize = (constraints.maxWidth * 0.14).clamp(8.5, 12.0);
          final gapLarge = (constraints.maxHeight * 0.08).clamp(3.0, 8.0);
          final gapSmall = (constraints.maxHeight * 0.04).clamp(2.0, 4.0);

          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: context.theme.colorScheme.onSurface,
                  size: iconSize,
                ),
                SizedBox(height: gapLarge),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: valueSize,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
                SizedBox(height: gapSmall),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.82,
                        ),
                        fontSize: labelSize,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final semDados = controller.totalRides.value == 0;
      final totalTempoAnalise = controller.onlineAnalysisTotalTimeSeconds;
      final totalKmAnalise = controller.rideAnalysisTotalKm;
      final semHoras = totalTempoAnalise < 60;
      final semKm = totalKmAnalise < 1;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Análise por corrida',
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Médias por corrida com base no bruto e no combustível por km rodado',
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (totalTempoAnalise == 0) ...[
              _buildSemTurnoAviso(),
              const SizedBox(height: 24),
            ] else ...[
              _buildSectionHeader(
                sectionKey: 'desempenho',
                icon: Icons.speed_rounded,
                title: 'Desempenho',
                subtitle: 'Viagens realizadas, horas no turno e km pelo GPS',
                color: AppColors.royalBlue,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.directions_car,
                        label: 'Viagens',
                        value: semDados
                            ? '--'
                            : controller.totalRides.value.toString(),
                        color: AppColors.royalBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.schedule,
                        label: 'Horas',
                        value: semDados
                            ? '--'
                            : _fmtHours(totalTempoAnalise / 3600),
                        color: AppColors.electricCyan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.route,
                        label: 'KM',
                        value: semDados
                            ? '--'
                            : totalKmAnalise.toStringAsFixed(0),
                        color: AppColors.royalBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(
                sectionKey: 'ganhos',
                icon: Icons.trending_up_rounded,
                title: 'Ganhos',
                subtitle:
                    'Valor bruto recebido pelas corridas — médias por viagem, hora e km',
                color: AppColors.royalBlue,
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: _buildMetricCard(
                            icon: Icons.directions_car,
                            label: 'por viagem',
                            value: semDados
                                ? '--'
                                : _fmt(
                                    controller.totalRides.value > 0
                                        ? _rideAnalysisGrossCents /
                                              100 /
                                              controller.totalRides.value
                                        : 0,
                                  ),
                            color: AppColors.royalBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: _buildMetricCard(
                            icon: Icons.schedule,
                            label: 'por hora',
                            value: (semDados || semHoras)
                                ? '--'
                                : _fmt(
                                    totalTempoAnalise > 0
                                        ? (_rideAnalysisGrossCents / 100) /
                                              (totalTempoAnalise / 3600)
                                        : 0,
                                  ),
                            color: AppColors.royalBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: _buildMetricCard(
                            icon: Icons.speed,
                            label: 'por km',
                            value: (semDados || semKm)
                                ? '--'
                                : _fmt(
                                    totalKmAnalise > 0
                                        ? (_rideAnalysisGrossCents / 100) /
                                              totalKmAnalise
                                        : 0,
                                  ),
                            color: AppColors.royalBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!semDados && (semHoras || semKm))
                    _buildInsuficienteAviso(semHoras: semHoras, semKm: semKm),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(
                sectionKey: 'custos',
                icon: Icons.local_gas_station_rounded,
                title: 'Custos das corridas',
                subtitle:
                    'Custo baseado no combustível consumido pelo km rodado nas corridas',
                color: AppColors.rose,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.local_gas_station,
                        label: 'por viagem',
                        value: semDados
                            ? '--'
                            : _fmt(
                                controller.totalRides.value > 0
                                    ? _rideAnalysisFuelCostCents /
                                          100 /
                                          controller.totalRides.value
                                    : 0,
                              ),
                        color: AppColors.rose,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.schedule,
                        label: 'por hora',
                        value: (semDados || semHoras)
                            ? '--'
                            : _fmt(
                                totalTempoAnalise > 0
                                    ? (_rideAnalysisFuelCostCents / 100) /
                                          (totalTempoAnalise / 3600)
                                    : 0,
                              ),
                        color: AppColors.rose,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.speed,
                        label: 'por km',
                        value: (semDados || semKm)
                            ? '--'
                            : _fmt(
                                totalKmAnalise > 0
                                    ? (_rideAnalysisFuelCostCents / 100) /
                                          totalKmAnalise
                                    : 0,
                              ),
                        color: AppColors.rose,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(
                sectionKey: 'lucro',
                icon: Icons.savings_rounded,
                title: 'Lucro das corridas',
                subtitle:
                    'Ganho bruto menos o custo do combustível calculado por km rodado',
                color: AppColors.emerald,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.emoji_events,
                        label: 'por viagem',
                        value: semDados
                            ? '--'
                            : _fmt(
                                controller.totalRides.value > 0
                                    ? _rideAnalysisProfitCents /
                                          100 /
                                          controller.totalRides.value
                                    : 0,
                              ),
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.schedule,
                        label: 'por hora',
                        value: (semDados || semHoras)
                            ? '--'
                            : _fmt(
                                totalTempoAnalise > 0
                                    ? (_rideAnalysisProfitCents / 100) /
                                          (totalTempoAnalise / 3600)
                                    : 0,
                              ),
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildMetricCard(
                        icon: Icons.speed,
                        label: 'por km',
                        value: (semDados || semKm)
                            ? '--'
                            : _fmt(
                                totalKmAnalise > 0
                                    ? (_rideAnalysisProfitCents / 100) /
                                          totalKmAnalise
                                    : 0,
                              ),
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      );
    });
  }
}
