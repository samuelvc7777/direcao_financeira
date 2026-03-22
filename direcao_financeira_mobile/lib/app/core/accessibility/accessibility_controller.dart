import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../domain/entities/detected_ride_draft_entity.dart';
import '../../domain/usecases/create_detected_ride_usecase.dart';
import 'accessibility_service.dart';

class AccessibilityController extends GetxController
    with WidgetsBindingObserver
    implements AccessibilityService {
  AccessibilityController({required this.storage});

  static const _platform = MethodChannel(
    'com.direcao_financeira/accessibility',
  );
  static const _trafficLightActiveKey = 'traffic_light_active';
  static const _journeyActiveShiftKey = 'journey_local_active_shift';

  final GetStorage storage;
  final lastRaceData = <String, dynamic>{}.obs;
  @override
  final isServiceEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initChannel();
    checkServiceStatus();
    syncSettingsWithNative();
    syncRuntimeStateWithNative();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshServiceStatus();
    }
  }

  void _initChannel() {
    _platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onRaceDetected':
          _handleRaceDetected(call.arguments);
          break;
        default:
          developer.log('Metodo nao implementado: ${call.method}');
      }
    });
  }

  @override
  Future<void> syncSettingsWithNative() async {
    try {
      final storedSettings = storage.read('traffic_light_settings');
      final settingsMap = storedSettings is Map
          ? Map<String, dynamic>.from(storedSettings)
          : <String, dynamic>{};

      final settings = {
        'position': settingsMap['position'] ?? storage.read('tl_position') ?? 0,
        'theme': settingsMap['theme'] ?? storage.read('tl_theme') ?? 1,
        'font_size':
            settingsMap['fontSize'] ?? storage.read('tl_font_size') ?? 15.0,
        'opacity':
            settingsMap['opacity'] ?? storage.read('tl_opacity') ?? 100.0,
        'duration':
            settingsMap['cardDuration'] ?? storage.read('tl_duration') ?? 10.0,
        'color_blind':
            settingsMap['colorBlindMode'] ??
            storage.read('tl_color_blind') ??
            false,
        'indicators': _normalizeIndicators(
          settingsMap['indicators'] ?? storage.read('tl_indicators'),
        ),
      };
      await _platform.invokeMethod('updateSettings', settings);
    } catch (e) {
      developer.log('Erro ao sincronizar configuracoes com o nativo: $e');
    }
  }

  @override
  bool get persistedTrafficLightActive {
    try {
      return storage.read(_trafficLightActiveKey) == true;
    } catch (_) {
      return false;
    }
  }

  bool get persistedJourneyActive {
    try {
      final raw = storage.read(_journeyActiveShiftKey);
      return raw is Map;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncRuntimeStateWithNative() async {
    await updateRuntimeState(
      trafficLightActive: persistedTrafficLightActive,
      journeyActive: persistedJourneyActive,
    );
  }

  @override
  Future<void> setTrafficLightActive(bool isActive) async {
    try {
      await storage.write(_trafficLightActiveKey, isActive);
      await updateRuntimeState(trafficLightActive: isActive);
    } catch (e) {
      developer.log('Erro ao persistir estado do semaforo: $e');
    }
  }

  @override
  Future<void> setJourneyActive(bool isActive) async {
    await updateRuntimeState(journeyActive: isActive);
  }

  Future<void> updateRuntimeState({
    bool? trafficLightActive,
    bool? journeyActive,
  }) async {
    try {
      final payload = <String, dynamic>{};

      if (trafficLightActive != null) {
        payload['traffic_light_active'] = trafficLightActive;
      }

      if (journeyActive != null) {
        payload['journey_active'] = journeyActive;
      }

      await _platform.invokeMethod('updateRuntimeState', payload);
    } on PlatformException catch (e) {
      developer.log("Erro ao atualizar estado runtime nativo: '${e.message}'.");
    }
  }

  Map<String, bool> _normalizeIndicators(dynamic rawIndicators) {
    if (rawIndicators is Map) {
      return rawIndicators.map(
        (key, value) => MapEntry(key.toString(), value == true),
      );
    }

    return {'R\$/Km': true, 'R\$/Hora': true, 'Lucro/H': true, 'Nota': true};
  }

  Future<void> _handleRaceDetected(dynamic arguments) async {
    if (arguments is Map) {
      final data = Map<String, dynamic>.from(arguments);
      lastRaceData.value = data;

      developer.log('Corrida detectada pelo Accessibility Service: $data');
      await _persistDetectedRide(data);
    }
  }

  Future<void> _persistDetectedRide(Map<String, dynamic> data) async {
    if (!Get.isRegistered<CreateDetectedRideUseCase>()) {
      return;
    }

    final ride = _mapDetectedRide(data);
    if (ride == null) {
      return;
    }

    final result = await Get.find<CreateDetectedRideUseCase>()(ride);
    result.fold(
      (failure) => developer.log(
        'Erro ao salvar corrida detectada no Supabase: ${failure.message}',
      ),
      (_) => developer.log('Corrida detectada salva como PENDING.'),
    );
  }

  DetectedRideDraftEntity? _mapDetectedRide(Map<String, dynamic> data) {
    final grossValueCents = _parseCurrencyToCents(data['valor_bruto']);
    final totalKm = _toDouble(data['km_total']);
    final totalMinutes = _toInt(data['minutos_total']);

    if (grossValueCents <= 0 || (totalKm <= 0 && totalMinutes <= 0)) {
      return null;
    }

    return DetectedRideDraftEntity(
      paymentMethod: _mapPaymentMethod(data['forma_pagamento']),
      grossValueCents: grossValueCents,
      netProfitCents: 0,
      totalKm: totalKm,
      totalTimeSeconds: totalMinutes * 60,
      passengerName: _resolvePassengerName(data),
      originAddress: null,
      destinationAddress: null,
    );
  }

  int _parseCurrencyToCents(dynamic rawValue) {
    final text = rawValue?.toString().trim() ?? '';
    if (text.isEmpty) {
      return 0;
    }

    final normalized = text
        .replaceAll(RegExp(r'[^0-9,\.]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final value = double.tryParse(normalized) ?? 0.0;
    return (value * 100).round();
  }

  double _toDouble(dynamic rawValue) {
    if (rawValue is num) {
      return rawValue.toDouble();
    }

    final text = rawValue?.toString().trim().replaceAll(',', '.') ?? '';
    return double.tryParse(text) ?? 0.0;
  }

  int _toInt(dynamic rawValue) {
    if (rawValue is int) {
      return rawValue;
    }

    if (rawValue is num) {
      return rawValue.round();
    }

    final text = rawValue?.toString().trim().replaceAll(',', '.') ?? '';
    return double.tryParse(text)?.round() ?? 0;
  }

  String _mapPaymentMethod(dynamic rawValue) {
    final normalized = rawValue?.toString().trim().toLowerCase() ?? '';

    if (normalized.contains('pix')) {
      return 'PIX';
    }
    if (normalized.contains('dinheiro') || normalized.contains('cash')) {
      return 'CASH';
    }
    if (normalized.contains('cart')) {
      return 'CARD';
    }

    return 'APP';
  }

  String? _resolvePassengerName(Map<String, dynamic> data) {
    final profile = data['perfil_passageiro']?.toString().trim();
    if (profile != null && profile.isNotEmpty) {
      return profile;
    }

    final driver = data['motorista']?.toString().trim();
    if (driver == null || driver.isEmpty) {
      return null;
    }

    final lower = driver.toLowerCase();
    if (lower == '99' || lower == 'movesj' || lower == 'motorista') {
      return null;
    }

    return driver;
  }

  Future<void> checkServiceStatus() async {
    try {
      final enabled = await _platform.invokeMethod<bool>('isServiceEnabled');
      isServiceEnabled.value = enabled ?? false;
    } on PlatformException catch (e) {
      developer.log("Erro ao verificar status do servico: '${e.message}'.");
    }
  }

  Future<void> refreshServiceStatus() async {
    final wasEnabled = isServiceEnabled.value;
    await checkServiceStatus();

    if (!wasEnabled && isServiceEnabled.value) {
      await syncSettingsWithNative();
      await syncRuntimeStateWithNative();
    }
  }

  @override
  Future<void> requestAccessibilityPermission() async {
    try {
      await _platform.invokeMethod('openAccessibilitySettings');
      developer.log('Abrindo configuracoes de acessibilidade');
    } on PlatformException catch (e) {
      developer.log(
        "Erro ao abrir configuracoes de acessibilidade: '${e.message}'.",
      );
    }
  }
}
