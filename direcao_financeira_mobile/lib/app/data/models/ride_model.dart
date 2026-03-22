import '../../domain/entities/ride_entity.dart';

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.status,
    required super.appName,
    required super.grossValueCents,
    required super.date,
    required super.time,
    required super.origin,
    required super.passenger,
    required super.durationMinutes,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    String formattedDate = '--/--';
    String formattedTime = '--:--';

    if (json['createdAt'] != null) {
      try {
        final dt = DateTime.parse(json['createdAt']).toLocal();
        formattedDate =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
        formattedTime =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final int durationSeconds = json['totalTime'] as int? ?? 0;

    return RideModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'PENDING',
      appName:
          'Uber', // Temporary static as backend does not have platform name yet, or derive from tags if available.
      grossValueCents: json['grossValueCents'] as int? ?? 0,
      date: formattedDate,
      time: formattedTime,
      origin: json['originAddress'] as String? ?? 'Origem não informada',
      passenger: json['passengerName'] as String? ?? 'Não informado',
      durationMinutes: durationSeconds ~/ 60,
    );
  }
}
