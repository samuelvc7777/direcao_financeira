import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../feedback/app_snackbar.dart';
import 'realtime_client.dart';

class RealtimeFeedbackController extends GetxController {
  RealtimeFeedbackController({required this.realtimeClient});

  final RealtimeClient realtimeClient;
  Worker? _statusWorker;
  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    _statusWorker = ever<bool>(realtimeClient.isOnline, _handleStatusChange);
  }

  @override
  void onClose() {
    _statusWorker?.dispose();
    super.onClose();
  }

  void _handleStatusChange(bool isOnline) {
    // Temporariamente desativado para nao bloquear a navegacao nas telas
    // de autenticacao enquanto o fluxo Supabase ainda esta sendo ajustado.
    return;

    if (!isOnline) {
      _wasOffline = true;

      if (!Get.isSnackbarOpen) {
        AppSnackbar.show(
          'Voce esta offline',
          'Tentando reconectar ao servidor...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          isDismissible: false,
          icon: const Icon(Icons.wifi_off, color: Colors.white),
          margin: const EdgeInsets.all(8),
          borderRadius: 8,
        );
      }

      return;
    }

    if (!Get.isSnackbarOpen && !_wasOffline) {
      return;
    }

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    if (_wasOffline) {
      AppSnackbar.show(
        'Conexao Restabelecida',
        'Voce esta online novamente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF03A696),
        colorText: Colors.white,
        icon: const Icon(Icons.wifi, color: Colors.white),
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    }

    _wasOffline = false;
  }
}
