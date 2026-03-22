import '../../domain/entities/traffic_light_settings_entity.dart';

class TrafficLightSettingsModel extends TrafficLightSettingsEntity {
  TrafficLightSettingsModel({
    required super.position,
    required super.theme,
    required super.indicators,
    required super.fontSize,
    required super.opacity,
    required super.cardDuration,
    required super.colorBlindMode,
  });

  factory TrafficLightSettingsModel.fromJson(Map<String, dynamic> json) {
    return TrafficLightSettingsModel(
      position: TrafficLightPosition.values[json['position'] ?? 0],
      theme: TrafficLightTheme.values[json['theme'] ?? 1],
      indicators: Map<String, bool>.from(json['indicators'] ?? {
        'R\$/Km': true,
        'R\$/Hora': true,
        'Lucro/H': true,
        'Nota': true,
      }),
      fontSize: (json['fontSize'] ?? 15.0).toDouble(),
      opacity: (json['opacity'] ?? 100.0).toDouble(),
      cardDuration: (json['cardDuration'] ?? 10.0).toDouble(),
      colorBlindMode: json['colorBlindMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position.index,
      'theme': theme.index,
      'indicators': indicators,
      'fontSize': fontSize,
      'opacity': opacity,
      'cardDuration': cardDuration,
      'colorBlindMode': colorBlindMode,
    };
  }

  factory TrafficLightSettingsModel.fromEntity(TrafficLightSettingsEntity entity) {
    return TrafficLightSettingsModel(
      position: entity.position,
      theme: entity.theme,
      indicators: entity.indicators,
      fontSize: entity.fontSize,
      opacity: entity.opacity,
      cardDuration: entity.cardDuration,
      colorBlindMode: entity.colorBlindMode,
    );
  }
}
