import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'realtime_client.dart';

abstract class JourneyRealtimeBridge {
  RxBool get isOnline;
  void bind({
    required VoidCallback onRideChanged,
  });
  void unbind();
}

class DefaultJourneyRealtimeBridge implements JourneyRealtimeBridge {
  DefaultJourneyRealtimeBridge({required this.realtimeClient});

  final RealtimeClient realtimeClient;

  static const _rideEvents = <String>[
    'journey.ride.created',
    'journey.ride.updated',
  ];

  @override
  RxBool get isOnline => realtimeClient.isOnline;

  @override
  void bind({
    required VoidCallback onRideChanged,
  }) {
    for (final event in _rideEvents) {
      realtimeClient.on(event, (_) => onRideChanged());
    }
  }

  @override
  void unbind() {
    for (final event in _rideEvents) {
      realtimeClient.off(event);
    }
  }
}
