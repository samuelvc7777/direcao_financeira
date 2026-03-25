import '../../domain/entities/ride_entity.dart';

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.status,
    required super.appName,
    required super.paymentMethod,
    required super.grossValueCents,
    required super.date,
    required super.time,
    required super.origin,
    required super.destination,
    required super.passenger,
    required super.durationMinutes,
    required super.gainPerKmCents,
    required super.gainPerHourCents,
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

    final durationSeconds = json['totalTime'] as int? ?? 0;
    final platformName = (json['platformName'] as String?)?.trim();

    return RideModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'PENDING',
      appName: platformName != null && platformName.isNotEmpty
          ? platformName
          : 'App',
      paymentMethod: json['paymentMethod'] as String?,
      grossValueCents: json['grossValueCents'] as int? ?? 0,
      date: formattedDate,
      time: formattedTime,
      origin: json['originAddress'] as String? ?? 'Origem não informada',
      destination:
          json['destinationAddress'] as String? ?? 'Destino não informado',
      passenger: json['passengerName'] as String? ?? 'Não informado',
      durationMinutes: durationSeconds ~/ 60,
      gainPerKmCents: json['gainPerKmCents'] as int? ?? 0,
      gainPerHourCents: json['gainPerHourCents'] as int? ?? 0,
    );
  }
}
