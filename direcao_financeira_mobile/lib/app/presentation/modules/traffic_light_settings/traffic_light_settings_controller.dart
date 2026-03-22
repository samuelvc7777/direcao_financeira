import 'package:get/get.dart';
import '../../../core/accessibility/accessibility_controller.dart';
import '../../../domain/entities/traffic_light_settings_entity.dart';
import '../../../domain/usecases/traffic_light_settings_use_cases.dart';

class TrafficLightSettingsController extends GetxController {
  final GetTrafficLightSettingsUseCase getSettingsUseCase;
  final SaveTrafficLightSettingsUseCase saveSettingsUseCase;

  TrafficLightSettingsController({
    required this.getSettingsUseCase,
    required this.saveSettingsUseCase,
  });

  final selectedPosition = TrafficLightPosition.topo.obs;
  final selectedTheme = TrafficLightTheme.escuro.obs;

  final indicators = <String, bool>{
    'R\$/Km': true,
    'R\$/Hora': true,
    'Lucro/H': true,
    'Nota': true,
  }.obs;

  final fontSize = 15.0.obs;
  final opacity = 100.0.obs;
  final cardDuration = 10.0.obs;
  final colorBlindMode = false.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    isLoading.value = true;
    final result = await getSettingsUseCase();
    result.fold((failure) => Get.snackbar('Erro', failure.message), (settings) {
      selectedPosition.value = settings.position;
      selectedTheme.value = settings.theme;
      fontSize.value = settings.fontSize;
      opacity.value = settings.opacity;
      cardDuration.value = settings.cardDuration;
      colorBlindMode.value = settings.colorBlindMode;
      indicators.assignAll(settings.indicators);
    });
    isLoading.value = false;
  }

  Future<void> saveSettings() async {
    isLoading.value = true;

    final settings = TrafficLightSettingsEntity(
      position: selectedPosition.value,
      theme: selectedTheme.value,
      indicators: Map<String, bool>.from(indicators),
      fontSize: fontSize.value,
      opacity: opacity.value,
      cardDuration: cardDuration.value,
      colorBlindMode: colorBlindMode.value,
    );

    final result = await saveSettingsUseCase(settings);
    result.fold((failure) => Get.snackbar('Erro', failure.message), (_) {
      // Sincronizar com o lado nativo imediatamente
      Get.find<AccessibilityController>().syncSettingsWithNative();

      Get.snackbar(
        'Sucesso',
        'Configurações salvas com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
    isLoading.value = false;
  }

  void toggleIndicator(String name) {
    indicators[name] = !(indicators[name] ?? false);
  }

  int get selectedIndicatorsCount => indicators.values.where((v) => v).length;

  List<String> get orderedActiveIndicators {
    const order = ['R\$/Km', 'R\$/Hora', 'Nota', 'Lucro/H'];
    return order.where((name) => indicators[name] ?? false).toList();
  }
}
