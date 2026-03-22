import '../../domain/entities/active_shift_entity.dart';

class ActiveShiftModel extends ActiveShiftEntity {
  const ActiveShiftModel({
    required super.id,
    super.remoteShiftId,
    required super.startTime,
    required super.createdAt,
    required super.currentDrivenKm,
    required super.idleTimeSeconds,
    super.pausedAt,
  });

  @override
  ActiveShiftModel copyWith({
    int? id,
    int? remoteShiftId,
    DateTime? startTime,
    DateTime? createdAt,
    double? currentDrivenKm,
    int? idleTimeSeconds,
    DateTime? pausedAt,
    bool clearPausedAt = false,
  }) {
    return ActiveShiftModel(
      id: id ?? this.id,
      remoteShiftId: remoteShiftId ?? this.remoteShiftId,
      startTime: startTime ?? this.startTime,
      createdAt: createdAt ?? this.createdAt,
      currentDrivenKm: currentDrivenKm ?? this.currentDrivenKm,
      idleTimeSeconds: idleTimeSeconds ?? this.idleTimeSeconds,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
    );
  }

  factory ActiveShiftModel.fromJson(Map<String, dynamic> json) {
    return ActiveShiftModel(
      id: json['id'] as int,
      remoteShiftId: json['remoteShiftId'] as int?,
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      currentDrivenKm: (json['currentDrivenKm'] as num?)?.toDouble() ?? 0.0,
      idleTimeSeconds: json['idleTime'] as int? ?? 0,
      pausedAt: json['pausedAt'] != null
          ? DateTime.parse(json['pausedAt'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remoteShiftId': remoteShiftId,
      'startTime': startTime.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'currentDrivenKm': currentDrivenKm,
      'idleTime': idleTimeSeconds,
      'pausedAt': pausedAt?.toUtc().toIso8601String(),
    };
  }
}
