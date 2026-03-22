class ActiveShiftEntity {
  final int id;
  final int? remoteShiftId;
  final DateTime startTime;
  final DateTime createdAt;
  final double currentDrivenKm;
  final int idleTimeSeconds;
  final DateTime? pausedAt;

  const ActiveShiftEntity({
    required this.id,
    this.remoteShiftId,
    required this.startTime,
    required this.createdAt,
    required this.currentDrivenKm,
    required this.idleTimeSeconds,
    this.pausedAt,
  });

  bool get isPaused => pausedAt != null;
  bool get isLocalOnly => remoteShiftId == null;

  ActiveShiftEntity copyWith({
    int? id,
    int? remoteShiftId,
    DateTime? startTime,
    DateTime? createdAt,
    double? currentDrivenKm,
    int? idleTimeSeconds,
    DateTime? pausedAt,
    bool clearPausedAt = false,
  }) {
    return ActiveShiftEntity(
      id: id ?? this.id,
      remoteShiftId: remoteShiftId ?? this.remoteShiftId,
      startTime: startTime ?? this.startTime,
      createdAt: createdAt ?? this.createdAt,
      currentDrivenKm: currentDrivenKm ?? this.currentDrivenKm,
      idleTimeSeconds: idleTimeSeconds ?? this.idleTimeSeconds,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
    );
  }
}
