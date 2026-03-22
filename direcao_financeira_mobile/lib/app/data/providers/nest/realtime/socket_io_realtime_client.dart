import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../../../../core/network/realtime_client.dart';

class SocketIoRealtimeClient implements RealtimeClient {
  SocketIoRealtimeClient({
    required this.baseUrl,
    required this.enableRealtime,
  });

  final String baseUrl;
  final bool enableRealtime;
  final RxBool _isOnline = true.obs;
  socket_io.Socket? _socket;

  @override
  RxBool get isOnline => _isOnline;

  @override
  void connect({required String token}) {
    if (!enableRealtime || token.isEmpty) {
      return;
    }

    _socket ??= socket_io.io(
      baseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      _isOnline.value = true;
    });
    _socket?.onDisconnect((_) {
      _isOnline.value = false;
    });
    _socket?.onConnectError((_) {
      if (_isOnline.value) {
        _isOnline.value = false;
      }
    });
    _socket?.auth = {'token': token};
    _socket?.connect();
  }

  @override
  void disconnect() {
    _socket?.disconnect();
  }

  @override
  void on(String event, void Function(dynamic payload) handler) {
    _socket?.on(event, handler);
  }

  @override
  void off(String event) {
    _socket?.off(event);
  }

  @override
  Future<void> dispose() async {
    _socket?.dispose();
    _socket = null;
  }
}
