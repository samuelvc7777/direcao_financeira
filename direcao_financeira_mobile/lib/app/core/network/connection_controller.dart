import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class ConnectionController extends GetxController {
  final GetStorage storage;
  final String baseUrl;

  socket_io.Socket? socket;
  final RxBool isOnline = true.obs;

  ConnectionController({required this.storage, required this.baseUrl});

  @override
  void onInit() {
    super.onInit();
    _initSocket();
  }

  void _initSocket() {
    final token = storage.read('token');

    socket = socket_io.io(
      baseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket?.onConnect((_) {
      final wasOffline = !isOnline.value;
      isOnline.value = true;
      
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      
      if (wasOffline) {
        _showOnlineSnackbar();
      }
    });

    socket?.onDisconnect((_) {
      isOnline.value = false;
      _showOfflineSnackbar();
    });

    socket?.onConnectError((_) {
      if (isOnline.value) {
        isOnline.value = false;
        _showOfflineSnackbar();
      }
    });

    // Se já houver token, tenta conectar
    if (token != null && token.toString().isNotEmpty) {
      connectWithToken(token);
    }
  }

  void connectWithToken(String token) {
    socket?.auth = {'token': token};
    socket?.connect();
  }

  void disconnect() {
    socket?.disconnect();
  }

  void _showOfflineSnackbar() {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Você está offline',
        'Tentando reconectar ao servidor...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        isDismissible: false,
        duration: const Duration(days: 1), // Permanece até reconectar e fechar
        icon: const Icon(Icons.wifi_off, color: Colors.white),
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    }
  }

  void _showOnlineSnackbar() {
    Get.snackbar(
      'Conexão Restabelecida',
      'Você está online novamente.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF03A696),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.wifi, color: Colors.white),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
    );
  }

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
  }
}
