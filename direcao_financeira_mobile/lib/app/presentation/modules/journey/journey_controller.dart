import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/accessibility/accessibility_service.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/network/journey_realtime_bridge.dart';
import '../../../domain/entities/active_shift_entity.dart';
import '../../../domain/entities/location_tracking_status_entity.dart';
import '../../../domain/entities/ride_entity.dart';
import '../../../domain/entities/shift_entity.dart';
import '../../../domain/usecases/get_rides_usecase.dart';
import '../../../domain/usecases/journey_use_cases.dart';

class JourneyController extends GetxController {
  final GetActiveShiftUseCase getActiveShift;
  final GetDailyStatisticsUseCase getDailyStatistics;
  final GetShiftHistoryUseCase getShiftHistory;
  final StartShiftUseCase startShiftUseCase;
  final PauseShiftUseCase pauseShiftUseCase;
  final ResumeShiftUseCase resumeShiftUseCase;
  final FinishShiftUseCase finishShiftUseCase;
  final SyncPendingJourneyUseCase syncPendingJourneyUseCase;
  final EnsureReadyForShiftStartUseCase ensureReadyForShiftStartUseCase;
  final GetLocationTrackingStatusUseCase getLocationTrackingStatusUseCase;
  final WatchLocationTrackingStatusUseCase watchLocationTrackingStatusUseCase;
  final GetRidesUseCase getRidesUseCase;
  final JourneyRealtimeBridge journeyRealtimeBridge;
  final AccessibilityService accessibilityService;

  JourneyController({
    required this.getActiveShift,
    required this.getDailyStatistics,
    required this.getShiftHistory,
    required this.startShiftUseCase,
    required this.pauseShiftUseCase,
    required this.resumeShiftUseCase,
    required this.finishShiftUseCase,
    required this.syncPendingJourneyUseCase,
    required this.ensureReadyForShiftStartUseCase,
    required this.getLocationTrackingStatusUseCase,
    required this.watchLocationTrackingStatusUseCase,
    required this.getRidesUseCase,
    required this.journeyRealtimeBridge,
    required this.accessibilityService,
  });

  final isLoading = false.obs;
  final isStartingShift = false.obs;
  final isPauseShiftLoading = false.obs;
  final isFinishingShift = false.obs;
  final selectedFilter = 'day'.obs; // day, week, month, year, custom
  final customStartDate = Rxn<DateTime>();
  final customEndDate = Rxn<DateTime>();
  final activeShift = Rxn<ActiveShiftEntity>();
  final activeShiftError = RxnString();
  final metricsError = RxnString();
  final historyError = RxnString();
  final ridesError = RxnString();

  Timer? _timer;
  Worker? _accessibilityWorker;
  Worker? _connectionWorker;
  StreamSubscription<LocationTrackingStatusEntity>? _trackingStatusSubscription;
  final elapsedSeconds = 0.obs;
  final startTimeStr = '--:--'.obs;
  final currentKm = 0.0.obs;
  final isWaitingAccessibilityActivation = false.obs;
  final pendingShiftSyncCount = 0.obs;
  final trackingStatus = Rxn<LocationTrackingStatusEntity>();

  String get formattedElapsed {
    final hours = elapsedSeconds.value ~/ 3600;
    final minutes = (elapsedSeconds.value % 3600) ~/ 60;
    final seconds = elapsedSeconds.value % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  final ridesList = <RideEntity>[].obs;
  final selectedRideStatusFilter = 'Todos'.obs;

  List<RideEntity> get filteredRidesList {
    if (selectedRideStatusFilter.value == 'Todos') {
      return ridesList;
    }

    if (selectedRideStatusFilter.value == 'Pendentes') {
      return ridesList.where((ride) => ride.status == 'PENDING').toList();
    }

    if (selectedRideStatusFilter.value == 'Cancelados') {
      return ridesList
          .where(
            (ride) => ride.status == 'CANCELED' || ride.status == 'CANCELLED',
          )
          .toList();
    }

    return ridesList.where((ride) => ride.status == 'FINISHED').toList();
  }

  void changeRideStatusFilter(String filter) {
    selectedRideStatusFilter.value = filter;
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

  final shiftsCount = 0.obs;
  final shiftsList = <ShiftEntity>[].obs;

  final selectedDate = DateTime.now().obs;
  final isTrafficLightActive = false.obs;

  bool get hasActiveShift => activeShift.value != null;
  bool get isAccessibilityServiceEnabled =>
      accessibilityService.isServiceEnabled.value;
  String get status => hasActiveShift ? 'Ativo' : 'Inativo';
  bool get isOnline => journeyRealtimeBridge.isOnline.value;
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

  @override
  void onInit() {
    super.onInit();
    isTrafficLightActive.value =
        accessibilityService.persistedTrafficLightActive;
    _accessibilityWorker = ever<bool>(
      accessibilityService.isServiceEnabled,
      _handleAccessibilityStatusChanged,
    );
    _connectionWorker = ever<bool>(
      journeyRealtimeBridge.isOnline,
      _handleConnectionStatusChanged,
    );
    _trackingStatusSubscription = watchLocationTrackingStatusUseCase().listen(
      _handleTrackingStatusUpdated,
    );
    journeyRealtimeBridge.bind(
      onRideChanged: () {
        refreshJourneyData(silent: true, showErrors: false);
      },
    );
    refreshJourneyData(showErrors: false);
    _loadTrackingStatus();
  }

  @override
  void onClose() {
    journeyRealtimeBridge.unbind();
    _timer?.cancel();
    _accessibilityWorker?.dispose();
    _connectionWorker?.dispose();
    _trackingStatusSubscription?.cancel();
    super.onClose();
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
      _loadStatistics(
        startDateParam: params.startDateParam,
        endDateParam: params.endDateParam,
        showErrors: showErrors,
      ),
      _loadHistory(
        startDateParam: params.startDateParam,
        endDateParam: params.endDateParam,
        showErrors: showErrors,
      ),
      if (includeRides)
        _loadRides(
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

    final isLocationReady = await _ensureLocationReadyForShiftStart();
    if (!isLocationReady) {
      isStartingShift.value = false;
      return;
    }

    final result = await startShiftUseCase();
    result.fold(
      (failure) => _showActionError('iniciar o turno', failure.message),
      (_) async {
        _showSuccess('Turno iniciado com sucesso.');
        await refreshJourneyData(silent: true);
        await _loadTrackingStatus();
      },
    );
    isStartingShift.value = false;
  }

  Future<void> pauseShift() async {
    await _togglePauseResumeShift();
  }

  Future<void> finishShift() async {
    isFinishingShift.value = true;
    final result = await finishShiftUseCase();
    result.fold((failure) => _showActionError('parar o turno', failure.message), (
      finishResult,
    ) async {
      if (finishResult.synced) {
        _showSuccess('Turno finalizado e sincronizado com sucesso.');
      } else {
        _showWarning(
          'Turno salvo no aparelho',
          'O turno foi finalizado localmente e sera sincronizado quando a internet voltar.',
        );
      }
      await refreshJourneyData(silent: true);
      await _loadTrackingStatus();
    });
    isFinishingShift.value = false;
  }

  Future<void> retryJourneyData() async {
    await refreshJourneyData(showErrors: false);
  }

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
        accessibilityService.setJourneyActive(shift != null);
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
        totalTime.value = stats.totalTime;
        averageTime.value = stats.averageTime;
        idleTime.value = stats.idleTime;
        drivenKm.value = stats.drivenKm;
        averageKmh.value = stats.averageKmh;

        totalRides.value = stats.rideStats.totalRides;
        grossEarningsCents.value = stats.rideStats.grossEarningsCents;
        netEarningsCents.value = stats.rideStats.netEarningsCents;
        totalCostsCents.value = stats.rideStats.totalCostsCents;
        ridesTotalKm.value = stats.rideStats.ridesTotalKm;
        ridesTotalTime.value = stats.rideStats.ridesTotalTime;
      },
    );
  }

  Future<void> _loadHistory({
    required String? startDateParam,
    required String? endDateParam,
    required bool showErrors,
  }) async {
    final historyResult = await getShiftHistory(
      filter: selectedFilter.value,
      date: startDateParam,
      endDate: endDateParam,
    );

    historyResult.fold(
      (failure) => _handleLoadFailure(
        context: 'historico',
        message: failure.message,
        showErrors: showErrors,
      ),
      (shifts) {
        historyError.value = null;
        shiftsList.assignAll(shifts);
        shiftsCount.value = shifts.length;
        pendingShiftSyncCount.value = shifts
            .where((shift) => shift.isPendingSync)
            .length;
      },
    );
  }

  Future<void> _loadRides({
    required String? startDateParam,
    required String? endDateParam,
    required bool showErrors,
  }) async {
    final ridesResult = await getRidesUseCase(
      period: selectedFilter.value,
      date: startDateParam,
      endDate: endDateParam,
    );

    ridesResult.fold(
      (failure) => _handleLoadFailure(
        context: 'corridas',
        message: failure.message,
        showErrors: showErrors,
      ),
      (rides) {
        ridesError.value = null;
        ridesList.assignAll(rides);
      },
    );
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
      return;
    }

    _startElapsedTimer(shift.startTime, shift.idleTimeSeconds);
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

  Future<void> _togglePauseResumeShift() async {
    isPauseShiftLoading.value = true;
    final isPaused = isShiftPaused;
    final result = isPaused
        ? await resumeShiftUseCase()
        : await pauseShiftUseCase();

    result.fold(
      (failure) => _showActionError(
        isPaused ? 'retomar o turno' : 'pausar o turno',
        failure.message,
      ),
      (_) async {
        _showSuccess(
          isPaused
              ? 'Turno retomado com sucesso.'
              : 'Turno pausado com sucesso.',
        );
        await refreshJourneyData(silent: true, includeRides: false);
        await _loadTrackingStatus();
      },
    );

    isPauseShiftLoading.value = false;
  }

  Future<void> _handleConnectionStatusChanged(bool isOnlineNow) async {
    if (!isOnlineNow) {
      return;
    }

    final syncedCount = await _syncPendingShifts(showFeedback: true);
    if (syncedCount > 0 || pendingShiftSyncCount.value > 0) {
      await refreshJourneyData(silent: true, showErrors: false);
    }
  }

  Future<void> _loadTrackingStatus() async {
    final result = await getLocationTrackingStatusUseCase();
    result.fold((_) {}, _handleTrackingStatusUpdated);
  }

  Future<bool> _ensureLocationReadyForShiftStart() async {
    String? failureMessage;
    LocationTrackingStatusEntity? status;

    final result = await ensureReadyForShiftStartUseCase();
    result.fold(
      (failure) => failureMessage = failure.message,
      (resolvedStatus) => status = resolvedStatus,
    );

    if (failureMessage != null) {
      _showActionError('validar a localizacao', failureMessage!);
      return false;
    }

    if (status == null) {
      _showError(
        'Erro',
        'Nao foi possivel validar a localizacao para iniciar o turno.',
      );
      return false;
    }

    trackingStatus.value = status;
    if (status!.canTrackFully) {
      return true;
    }

    final shouldOpenSettings = await _showStartShiftLocationDialog(status!);
    if (shouldOpenSettings == true) {
      await _openTrackingSettings(status: status!, showFollowUpWarning: false);
    }

    return false;
  }

  Future<int> _syncPendingShifts({required bool showFeedback}) async {
    final result = await syncPendingJourneyUseCase();
    return result.fold(
      (failure) {
        debugPrint(
          '[JourneyController] Falha ao sincronizar turnos pendentes: ${failure.message}',
        );
        return 0;
      },
      (syncedCount) {
        if (syncedCount > 0 && showFeedback) {
          _showSuccess(
            syncedCount == 1
                ? '1 turno pendente foi sincronizado.'
                : '$syncedCount turnos pendentes foram sincronizados.',
          );
        }
        return syncedCount;
      },
    );
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
    trackingStatus.value = status;

    if (!hasActiveShift) {
      return;
    }

    final trackedKm = status.totalDistanceMeters / 1000;
    currentKm.value = trackedKm;

    final shift = activeShift.value;
    if (shift != null) {
      activeShift.value = shift.copyWith(currentDrivenKm: trackedKm);
    }
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

  void _showActionError(String action, String message) {
    _showError('Nao foi possivel $action', _normalizeErrorMessage(message));
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
    if (accessibilityService.isServiceEnabled.value) {
      isTrafficLightActive.value = !isTrafficLightActive.value;
      await accessibilityService.setTrafficLightActive(
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
      await accessibilityService.setTrafficLightActive(false);
      return;
    }

    final shouldOpenSettings = await _showAccessibilityDialog();
    if (shouldOpenSettings == true) {
      isWaitingAccessibilityActivation.value = true;
      await accessibilityService.requestAccessibilityPermission();
    }
  }

  void _handleAccessibilityStatusChanged(bool isEnabled) {
    if (isEnabled && isWaitingAccessibilityActivation.value) {
      isTrafficLightActive.value = true;
      isWaitingAccessibilityActivation.value = false;
      accessibilityService.setTrafficLightActive(true);
      AppSnackbar.show(
        'Semaforo ativado',
        'A acessibilidade foi habilitada e o semaforo ja esta pronto para uso.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isEnabled && accessibilityService.persistedTrafficLightActive) {
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
}
