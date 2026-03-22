enum TrafficLightPosition { topo, esquerda, direita, rodape }
enum TrafficLightTheme { claro, escuro, verde }

class TrafficLightSettingsEntity {
  final TrafficLightPosition position;
  final TrafficLightTheme theme;
  final Map<String, bool> indicators;
  final double fontSize;
  final double opacity;
  final double cardDuration;
  final bool colorBlindMode;

  TrafficLightSettingsEntity({
    required this.position,
    required this.theme,
    required this.indicators,
    required this.fontSize,
    required this.opacity,
    required this.cardDuration,
    required this.colorBlindMode,
  });
}
