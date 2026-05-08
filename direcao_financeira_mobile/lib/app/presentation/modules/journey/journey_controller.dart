import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../domain/entities/active_shift_entity.dart';
import '../../../domain/entities/costs_gains_settings_entity.dart';
import '../../../domain/entities/location_tracking_status_entity.dart';
import '../../../domain/entities/online_hourly_projection_entity.dart';
import '../../../domain/entities/ride_entity.dart';
import '../../../domain/entities/shift_entity.dart';
import '../../../domain/services/online_hourly_projection_calculator.dart';
import '../../../domain/usecases/costs_gains_settings_use_cases.dart';
import '../../../domain/usecases/get_rides_usecase.dart';
import '../../../domain/usecases/journey_use_cases.dart';
import 'journey_runtime_coordinator.dart';
import 'journey_statistics_display_data.dart';
import 'shift_lifecycle_coordinator.dart';

class JourneyController extends GetxController with WidgetsBindingObserver {
  static const int _historyPageSize = 20;

  final GetActiveShiftUseCase getActiveShift;
  final GetDailyStatisticsUseCase getDailyStatistics;
  final GetShiftHistoryUseCase getShiftHistory;
  final GetRidesUseCase getRidesUseCase;
  final GetCostsGainsSettingsUseCase? getCostsGainsSettings;
  final ShiftLifecycleCoordinator shiftLifecycleCoordinator;
  final JourneyRuntimeCoordinator runtimeCoordinator;

  JourneyController({
    required this.getActiveShift,
    required this.getDailyStatistics,
    required this.getShiftHistory,
    required this.getRidesUseCase,
    required this.getCostsGainsSettings,
    required this.shiftLifecycleCoordinator,
    required this.runtimeCoordinator,
  });

  final isLoading = false.obs;
  final isStartingShift = false.obs;
  final isPauseShiftLoading = false.obs;
  final isFinishingShift = false.obs;
  final isLoadingMoreShifts = false.obs;
  final isLoadingMoreRides = false.obs;
  final hasMoreShifts = false.obs;
  final hasMoreRides = false.obs;
  final selectedFilter = 'day'.obs; // day, week, month, year, custom
  final customStartDate = Rxn<DateTime>();
  final customEndDate = Rxn<DateTime>();
  final activeShift = Rxn<ActiveShiftEntity>();
  final activeShiftError = RxnString();
  final metricsError = RxnString();
  final historyError = RxnString();
  final ridesError = RxnString();

  Timer? _timer;
  Worker? _journeyMetricsWorker;
  final elapsedSeconds = 0.obs;
  final startTimeStr = '--:--'.obs;
  final currentKm = 0.0.obs;
  final isWaitingAccessibilityActivation = false.obs;
  final pendingShiftSyncCount = 0.obs;
  final trackingStatus = Rxn<LocationTrackingStatusEntity>();
  DateTime? _lastTrackingUiRefreshAt;
  double? _lastTrackingUiDistanceMeters;

  String get formattedElapsed {
    final hours = elapsedSeconds.value ~/ 3600;
    final minutes = (elapsedSeconds.value % 3600) ~/ 60;
    final seconds = elapsedSeconds.value % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  final ridesList = <RideEntity>[].obs;
  final paymentMethodSummary = <PaymentMethodSummaryItem>[].obs;
  final isPaymentMethodSectionExpanded = false.obs;
  final selectedRideStatusFilter = 'Todos'.obs;
  final shiftsTotalCount = 0.obs;
  final ridesHistoryTotalCount = 0.obs;
  final paymentMethodFinishedRidesCount = 0.obs;

  List<RideEntity> get filteredRidesList =>
      ridesList.where(_matchesSelectedRideStatus).toList(growable: false);
  int get filteredRidesCount => filteredRidesList.length;
  int get mappedPaymentMethodCount =>
      paymentMethodSummary.fold(0, (total, item) => total + item.count);

  void togglePaymentMethodSection() {
    isPaymentMethodSectionExpanded.toggle();
  }

  void changeRideStatusFilter(String filter) {
    if (selectedRideStatusFilter.value == filter) {
      return;
    }
    selectedRideStatusFilter.value = filter;
    ridesHistoryTotalCount.value = filteredRidesCount;
  }

  void openRideDetails(RideEntity ride) {
    Get.toNamed('/journey/ride-details', arguments: ride);
  }

  final totalShifts = '0'.obs;
  final totalTime = '00:00:00'.obs;
  final averageTime = '00:00:00'.obs;
  final idleTime = '00:00:00'.obs;
  final drivenKm = '0.0 km'.obs;
  final averageKmh = '0.0 km/h'.obs;

  final totalRides = 0.obs;
  final grossEarningsCents = 0.obs;
  final netEarningsCents = 0.obs;
  final totalCostsCents = 0.obs;
  final ridesTotalKm = 0.0.obs;
  final ridesTotalTime = 0.obs;
  final totalShiftDrivenKm = 0.0.obs;
  final costsGainsSettings = Rxn<CostsGainsSettingsEntity>();
  final isOperationalCostBreakdownExpanded = false.obs;

  final shiftsCount = 0.obs;
  final shiftsList = <ShiftEntity>[].obs;

  final selectedDate = DateTime.now().obs;
  final isTrafficLightActive = false.obs;
  final isAssistantActive = false.obs;
  final isAssistantBusy = false.obs;
  int _statisticsTotalTimeBaseSeconds = 0;
  int _statisticsIdleTimeBaseSeconds = 0;

  bool get hasActiveShift => activeShift.value != null;
  bool get isAccessibilityServiceEnabled =>
      runtimeCoordinator.accessibilityService.isServiceEnabled.value;
  String get status => hasActiveShift ? 'Ativo' : 'Inativo';
  bool get isOnline => runtimeCoordinator.journeyRealtimeBridge.isOnline.value;
  bool get canRetry =>
      activeShiftError.value != null ||
      metricsError.value != null ||
      historyError.value != null ||
      ridesError.value != null;
  bool get canStartShift =>
      !isLoading.value && !isStartingShift.value && !hasActiveShift;
  bool get canFinishShift =>
      !isLoading.value && !isFinishingShift.value && hasActiveShift;
  bool get canPauseOrResumeShift =>
      !isLoading.value && !isPauseShiftLoading.value && hasActiveShift;
  bool get isShiftPaused => activeShift.value?.isPaused ?? false;
  bool get canOpenTrackingSettings {
    final status = trackingStatus.value;
    if (!hasActiveShift || status == null) {
      return false;
    }

    return !status.isLocationServiceEnabled ||
        !status.hasForegroundPermission ||
        !status.hasBackgroundPermission ||
        !status.isPreciseLocation;
  }

  String get trackingSettingsLabel {
    final status = trackingStatus.value;
    if (status == null) {
      return 'Abrir ajustes';
    }

    if (!status.isLocationServiceEnabled) {
      return 'Ativar GPS';
    }

    return 'Abrir ajustes';
  }

  String? get bannerMessage {
    if (!isOnline) {
      return 'Voce esta offline. O turno continua funcionando no aparelho e sera sincronizado quando a internet voltar.';
    }

    if (pendingShiftSyncCount.value > 0) {
      return pendingShiftSyncCount.value == 1
          ? 'Existe 1 turno pendente de sincronizacao com o servidor.'
          : 'Existem ${pendingShiftSyncCount.value} turnos pendentes de sincronizacao com o servidor.';
    }

    final trackingIssue = trackingStatus.value?.issueMessage;
    if (hasActiveShift && trackingIssue != null) {
      return trackingIssue;
    }

    return activeShiftError.value ??
        metricsError.value ??
        historyError.value ??
        ridesError.value;
  }

  JourneyHistorySectionState get historySectionState =>
      JourneyHistorySectionState(
        shifts: List<ShiftEntity>.unmodifiable(shiftsList),
        totalCount: shiftsTotalCount.value,
        isLoadingMore: isLoadingMoreShifts.value,
        hasMore: hasMoreShifts.value,
        errorMessage: historyError.value,
      );

  JourneyRidesSectionState get ridesSectionState => JourneyRidesSectionState(
    selectedStatusFilter: selectedRideStatusFilter.value,
    visibleRides: List<RideEntity>.unmodifiable(filteredRidesList),
    totalVisibleCount: ridesHistoryTotalCount.value,
    periodLabel: dateLabel,
    isLoadingMore: isLoadingMoreRides.value,
    errorMessage: ridesError.value,
  );

  JourneyPaymentMethodsSectionState get paymentMethodsSectionState =>
      JourneyPaymentMethodsSectionState(
        items: List<PaymentMethodSummaryItem>.unmodifiable(paymentMethodSummary),
        totalFinishedRides: paymentMethodFinishedRidesCount.value,
        mappedCount: mappedPaymentMethodCount,
        isExpanded: isPaymentMethodSectionExpanded.value,
      );

  JourneyOperationalSummaryData get operationalSummaryData =>
      JourneyOperationalSummaryData(
        netEarningsCents: operationalNetEarningsCents,
        grossEarningsCents: operationalGrossEarningsCents,
        totalCostsCents: operationalTotalCostsCents,
        totalRides: totalRides.value,
        margin: operationalMargin,
        isCostBreakdownExpanded: isOperationalCostBreakdownExpanded.value,
      );

  JourneyOperationalCostBreakdownData get operationalCostBreakdownData =>
      JourneyOperationalCostBreakdownData(
        variableCostsCents: operationalVariableCostsCents,
        fixedCostsCents: operationalFixedCostsCents,
        variableItems: List<OperationalCostBreakdownItem>.unmodifiable(
          operationalVariableCostItems,
        ),
        fixedItems: List<OperationalCostBreakdownItem>.unmodifiable(
          operationalFixedCostItems,
        ),
      );

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    isTrafficLightActive.value =
        runtimeCoordinator.accessibilityService.persistedTrafficLightActive;
    _journeyMetricsWorker = everAll([
      activeShift,
      currentKm,
      elapsedSeconds,
      totalShifts,
      selectedFilter,
      selectedDate,
      customStartDate,
      customEndDate,
      totalShiftDrivenKm,
    ], (_) => _syncDisplayedJourneyMetrics());
    runtimeCoordinator.bind(
      onConnectionChanged: _handleConnectionStatusChanged,
      onTrackingStatusChanged: _handleTrackingStatusUpdated,
      onRideChanged: () {
        refreshJourneyData(silent: true, showErrors: false);
      },
      onAccessibilityChanged: _handleAccessibilityStatusChanged,
    );
    refreshJourneyData(showErrors: false);
    _loadTrackingStatus();
    runtimeCoordinator.loadAssistantStatus(
      onAssistantStateChanged: (isActive) => isAssistantActive.value = isActive,
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    runtimeCoordinator.unbind();
    _timer?.cancel();
    _journeyMetricsWorker?.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    _syncSelectedDateWithTodayIfNeeded();
  }

  String get dateLabel {
    if (selectedFilter.value == 'custom' &&
        customStartDate.value != null &&
        customEndDate.value != null) {
      final start = customStartDate.value!;
      final end = customEndDate.value!;
      final startDay = start.day.toString().padLeft(2, '0');
      final startMonth = start.month.toString().padLeft(2, '0');
      final endDay = end.day.toString().padLeft(2, '0');
      final endMonth = end.month.toString().padLeft(2, '0');
      return '$startDay/$startMonth - $endDay/$endMonth';
    }

    final date = selectedDate.value;
    if (selectedFilter.value == 'day') {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    if (selectedFilter.value == 'month') {
      const months = [
        'Janeiro',
        'Fevereiro',
        'Marco',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro',
      ];
      return '${months[date.month - 1]} ${date.year}';
    }

    if (selectedFilter.value == 'year') {
      return '${date.year}';
    }

    if (selectedFilter.value == 'week') {
      final weekDay = date.weekday;
      final startOfWeek = date.subtract(Duration(days: weekDay - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final startDay = startOfWeek.day.toString().padLeft(2, '0');
      final startMonth = startOfWeek.month.toString().padLeft(2, '0');
      final endDay = endOfWeek.day.toString().padLeft(2, '0');
      final endMonth = endOfWeek.month.toString().padLeft(2, '0');

      return '$startDay/$startMonth - $endDay/$endMonth';
    }

    return 'Semana de ${date.day}/${date.month}';
  }

  void nextDate() {
    if (selectedFilter.value == 'day') {
      selectedDate.value = selectedDate.value.add(const Duration(days: 1));
    } else if (selectedFilter.value == 'week') {
      selectedDate.value = selectedDate.value.add(const Duration(days: 7));
    } else if (selectedFilter.value == 'month') {
      selectedDate.value = DateTime(
        selectedDate.value.year,
        selectedDate.value.month + 1,
        1,
      );
    } else if (selectedFilter.value == 'year') {
      selectedDate.value = DateTime(selectedDate.value.year + 1, 1, 1);
    }
    refreshJourneyData(showErrors: false);
  }

  void previousDate() {
    if (selectedFilter.value == 'day') {
      selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    } else if (selectedFilter.value == 'week') {
      selectedDate.value = selectedDate.value.subtract(const Duration(days: 7));
    } else if (selectedFilter.value == 'month') {
      selectedDate.value = DateTime(
        selectedDate.value.year,
        selectedDate.value.month - 1,
        1,
      );
    } else if (selectedFilter.value == 'year') {
      selectedDate.value = DateTime(selectedDate.value.year - 1, 1, 1);
    }
    refreshJourneyData(showErrors: false);
  }

  void changeFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      refreshJourneyData(showErrors: false);
    }
  }

  void _syncSelectedDateWithTodayIfNeeded() {
    if (selectedFilter.value != 'day') {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = selectedDate.value;
    final selectedDay = DateTime(selected.year, selected.month, selected.day);

    if (selectedDay == today) {
      return;
    }

    selectedDate.value = today;
    refreshJourneyData(silent: true, showErrors: false);
  }

  void setCustomRange(DateTime start, DateTime end) {
    selectedFilter.value = 'custom';
    customStartDate.value = start;
    customEndDate.value = end;
    refreshJourneyData(showErrors: false);
  }

  String formatCurrency(int cents) {
    final value = cents / 100;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  double get margin {
    if (grossEarningsCents.value == 0) return 0.0;
    return (netEarningsCents.value / grossEarningsCents.value) * 100;
  }

  int get operationalGrossEarningsCents => grossEarningsCents.value;

  int get operationalTotalCostsCents {
    final settings = costsGainsSettings.value;
    if (settings == null) {
      return totalCostsCents.value;
    }

    return operationalFixedCostsCents + operationalVariableCostsCents;
  }

  int get operationalNetEarningsCents =>
      operationalGrossEarningsCents - operationalTotalCostsCents;

  double get operationalMargin {
    if (operationalGrossEarningsCents == 0) {
      return 0.0;
    }

    return (operationalNetEarningsCents / operationalGrossEarningsCents) * 100;
  }

  int get operationalFixedCostsCents {
    final settings = costsGainsSettings.value;
    if (settings == null) {
      return 0;
    }

    return _operationalFixedCostItems(
      settings,
    ).fold(0, (total, item) => total + item.amountCents);
  }

  int get operationalFuelCostsCents {
    final settings = costsGainsSettings.value;
    if (settings == null || settings.kmPerLiter <= 0) {
      return 0;
    }

    final litersUsed = operationalDrivenKm / settings.kmPerLiter;
    return (litersUsed * settings.fuelPricePerLiterCents).round();
  }

  int get rideAnalysisFuelCostsCents {
    final settings = costsGainsSettings.value;
    if (settings == null || settings.kmPerLiter <= 0) {
      return 0;
    }

    final litersUsed = rideAnalysisTotalKm / settings.kmPerLiter;
    return (litersUsed * settings.fuelPricePerLiterCents).round();
  }

  int get operationalVariablePlatformFeeCents {
    final settings = costsGainsSettings.value;
    if (settings == null ||
        settings.platformFeeType != PlatformFeeType.percentage ||
        settings.platformFeeValue <= 0) {
      return 0;
    }

    return (operationalGrossEarningsCents * (settings.platformFeeValue / 100))
        .round();
  }

  int get operationalVariableCostsCents =>
      operationalFuelCostsCents + operationalVariablePlatformFeeCents;

  double get operationalDrivenKm {
    var km = totalShiftDrivenKm.value;
    if (_shouldUseLiveJourneyKm) {
      km += currentKm.value.floorToDouble();
    }
    return km;
  }

  int get rideAnalysisTotalTimeSeconds {
    var seconds = ridesTotalTime.value;
    if (_selectedRangeIncludesNow && hasActiveShift) {
      // Atualiza em blocos de 5s para evitar oscilação visual excessiva.
      seconds += (elapsedSeconds.value ~/ 5) * 5;
    }
    return seconds;
  }

  double get rideAnalysisTotalKm {
    var km = ridesTotalKm.value;
    if (_shouldUseLiveJourneyKm) {
      km += currentKm.value.floorToDouble();
    }
    return km;
  }

  int get onlineAnalysisTotalTimeSeconds {
    var seconds = _statisticsTotalTimeBaseSeconds;
    if (_shouldUseLiveJourneyTime) {
      seconds += _statisticsLiveElapsedSeconds;
    }
    return seconds;
  }

  int get operationalGrossEarningsPerOnlineHourCents =>
      OnlineHourlyProjectionCalculator.calculateHourlyCents(
        earningsCents: operationalGrossEarningsCents,
        onlineTimeSeconds: onlineAnalysisTotalTimeSeconds,
      );

  int get operationalCostsPerOnlineHourCents =>
      OnlineHourlyProjectionCalculator.calculateHourlyCents(
        earningsCents: operationalTotalCostsCents,
        onlineTimeSeconds: onlineAnalysisTotalTimeSeconds,
      );

  int get operationalNetEarningsPerOnlineHourCents =>
      OnlineHourlyProjectionCalculator.calculateHourlyCents(
        earningsCents: operationalNetEarningsCents,
        onlineTimeSeconds: onlineAnalysisTotalTimeSeconds,
      );

  OnlineHourlyProjectionEntity projectGrossOnlineHourlyWithRide({
    required int offeredRideEarningsCents,
    required int offeredRideDurationSeconds,
  }) {
    return OnlineHourlyProjectionCalculator.project(
      historicalEarningsCents: operationalGrossEarningsCents,
      historicalOnlineTimeSeconds: onlineAnalysisTotalTimeSeconds,
      offeredRideEarningsCents: offeredRideEarningsCents,
      offeredRideDurationSeconds: offeredRideDurationSeconds,
    );
  }

  String get operationalCostBreakdownLabel {
    final settings = costsGainsSettings.value;
    if (settings == null) {
      return 'Baseado no custo atual das corridas';
    }

    return 'Fixos ${formatCurrency(operationalFixedCostsCents)} + variáveis ${formatCurrency(operationalVariableCostsCents)}';
  }

  List<OperationalCostBreakdownItem> get operationalVariableCostItems {
    final settings = costsGainsSettings.value;
    if (settings == null) {
      return operationalFuelCostsCents <= 0
          ? const []
          : [
              OperationalCostBreakdownItem(
                label: 'Combustível',
                amountCents: operationalFuelCostsCents,
              ),
            ];
    }

    final items = <OperationalCostBreakdownItem>[];

    if (operationalFuelCostsCents > 0) {
      items.add(
        OperationalCostBreakdownItem(
          label: 'Combustível',
          amountCents: operationalFuelCostsCents,
        ),
      );
    }

    if (operationalVariablePlatformFeeCents > 0) {
      items.add(
        OperationalCostBreakdownItem(
          label: settings.platformFeeType == PlatformFeeType.percentage
              ? 'Taxa da Plataforma'
              : 'Taxa Variável Plataforma',
          amountCents: operationalVariablePlatformFeeCents,
        ),
      );
    }

    return items;
  }

  List<OperationalCostBreakdownItem> get operationalFixedCostItems {
    final settings = costsGainsSettings.value;
    if (settings == null) {
      return const [];
    }

    return _operationalFixedCostItems(settings);
  }

  void toggleOperationalCostBreakdown() {
    isOperationalCostBreakdownExpanded.toggle();
  }

  Future<void> refreshJourneyData({
    bool silent = false,
    bool includeRides = true,
    bool showErrors = false,
  }) async {
    if (!silent) {
      isLoading.value = true;
    }

    final params = _buildQueryParams();

    await Future.wait([
      _loadActiveShift(showErrors: showErrors),
      _loadCostsGainsSettings(showErrors: showErrors),
      _loadStatistics(
        startDateParam: params.startDateParam,
        endDateParam: params.endDateParam,
        showErrors: showErrors,
      ),
      _loadHistory(
        startDateParam: params.startDateParam,
        endDateParam: params.endDateParam,
        showErrors: showErrors,
        reset: true,
      ),
      if (includeRides)
        _loadRidesData(
          startDateParam: params.startDateParam,
          endDateParam: params.endDateParam,
          showErrors: showErrors,
        ),
    ]);

    if (!silent) {
      isLoading.value = false;
    }
  }

  Future<void> startShift() async {
    isStartingShift.value = true;
    final started = await shiftLifecycleCoordinator.startShift(
      onTrackingStatusResolved: (status) => trackingStatus.value = status,
      askToOpenTrackingSettings: _showStartShiftLocationDialog,
      openTrackingSettings: (status, {bool showFollowUpWarning = true}) =>
          _openTrackingSettings(
            status: status,
            showFollowUpWarning: showFollowUpWarning,
          ),
      showSuccess: _showSuccess,
      showError: _showError,
      normalizeErrorMessage: _normalizeErrorMessage,
    );
    if (started) {
      await refreshJourneyData(silent: true);
      await _loadTrackingStatus();
    }
    isStartingShift.value = false;
  }

  Future<void> pauseShift() async {
    isPauseShiftLoading.value = true;
    final completed = await shiftLifecycleCoordinator.pauseOrResumeShift(
      isPaused: isShiftPaused,
      showSuccess: _showSuccess,
      showError: _showError,
      normalizeErrorMessage: _normalizeErrorMessage,
    );
    if (completed) {
      await refreshJourneyData(silent: true, includeRides: false);
      await _loadTrackingStatus();
    }
    isPauseShiftLoading.value = false;
  }

  Future<void> finishShift() async {
    isFinishingShift.value = true;
    final result = await shiftLifecycleCoordinator.finishShift(
      showSuccess: _showSuccess,
      showWarning: _showWarning,
      showError: _showError,
      normalizeErrorMessage: _normalizeErrorMessage,
    );
    if (result != null) {
      await refreshJourneyData(silent: true);
      await _loadTrackingStatus();
    }
    isFinishingShift.value = false;
  }

  Future<void> retryJourneyData() async {
    await refreshJourneyData(showErrors: false);
  }

  Future<void> loadMoreShifts() async {
    if (isLoadingMoreShifts.value || !hasMoreShifts.value) {
      return;
    }

    isLoadingMoreShifts.value = true;
    final params = _buildQueryParams();
    await _loadHistory(
      startDateParam: params.startDateParam,
      endDateParam: params.endDateParam,
      showErrors: false,
      reset: false,
    );
    isLoadingMoreShifts.value = false;
  }

  Future<void> loadMoreRides() async {}

  Future<void> openTrackingSettings() async {
    final status = trackingStatus.value;
    if (status == null) {
      return;
    }

    await _openTrackingSettings(status: status);
  }

  Future<void> _loadActiveShift({required bool showErrors}) async {
    final result = await getActiveShift();
    result.fold(
      (failure) => _handleLoadFailure(
        context: 'turno ativo',
        message: failure.message,
        showErrors: showErrors,
      ),
      (shift) {
        activeShiftError.value = null;
        activeShift.value = shift;
        runtimeCoordinator.accessibilityService.setJourneyActive(shift != null);
        _syncActiveShiftPresentation(shift);
      },
    );
    await _loadTrackingStatus();
  }

  Future<void> _loadStatistics({
    required String? startDateParam,
    required String? endDateParam,
    required bool showErrors,
  }) async {
    final statsResult = await getDailyStatistics(
      filter: selectedFilter.value,
      date: startDateParam,
      endDate: endDateParam,
    );

    statsResult.fold(
      (failure) => _handleLoadFailure(
        context: 'metricas',
        message: failure.message,
        showErrors: showErrors,
      ),
      (stats) {
        metricsError.value = null;
        totalShifts.value = stats.totalShifts.toString();
        _statisticsTotalTimeBaseSeconds =
            JourneyStatisticsDisplayComposer.parseHmsToSeconds(stats.totalTime);
        _statisticsIdleTimeBaseSeconds =
            JourneyStatisticsDisplayComposer.parseHmsToSeconds(stats.idleTime);
        totalShiftDrivenKm.value = stats.totalDrivenKmValue > 0
            ? stats.totalDrivenKmValue
            : JourneyStatisticsDisplayComposer.parseKmLabelToDouble(
                stats.drivenKm,
              );

        totalRides.value = stats.rideStats.totalRides;
        grossEarningsCents.value = stats.rideStats.grossEarningsCents;
        netEarningsCents.value = stats.rideStats.netEarningsCents;
        totalCostsCents.value = stats.rideStats.totalCostsCents;
        ridesTotalKm.value = stats.rideStats.ridesTotalKm;
        ridesTotalTime.value = stats.rideStats.ridesTotalTime;
        _syncDisplayedJourneyMetrics();
      },
    );
  }

  Future<void> _loadCostsGainsSettings({required bool showErrors}) async {
    final useCase = getCostsGainsSettings;
    if (useCase == null) {
      costsGainsSettings.value = null;
      return;
    }

    final result = await useCase();
    result.fold((failure) {
      costsGainsSettings.value = null;
      debugPrint(
        '[JourneyController] Erro ao carregar configuracoes de custos: ${failure.message}',
      );
    }, (settings) => costsGainsSettings.value = settings);
  }

  Future<void> _loadHistory({
    required String? startDateParam,
    required String? endDateParam,
    required bool showErrors,
    required bool reset,
  }) async {
    final historyResult = await getShiftHistory(
      filter: selectedFilter.value,
      date: startDateParam,
      endDate: endDateParam,
      offset: reset ? 0 : shiftsList.length,
      limit: _historyPageSize,
    );

    historyResult.fold(
      (failure) => _handleLoadFailure(
        context: 'historico',
        message: failure.message,
        showErrors: showErrors,
      ),
      (shiftsPage) {
        historyError.value = null;
        if (reset) {
          shiftsList.assignAll(shiftsPage.items);
        } else {
          shiftsList.addAll(shiftsPage.items);
        }
        shiftsCount.value = shiftsList.length;
        shiftsTotalCount.value = shiftsPage.totalCount;
        hasMoreShifts.value = shiftsPage.hasMore;
        pendingShiftSyncCount.value = shiftsList
            .where((shift) => shift.isPendingSync)
            .length;
      },
    );
  }

  Future<void> _loadRidesData({
    required String? startDateParam,
    required String? endDateParam,
    required bool showErrors,
  }) async {
    const limit = 100;
    var offset = 0;
    final allRides = <RideEntity>[];

    while (true) {
      final ridesResult = await getRidesUseCase(
        period: selectedFilter.value,
        date: startDateParam,
        endDate: endDateParam,
        status: null,
        offset: offset,
        limit: limit,
      );

      final shouldContinue = await ridesResult.fold<Future<bool>>(
        (failure) async {
          ridesList.clear();
          ridesHistoryTotalCount.value = 0;
          hasMoreRides.value = false;
          paymentMethodSummary.clear();
          paymentMethodFinishedRidesCount.value = 0;
          _handleLoadFailure(
            context: 'corridas',
            message: failure.message,
            showErrors: showErrors,
          );
          return false;
        },
        (ridesPage) async {
          ridesError.value = null;
          allRides.addAll(ridesPage.items);
          offset += ridesPage.items.length;
          return ridesPage.hasMore && ridesPage.items.isNotEmpty;
        },
      );

      if (!shouldContinue) {
        break;
      }
    }

    if (ridesError.value != null) {
      return;
    }

    ridesList.assignAll(allRides);
    hasMoreRides.value = false;
    ridesHistoryTotalCount.value = filteredRidesCount;
    _rebuildPaymentMethodSummary();
  }

  String? _normalizePaymentMethod(String? paymentMethod) {
    final normalized = paymentMethod?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    switch (normalized) {
      case 'CARD':
      case 'CREDIT_CARD':
      case 'DEBIT_CARD':
      case 'CREDIT_OR_DEBIT_CARD':
        return 'CARD';
      case 'CASH':
      case 'MONEY':
        return 'CASH';
      case 'PIX':
        return 'PIX';
      case 'VOUCHER':
        return 'VOUCHER';
      default:
        return normalized;
    }
  }

  bool _matchesSelectedRideStatus(RideEntity ride) {
    final selectedStatus = _selectedRideStatusQuery;
    if (selectedStatus == null) {
      return true;
    }

    return ride.status.trim().toUpperCase() == selectedStatus;
  }

  void _rebuildPaymentMethodSummary() {
    final counts = <String, int>{};

    for (final ride in ridesList) {
      if (ride.status.trim().toUpperCase() != 'FINISHED') {
        continue;
      }

      final normalizedPaymentMethod = _normalizePaymentMethod(
        ride.paymentMethod,
      );
      if (normalizedPaymentMethod == null) {
        continue;
      }

      counts.update(
        normalizedPaymentMethod,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    paymentMethodFinishedRidesCount.value = ridesList
        .where((ride) => ride.status.trim().toUpperCase() == 'FINISHED')
        .length;
    paymentMethodSummary.assignAll(
      counts.entries
          .map(
            (entry) =>
                PaymentMethodSummaryItem(code: entry.key, count: entry.value),
          )
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count)),
    );
  }

  String? get _selectedRideStatusQuery {
    switch (selectedRideStatusFilter.value) {
      case 'Pendentes':
        return 'PENDING';
      case 'Finalizados':
        return 'FINISHED';
      case 'Cancelados':
        return 'CANCELED';
      default:
        return null;
    }
  }

  ({String? startDateParam, String? endDateParam}) _buildQueryParams() {
    if (selectedFilter.value == 'custom' &&
        customStartDate.value != null &&
        customEndDate.value != null) {
      return (
        startDateParam: customStartDate.value!.toIso8601String(),
        endDateParam: customEndDate.value!.toIso8601String(),
      );
    }

    return (
      startDateParam: selectedDate.value.toIso8601String(),
      endDateParam: null,
    );
  }

  void _syncActiveShiftPresentation(ActiveShiftEntity? shift) {
    if (shift == null) {
      _timer?.cancel();
      elapsedSeconds.value = 0;
      startTimeStr.value = '--:--';
      currentKm.value = 0.0;
      _syncDisplayedJourneyMetrics();
      return;
    }

    startTimeStr.value =
        '${shift.startTime.hour.toString().padLeft(2, '0')}:${shift.startTime.minute.toString().padLeft(2, '0')}';
    currentKm.value = shift.currentDrivenKm;

    if (shift.isPaused) {
      _timer?.cancel();
      final pausedReference = shift.pausedAt ?? DateTime.now();
      elapsedSeconds.value = _computeEffectiveElapsedSeconds(
        startTime: shift.startTime,
        idleTimeSeconds: shift.idleTimeSeconds,
        reference: pausedReference,
      );
      _syncDisplayedJourneyMetrics();
      return;
    }

    _startElapsedTimer(shift.startTime, shift.idleTimeSeconds);
    _syncDisplayedJourneyMetrics();
  }

  void _startElapsedTimer(DateTime startTime, int idleTimeSeconds) {
    _timer?.cancel();
    _updateElapsed(startTime, idleTimeSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed(startTime, idleTimeSeconds);
    });
  }

  void _updateElapsed(DateTime startTime, int idleTimeSeconds) {
    elapsedSeconds.value = _computeEffectiveElapsedSeconds(
      startTime: startTime,
      idleTimeSeconds: idleTimeSeconds,
      reference: DateTime.now(),
    );
  }

  int _computeEffectiveElapsedSeconds({
    required DateTime startTime,
    required int idleTimeSeconds,
    required DateTime reference,
  }) {
    final total = reference.difference(startTime).inSeconds - idleTimeSeconds;
    return total < 0 ? 0 : total;
  }

  Future<void> _handleConnectionStatusChanged(bool isOnlineNow) async {
    if (!isOnlineNow) {
      return;
    }

    final syncedCount = await runtimeCoordinator.syncPendingShifts();
    if (syncedCount > 0) {
      _showSuccess(
        syncedCount == 1
            ? '1 turno pendente foi sincronizado.'
            : '$syncedCount turnos pendentes foram sincronizados.',
      );
    }
    if (syncedCount > 0 || pendingShiftSyncCount.value > 0) {
      await refreshJourneyData(silent: true, showErrors: false);
    }
  }

  Future<void> _loadTrackingStatus() async {
    final status = await runtimeCoordinator.loadTrackingStatus();
    if (status != null) {
      _handleTrackingStatusUpdated(status);
    }
  }

  void _handleLoadFailure({
    required String context,
    required String message,
    required bool showErrors,
  }) {
    final normalizedMessage = _normalizeErrorMessage(message);

    switch (context) {
      case 'turno ativo':
        activeShiftError.value =
            'Nao foi possivel atualizar o turno atual. $normalizedMessage';
        break;
      case 'metricas':
        metricsError.value =
            'Nao foi possivel carregar as metricas. $normalizedMessage';
        break;
      case 'historico':
        historyError.value =
            'Nao foi possivel carregar o historico de turnos. $normalizedMessage';
        break;
      case 'corridas':
        ridesError.value =
            'Nao foi possivel carregar as corridas. $normalizedMessage';
        break;
    }

    if (showErrors) {
      _showError('Erro', normalizedMessage);
      return;
    }

    debugPrint(
      '[JourneyController] Erro ao carregar $context: $normalizedMessage',
    );
  }

  void _handleTrackingStatusUpdated(LocationTrackingStatusEntity status) {
    final now = DateTime.now();
    final shouldRefreshDistanceUi =
        _lastTrackingUiRefreshAt == null ||
        _lastTrackingUiDistanceMeters == null ||
        (status.totalDistanceMeters - _lastTrackingUiDistanceMeters!).abs() >=
            100 ||
        now.difference(_lastTrackingUiRefreshAt!) >=
            const Duration(seconds: 15);

    final previousStatus = trackingStatus.value;
    final shouldRefreshStatusUi =
        previousStatus == null ||
        previousStatus.issueMessage != status.issueMessage ||
        previousStatus.isTrackingActive != status.isTrackingActive ||
        previousStatus.isPaused != status.isPaused ||
        previousStatus.idleTimeSeconds != status.idleTimeSeconds ||
        previousStatus.isLocationServiceEnabled !=
            status.isLocationServiceEnabled ||
        previousStatus.hasForegroundPermission !=
            status.hasForegroundPermission ||
        previousStatus.hasBackgroundPermission !=
            status.hasBackgroundPermission ||
        previousStatus.isPreciseLocation != status.isPreciseLocation;

    if (shouldRefreshStatusUi || shouldRefreshDistanceUi) {
      trackingStatus.value = status;
      _lastTrackingUiRefreshAt = now;
      _lastTrackingUiDistanceMeters = status.totalDistanceMeters;
    }

    if (!hasActiveShift) {
      return;
    }

    final trackedKm = status.totalDistanceMeters / 1000;
    if (shouldRefreshDistanceUi || shouldRefreshStatusUi) {
      currentKm.value = trackedKm;
    }

    final shift = activeShift.value;
    if (shift != null && (shouldRefreshDistanceUi || shouldRefreshStatusUi)) {
      final didIdleTimeChange = shift.idleTimeSeconds != status.idleTimeSeconds;
      activeShift.value = shift.copyWith(
        currentDrivenKm: trackedKm,
        idleTimeSeconds: status.idleTimeSeconds,
      );
      if (didIdleTimeChange && !shift.isPaused) {
        _startElapsedTimer(shift.startTime, status.idleTimeSeconds);
      }
      _syncDisplayedJourneyMetrics();
    }
  }

  void _syncDisplayedJourneyMetrics() {
    final displayData = JourneyStatisticsDisplayComposer.compose(
      baseTotalTimeSeconds: _statisticsTotalTimeBaseSeconds,
      baseIdleTimeSeconds: _statisticsIdleTimeBaseSeconds,
      baseDrivenKm: totalShiftDrivenKm.value,
      shiftsCount: int.tryParse(totalShifts.value) ?? 0,
      activeIdleSeconds: _selectedRangeIncludesNow && hasActiveShift
          ? activeShift.value?.idleTimeSeconds ?? 0
          : 0,
      liveElapsedSeconds: _statisticsLiveElapsedSeconds,
      liveDrivenKm: currentKm.value.floorToDouble(),
      includeLiveTime: _shouldUseLiveJourneyTime,
      includeLiveKm: _shouldUseLiveJourneyKm,
    );

    totalTime.value = displayData.totalTime;
    averageTime.value = displayData.averageTime;
    idleTime.value = displayData.idleTime;
    drivenKm.value = displayData.drivenKm;
    averageKmh.value = displayData.averageKmh;
  }

  String _normalizeErrorMessage(String message) {
    final normalized = message.trim();
    final lower = normalized.toLowerCase();

    if (lower.contains('socketexception') ||
        lower.contains('connection error') ||
        lower.contains('connection timed out') ||
        lower.contains('connection aborted') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable')) {
      return 'Verifique sua conexao e tente novamente.';
    }

    if (lower.contains('timeout')) {
      return 'O servidor demorou para responder. Tente novamente em instantes.';
    }

    if (normalized.isEmpty) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }

    return normalized;
  }

  double _selectedPeriodWorkDays(CostsGainsSettingsEntity settings) {
    final totalDays = _selectedPeriodDayCount;
    if (totalDays <= 0 || settings.workDaysPerWeek <= 0) {
      return 0;
    }

    if (selectedFilter.value == 'day') {
      return 1;
    }

    return totalDays * (settings.workDaysPerWeek / 7);
  }

  List<OperationalCostBreakdownItem> _operationalFixedCostItems(
    CostsGainsSettingsEntity settings,
  ) {
    final items = <OperationalCostBreakdownItem>[
      OperationalCostBreakdownItem(
        label: 'Prestação/Aluguel',
        amountCents: _diluteMonthlyCostForSelectedPeriod(
          monthlyCostCents: settings.financeOrRentMonthlyCents,
          settings: settings,
        ),
      ),
      OperationalCostBreakdownItem(
        label: 'Seguro',
        amountCents: _diluteMonthlyCostForSelectedPeriod(
          monthlyCostCents: settings.insuranceMonthlyCents,
          settings: settings,
        ),
      ),
      OperationalCostBreakdownItem(
        label: 'Manutenção',
        amountCents: _diluteMonthlyCostForSelectedPeriod(
          monthlyCostCents: settings.maintenanceMonthlyCents,
          settings: settings,
        ),
      ),
      OperationalCostBreakdownItem(
        label: 'Impostos',
        amountCents: _diluteMonthlyCostForSelectedPeriod(
          monthlyCostCents: (settings.annualTaxesCents / 12).round(),
          settings: settings,
        ),
      ),
    ];

    if (settings.platformFeeType == PlatformFeeType.fixed &&
        settings.platformFeeValue > 0) {
      items.add(
        OperationalCostBreakdownItem(
          label: 'Taxa Fixa Plataforma',
          amountCents: _diluteMonthlyCostForSelectedPeriod(
            monthlyCostCents: (settings.platformFeeValue * 100).round(),
            settings: settings,
          ),
        ),
      );
    }

    return items.where((item) => item.amountCents > 0).toList();
  }

  int _diluteMonthlyCostForSelectedPeriod({
    required int monthlyCostCents,
    required CostsGainsSettingsEntity settings,
  }) {
    if (monthlyCostCents <= 0) {
      return 0;
    }

    final monthlyWorkDays = settings.workDaysPerWeek * 4.33;
    if (monthlyWorkDays <= 0) {
      return 0;
    }

    final fixedCostPerWorkDayCents = monthlyCostCents / monthlyWorkDays;
    return (fixedCostPerWorkDayCents * _selectedPeriodWorkDays(settings))
        .round();
  }

  int get _selectedPeriodDayCount {
    final range = _selectedRange;
    return range.endExclusive.difference(range.start).inDays;
  }

  bool get _selectedRangeIncludesNow {
    final now = DateTime.now();
    final range = _selectedRange;
    return !now.isBefore(range.start) && now.isBefore(range.endExclusive);
  }

  bool get _shouldUseLiveJourneyKm =>
      hasActiveShift && _selectedRangeIncludesNow;

  bool get _shouldUseLiveJourneyTime =>
      hasActiveShift && _selectedRangeIncludesNow;

  int get _statisticsLiveElapsedSeconds => (elapsedSeconds.value ~/ 30) * 30;

  ({DateTime start, DateTime endExclusive}) get _selectedRange {
    DateTime startOfDay(DateTime value) =>
        DateTime(value.year, value.month, value.day);

    if (selectedFilter.value == 'custom' &&
        customStartDate.value != null &&
        customEndDate.value != null) {
      final start = startOfDay(customStartDate.value!);
      final endExclusive = startOfDay(
        customEndDate.value!,
      ).add(const Duration(days: 1));
      return (start: start, endExclusive: endExclusive);
    }

    final date = selectedDate.value;

    switch (selectedFilter.value) {
      case 'week':
        final start = startOfDay(
          date.subtract(Duration(days: date.weekday - 1)),
        );
        return (start: start, endExclusive: start.add(const Duration(days: 7)));
      case 'month':
        final start = DateTime(date.year, date.month);
        return (
          start: start,
          endExclusive: DateTime(date.year, date.month + 1),
        );
      case 'year':
        final start = DateTime(date.year);
        return (start: start, endExclusive: DateTime(date.year + 1));
      case 'day':
      default:
        final start = startOfDay(date);
        return (start: start, endExclusive: start.add(const Duration(days: 1)));
    }
  }

  Future<bool?> _showStartShiftLocationDialog(
    LocationTrackingStatusEntity status,
  ) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(_locationDialogTitle(status)),
        content: Text(_locationDialogMessage(status)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Agora nao'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(_locationDialogConfirmLabel(status)),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  String _locationDialogTitle(LocationTrackingStatusEntity status) {
    if (!status.isLocationServiceEnabled) {
      return 'Ativar localizacao';
    }

    if (!status.hasBackgroundPermission) {
      return 'Permitir o tempo todo';
    }

    if (!status.hasForegroundPermission) {
      return 'Liberar localizacao';
    }

    if (!status.isPreciseLocation) {
      return 'Ativar localizacao precisa';
    }

    return 'Revisar localizacao';
  }

  String _locationDialogMessage(LocationTrackingStatusEntity status) {
    if (!status.isLocationServiceEnabled) {
      return 'Para iniciar o turno, ative o GPS do aparelho. O rastreamento da jornada depende da localizacao ligada durante todo o turno.';
    }

    if (!status.hasBackgroundPermission) {
      return 'Para iniciar o turno, abra as configuracoes do app e marque a localizacao como "Permitir o tempo todo". Assim a jornada continua sendo rastreada mesmo com o app fechado.';
    }

    if (!status.hasForegroundPermission) {
      return 'Para iniciar o turno, libere a localizacao do app nas configuracoes e volte para tentar novamente.';
    }

    if (!status.isPreciseLocation) {
      return 'Para iniciar o turno, troque a localizacao aproximada para precisa nas configuracoes do app.';
    }

    return 'Revise as configuracoes de localizacao antes de iniciar o turno.';
  }

  String _locationDialogConfirmLabel(LocationTrackingStatusEntity status) {
    if (!status.isLocationServiceEnabled) {
      return 'Ir para GPS';
    }

    return 'Ir para config';
  }

  Future<void> _openTrackingSettings({
    required LocationTrackingStatusEntity status,
    bool showFollowUpWarning = true,
  }) async {
    final opened = !status.isLocationServiceEnabled
        ? await Geolocator.openLocationSettings()
        : await Geolocator.openAppSettings();

    if (!opened) {
      _showWarning(
        'Nao foi possivel abrir os ajustes',
        'Abra manualmente as configuracoes do app e revise permissao de localizacao, GPS e localizacao precisa.',
      );
      return;
    }

    if (!showFollowUpWarning) {
      return;
    }

    _showWarning(
      'Revise a localizacao',
      !status.isLocationServiceEnabled
          ? 'Ative o GPS do aparelho e volte para continuar o turno.'
          : 'Marque "Permitir o tempo todo" e mantenha a localizacao precisa ativada.',
    );
  }

  void _showSuccess(String message) {
    _showSnackbar(
      title: 'Sucesso',
      message: message,
      backgroundColor: const Color(0xFF03A696),
    );
  }

  void _showWarning(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.orangeAccent,
    );
  }

  void _showError(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.redAccent,
    );
  }

  void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    AppSnackbar.show(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
    );
  }

  Future<void> toggleTrafficLight() async {
    if (runtimeCoordinator.accessibilityService.isServiceEnabled.value) {
      isTrafficLightActive.value = !isTrafficLightActive.value;
      await runtimeCoordinator.accessibilityService.setTrafficLightActive(
        isTrafficLightActive.value,
      );
      if (!isTrafficLightActive.value) {
        isWaitingAccessibilityActivation.value = false;
      }
      return;
    }

    if (isTrafficLightActive.value) {
      isTrafficLightActive.value = false;
      isWaitingAccessibilityActivation.value = false;
      await runtimeCoordinator.accessibilityService.setTrafficLightActive(
        false,
      );
      return;
    }

    final shouldOpenSettings = await _showAccessibilityDialog();
    if (shouldOpenSettings == true) {
      isWaitingAccessibilityActivation.value = true;
      await runtimeCoordinator.accessibilityService
          .requestAccessibilityPermission();
    }
  }

  void _handleAccessibilityStatusChanged(bool isEnabled) {
    if (isEnabled && isWaitingAccessibilityActivation.value) {
      isTrafficLightActive.value = true;
      isWaitingAccessibilityActivation.value = false;
      runtimeCoordinator.accessibilityService.setTrafficLightActive(true);
      AppSnackbar.show(
        'Semaforo ativado',
        'A acessibilidade foi habilitada e o semaforo ja esta pronto para uso.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isEnabled &&
        runtimeCoordinator.accessibilityService.persistedTrafficLightActive) {
      isTrafficLightActive.value = true;
    }
  }

  Future<bool?> _showAccessibilityDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Ativar acessibilidade'),
        content: const Text(
          'Para ativar o semaforo, habilite o servico de acessibilidade nas configuracoes do Android.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ir para config'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void activateTrafficLight() {
    toggleTrafficLight();
  }

  Future<void> toggleAssistant() async {
    if (isAssistantBusy.value) return;
    await runtimeCoordinator.toggleAssistant(
      isAssistantActive: isAssistantActive.value,
      onAssistantStateChanged: (isActive) => isAssistantActive.value = isActive,
      onBusyStateChanged: (isBusy) => isAssistantBusy.value = isBusy,
      showSuccess: (title, message) => _showSnackbar(
        title: title,
        message: message,
        backgroundColor: const Color(0xFF03A696),
      ),
      showWarning: (title, message) => _showSnackbar(
        title: title,
        message: message,
        backgroundColor: Colors.orangeAccent,
      ),
      showError: (title, message) => _showSnackbar(
        title: title,
        message: message,
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

class OperationalCostBreakdownItem {
  const OperationalCostBreakdownItem({
    required this.label,
    required this.amountCents,
  });

  final String label;
  final int amountCents;
}

class JourneyHistorySectionState {
  const JourneyHistorySectionState({
    required this.shifts,
    required this.totalCount,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
  });

  final List<ShiftEntity> shifts;
  final int totalCount;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  int get loadedCount => shifts.length;
  bool get isEmpty => shifts.isEmpty;
}

class JourneyRidesSectionState {
  const JourneyRidesSectionState({
    required this.selectedStatusFilter,
    required this.visibleRides,
    required this.totalVisibleCount,
    required this.periodLabel,
    required this.isLoadingMore,
    required this.errorMessage,
  });

  final String selectedStatusFilter;
  final List<RideEntity> visibleRides;
  final int totalVisibleCount;
  final String periodLabel;
  final bool isLoadingMore;
  final String? errorMessage;

  int get visibleCount => visibleRides.length;
  bool get isEmpty => visibleRides.isEmpty;
}

class JourneyPaymentMethodsSectionState {
  const JourneyPaymentMethodsSectionState({
    required this.items,
    required this.totalFinishedRides,
    required this.mappedCount,
    required this.isExpanded,
  });

  final List<PaymentMethodSummaryItem> items;
  final int totalFinishedRides;
  final int mappedCount;
  final bool isExpanded;

  int get unmappedCount => totalFinishedRides - mappedCount;
  bool get hasUnmappedRides => unmappedCount > 0;
}

class JourneyOperationalSummaryData {
  const JourneyOperationalSummaryData({
    required this.netEarningsCents,
    required this.grossEarningsCents,
    required this.totalCostsCents,
    required this.totalRides,
    required this.margin,
    required this.isCostBreakdownExpanded,
  });

  final int netEarningsCents;
  final int grossEarningsCents;
  final int totalCostsCents;
  final int totalRides;
  final double margin;
  final bool isCostBreakdownExpanded;

  bool get isPositive => netEarningsCents >= 0;
}

class JourneyOperationalCostBreakdownData {
  const JourneyOperationalCostBreakdownData({
    required this.variableCostsCents,
    required this.fixedCostsCents,
    required this.variableItems,
    required this.fixedItems,
  });

  final int variableCostsCents;
  final int fixedCostsCents;
  final List<OperationalCostBreakdownItem> variableItems;
  final List<OperationalCostBreakdownItem> fixedItems;
}

class PaymentMethodSummaryItem {
  const PaymentMethodSummaryItem({required this.code, required this.count});

  final String code;
  final int count;
}
