import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPermissionService {
  const NotificationPermissionService();

  Future<void> requestAndroidNotificationPermissionIfNeeded() async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (error) {
      developer.log(
        'Erro ao solicitar permissao de notificacao: $error',
        name: 'NotificationPermissionService',
      );
    }
  }
}
